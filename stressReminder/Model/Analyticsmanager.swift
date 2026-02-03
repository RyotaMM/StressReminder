//
//  AnalyticsManager.swift
//  stressReminder
//
//  Created on 2025/02/04.
//

import Foundation
import FirebaseAnalytics

class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    
    private init() {
        print("📊 AnalyticsManager初期化")
    }
    
    // MARK: - User Properties
    
    /// ユーザープロパティを設定（ユーザー属性）
    func setUserProperty(value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
        print("📊 ユーザープロパティ設定: \(name) = \(value ?? "nil")")
    }
    
    /// ユーザーIDを設定
    func setUserID(_ userID: String?) {
        Analytics.setUserID(userID)
        print("📊 ユーザーID設定: \(userID ?? "nil")")
    }
    
    // MARK: - Screen View Events
    
    /// 画面表示イベントを記録
    func logScreenView(screenName: String, screenClass: String? = nil) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass ?? screenName
        ])
        print("📊 画面表示: \(screenName)")
    }
    
    // MARK: - Custom Events
    
    /// カスタムイベントを記録
    func logEvent(name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
        
        if let params = parameters {
            print("📊 イベント: \(name), パラメータ: \(params)")
        } else {
            print("📊 イベント: \(name)")
        }
    }
    
    // MARK: - Stress Recording Events
    
    /// ストレス記録イベント
    func logStressRecorded(level: StressLevel, hasContent: Bool) {
        logEvent(name: "stress_recorded", parameters: [
            "stress_level": level.rawValue,
            "stress_level_name": level.description,
            "has_content": hasContent
        ])
    }
    
    /// 解決策記録イベント
    func logSolutionRecorded(isStandalone: Bool, hasLinkedStress: Bool) {
        logEvent(name: "solution_recorded", parameters: [
            "is_standalone": isStandalone,
            "has_linked_stress": hasLinkedStress
        ])
    }
    
    /// ストレスに解決策を追加イベント
    func logSolutionAddedToStress(stressLevel: StressLevel?, timeToResolve: TimeInterval?) {
        var params: [String: Any] = [:]
        
        if let level = stressLevel {
            params["stress_level"] = level.rawValue
            params["stress_level_name"] = level.description
        }
        
        if let time = timeToResolve {
            params["time_to_resolve_hours"] = Int(time / 3600)
        }
        
        logEvent(name: "solution_added_to_stress", parameters: params)
    }
    
    // MARK: - Data Management Events
    
    /// データ削除イベント
    func logDataDeleted(entryCount: Int) {
        logEvent(name: "data_deleted", parameters: [
            "entry_count": entryCount
        ])
    }
    
    /// データエクスポートイベント
    func logDataExported(format: String, entryCount: Int) {
        logEvent(name: "data_exported", parameters: [
            "format": format,
            "entry_count": entryCount
        ])
    }
    
    // MARK: - Statistics Events
    
    /// 統計画面の表示タイプ切り替えイベント
    func logStatsViewChanged(viewType: String) {
        logEvent(name: "stats_view_changed", parameters: [
            "view_type": viewType
        ])
    }
    
    /// 統計データの確認イベント
    func logStatsViewed(totalStress: Int, totalSolutions: Int, period: String) {
        logEvent(name: "stats_viewed", parameters: [
            "total_stress": totalStress,
            "total_solutions": totalSolutions,
            "period": period
        ])
    }
    
    // MARK: - Settings Events
    
    /// 通知設定変更イベント
    func logNotificationSettingChanged(type: String, enabled: Bool) {
        logEvent(name: "notification_setting_changed", parameters: [
            "notification_type": type,
            "enabled": enabled
        ])
    }
    
    /// ダークモード切り替えイベント
    func logDarkModeToggled(enabled: Bool) {
        logEvent(name: "dark_mode_toggled", parameters: [
            "enabled": enabled
        ])
    }
    
    // MARK: - Authentication Events
    
    /// サインアップイベント
    func logSignUp(method: String) {
        Analytics.logEvent(AnalyticsEventSignUp, parameters: [
            AnalyticsParameterMethod: method
        ])
        print("📊 サインアップ: \(method)")
    }
    
    /// ログインイベント
    func logLogin(method: String) {
        Analytics.logEvent(AnalyticsEventLogin, parameters: [
            AnalyticsParameterMethod: method
        ])
        print("📊 ログイン: \(method)")
    }
    
    /// ログアウトイベント
    func logLogout() {
        logEvent(name: "logout")
    }
    
    // MARK: - User Engagement
    
    /// アプリ起動イベント
    func logAppLaunched() {
        logEvent(name: "app_launched")
    }
    
    /// フィードバック送信イベント
    func logFeedbackSent(method: String) {
        logEvent(name: "feedback_sent", parameters: [
            "method": method
        ])
    }
    
    /// パスワードリセットリクエストイベント
    func logPasswordResetRequested() {
        logEvent(name: "password_reset_requested")
    }
    
    // MARK: - Error Events
    
    /// エラーイベント
    func logError(error: Error, context: String) {
        logEvent(name: "error_occurred", parameters: [
            "error_description": error.localizedDescription,
            "context": context
        ])
    }
}

// MARK: - Analytics Event Names (Custom)

extension AnalyticsManager {
    
    /// カスタムイベント名の定数
    struct EventName {
        static let stressRecorded = "stress_recorded"
        static let solutionRecorded = "solution_recorded"
        static let solutionAddedToStress = "solution_added_to_stress"
        static let dataDeleted = "data_deleted"
        static let dataExported = "data_exported"
        static let statsViewChanged = "stats_view_changed"
        static let statsViewed = "stats_viewed"
        static let notificationSettingChanged = "notification_setting_changed"
        static let darkModeToggled = "dark_mode_toggled"
        static let logout = "logout"
        static let appLaunched = "app_launched"
        static let feedbackSent = "feedback_sent"
        static let passwordResetRequested = "password_reset_requested"
        static let errorOccurred = "error_occurred"
    }
    
    /// パラメータ名の定数
    struct ParameterName {
        static let stressLevel = "stress_level"
        static let stressLevelName = "stress_level_name"
        static let hasContent = "has_content"
        static let isStandalone = "is_standalone"
        static let hasLinkedStress = "has_linked_stress"
        static let timeToResolveHours = "time_to_resolve_hours"
        static let entryCount = "entry_count"
        static let format = "format"
        static let viewType = "view_type"
        static let totalStress = "total_stress"
        static let totalSolutions = "total_solutions"
        static let period = "period"
        static let notificationType = "notification_type"
        static let enabled = "enabled"
        static let method = "method"
        static let errorDescription = "error_description"
        static let context = "context"
    }
}
