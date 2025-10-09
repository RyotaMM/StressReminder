//
//  AppDelegate.swift
//  stressReminder
//
//  Created by workspace on 2025/04/18.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 通知デリゲートの設定
        UNUserNotificationCenter.current().delegate = self
        
        
        
        // アプリの外観設定
        setupAppearance()
        
        return true
    }
    
    private func setupAppearance() {
        // ナビゲーションバーの外観設定
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
        
        // ダークモード設定の適用
        applyDarkModeSettings()
        
        
    }
    
    private func applyDarkModeSettings() {
        // UserDefaultsからダークモード設定を取得
        let darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        
        // ダークモード設定を適用
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
    
    
    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // 破棄されたシーンがある場合の処理
    }

    // MARK: - UNUserNotificationCenterDelegate

    // アプリがフォアグラウンドにある時に通知を受け取った場合
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // フォアグラウンドでも通知を表示
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }

    // 通知がタップされた時の処理
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // 通知のタイプに応じた処理
        let identifier = response.notification.request.identifier
        if identifier == "dailyStressCheck" {
            // ストレス記録画面に遷移
            navigateToStressRecordScreen()
        } else if identifier == "weeklyStressStats" {
            // 統計画面に遷移
            navigateToStatsScreen()
        } else if identifier.hasPrefix("stressFollowUp") {
            // 特定のストレスID付きの通知
            if let stressIDString = userInfo["stressID"] as? String,
               let stressID = UUID(uuidString: stressIDString) {
                // 解消法入力画面に遷移して特定のストレスを選択
                navigateToSolutionScreenWithStressID(stressID)
            }
        }
        completionHandler()
    }
    
    // 各画面への遷移ヘルパーメソッド
    private func navigateToStressRecordScreen() {
        if #available(iOS 15.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBarController = window.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 0
            }
        } else {
            // iOS 15.0未満のデバイス用（非推奨だが後方互換性のため）
            if let window = UIApplication.shared.windows.first,
               let tabBarController = window.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 0
            }
        }
    }
    
    private func navigateToStatsScreen() {
        if #available(iOS 15.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBarController = window.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 3
            }
        } else {
            // iOS 15.0未満のデバイス用（非推奨だが後方互換性のため）
            if let window = UIApplication.shared.windows.first,
               let tabBarController = window.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 3
            }
        }
    }
    
    private func navigateToSolutionScreenWithStressID(_ stressID: UUID) {
        if #available(iOS 15.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBarController = window.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 1
                
                // TODO: 特定のストレスIDを解消法画面に渡す処理
                // この機能は後で実装する必要があります
            }
        } else {
            // iOS 15.0未満のデバイス用（非推奨だが後方互換性のため）
            if let window = UIApplication.shared.windows.first,
               let tabBarController = window.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 1
                
                // TODO: 特定のストレスIDを解消法画面に渡す処理
                // この機能は後で実装する必要があります
            }
        }
    }
    
}
