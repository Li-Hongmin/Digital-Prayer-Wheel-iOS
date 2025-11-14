//
//  SharedDataManager.swift
//  Digital Prayer Wheel
//
//  Created by Claude on 2025/11/10.
//  App Group shared storage for iOS and Watch synchronization
//  免费方案：使用 App Group 实现 iOS 和 Watch 数据同步
//

import Foundation
import Combine

/// Shared data manager using App Group for iOS and Watch sync
/// 使用 App Group 实现 iOS 和 Watch 数据同步
@MainActor
class SharedDataManager: ObservableObject {

    // MARK: - App Group Configuration

    /// App Group identifier - must match in both iOS and Watch targets
    /// App Group 标识符 - 必须在 iOS 和 Watch 目标中匹配
    ///
    /// 配置步骤：
    /// 1. 在 Xcode 中选择项目 -> Signing & Capabilities
    /// 2. 点击 "+ Capability" -> 选择 "App Groups"
    /// 3. 点击 "+" 添加 App Group，命名为：group.com.yourname.digital-prayer-wheel
    /// 4. 对 iOS App 和 Watch App 都重复此步骤，使用相同的 Group ID
    // 🔧 配置说明：
    // 1. 如果您已在 Xcode 中配置了 App Group，将下面的 ID 改为您的 Group ID
    // 2. 如果未配置，保持原样，应用会自动使用本地存储（iOS 和 Watch 数据独立）
    // 3. 当前检测到的 Group ID: group.com.li-hongmin.digital-prayer-wheel
    private static let appGroupID = "group.com.li-hongmin.digital-prayer-wheel"

    // Shared UserDefaults
    private let sharedDefaults: UserDefaults?

    // Singleton
    static let shared = SharedDataManager()

    @Published var lastSyncTime: Date?
    @Published var syncStatus: String = "未配置"

    private init() {
        // Initialize shared UserDefaults with App Group
        sharedDefaults = UserDefaults(suiteName: SharedDataManager.appGroupID)

        if sharedDefaults != nil {
            syncStatus = "已就绪"
            print("✅ Shared UserDefaults initialized with App Group: \(SharedDataManager.appGroupID)")
        } else {
            syncStatus = "未配置 App Group"
            print("⚠️ Failed to initialize shared UserDefaults. Please configure App Group in Xcode.")
        }
    }

    // MARK: - Shared Storage Keys

    private func countKey(for type: String) -> String {
        return "Shared_TodayCount_\(type)"
    }

    private func totalCyclesKey(for type: String) -> String {
        return "Shared_TotalCycles_\(type)"
    }

    private func lastUpdateTimeKey(for type: String) -> String {
        return "Shared_LastUpdate_\(type)"
    }

    private let speedKey = "Shared_RotationSpeed"
    private let selectedTypeKey = "Shared_SelectedType"
    private let lastResetDateKey = "Shared_LastResetDate"

    // MARK: - Save Methods

    /// Save count data to shared storage
    /// 保存计数到共享存储
    func saveCount(type: String, todayCount: Int, totalCycles: Int) {
        guard let sharedDefaults = sharedDefaults else {
            print("⚠️ Shared storage not available")
            return
        }

        let now = Date()

        // Check for daily reset
        if shouldResetDaily(for: type) {
            // Reset today count
            sharedDefaults.set(0, forKey: countKey(for: type))
            sharedDefaults.set(now.timeIntervalSince1970, forKey: lastResetDateKey + "_\(type)")
            print("🔄 Daily reset triggered for \(type)")
        } else {
            // Merge strategy: take maximum value to avoid data loss
            // 合并策略：取最大值，避免数据丢失
            let existingTodayCount = sharedDefaults.integer(forKey: countKey(for: type))
            let existingTotalCycles = sharedDefaults.integer(forKey: totalCyclesKey(for: type))

            let mergedTodayCount = max(todayCount, existingTodayCount)
            let mergedTotalCycles = max(totalCycles, existingTotalCycles)

            sharedDefaults.set(mergedTodayCount, forKey: countKey(for: type))
            sharedDefaults.set(mergedTotalCycles, forKey: totalCyclesKey(for: type))
            sharedDefaults.set(now.timeIntervalSince1970, forKey: lastUpdateTimeKey(for: type))

            print("💾 Saved to shared storage - Type: \(type), Today: \(mergedTodayCount), Total: \(mergedTotalCycles)")
        }

        lastSyncTime = now
        syncStatus = "已同步"
    }

    /// Save rotation speed to shared storage
    /// 保存转经速度到共享存储
    func saveRotationSpeed(_ speed: Double) {
        guard let sharedDefaults = sharedDefaults else { return }
        sharedDefaults.set(speed, forKey: speedKey)
        print("💾 Saved rotation speed: \(speed)")
    }

    /// Save selected prayer type to shared storage
    /// 保存当前经文类型到共享存储
    func saveSelectedType(_ type: String) {
        guard let sharedDefaults = sharedDefaults else { return }
        sharedDefaults.set(type, forKey: selectedTypeKey)
        print("💾 Saved selected type: \(type)")
    }

    // MARK: - Load Methods

    /// Load count data from shared storage
    /// 从共享存储加载计数
    func loadCount(type: String) -> (todayCount: Int, totalCycles: Int) {
        guard let sharedDefaults = sharedDefaults else {
            return (0, 0)
        }

        // Check for daily reset first
        if shouldResetDaily(for: type) {
            // Reset and return zeros
            sharedDefaults.set(0, forKey: countKey(for: type))
            sharedDefaults.set(Date().timeIntervalSince1970, forKey: lastResetDateKey + "_\(type)")
            print("🔄 Daily reset triggered when loading \(type)")
            return (0, sharedDefaults.integer(forKey: totalCyclesKey(for: type)))
        }

        let todayCount = sharedDefaults.integer(forKey: countKey(for: type))
        let totalCycles = sharedDefaults.integer(forKey: totalCyclesKey(for: type))

        print("📂 Loaded from shared storage - Type: \(type), Today: \(todayCount), Total: \(totalCycles)")

        return (todayCount, totalCycles)
    }

    /// Load rotation speed from shared storage
    /// 从共享存储加载转经速度
    func loadRotationSpeed() -> Double {
        guard let sharedDefaults = sharedDefaults else { return 30.0 }
        let speed = sharedDefaults.double(forKey: speedKey)
        return speed > 0 ? speed : 30.0
    }

    /// Load selected prayer type from shared storage
    /// 从共享存储加载当前经文类型
    func loadSelectedType() -> String? {
        guard let sharedDefaults = sharedDefaults else { return nil }
        return sharedDefaults.string(forKey: selectedTypeKey)
    }

    /// Load last update time for a prayer type
    /// 加载某个经文类型的最后更新时间
    func loadLastUpdateTime(for type: String) -> Date? {
        guard let sharedDefaults = sharedDefaults else { return nil }
        let timestamp = sharedDefaults.double(forKey: lastUpdateTimeKey(for: type))
        return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
    }

    // MARK: - Daily Reset Logic

    /// Check if today's count should be reset (crossed midnight)
    /// 检查是否应该重置今日计数（跨越午夜）
    private func shouldResetDaily(for type: String) -> Bool {
        guard let sharedDefaults = sharedDefaults else { return false }

        let today = Calendar.current.startOfDay(for: Date())
        let lastResetTimestamp = sharedDefaults.double(forKey: lastResetDateKey + "_\(type)")

        if lastResetTimestamp == 0 {
            // First time, set reset date
            sharedDefaults.set(today.timeIntervalSince1970, forKey: lastResetDateKey + "_\(type)")
            return false
        }

        let lastResetDate = Date(timeIntervalSince1970: lastResetTimestamp)
        let lastResetDay = Calendar.current.startOfDay(for: lastResetDate)

        // If today is after last reset day, need to reset
        return today > lastResetDay
    }

    // MARK: - Utility Methods

    /// Check if App Group is properly configured
    /// 检查 App Group 是否正确配置
    var isConfigured: Bool {
        return sharedDefaults != nil
    }

    /// Get all counts for all prayer types
    /// 获取所有经文类型的计数
    func getAllCounts() -> [String: (todayCount: Int, totalCycles: Int)] {
        var counts: [String: (todayCount: Int, totalCycles: Int)] = [:]

        let types = ["六字大明咒", "心经", "南无阿弥陀佛", "南无观世音菩萨"]
        for type in types {
            counts[type] = loadCount(type: type)
        }

        return counts
    }

    /// Clear all shared data (for testing)
    /// 清除所有共享数据（用于测试）
    func clearAllData() {
        guard let sharedDefaults = sharedDefaults else { return }

        let types = ["六字大明咒", "心经", "南无阿弥陀佛", "南无观世音菩萨"]
        for type in types {
            sharedDefaults.removeObject(forKey: countKey(for: type))
            sharedDefaults.removeObject(forKey: totalCyclesKey(for: type))
            sharedDefaults.removeObject(forKey: lastUpdateTimeKey(for: type))
            sharedDefaults.removeObject(forKey: lastResetDateKey + "_\(type)")
        }

        sharedDefaults.removeObject(forKey: speedKey)
        sharedDefaults.removeObject(forKey: selectedTypeKey)

        print("🗑️ Cleared all shared data")
    }
}
