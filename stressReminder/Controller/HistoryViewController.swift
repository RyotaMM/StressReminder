//
//  HistoryViewController.swift
//  stressReminder
//
//  Created by workspace on 2025/04/19.
//

import UIKit
import FSCalendar

class HistoryViewController: UIViewController {

    private let stressManager = StressManager.shared
    private var calendar: FSCalendar!
    private var tableView: UITableView!
    private var segmentedControl: UISegmentedControl!

    private var selectedDate = Date()
    private var filteredEntries: [StressEntry] = []
    private var currentFilterMode = 0 // 0: すべて, 1: ストレス, 2: 解決策
    private var calendarHeightConstraint: NSLayoutConstraint!
    private var isDeletingRow = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "記録"

        setupSegmentedControl()
        setupCalendar()
        setupTableView()
        registerForNotifications()
        
        filterEntries(for: selectedDate)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterEntries(for: selectedDate)
        updateCalendar()
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(entriesDidChange),
            name: NSNotification.Name("EntriesDidChange"),
            object: nil
        )
    }
    
    @objc private func entriesDidChange() {
        // 削除中はリロードを無視
        guard !isDeletingRow else { return }
        filterEntries(for: selectedDate)
        updateCalendar()
    }

    
    private func updateCalendar() {
        calendar.reloadData()
    }
    
    private func setupSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["すべて", "ストレス", "解決策"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupCalendar() {
        calendar = FSCalendar()
        calendar.delegate = self
        calendar.dataSource = self
        calendar.scope = .week  // 初期表示を週表示に
        calendar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendar)

        // カレンダーのサイズを調整（高さの制約は後で変更できるように保持）
        calendarHeightConstraint = calendar.heightAnchor.constraint(equalToConstant: 300)
        
        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            calendarHeightConstraint
        ])
        
        // カレンダーの外観設定
        calendar.appearance.headerDateFormat = "yyyy年M月"
        calendar.appearance.weekdayTextColor = .systemGray
        calendar.appearance.titleDefaultColor = .label
        
        // フォントサイズを調整
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 16)
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 14)
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 18)
        
        // 日本語表示設定
        calendar.locale = Locale(identifier: "ja_JP")
        
        // セルの高さと幅の比率を調整
        calendar.rowHeight = 45
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        
        // 週間/月間表示切り替えボタンの追加
        let scopeButton = UIButton(type: .system)
        scopeButton.setTitle("週間/月間 切替", for: .normal)
        scopeButton.translatesAutoresizingMaskIntoConstraints = false
        scopeButton.addTarget(self, action: #selector(toggleCalendarScope), for: .touchUpInside)
        view.addSubview(scopeButton)
        
        NSLayoutConstraint.activate([
            scopeButton.topAnchor.constraint(equalTo: calendar.bottomAnchor, constant: 8),
            scopeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func toggleCalendarScope() {
        let newScope: FSCalendarScope = calendar.scope == .week ? .month : .week
        
        // スコープ切り替え時の高さを調整
        calendarHeightConstraint.constant = newScope == .month ? 400 : 300
        
        calendar.setScope(newScope, animated: true)
        
        // テーブルビューの位置も調整
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EntryCell.self, forCellReuseIdentifier: "entryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: calendar.bottomAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        currentFilterMode = sender.selectedSegmentIndex
        filterEntries(for: selectedDate)
    }

    private func filterEntries(for date: Date) {
        let entriesForDate = stressManager.entriesForDate(date)
        
        switch currentFilterMode {
        case 1: // ストレスのみ
            filteredEntries = entriesForDate.filter { $0.type == .stress }
        case 2: // 解決策のみ
            filteredEntries = entriesForDate.filter { $0.type == .solution }
        default: // すべて
            filteredEntries = entriesForDate
        }
        
        // 日付の降順にソート
        filteredEntries.sort { $0.date > $1.date }
        
        tableView.reloadData()
    }
}

// MARK: - FSCalendarDelegate, FSCalendarDataSource
extension HistoryViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        filterEntries(for: date)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let entryCount = stressManager.entryCountForDate(date)
        return entryCount > 0 ? 1 : 0 // イベントマーカーは1つだけ表示
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let entriesForDate = stressManager.entriesForDate(date)
        
        // ストレスと解決策の両方がある日
        if entriesForDate.contains(where: { $0.type == .stress }) &&
           entriesForDate.contains(where: { $0.type == .solution }) {
            return [.systemPurple]
        }
        // ストレスのみの日
        else if entriesForDate.contains(where: { $0.type == .stress }) {
            return [.systemRed]
        }
        // 解決策のみの日
        else if entriesForDate.contains(where: { $0.type == .solution }) {
            return [.systemGreen]
        }
        
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredEntries.isEmpty {
            // 空のメッセージを表示
            let emptyLabel = UILabel()
            emptyLabel.text = "この日の記録はありません"
            emptyLabel.textAlignment = .center
            emptyLabel.textColor = .secondaryLabel
            tableView.backgroundView = emptyLabel
            return 0
        } else {
            tableView.backgroundView = nil
            return filteredEntries.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as! EntryCell
        let entry = filteredEntries[indexPath.row]
        cell.configure(with: entry)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let entry = filteredEntries[indexPath.row]
        
        // ストレスエントリーの場合は詳細画面へ
        if entry.type == .stress {
            let detailVC = StressDetailViewController(entry: entry)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    // HistoryViewController.swift の修正

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard indexPath.row < filteredEntries.count else { return }

            isDeletingRow = true // ← 削除中フラグON

            let entry = filteredEntries[indexPath.row]
            stressManager.deleteEntry(id: entry.id)

            // ローカル配列を更新
            filteredEntries.remove(at: indexPath.row)

            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()

            isDeletingRow = false // ← 削除完了後フラグOFF

            if filteredEntries.isEmpty {
                let emptyLabel = UILabel()
                emptyLabel.text = "この日の記録はありません"
                emptyLabel.textAlignment = .center
                emptyLabel.textColor = .secondaryLabel
                tableView.backgroundView = emptyLabel
            }
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }

    
    // MARK: - EntryCell
    class EntryCell: UITableViewCell {
        
        private let timeLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .secondaryLabel
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let typeLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .center
            label.layer.cornerRadius = 8
            label.layer.masksToBounds = true
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let contentLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 16)
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let levelIndicator: UIView = {
            let view = UIView()
            view.layer.cornerRadius = 6
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configure(with entry: StressEntry) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            timeLabel.text = formatter.string(from: entry.date)
            contentLabel.text = entry.content
            
            // タイプ別の設定
            switch entry.type {
            case .stress:
                typeLabel.text = "ストレス"
                typeLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
                typeLabel.textColor = .systemRed
                
                // ストレスレベルの表示
                if let level = entry.level {
                    levelIndicator.backgroundColor = level.color
                    levelIndicator.isHidden = false
                } else {
                    levelIndicator.isHidden = true
                }
                
                // ストレス解決済みかどうか
                if entry.solution != nil {
                    accessoryType = .checkmark
                    tintColor = .systemGreen
                } else {
                    accessoryType = .disclosureIndicator
                }
                
            case .solution:
                typeLabel.text = "解決策"
                typeLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
                typeLabel.textColor = .systemGreen
                levelIndicator.isHidden = true
                accessoryType = .none
            }
        }
        
        private func setupViews() {
            contentView.addSubview(levelIndicator)
            contentView.addSubview(timeLabel)
            contentView.addSubview(typeLabel)
            contentView.addSubview(contentLabel)
            
            NSLayoutConstraint.activate([
                levelIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                levelIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                levelIndicator.widthAnchor.constraint(equalToConstant: 12),
                levelIndicator.heightAnchor.constraint(equalToConstant: 12),
                
                timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
                timeLabel.leadingAnchor.constraint(equalTo: levelIndicator.trailingAnchor, constant: 12),
                
                typeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
                typeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                typeLabel.widthAnchor.constraint(equalToConstant: 60),
                typeLabel.heightAnchor.constraint(equalToConstant: 24),
                
                contentLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
                contentLabel.leadingAnchor.constraint(equalTo: levelIndicator.trailingAnchor, constant: 12),
                contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
            ]);
        }
    }
}

