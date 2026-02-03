//
//  Authmanager.swift
//  stressReminder
//
//  Created by workspace on 2026/02/04.
//

import Foundation
import FirebaseAuth

class AuthManager {
    
    static let shared = AuthManager()
    
    private init() {
        // 認証状態の変化を監視
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                print("✅ ログイン中: \(user.email ?? "不明")")
            } else {
                print("⚠️ ログアウト状態")
            }
        }
    }
    
    // MARK: - Properties
    
    /// 現在のユーザー
    var currentUser: User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        return User(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName
        )
    }
    
    /// ログイン状態
    var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    /// 現在のユーザーID
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: - Sign Up (新規登録)
    
    /// メールアドレスとパスワードで新規登録
    func signUp(email: String, password: String, displayName: String?, completion: @escaping (Result<User, Error>) -> Void) {
        // 入力値検証
        guard !email.isEmpty, !password.isEmpty else {
            completion(.failure(AuthError.invalidInput))
            return
        }
        
        guard password.count >= 6 else {
            completion(.failure(AuthError.weakPassword))
            return
        }
        
        // Firebase Authで新規ユーザー作成
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print("❌ サインアップエラー: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let firebaseUser = authResult?.user else {
                completion(.failure(AuthError.unknown))
                return
            }
            
            // 表示名を設定
            if let displayName = displayName {
                let changeRequest = firebaseUser.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("⚠️ 表示名設定エラー: \(error.localizedDescription)")
                    }
                }
            }
            
            // Userモデルを作成
            let user = User(
                uid: firebaseUser.uid,
                email: firebaseUser.email ?? email,
                displayName: displayName
            )
            
            print("✅ サインアップ成功: \(user.email)")
            completion(.success(user))
        }
    }
    
    // MARK: - Sign In (ログイン)
    
    /// メールアドレスとパスワードでログイン
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        // 入力値検証
        guard !email.isEmpty, !password.isEmpty else {
            completion(.failure(AuthError.invalidInput))
            return
        }
        
        // Firebase Authでログイン
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print("❌ ログインエラー: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let firebaseUser = authResult?.user else {
                completion(.failure(AuthError.unknown))
                return
            }
            
            // Userモデルを作成
            let user = User(
                uid: firebaseUser.uid,
                email: firebaseUser.email ?? email,
                displayName: firebaseUser.displayName
            )
            
            print("✅ ログイン成功: \(user.email)")
            completion(.success(user))
        }
    }
    
    // MARK: - Sign Out (ログアウト)
    
    /// ログアウト
    func signOut(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            print("✅ ログアウト成功")
            completion(true)
        } catch {
            print("❌ ログアウトエラー: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Password Reset (パスワードリセット)
    
    /// パスワードリセットメールを送信
    func sendPasswordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !email.isEmpty else {
            completion(.failure(AuthError.invalidInput))
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("❌ パスワードリセットエラー: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("✅ パスワードリセットメール送信成功")
            completion(.success(()))
        }
    }
    
    // MARK: - Delete Account (アカウント削除)
    
    /// アカウント削除
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(AuthError.notLoggedIn))
            return
        }
        
        user.delete { error in
            if let error = error {
                print("❌ アカウント削除エラー: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("✅ アカウント削除成功")
            completion(.success(()))
        }
    }
}

// MARK: - Custom Errors

enum AuthError: LocalizedError {
    case invalidInput
    case weakPassword
    case notLoggedIn
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "メールアドレスまたはパスワードが入力されていません"
        case .weakPassword:
            return "パスワードは6文字以上で入力してください"
        case .notLoggedIn:
            return "ログインしていません"
        case .unknown:
            return "不明なエラーが発生しました"
        }
    }
}
