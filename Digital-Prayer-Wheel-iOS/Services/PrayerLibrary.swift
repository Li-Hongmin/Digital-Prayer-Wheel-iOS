//
//  PrayerLibrary.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/19.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PrayerLibrary: ObservableObject {
    // 统计管理器
    @Published var statistics = PrayerStatistics()

    // 当前选择的经文类型
    @Published var selectedType: PrayerType = .amitabha {
        didSet {
            loadTextsForCurrentType()
            loadCount()
            checkDailyReset() // 切换经文时也检查是否需要重置
        }
    }

    // 今日计数（每日独立，午夜自动重置）
    @Published var todayCount: Int = 0

    // 历史总循环数（从安装App开始的总转经次数）
    @Published var totalCycles: Int = 0

    // 上次重置日期（用于跨日检测）
    private var lastResetDate: Date?

    // 定时保存机制（优化：每10分钟自动保存一次）
    @Published var lastCountSaveTime: Date?  // 上次保存时间（用于UI显示）
    @Published var hasUnsavedChanges: Bool = false  // 是否有未保存的变更
    private var lastSaveTime: Date = Date()
    private let saveInterval: TimeInterval = 600  // 10分钟 = 600秒

    // 转经速度（圈/分钟）
    @Published var rotationSpeed: Double = 30 {
        didSet {
            saveRotationSpeed()
        }
    }

    // 当前经文索引
    private var currentIndex: Int = 0

    // 当前经文类型的文本数组
    private var texts: [String] = []

    init() {
        // 默认使用南无阿弥陀佛
        loadTextsForCurrentType()

        // 延迟加载计数，避免阻塞启动（大指数幂运算可能很慢）
        Task { @MainActor in
            loadCount()
            loadRotationSpeed()
        }
    }

    // MARK: - 公共方法

    /// 设置经文类型
    /// - Parameter type: 经文类型
    func setType(_ type: PrayerType) {
        selectedType = type
    }

    /// 获取下一条经文
    /// - Returns: 经文文本
    func getNextText() -> String? {
        guard !texts.isEmpty else { return nil }

        // 获取当前索引的经文
        let text = texts[currentIndex]

        // 每获取一条经文就计数一次（每条弹幕显示都计数）
        incrementCount()

        // 索引加1，为下一次获取做准备
        currentIndex += 1

        // 如果已经到达末尾，重新从头开始
        if currentIndex >= texts.count {
            currentIndex = 0
        }

        return text
    }

    /// 增加计数 - 简单整数累加
    /// 新增：每日独立计数，午夜自动重置
    /// 每次调用都增加总转数 totalCycles 和今日转数 todayCount
    /// 性能优化：定时保存，每10分钟自动保存一次，减少磁盘I/O
    func incrementCount() {
        // 检查是否需要每日重置
        checkDailyReset()

        // 增加历史总计数和今日计数
        totalCycles += 1
        todayCount += 1

        hasUnsavedChanges = true  // 标记有未保存的变更

        // 定时保存优化：检查距离上次保存是否超过10分钟
        let currentTime = Date()
        if currentTime.timeIntervalSince(lastSaveTime) >= saveInterval {
            saveCount()
            lastSaveTime = currentTime
            hasUnsavedChanges = false
        }

        // 更新今日统计记录
        statistics.updateTodayCount(
            for: selectedType.rawValue,
            countExponent: 0,  // 不再使用指数
            totalCycles: todayCount
        )
    }

    /// 检查是否需要每日重置
    private func checkDailyReset() {
        let today = Calendar.current.startOfDay(for: Date())

        // 如果还没有记录重置日期，或者已经过了一天
        if lastResetDate == nil || lastResetDate! < today {
            // 重置今日计数
            todayCount = 0
            lastResetDate = today
            saveDailyResetDate()
        }
    }

    /// 最终保存计数（视图消失/app关闭时调用，确保保存所有未保存的计数）
    func finalizeCount() {
        if hasUnsavedChanges {
            saveCount()
            hasUnsavedChanges = false
            lastSaveTime = Date()
        }
    }

    /// 重置计数
    func resetCount() {
        todayCount = 0
        totalCycles = 0
        saveCount()
    }

    /// 获取当前经文类型的描述
    var currentDescription: String {
        selectedType.description
    }

    /// 获取当前经文类型的总数
    var totalTexts: Int {
        texts.count
    }

    // MARK: - 私有方法

    /// 为当前类型加载经文
    private func loadTextsForCurrentType() {
        texts = selectedType.texts
        currentIndex = 0 // 重置索引
    }

    /// 加载计数
    private func loadCount() {
        let totalCyclesKey = "TotalCycles_\(selectedType.rawValue)"
        let todayKey = "TodayCount_\(selectedType.rawValue)"

        // 加载每日重置日期
        loadDailyResetDate()

        // 检查是否需要重置（跨日检测）
        checkDailyReset()

        // 加载今日计数和总循环数
        todayCount = UserDefaults.standard.integer(forKey: todayKey)
        totalCycles = UserDefaults.standard.integer(forKey: totalCyclesKey)
    }

    /// 保存计数
    private func saveCount() {
        let totalCyclesKey = "TotalCycles_\(selectedType.rawValue)"
        let todayKey = "TodayCount_\(selectedType.rawValue)"

        // 保存到本地 UserDefaults（不同步到 iCloud）
        UserDefaults.standard.set(todayCount, forKey: todayKey)
        UserDefaults.standard.set(totalCycles, forKey: totalCyclesKey)

        // 更新保存时间（用于UI显示）
        lastCountSaveTime = Date()
    }

    /// 保存每日重置日期
    private func saveDailyResetDate() {
        let key = "LastResetDate_\(selectedType.rawValue)"
        if let date = lastResetDate {
            UserDefaults.standard.set(date.timeIntervalSince1970, forKey: key)
        }
    }

    /// 加载每日重置日期
    private func loadDailyResetDate() {
        let key = "LastResetDate_\(selectedType.rawValue)"
        let timestamp = UserDefaults.standard.double(forKey: key)
        if timestamp > 0 {
            lastResetDate = Date(timeIntervalSince1970: timestamp)
        }
    }

    /// 加载转经速度
    private func loadRotationSpeed() {
        let key = "RotationSpeed"
        let speed = UserDefaults.standard.double(forKey: key)
        rotationSpeed = speed > 0 ? speed : 30
    }

    /// 保存转经速度
    private func saveRotationSpeed() {
        let key = "RotationSpeed"
        // 仅保存到本地 UserDefaults（不同步到 iCloud）
        UserDefaults.standard.set(rotationSpeed, forKey: key)
    }

    /// 设置转经速度
    func setRotationSpeed(_ speed: Double) {
        rotationSpeed = max(6, min(600, speed))  // 限制在6-600范围内
    }

    /// 获取所有类型的今日计数
    func getAllCounts() -> [PrayerType: Int] {
        var counts: [PrayerType: Int] = [:]
        for type in PrayerType.allCases {
            let key = "TodayCount_\(type.rawValue)"
            counts[type] = UserDefaults.standard.integer(forKey: key)
        }
        return counts
    }

    /// 获取今日总计数
    var totalCount: Int {
        let allCounts = getAllCounts()
        return allCounts.values.reduce(0, +)
    }

}