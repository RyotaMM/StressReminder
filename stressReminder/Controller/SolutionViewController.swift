//
//  SolutionViewController.swift
//  stressReminder
//
//  Created by workspace on 2025/04/20.
//

import UIKit

class SolutionViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    private let stressManager = StressManager.shared
    private var unresolvedStresses: [StressEntry] = []
    private var selectedStressID: UUID?
    private var initialViewFrame: CGRect?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "解消法の記録"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let solutionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "解消法を入力..."
        textView.textColor = .lightGray
        return textView
    }()
    
    private let stressSelectionLabel: UILabel = {
        let label = UILabel()
        label.text = "関連付けるストレス（任意）"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let stressTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "stressCell")
        tableView.layer.borderColor = UIColor.gray.cgColor
        tableView.layer.borderWidth = 1
        tableView.layer.cornerRadius = 8
        return tableView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("保存", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        solutionTextView.delegate = self
        setupLayout()
        
        stressTableView.dataSource = self
        stressTableView.delegate = self
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        loadUnresolvedStresses()
        registerForKeyboardNotifications()
        
        initialViewFrame = view.frame
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            // 重要: テキストビューなどのコントロールの操作を妨げないようにする
            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUnresolvedStresses()
    }
    
    private func loadUnresolvedStresses() {
        unresolvedStresses = stressManager.unresolvedStressEntries().sorted(by: { $0.date > $1.date })
        stressTableView.reloadData()
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
            // 保存ボタンの位置を取得
            let saveButtonFrame = saveButton.convert(saveButton.bounds, to: view)
            let saveButtonBottomY = saveButtonFrame.origin.y + saveButtonFrame.height
            
            // キーボードの上端位置
            let keyboardTopY = view.frame.height - keyboardFrame.height
            
            // ボタンがキーボードに隠れる場合
            if saveButtonBottomY > keyboardTopY {
                // ボタンが見えるようにビューを上にスクロール
                let offsetY = saveButtonBottomY - keyboardTopY + 20 // 20pxの余白を追加
                
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = -offsetY
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        // ビューを元の位置に戻す
        if let initialFrame = initialViewFrame {
            UIView.animate(withDuration: 0.3) {
                self.view.frame = initialFrame
            }
        }
    }
    
    private func textViewDidBeginEditing2(_ textView: UITextView) {
        // 既存のコード...
        
        // テキストビュー編集開始時にキーボード調整を強制的に実行
        let dummyNotification = Notification(
            name: UIResponder.keyboardWillShowNotification,
            object: nil,
            userInfo: [
                UIResponder.keyboardFrameEndUserInfoKey:
                    UIScreen.main.bounds.height - (textView.frame.origin.y + textView.frame.height + 216)
            ]
        )
        keyboardWillShow(notification: dummyNotification as NSNotification)
    }

    @objc private func dismissKeyboard() {
        // ファーストレスポンダを解除してキーボードを閉じる
        view.endEditing(true)
    }
    
    private func setupLayout() {
        [titleLabel, solutionTextView, stressSelectionLabel, stressTableView, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            solutionTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            solutionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            solutionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            solutionTextView.heightAnchor.constraint(equalToConstant: 150),
            
            stressSelectionLabel.topAnchor.constraint(equalTo: solutionTextView.bottomAnchor, constant: 20),
            stressSelectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            stressTableView.topAnchor.constraint(equalTo: stressSelectionLabel.bottomAnchor, constant: 10),
            stressTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stressTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stressTableView.heightAnchor.constraint(equalToConstant: 200),

            saveButton.topAnchor.constraint(equalTo: stressTableView.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func saveTapped() {
        guard let text = solutionTextView.text,
              text != "解消法を入力...",
              !text.isEmpty else { return }
        
        // 選択されたストレスがある場合は解決策として関連付ける
        if let stressID = selectedStressID {
            stressManager.addSolutionToStress(stressID: stressID, solution: text)
            
            // 成功メッセージ
            let alert = UIAlertController(title: "保存完了", message: "ストレスに解決策を関連付けました", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            // 独立した解決策として保存
            let solutionEntry = StressEntry.createSolutionEntry(date: Date(), content: text)
            stressManager.addEntry(solutionEntry)
            
            // 成功メッセージ
            let alert = UIAlertController(title: "保存完了", message: "解決策を記録しました", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        
        // フォームをリセット
        solutionTextView.text = "解消法を入力..."
        solutionTextView.textColor = .lightGray
        selectedStressID = nil
        stressTableView.reloadData()
        
        // 未解決ストレスリストを更新
        loadUnresolvedStresses()
    }

    // プレースホルダ風の処理
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "解消法を入力..."
            textView.textColor = .lightGray
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return unresolvedStresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stressCell", for: indexPath)
        let stress = unresolvedStresses[indexPath.row]
        
        // 日付フォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        let dateStr = formatter.string(from: stress.date)
        
        // セルの設定
        cell.textLabel?.text = "\(dateStr) - \(stress.content)"
        
        // 選択状態の表示
        if let selectedID = selectedStressID, selectedID == stress.id {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let stress = unresolvedStresses[indexPath.row]
        
        // 選択状態を切り替え
        if selectedStressID == stress.id {
            selectedStressID = nil
        } else {
            selectedStressID = stress.id
        }
        
        tableView.reloadData()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // リターンキーが押されたらキーボードを閉じる
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension SolutionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // タッチイベントの対象ビューがnilの場合は処理する
        guard let targetView = touch.view else {
            return true
        }
        
        // テキストビューまたはテーブルビューの場合は処理しない
        if targetView is UITextView || targetView is UITableView {
            return false
        }
        
        // テーブルビューの子孫の場合は処理しない
        if targetView.isDescendant(of: stressTableView) {
            return false
        }
        
        // それ以外の場合は処理する
        return true
    }
}
