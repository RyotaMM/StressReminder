//
//  SceneDelegate.swift
//  stressReminder
//
//  Created by workspace on 2025/04/18.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        // ストレス入力画面
        let stressVC = UINavigationController(rootViewController: RecordViewController())
        stressVC.tabBarItem = UITabBarItem(title: "ストレス", image: UIImage(systemName: "exclamationmark.triangle"), tag: 0)

        // 解消法画面
        let solutionVC = UINavigationController(rootViewController: SolutionViewController())
        solutionVC.tabBarItem = UITabBarItem(title: "解消法", image: UIImage(systemName: "lightbulb"), tag: 1)

        // 記録画面（履歴）
        let historyVC = UINavigationController(rootViewController: HistoryViewController())
        historyVC.tabBarItem = UITabBarItem(title: "記録", image: UIImage(systemName: "calendar"), tag: 2)
        
        // 統計画面
        let statsVC = UINavigationController(rootViewController: StatsViewController())
        statsVC.tabBarItem = UITabBarItem(title: "統計", image: UIImage(systemName: "chart.bar"), tag: 3)
        
        // 設定画面
        let settingsVC = UINavigationController(rootViewController: SettingsViewController())
        settingsVC.tabBarItem = UITabBarItem(title: "設定", image: UIImage(systemName: "gear"), tag: 4)

        // タブバー設定
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [stressVC, solutionVC, historyVC, statsVC, settingsVC]
        
        // タブバーの外観設定
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
        
        // アプリ起動時にユーザー通知の許可をリクエスト
        requestNotificationPermission()
        
        // 初回起動時の処理
        performFirstLaunchSetup()
    }
    
    private func requestNotificationPermission() {
        // 通知許可のリクエスト
        NotificationManager.shared.requestAuthorization()
    }
    
    private func performFirstLaunchSetup() {
        let userDefaults = UserDefaults.standard
        let isFirstLaunch = !userDefaults.bool(forKey: "hasLaunchedBefore")
        
        if isFirstLaunch {
            // 初回起動のフラグを設定
            userDefaults.set(true, forKey: "hasLaunchedBefore")
            
            // デフォルト設定の初期化
            userDefaults.set(true, forKey: "dailyReminderEnabled")
            userDefaults.set(true, forKey: "dailyStressTipEnabled")
            userDefaults.set(true, forKey: "weeklyStatsEnabled")
            
            // デフォルトの通知時間を設定
            let calendar = Calendar.current
            
            // 毎日20:00のリマインダー
            if let dailyTime = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) {
                userDefaults.set(dailyTime.timeIntervalSince1970, forKey: "dailyReminderTime")
                NotificationManager.shared.scheduleDailyStressCheckReminder(hour: 20, minute: 0)
            }
            
            // 毎日10:00のストレス対処法ヒント
            if let tipTime = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) {
                userDefaults.set(tipTime.timeIntervalSince1970, forKey: "dailyStressTipTime")
                NotificationManager.shared.scheduleRandomStressTip(hour: 10, minute: 0)
            }
            
            // 毎週日曜日18:00の週間統計
            if let weeklyTime = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) {
                userDefaults.set(weeklyTime.timeIntervalSince1970, forKey: "weeklyStatsTime")
                NotificationManager.shared.scheduleWeeklyStressStatisticsReminder(weekday: 1, hour: 18, minute: 0)
            }
        }
    }
}
