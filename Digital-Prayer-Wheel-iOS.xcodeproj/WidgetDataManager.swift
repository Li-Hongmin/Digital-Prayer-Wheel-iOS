//
//  WidgetDataManager.swift
//  Digital-Prayer-Wheel
//
//  小组件数据管理器 - 负责应用和小组件之间的数据共享
//  Created by Claude on 2025/10/23.
//

import Foundation
import WidgetKit

/// 小组件数据管理器
/// 负责在应用和小组件之间共享数据
class WidgetDataManager {
    
    // 共享的 UserDefaults suite 名称
    // 需要在 Xcode 项目中添加 App Groups 能力
    static let suiteName = "group.digital-prayer-wheel"
    
    // 数据键名
    private enum Keys {
        static let todayCount = "todayCount"
        static let totalCount = "totalCount" 
        static let currentPrayerType = "currentPrayerType"
        static let lastUpdateDate = "lastUpdateDate"
        static let todayStartDate = "todayStartDate"
    }
    
    /// 共享的 UserDefaults 实例
    private static var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: suiteName)
    }
    
    // MARK: - 数据更新方法
    
    /// 更新今日转经次数
    /// - Parameter count: 今日转经次数
    static func updateTodayCount(_ count: Int) {
        sharedDefaults?.set(count, forKey: Keys.todayCount)
        updateLastModified()
        refreshWidgets()
    }
    
    /// 更新总转经次数
    /// - Parameter count: 总转经次数
    static func updateTotalCount(_ count: Int) {
        sharedDefaults?.set(count, forKey: Keys.totalCount)
        updateLastModified()
        refreshWidgets()
    }
    
    /// 更新当前经文类型
    /// - Parameter prayerType: 当前选择的经文类型
    static func updateCurrentPrayerType(_ prayerType: String) {
        sharedDefaults?.set(prayerType, forKey: Keys.currentPrayerType)
        updateLastModified()
        refreshWidgets()
    }
    
    /// 批量更新所有数据（提高性能，减少小组件刷新次数）
    /// - Parameters:
    ///   - todayCount: 今日转经次数
    ///   - totalCount: 总转经次数
    ///   - prayerType: 当前经文类型
    static func updateAllData(todayCount: Int, totalCount: Int, prayerType: String) {
        guard let defaults = sharedDefaults else { return }
        
        defaults.set(todayCount, forKey: Keys.todayCount)
        defaults.set(totalCount, forKey: Keys.totalCount)
        defaults.set(prayerType, forKey: Keys.currentPrayerType)
        updateLastModified()
        refreshWidgets()
    }
    
    // MARK: - 数据读取方法
    
    /// 获取今日转经次数
    static func getTodayCount() -> Int {
        return sharedDefaults?.integer(forKey: Keys.todayCount) ?? 0
    }
    
    /// 获取总转经次数
    static func getTotalCount() -> Int {
        return sharedDefaults?.integer(forKey: Keys.totalCount) ?? 0
    }
    
    /// 获取当前经文类型
    static func getCurrentPrayerType() -> String {
        return sharedDefaults?.string(forKey: Keys.currentPrayerType) ?? "大悲咒"
    }
    
    /// 获取上次更新日期
    static func getLastUpdateDate() -> Date {
        if let timestamp = sharedDefaults?.object(forKey: Keys.lastUpdateDate) as? Date {
            return timestamp
        }
        return Date()
    }
    
    // MARK: - 日期相关方法
    
    /// 检查是否是新的一天，如果是则重置今日计数
    static func checkAndResetDailyCount() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let storedStartDate = sharedDefaults?.object(forKey: Keys.todayStartDate) as? Date {
            // 如果存储的开始日期不是今天，说明是新的一天
            if !Calendar.current.isDate(storedStartDate, inSameDayAs: today) {
                // 重置今日计数
                updateTodayCount(0)
                sharedDefaults?.set(today, forKey: Keys.todayStartDate)
            }
        } else {
            // 第一次运行，设置开始日期
            sharedDefaults?.set(today, forKey: Keys.todayStartDate)
        }
    }
    
    // MARK: - 私有方法
    
    /// 更新最后修改时间戳
    private static func updateLastModified() {
        sharedDefaults?.set(Date(), forKey: Keys.lastUpdateDate)
    }
    
    /// 通知小组件刷新
    private static func refreshWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: "PrayerWheelWidget")
    }
    
    // MARK: - 调试和维护方法
    
    /// 清除所有小组件数据（用于调试）
    static func clearAllData() {
        guard let defaults = sharedDefaults else { return }
        
        defaults.removeObject(forKey: Keys.todayCount)
        defaults.removeObject(forKey: Keys.totalCount)
        defaults.removeObject(forKey: Keys.currentPrayerType)
        defaults.removeObject(forKey: Keys.lastUpdateDate)
        defaults.removeObject(forKey: Keys.todayStartDate)
        
        refreshWidgets()
    }
    
    /// 获取所有数据的摘要（用于调试）
    static func getDataSummary() -> [String: Any] {
        return [
            "todayCount": getTodayCount(),
            "totalCount": getTotalCount(),
            "currentPrayerType": getCurrentPrayerType(),
            "lastUpdate": getLastUpdateDate(),
            "todayStart": sharedDefaults?.object(forKey: Keys.todayStartDate) as? Date ?? Date()
        ]
    }
}

// MARK: - PrayerLibrary 扩展
extension PrayerLibrary {
    
    /// 同步数据到小组件
    func syncToWidget() {
        WidgetDataManager.updateAllData(
            todayCount: self.todayCount,
            totalCount: self.totalCycles,
            prayerType: self.selectedType.rawValue
        )
    }
}

// MARK: - AppSettings 扩展  
extension AppSettings {
    
    /// 同步设置到小组件
    func syncToWidget() {
        // 当经文选择改变时同步到小组件
        if let prayerType = PrayerType(rawValue: selectedPrayerType) {
            WidgetDataManager.updateCurrentPrayerType(prayerType.rawValue)
        }
    }
}