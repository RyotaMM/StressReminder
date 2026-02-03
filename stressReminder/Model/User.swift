//
//  User.swift
//  stressReminder
//
//  Created on 2025/02/04.
//

import Foundation

struct User {
    let uid: String           // Firebase UserのUID
    let email: String         // メールアドレス
    let displayName: String?  // 表示名（任意）
    
    init(uid: String, email: String, displayName: String? = nil) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
    }
}
