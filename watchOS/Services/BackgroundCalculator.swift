//
//  BackgroundCalculator.swift
//  Digital Prayer Wheel Watch App
//
//  Created by Claude on 2025/11/09.
//  自动补圈系统：根据离线时间和转速计算并补充圈数

import Foundation
import Combine

/// Background rotation calculator - auto-compensates missed rotations when app is closed
/// 后台转圈计算器 - 应用关闭期间自动补充转圈数
class BackgroundCalculator: ObservableObject {
    // UserDefaults keys
    private let lastCloseTimeKey = "BackgroundCalc_LastCloseTime"
    private let lastSpeedKey = "BackgroundCalc_LastSpeed"
    private let lastPrayerTypeKey = "BackgroundCalc_LastPrayerType"

    @Published var missedRotations: Int = 0  // Recently calculated missed rotations
    @Published var lastCalculationTime: Date?  // Last calculation timestamp

    // MARK: - Save state when app closes

    /// Save current state when app is about to close
    /// 应用即将关闭时保存当前状态
    /// - Parameters:
    ///   - speed: Current rotation speed in rotations per minute (圈/分钟)
    ///   - prayerType: Currently selected prayer type
    func saveBackgroundState(speed: Double, prayerType: String) {
        let now = Date()

        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: lastCloseTimeKey)
        UserDefaults.standard.set(speed, forKey: lastSpeedKey)
        UserDefaults.standard.set(prayerType, forKey: lastPrayerTypeKey)

        print("📱 Saved background state: Speed=\(speed) RPM, Type=\(prayerType), Time=\(now)")
    }

    // MARK: - Calculate missed rotations when app opens

    /// Calculate how many rotations were missed while app was closed
    /// 计算应用关闭期间错过的转圈数
    /// - Returns: Number of missed rotations to compensate
    func calculateMissedRotations() -> Int {
        // Load saved state
        guard let lastCloseTime = loadLastCloseTime(),
              let lastSpeed = loadLastSpeed() else {
            print("ℹ️ No previous session data, skipping compensation")
            return 0
        }

        // Calculate elapsed time
        let now = Date()
        let elapsedSeconds = now.timeIntervalSince(lastCloseTime)
        let elapsedMinutes = elapsedSeconds / 60.0

        // Calculate missed rotations
        // Formula: rotations = time(minutes) × speed(rotations/minute)
        let calculatedRotations = Int(elapsedMinutes * lastSpeed)

        // Apply reasonable limits (max 24 hours worth of rotations)
        let maxRotations = Int(24 * 60 * lastSpeed)  // 24 hours
        let compensatedRotations = min(calculatedRotations, maxRotations)

        // Update published properties
        missedRotations = compensatedRotations
        lastCalculationTime = now

        print("⏰ Background compensation:")
        print("  - Offline duration: \(formatDuration(elapsedSeconds))")
        print("  - Last speed: \(lastSpeed) RPM")
        print("  - Calculated rotations: \(calculatedRotations)")
        print("  - Compensated: \(compensatedRotations) rotations")

        return compensatedRotations
    }

    // MARK: - Helper methods

    /// Load last close time from UserDefaults
    private func loadLastCloseTime() -> Date? {
        let timestamp = UserDefaults.standard.double(forKey: lastCloseTimeKey)
        guard timestamp > 0 else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }

    /// Load last rotation speed from UserDefaults
    private func loadLastSpeed() -> Double? {
        let speed = UserDefaults.standard.double(forKey: lastSpeedKey)
        guard speed > 0 else { return nil }
        return speed
    }

    /// Load last prayer type from UserDefaults
    private func loadLastPrayerType() -> String? {
        let type = UserDefaults.standard.string(forKey: lastPrayerTypeKey)
        return type
    }

    /// Format duration in human-readable format
    /// 格式化时长为易读格式
    private func formatDuration(_ seconds: TimeInterval) -> String {
        if seconds < 60 {
            return String(format: "%.0f秒", seconds)
        } else if seconds < 3600 {
            return String(format: "%.1f分钟", seconds / 60)
        } else if seconds < 86400 {
            return String(format: "%.1f小时", seconds / 3600)
        } else {
            return String(format: "%.1f天", seconds / 86400)
        }
    }

    /// Clear saved state (call after successful compensation)
    /// 清除已保存的状态（补圈成功后调用）
    func clearSavedState() {
        UserDefaults.standard.removeObject(forKey: lastCloseTimeKey)
        UserDefaults.standard.removeObject(forKey: lastSpeedKey)
        UserDefaults.standard.removeObject(forKey: lastPrayerTypeKey)

        print("🗑️ Cleared background state")
    }

    /// Check if there's saved state from previous session
    /// 检查是否有上次会话保存的状态
    var hasSavedState: Bool {
        return loadLastCloseTime() != nil && loadLastSpeed() != nil
    }
}
