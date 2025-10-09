//
//  SettingsViewController.swift
//  stressReminder
//
//  Created on 2025/04/20.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,MFMailComposeViewControllerDelegate {
    
    private let notificationManager = NotificationManager.shared
    private let stressManager = StressManager.shared
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(SwitchTableViewCell.self, forCellReuseIdentifier: "switchCell")
        table.register(TimePickerTableViewCell.self, forCellReuseIdentifier: "timePickerCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // 設定項目のセクション
    private enum Section: Int, CaseIterable {
        case notifications
        case appearance
        case data
        case about
        
        var title: String {
            switch self {
            case .notifications: return "通知"
            case .appearance: return "表示設定"
            case .data: return "データ管理"
            case .about: return "アプリについて"
            }
        }
    }
    
    // 通知セクションの項目
    private enum NotificationOption: Int, CaseIterable {
        case dailyReminder
        case dailyStressTip
        case weeklyStats
        
        var title: String {
            switch self {
            case .dailyReminder: return "日次ストレスチェック"
            case .dailyStressTip: return "ストレス対処法のヒント"
            case .weeklyStats: return "週間統計"
            }
        }
    }
    
    // 表示設定セクションの項目
    private enum AppearanceOption: Int, CaseIterable {
        case darkMode
        
        
        var title: String {
            switch self {
            case .darkMode: return "ダークモード"
            }
        }
    }
    
    // データ管理セクションの項目
    private enum DataOption: Int, CaseIterable {
        case delete
        
        var title: String {
            switch self {
            case .delete: return "すべてのデータを削除"
            }
        }
    }
    
    // アプリについてセクションの項目
    private enum AboutOption: Int, CaseIterable {
        case version
        case feedback
        
        var title: String {
            switch self {
            case .version: return "バージョン情報"
            case .feedback: return "フィードバックを送る"
            }
        }
    }
    
    // 通知設定の状態
    private var notificationSettings: [NotificationOption: Bool] = [
        .dailyReminder: UserDefaults.standard.bool(forKey: "dailyReminderEnabled"),
        .dailyStressTip: UserDefaults.standard.bool(forKey: "dailyStressTipEnabled"),
        .weeklyStats: UserDefaults.standard.bool(forKey: "weeklyStatsEnabled")
    ]
    
    // 通知時間の設定
    private var notificationTimes: [NotificationOption: Date] = [:]
    
    // ダークモード設定
    private var darkModeEnabled: Bool {
        get { return UserDefaults.standard.bool(forKey: "darkModeEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "darkModeEnabled") }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "設定"
        
        setupTableView()
        loadSettings()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func loadSettings() {
        // 通知時間の設定を読み込み
        let calendar = Calendar.current
        let defaultDate = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
        
        for option in NotificationOption.allCases {
            let key = "\(option)Time"
            if let timeInterval = UserDefaults.standard.double(forKey: key) as TimeInterval?, timeInterval > 0 {
                notificationTimes[option] = Date(timeIntervalSince1970: timeInterval)
            } else {
                notificationTimes[option] = defaultDate
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .notifications: return NotificationOption.allCases.count
        case .appearance: return AppearanceOption.allCases.count
        case .data: return DataOption.allCases.count
        case .about: return AboutOption.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = Section(rawValue: section) else { return nil }
        return sectionType.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        case .notifications:
            guard let option = NotificationOption(rawValue: indexPath.row) else {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(title: option.title, isOn: notificationSettings[option] ?? false) { [weak self] isOn in
                self?.notificationSettings[option] = isOn
                UserDefaults.standard.set(isOn, forKey: "\(option)Enabled")
                
                if isOn {
                    self?.showTimePickerForNotification(option)
                } else {
                    // 通知をオフにした場合、対応する通知をキャンセル
                    switch option {
                    case .dailyReminder:
                        self?.notificationManager.cancelAllNotifications()
                    case .dailyStressTip:
                        self?.notificationManager.cancelAllNotifications()
                    case .weeklyStats:
                        self?.notificationManager.cancelAllNotifications()
                    }
                }
            }
            return cell
            
        case .appearance:
            guard let option = AppearanceOption(rawValue: indexPath.row) else {
                return UITableViewCell()
            }
            
            switch option {
            case .darkMode:
                let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell
                cell.configure(title: option.title, isOn: darkModeEnabled) { [weak self] isOn in
                    self?.darkModeEnabled = isOn
                    self?.applyDarkModeSettings()
                }
                return cell
            
            }
            
        case .data:
            guard let option = DataOption(rawValue: indexPath.row) else {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = option.title
            
            if option == .delete {
                cell.textLabel?.textColor = .systemRed
            } else {
                cell.textLabel?.textColor = .label
            }
            
            return cell
            
        case .about:
            guard let option = AboutOption(rawValue: indexPath.row) else {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = option.title
            
            if option == .version {
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                cell.detailTextLabel?.text = "v\(version) (\(build))"
                cell.selectionStyle = .none
            } else {
                cell.accessoryType = .disclosureIndicator
            }
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .notifications:
            guard let option = NotificationOption(rawValue: indexPath.row),
                  notificationSettings[option] == true else { return }
            
            showTimePickerForNotification(option)
            
        case .appearance:
            guard let option = AppearanceOption(rawValue: indexPath.row) else { return }
            
            
            
        case .data:
            // データ削除のみ実装
            showDeleteConfirmation()
                
        case .about:
            guard let option = AboutOption(rawValue: indexPath.row) else { return }
            
            if option == .feedback {
                showFeedbackOptions()
            }
        }
    }
    
    private func showDeleteConfirmation() {
        let alert = UIAlertController(title: "データを削除", message: "すべてのストレスと解決策のデータが削除されます。この操作は元に戻せません。", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        alert.addAction(UIAlertAction(title: "削除", style: .destructive) { [weak self] _ in
            // ストレスマネージャーを使ってデータを削除
            self?.stressManager.deleteAllEntries()
            
            // 完了メッセージ
            let confirmAlert = UIAlertController(title: "完了", message: "すべてのデータが削除されました", preferredStyle: .alert)
            confirmAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(confirmAlert, animated: true)
        })
        
        present(alert, animated: true)
    }
    
    
    
    // MARK: - Helper Methods
    
    private func showTimePickerForNotification(_ option: NotificationOption) {
        let alertController = UIAlertController(title: "\(option.title)の時間を設定", message: nil, preferredStyle: .actionSheet)
        
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        
        if let savedTime = notificationTimes[option] {
            timePicker.date = savedTime
        }
        
        let pickerViewController = UIViewController()
        pickerViewController.view.addSubview(timePicker)
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timePicker.centerXAnchor.constraint(equalTo: pickerViewController.view.centerXAnchor),
            timePicker.topAnchor.constraint(equalTo: pickerViewController.view.topAnchor, constant: 20),
            timePicker.bottomAnchor.constraint(equalTo: pickerViewController.view.bottomAnchor, constant: -20)
        ])
        
        alertController.setValue(pickerViewController, forKey: "contentViewController")
        
        alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "設定", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let selectedTime = timePicker.date
            self.notificationTimes[option] = selectedTime
            
            // UserDefaultsに時間を保存
            UserDefaults.standard.set(selectedTime.timeIntervalSince1970, forKey: "\(option)Time")
            
            // 通知をスケジュール
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: selectedTime)
            let minute = calendar.component(.minute, from: selectedTime)
            
            switch option {
            case .dailyReminder:
                self.notificationManager.scheduleDailyStressCheckReminder(hour: hour, minute: minute)
            case .dailyStressTip:
                self.notificationManager.scheduleRandomStressTip(hour: hour, minute: minute)
            case .weeklyStats:
                self.notificationManager.scheduleWeeklyStressStatisticsReminder(weekday: 1, hour: hour, minute: minute)
            }
            
            self.tableView.reloadData()
        })
        
        present(alertController, animated: true)
    }
    
    private func applyDarkModeSettings() {
        // アプリ全体のダークモード設定を適用
        if #available(iOS 15.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    for window in windowScene.windows {
                        window.overrideUserInterfaceStyle = darkModeEnabled ? .dark : .light
                    }
                }
            }
        } else {
            // iOS 15.0未満のデバイス用（非推奨だが後方互換性のため）
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = darkModeEnabled ? .dark : .light
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    
    private func showFeedbackOptions() {
        let alert = UIAlertController(title: "フィードバック", message: "フィードバックをお送りいただきありがとうございます", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "メールで送信", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["deveryota@icloud.com"]) // 宛先メールアドレスを変更
                mail.setSubject("フィードバック")
                mail.setMessageBody("アプリについてのフィードバックをご記入ください。", isHTML: false)
                self.present(mail, animated: true)
            } else {
                let errorAlert = UIAlertController(title: "メール送信不可", message: "メールを送信するための設定がされていません。", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
            }
        })
        
        alert.addAction(UIAlertAction(title: "レビューを書く", style: .default) { _ in
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let url = URL(string: "https://apps.apple.com/app/6745258554?action=write-review") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - SwitchTableViewCell
class SwitchTableViewCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    private var switchCallback: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    func configure(title: String, isOn: Bool, callback: @escaping (Bool) -> Void) {
        titleLabel.text = title
        switchControl.isOn = isOn
        switchCallback = callback
    }
    
    @objc private func switchValueChanged() {
        switchCallback?(switchControl.isOn)
    }
}

// MARK: - TimePickerTableViewCell
class TimePickerTableViewCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(title: String, time: Date) {
        titleLabel.text = title
        timeLabel.text = timeFormatter.string(from: time)
    }
}
