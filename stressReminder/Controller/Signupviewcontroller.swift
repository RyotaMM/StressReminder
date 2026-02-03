//
//  SignUpViewController.swift
//  stressReminder
//
//  Created on 2025/02/04.
//

import UIKit

class SignUpViewController: UIViewController {
    
    private let authManager = AuthManager.shared
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "新規登録"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let displayNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "表示名（任意）"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "メールアドレス"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "パスワード（6文字以上）"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.textContentType = .newPassword  // ⭐ 追加
        textField.passwordRules = nil  // ⭐ 追加（自動生成を無効化）
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "パスワード（確認）"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.textContentType = .newPassword  // ⭐ 追加
        textField.passwordRules = nil  // ⭐ 追加（自動生成を無効化）
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("登録", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "新規登録"
        
        setupViews()
        setupActions()
        setupKeyboardDismiss()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsManager.shared.logScreenView(screenName: "SignUpView")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(displayNameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(signUpButton)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            displayNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            displayNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            displayNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            displayNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            emailTextField.topAnchor.constraint(equalTo: displayNameTextField.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: displayNameTextField.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: displayNameTextField.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            signUpButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 30),
            signUpButton.leadingAnchor.constraint(equalTo: confirmPasswordTextField.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: confirmPasswordTextField.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    
    @objc private func signUpTapped() {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            showAlert(title: "エラー", message: "すべての必須項目を入力してください")
            return
        }
        
        // バリデーション
        guard !email.isEmpty, !password.isEmpty else {
            showAlert(title: "エラー", message: "メールアドレスとパスワードを入力してください")
            return
        }
        
        guard password == confirmPassword else {
            showAlert(title: "エラー", message: "パスワードが一致しません")
            return
        }
        
        guard password.count >= 6 else {
            showAlert(title: "エラー", message: "パスワードは6文字以上で入力してください")
            return
        }
        
        let displayName = displayNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalDisplayName = displayName?.isEmpty == false ? displayName : nil
        
        // ローディング開始
        setLoading(true)
        
        // サインアップ処理
        authManager.signUp(email: email, password: password, displayName: finalDisplayName) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                switch result {
                case .success(let user):
                    print("✅ サインアップ成功: \(user.email)")
                    self?.showSuccessAndNavigate()
                    
                case .failure(let error):
                    self?.showAlert(title: "登録エラー", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    private func showSuccessAndNavigate() {
        let alert = UIAlertController(
            title: "登録完了",
            message: "アカウントの登録が完了しました",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigateToMainScreen()
        })
        
        present(alert, animated: true)
    }
    
    private func navigateToMainScreen() {
        // SceneDelegateを取得してメイン画面に遷移
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.showMainScreen()
        }
    }
    
    // MARK: - Helpers
    
    private func setLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
            signUpButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            signUpButton.isEnabled = true
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
