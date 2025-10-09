//
//  StressDetailViewController.swift
//  stressReminder
//
//  Created  on 2025/04/20.
//ストレス画面でタップした時に遷移する画面

import UIKit

class StressDetailViewController: UIViewController, UITextViewDelegate {
    
    private let stressManager = StressManager.shared
    private let entry: StressEntry
    
    // UI要素
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let solutionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "解決策"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let solutionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.isEditable = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let saveSolutionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("解決策を保存", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 初期化
    init(entry: StressEntry) { //画面がどのストレスデータを表示するか
        self.entry = entry
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { //Storyboardを使わない設計の安全装置
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "ストレス詳細"
        
        setupViews()
        configureWithEntry()
        setupActions()
    }
    
    private func setupViews() {
        // UI要素の追加
        view.addSubview(dateLabel)
        view.addSubview(levelIndicator)
        view.addSubview(levelLabel)
        view.addSubview(contentLabel)
        view.addSubview(solutionTitleLabel)
        view.addSubview(solutionTextView)
        view.addSubview(saveSolutionButton)
        
        // キーボード通知の登録
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
        
        // 制約の設定
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            levelIndicator.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            levelIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            levelIndicator.widthAnchor.constraint(equalToConstant: 16),
            levelIndicator.heightAnchor.constraint(equalToConstant: 16),
            
            levelLabel.centerYAnchor.constraint(equalTo: levelIndicator.centerYAnchor),
            levelLabel.leadingAnchor.constraint(equalTo: levelIndicator.trailingAnchor, constant: 12),
            levelLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: levelIndicator.bottomAnchor, constant: 20),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            solutionTitleLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 30),
            solutionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            solutionTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            solutionTextView.topAnchor.constraint(equalTo: solutionTitleLabel.bottomAnchor, constant: 12),
            solutionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            solutionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            solutionTextView.heightAnchor.constraint(equalToConstant: 150),
            
            saveSolutionButton.topAnchor.constraint(equalTo: solutionTextView.bottomAnchor, constant: 20),
            saveSolutionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveSolutionButton.widthAnchor.constraint(equalToConstant: 200),
            saveSolutionButton.heightAnchor.constraint(equalToConstant: 44)
        ]);
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let inset = keyboardFrame.height
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)
            
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -inset/2
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
    
    private func configureWithEntry() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateLabel.text = formatter.string(from: entry.date)
        
        contentLabel.text = entry.content //ストレス内容を取得
        
        if let level = entry.level {
            levelLabel.text = level.description
            levelIndicator.backgroundColor = level.color
        } else {
            levelLabel.text = "レベル未設定"
            levelIndicator.backgroundColor = .systemGray
        }
        
        if let solution = entry.solution {
            solutionTextView.text = solution
            solutionTextView.textColor = .label
        } else {
            solutionTextView.text = "解決策を入力してください..."
            solutionTextView.textColor = .placeholderText
        }
        
        // TextViewのデリゲート設定
        solutionTextView.delegate = self
    }
    
    private func setupActions() {
        saveSolutionButton.addTarget(self, action: #selector(saveSolutionTapped), for: .touchUpInside)
    }
    
    @objc private func saveSolutionTapped() {
        let text = solutionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if text?.isEmpty == true || solutionTextView.textColor == .placeholderText {
            // 空文字やプレースホルダー状態 → nilを保存（解決策を削除）
            stressManager.addSolutionToStress(stressID: entry.id, solution: nil)
        } else {
            // 通常の保存処理
            stressManager.addSolutionToStress(stressID: entry.id, solution: text)
        }
        
        // 通知キャンセルなどは共通処理として残す
        NotificationManager.shared.cancelStressFollowUp(for: entry.id)
        
        let alert = UIAlertController(title: "保存完了", message: "解決策を保存しました", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true)
    }

    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "解決策を入力してください..."
            textView.textColor = .placeholderText
        }
    }
}
