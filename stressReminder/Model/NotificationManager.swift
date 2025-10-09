///
//  NotificationManager.swift
//  stressReminder
//
//  Created by Claude on 2025/04/20.
//

import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {
        // 通知許可をリクエスト
        requestAuthorization()
    }
    
    // 通知の許可をリクエスト
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知許可が承認されました")
            } else if let error = error {
                print("通知許可エラー: \(error.localizedDescription)")
            }
        }
    }
    
    // 日次ストレスチェックリマインダーを設定
    func scheduleDailyStressCheckReminder(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "ストレスチェック"
        content.body = "今日のストレスレベルを記録しましょう。"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "dailyStressCheck",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知スケジュールエラー: \(error.localizedDescription)")
            } else {
                print("日次ストレスチェック通知をスケジュールしました: \(hour):\(minute)")
            }
        }
    }
    
    // ストレス解消リマインダーを設定
    func scheduleStressReliefReminder(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "ストレス解消タイム"
        content.body = "ストレス解消のために少し休憩しましょう。"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "stressReliefReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知スケジュールエラー: \(error.localizedDescription)")
            } else {
                print("ストレス解消通知をスケジュールしました: \(hour):\(minute)")
            }
        }
    }
    
    // 特定のストレスに対するフォローアップリマインダーを設定（X時間後）
    func scheduleStressFollowUp(for stressID: UUID, hours: Int) {
        let content = UNMutableNotificationContent()
        content.title = "ストレスフォローアップ"
        content.body = "記録したストレスは解消されましたか？解決策を記録しましょう。"
        content.sound = .default
        content.userInfo = ["stressID": stressID.uuidString]
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(hours * 3600),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "stressFollowUp-\(stressID.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知スケジュールエラー: \(error.localizedDescription)")
            } else {
                print("ストレスフォローアップ通知をスケジュールしました: \(hours)時間後")
            }
        }
    }
    
    // 週間ストレス統計通知を設定
    func scheduleWeeklyStressStatisticsReminder(weekday: Int, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "週間ストレス統計"
        content.body = "今週のストレス状況を確認しましょう。統計ページで詳細を見ることができます。"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.weekday = weekday // 1（日曜）〜7（土曜）
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "weeklyStressStats",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知スケジュールエラー: \(error.localizedDescription)")
            } else {
                print("週間統計通知をスケジュールしました: 毎週\(weekday)曜日 \(hour):\(minute)")
            }
        }
    }
    
    // ランダムなストレス対処法のヒントを通知
    func scheduleRandomStressTip(hour: Int, minute: Int) {
        let tips = [
            "深呼吸をして、5秒間息を吸い、7秒間かけて吐き出してみましょう。",
            "5分間の短い散歩でもストレスを軽減できます。",
            "好きな音楽を聴いてリラックスする時間を作りましょう。",
            "ストレッチや軽い運動でリフレッシュしましょう。",
            "温かい飲み物を飲んでリラックスしてみましょう。",
            "思いやりの瞑想：自分自身にポジティブな言葉をかけましょう。",
            "ストレスを感じたら、一時的に環境を変えてみましょう。"
        ]
        
        let randomTip = tips.randomElement() ?? "今日のストレス対処法を実践しましょう。"
        
        let content = UNMutableNotificationContent()
        content.title = "ストレス対処法のヒント"
        content.body = randomTip
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "dailyStressTip",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知スケジュールエラー: \(error.localizedDescription)")
            } else {
                print("ストレス対処法ヒント通知をスケジュールしました: \(hour):\(minute)")
            }
        }
    }
    
    // すべての通知をキャンセル
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("すべての通知をキャンセルしました")
    }
    
    // 特定のストレスに関連する通知をキャンセル
    func cancelStressFollowUp(for stressID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["stressFollowUp-\(stressID.uuidString)"]
        )
        print("ストレスID \(stressID) のフォローアップ通知をキャンセルしました")
    }
}
