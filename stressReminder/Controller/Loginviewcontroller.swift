//
//  LoginViewController.swift
//  stressReminder
//
//  Created on 2025/02/04.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let authManager = AuthManager.shared
    private let analyticsManager = AnalyticsManager.shared  // ⭐ 追加
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ストレスリマインダー"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "ログイン"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        textField.placeholder = "パスワード"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.textContentType = .password
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("ログイン", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("新規登録はこちら", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("パスワードを忘れた方", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.secondaryLabel, for: .normal)
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
        
        setupViews()
        setupActions()
        setupKeyboardDismiss()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // ⭐ 画面表示イベント
        analyticsManager.logScreenView(screenName: "LoginView", screenClass: "LoginViewController")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        view.addSubview(forgotPasswordButton)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 50),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            signUpButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 30),
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    
    @objc private func loginTapped() {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text else {
            showAlert(title: "エラー", message: "メールアドレスとパスワードを入力してください")
            return
        }
        
        // ローディング開始
        setLoading(true)
        
        // ログイン処理
        authManager.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                switch result {
                case .success(let user):
                    print("✅ ログイン成功: \(user.email)")
                    
                    // ⭐ ログインイベント
                    self?.analyticsManager.logLogin(method: "email")
                    
                    // ⭐ ユーザーIDを設定
                    self?.analyticsManager.setUserID(user.uid)
                    
                    self?.navigateToMainScreen()
                    
                case .failure(let error):
                    // ⭐ エラーイベント
                    self?.analyticsManager.logError(error: error, context: "login")
                    
                    self?.showAlert(title: "ログインエラー", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func signUpTapped() {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc private func forgotPasswordTapped() {
        let alert = UIAlertController(
            title: "パスワードリセット",
            message: "登録したメールアドレスを入力してください",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "メールアドレス"
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
        }
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        alert.addAction(UIAlertAction(title: "送信", style: .default) { [weak self] _ in
            guard let email = alert.textFields?.first?.text,
                  !email.isEmpty else {
                self?.showAlert(title: "エラー", message: "メールアドレスを入力してください")
                return
            }
            
            self?.sendPasswordReset(email: email)
        })
        
        present(alert, animated: true)
    }
    
    private func sendPasswordReset(email: String) {
        setLoading(true)
        
        // ⭐ パスワードリセットリクエストイベント
        analyticsManager.logPasswordResetRequested()
        
        authManager.sendPasswordReset(email: email) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                switch result {
                case .success:
                    self?.showAlert(
                        title: "送信完了",
                        message: "パスワードリセット用のメールを送信しました。メールをご確認ください。"
                    )
                case .failure(let error):
                    // ⭐ エラーイベント
                    self?.analyticsManager.logError(error: error, context: "password_reset")
                    
                    self?.showAlert(title: "エラー", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Navigation
    
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
            loginButton.isEnabled = false
            signUpButton.isEnabled = false
            forgotPasswordButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            loginButton.isEnabled = true
            signUpButton.isEnabled = true
            forgotPasswordButton.isEnabled = true
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
