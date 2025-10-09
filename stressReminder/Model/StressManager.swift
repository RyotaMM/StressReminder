//
//  StressManager.swift
//  stressReminder
//
//  Created by workspace on 2025/04/20.
//

import Foundation
import UIKit

// ストレスエントリーのタイプ定義
enum EntryType: String, Codable {
    case stress = "stress"
    case solution = "solution"
}

// ストレスレベルの定義
enum StressLevel: Int, Codable, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
    case extreme = 4
    
    var description: String {
        switch self {
        case .low: return "軽度"
        case .medium: return "中度"
        case .high: return "高度"
        case .extreme: return "極度"
        }
    }
    
    var color: UIColor {
        switch self {
        case .low: return UIColor.systemBlue
        case .medium: return UIColor.systemYellow
        case .high: return UIColor.systemOrange
        case .extreme: return UIColor.systemRed
        }
    }
}

// 統一されたエントリーモデルの定義
struct StressEntry: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let type: EntryType
    let level: StressLevel?
    var content: String
    var solution: String?
    
    // ストレスエントリーを作成する
    static func createStressEntry(date: Date, level: StressLevel, content: String) -> StressEntry {
        return StressEntry(id: UUID(), date: date, type: .stress, level: level, content: content, solution: nil)
    }
    
    // 解決策エントリーを作成する
    static func createSolutionEntry(date: Date, content: String) -> StressEntry {
        return StressEntry(id: UUID(), date: date, type: .solution, level: nil, content: content, solution: nil)
    }
    
    // DailyEntryに変換するメソッド（互換性のため）
    func toDailyEntry() -> DailyEntry {
        return DailyEntry(time: date, content: content, type: type.rawValue)
    }
}

// データ管理クラス
class StressManager {
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let archiveURL: URL
    
    static let shared = StressManager()
    
    private(set) var entries: [StressEntry] = []
    
    private init() {
        archiveURL = documentsDirectory.appendingPathComponent("stressEntries").appendingPathExtension("plist")
        loadEntries()
        
        // 初回起動時にサンプルデータを追加
        if entries.isEmpty {
            addSampleData()
        }
    }
    
    // エントリーを追加
    func addEntry(_ entry: StressEntry) {
        entries.append(entry)
        saveEntries()
        NotificationCenter.default.post(name: NSNotification.Name("EntriesDidChange"), object: nil)
    }
    
    // 指定した日付のエントリーを取得
    func entriesForDate(_ date: Date) -> [StressEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    // ストレスタイプのエントリーのみ取得
    func stressEntries() -> [StressEntry] {
        return entries.filter { $0.type == .stress }
    }
    
    // 解決策タイプのエントリーのみ取得
    func solutionEntries() -> [StressEntry] {
        return entries.filter { $0.type == .solution }
    }
    
    // 解決策が設定されていないストレスエントリーを取得
    func unresolvedStressEntries() -> [StressEntry] {
        return entries.filter { $0.type == .stress && $0.solution == nil }
    }
    
    // 特定のストレスエントリーに解決策を追加
    func addSolutionToStress(stressID: UUID, solution: String?) {
        if let index = entries.firstIndex(where: { $0.id == stressID }) {
            var updatedEntry = entries[index]
            updatedEntry.solution = solution
            entries[index] = updatedEntry
            saveEntries()
            NotificationCenter.default.post(name: NSNotification.Name("EntriesDidChange"), object: nil)
        }
    }
    
    // ストレスレベルごとの統計を取得
    func stressLevelStatistics() -> [StressLevel: Int] {
        var statistics: [StressLevel: Int] = [:]
        
        for level in StressLevel.allCases {
            statistics[level] = entries.filter { $0.level == level }.count
        }
        
        return statistics
    }
    
    // エントリーを更新
    func updateEntry(id: UUID, content: String) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            var updatedEntry = entries[index]
            updatedEntry.content = content       // ← ここで内容を更新！
            entries[index] = updatedEntry
            saveEntries()
            NotificationCenter.default.post(name: NSNotification.Name("EntriesDidChange"), object: nil)
        }
    }
    
    // エントリーを削除
    func deleteEntry(id: UUID) {
        entries.removeAll { $0.id == id }
        saveEntries()
        NotificationCenter.default.post(name: NSNotification.Name("EntriesDidChange"), object: nil)
    }
    
    // データを保存
    private func saveEntries() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(entries)
            try data.write(to: archiveURL)
        } catch {
            print("Error saving entries: \(error)")
        }
    }
    
    // データを読み込み
    private func loadEntries() {
        guard let data = try? Data(contentsOf: archiveURL) else { return }
        
        let decoder = PropertyListDecoder()
        do {
            entries = try decoder.decode([StressEntry].self, from: data)
        } catch {
            print("Error loading entries: \(error)")
        }
    }
    
    // サンプルデータの追加
    private func addSampleData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let sample1 = StressEntry(
            id: UUID(),
            date: formatter.date(from: "2025/04/20 16:04")!,
            type: .stress,
            level: .medium,
            content: "仕事のプレッシャー",
            solution: nil
        )
        
        let sample2 = StressEntry(
            id: UUID(),
            date: formatter.date(from: "2025/04/20 20:10")!,
            type: .solution,
            level: nil,
            content: "夜風にあたる",
            solution: nil
        )
        
        let sample3 = StressEntry(
            id: UUID(),
            date: formatter.date(from: "2025/04/21 09:10")!,
            type: .stress,
            level: .high,
            content: "朝の遅刻",
            solution: nil
        )
        
        entries = [sample1, sample2, sample3]
        saveEntries()
    }
    
    // DailyEntry形式でエントリーを取得（互換性のため）
    func getAllDailyEntries() -> [DailyEntry] {
        return entries.map { $0.toDailyEntry() }
    }
    
    // 日付別のエントリー数を取得（カレンダー表示用）
    func entryCountForDate(_ date: Date) -> Int {
        return entriesForDate(date).count
    }
    
    func deleteAllEntries() {
        entries.removeAll()
        saveEntries()
        NotificationCenter.default.post(name: NSNotification.Name("EntriesDidChange"), object: nil)
    }
}
