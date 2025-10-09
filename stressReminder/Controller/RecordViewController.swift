//
//  RecordViewController.swift
//  stressReminder
//
//  Created by workspace on 2025/04/18.
//
import UIKit

class RecordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let stressManager = StressManager.shared
    private var entries: [StressEntry] = []
    private var isInputMode = false
    private var selectedLevel: StressLevel = .medium

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(StressCell.self, forCellReuseIdentifier: "stressCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 30
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let inputPanel: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "ストレス内容を入力"
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let levelSegmentedControl: UISegmentedControl = {
        let items = StressLevel.allCases.map { $0.description }
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 1 // デフォルトで中度を選択
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("キャンセル", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveInputButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("保存", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var inputPanelBottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ストレス"
        view.backgroundColor = .systemBackground
        
        setupViews()
        setupActions()
        registerForNotifications()
        loadEntries()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadEntries()
    }
    
    private func setupViews() {
        // テーブルビューとボタンの追加
        view.addSubview(tableView)
        view.addSubview(addButton)
        
        // 入力パネルの設定
        view.addSubview(inputPanel)
        inputPanel.addSubview(inputTextField)
        inputPanel.addSubview(levelSegmentedControl)
        inputPanel.addSubview(cancelButton)
        inputPanel.addSubview(saveInputButton)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 0
        let safeAreaBottom = view.safeAreaInsets.bottom
        
        // 制約の設定
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            inputPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            inputPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            
            inputTextField.topAnchor.constraint(equalTo: inputPanel.topAnchor, constant: 16),
            inputTextField.leadingAnchor.constraint(equalTo: inputPanel.leadingAnchor, constant: 16),
            inputTextField.trailingAnchor.constraint(equalTo: inputPanel.trailingAnchor, constant: -16),
            
            levelSegmentedControl.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 16),
            levelSegmentedControl.leadingAnchor.constraint(equalTo: inputPanel.leadingAnchor, constant: 16),
            levelSegmentedControl.trailingAnchor.constraint(equalTo: inputPanel.trailingAnchor, constant: -16),
            
            cancelButton.topAnchor.constraint(equalTo: levelSegmentedControl.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: inputPanel.leadingAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: inputPanel.bottomAnchor, constant: -16),
            
            saveInputButton.topAnchor.constraint(equalTo: levelSegmentedControl.bottomAnchor, constant: 16),
            saveInputButton.trailingAnchor.constraint(equalTo: inputPanel.trailingAnchor, constant: -16),
            saveInputButton.bottomAnchor.constraint(equalTo: inputPanel.bottomAnchor, constant: -16),
            saveInputButton.widthAnchor.constraint(equalToConstant: 80),
            saveInputButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // キーボード用の制約
        inputPanelBottomConstraint = inputPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        inputPanelBottomConstraint?.isActive = true
        
        // 入力パネル用のボトム制約（keyboardWillShowで操作するため参照を保持）
        inputPanelBottomConstraint = inputPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(tabBarHeight + safeAreaBottom))
        inputPanelBottomConstraint?.isActive = true
        
        registerForKeyboardNotifications()
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        saveInputButton.addTarget(self, action: #selector(saveInputTapped), for: .touchUpInside)
        levelSegmentedControl.addTarget(self, action: #selector(levelChanged), for: .valueChanged)
        
        // キーボード通知の登録
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(entriesDidChange), name: NSNotification.Name("EntriesDidChange"), object: nil)
    }
    
    @objc private func entriesDidChange() {
        loadEntries()
    }
    
    private func loadEntries() {
        entries = stressManager.stressEntries().sorted(by: { $0.date > $1.date })
        tableView.reloadData()
    }

    @objc private func addButtonTapped() {
        showInputPanel(true)
    }
    
    @objc private func cancelTapped() {
        showInputPanel(false)
    }
    
    @objc private func saveInputTapped() {
        guard let text = inputTextField.text, !text.isEmpty else { return }
        
        let level = StressLevel.allCases[levelSegmentedControl.selectedSegmentIndex]
        let newEntry = StressEntry.createStressEntry(date: Date(), level: level, content: text)
        stressManager.addEntry(newEntry)
        
        showInputPanel(false)
        inputTextField.text = ""
    }
    
    @objc private func levelChanged(_ sender: UISegmentedControl) {
        selectedLevel = StressLevel.allCases[sender.selectedSegmentIndex]
    }
    
    private func showInputPanel(_ show: Bool) {
        inputPanel.isHidden = !show
        
        if show {
            inputTextField.becomeFirstResponder()
        } else {
            inputTextField.resignFirstResponder()
        }
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            // タブバーの高さを考慮
            let tabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 0
            let bottomInset = keyboardFrame.height + tabBarHeight
            
            // 入力パネルの位置を調整
            inputPanelBottomConstraint?.constant = -bottomInset
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        // タブバーの高さを考慮して入力パネルを元の位置に戻す
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 0
        let safeAreaBottom = view.safeAreaInsets.bottom
        
        // 入力パネルを元の位置に戻す
        inputPanelBottomConstraint?.constant = -(tabBarHeight + safeAreaBottom)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stressCell", for: indexPath) as! StressCell
        let entry = entries[indexPath.row]
        cell.configure(with: entry)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let entry = entries[indexPath.row]
        
        // ストレスエントリーの詳細画面へ遷移
        let detailVC = StressDetailViewController(entry: entry)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 選択された項目を削除
            let entryToDelete = entries[indexPath.row]
            
            // StressManagerからデータを削除
            stressManager.deleteEntry(id: entryToDelete.id)
            
            // ローカル配列からも削除
            entries.remove(at: indexPath.row)
            
            // テーブルビューの更新
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "削除") { [weak self] (action, view, completion) in
            guard let self = self else {
                completion(false)
                return
            }
            
            // 配列の範囲チェックを追加（entriesを使用）
            guard indexPath.row < self.entries.count else {
                completion(false)
                return
            }
            
            let entryToDelete = self.entries[indexPath.row]
            self.stressManager.deleteEntry(id: entryToDelete.id)
            
            // 先に配列から削除
            self.entries.remove(at: indexPath.row)
            
            // その後でテーブルビューを更新
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            completion(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
}

// MARK: - StressCell

class StressCell: UITableViewCell {
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
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
    
    private let solutionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 14)
        label.textColor = .systemGreen
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(levelIndicator)
        contentView.addSubview(timeLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(solutionLabel)
        
        NSLayoutConstraint.activate([
            levelIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            levelIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            levelIndicator.widthAnchor.constraint(equalToConstant: 12),
            levelIndicator.heightAnchor.constraint(equalToConstant: 12),
            
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            timeLabel.leadingAnchor.constraint(equalTo: levelIndicator.trailingAnchor, constant: 12),
            
            contentLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            contentLabel.leadingAnchor.constraint(equalTo: levelIndicator.trailingAnchor, constant: 12),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            solutionLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 4),
            solutionLabel.leadingAnchor.constraint(equalTo: levelIndicator.trailingAnchor, constant: 12),
            solutionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            solutionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with entry: StressEntry) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        timeLabel.text = formatter.string(from: entry.date)
        contentLabel.text = entry.content
        
        if let solution = entry.solution {
            solutionLabel.text = "解決策: \(solution)"
            solutionLabel.isHidden = false
        } else {
            solutionLabel.isHidden = true
        }
        
        if let level = entry.level {
            levelIndicator.backgroundColor = level.color
            levelIndicator.isHidden = false
        } else {
            levelIndicator.isHidden = true
        }
        
        // アクセサリータイプの設定
        accessoryType = .disclosureIndicator
    }
}
