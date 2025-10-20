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

    // 今日计数的指数（每日独立，午夜自动重置）
    @Published var todayCountExponent: Int = 0

    // 今日总循环数（今日转经次数）
    @Published var todayCycles: Int = 0

    // 上次重置日期（用于跨日检测）
    private var lastResetDate: Date?

    // 历史总计数（仅用于兼容旧版本，不再主要使用）
    @Published var countExponent: Int = 0
    @Published var totalCycles: Int = 0

    // 当前计数的缓存值（避免重复计算）
    private var cachedCount: Decimal?
    private var cachedExponent: Int = -1

    // 定时保存机制（优化：每10分钟自动保存一次）
    @Published var lastCountSaveTime: Date?  // 上次保存时间（用于UI显示）
    @Published var hasUnsavedChanges: Bool = false  // 是否有未保存的变更
    private var lastSaveTime: Date = Date()
    private let saveInterval: TimeInterval = 600  // 10分钟 = 600秒

    // 计算属性：获取当前计数的 Decimal 值用于显示
    var currentCount: Decimal {
        // 如果指数未变，直接返回缓存的值
        if cachedExponent == countExponent, let cached = cachedCount {
            return cached
        }

        // 计算 2^countExponent
        // 2^0 = 1, 2^1 = 2, 2^2 = 4, ...
        let base = NSDecimalNumber(integerLiteral: 2)
        let result = base.raising(toPower: countExponent)
        let decimal = Decimal(string: result.stringValue) ?? Decimal(1)

        // 更新缓存
        cachedCount = decimal
        cachedExponent = countExponent

        return decimal
    }

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

    /// 增加计数 - 使用复利方式（每次增加一倍 = 指数+1）
    /// 新增：每日独立计数，午夜自动重置
    /// 2^0 → 2^1 → 2^2 → 2^3 → 2^4 ...
    /// 存储形式：只存储指数，节省空间
    /// 每次调用都增加总转数 totalCycles 和今日转数 todayCycles
    /// 上限：当 2^n 超过 1000×10^68 时自动重置为 0
    /// 性能优化：定时保存，每10分钟自动保存一次，减少磁盘I/O
    func incrementCount() {
        // 检查是否需要每日重置
        checkDailyReset()

        // 增加历史总计数
        countExponent += 1
        totalCycles += 1

        // 增加今日计数
        todayCountExponent += 1
        todayCycles += 1

        // 检查是否超过上限（2^236 ≈ 1.2×10^71，超过 1000×10^68）
        if countExponent > 235 {
            countExponent = 0
        }
        if todayCountExponent > 235 {
            todayCountExponent = 0
        }

        cachedCount = nil  // 清除缓存，强制重新计算
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
            countExponent: todayCountExponent,
            totalCycles: todayCycles
        )
    }

    /// 检查是否需要每日重置
    private func checkDailyReset() {
        let today = Calendar.current.startOfDay(for: Date())

        // 如果还没有记录重置日期，或者已经过了一天
        if lastResetDate == nil || lastResetDate! < today {
            print("🌅 新的一天，重置今日计数")
            // 重置今日计数
            todayCountExponent = 0
            todayCycles = 0
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
        countExponent = 0
        cachedCount = nil  // 清除缓存
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

    /// 加载计数的指数和总体循环数
    private func loadCount() {
        let key = "PrayerCount_\(selectedType.rawValue)"
        let totalCyclesKey = "TotalCycles_\(selectedType.rawValue)"
        let todayKey = "TodayCount_\(selectedType.rawValue)"
        let todayCyclesKey = "TodayCycles_\(selectedType.rawValue)"

        // 加载总体循环数
        totalCycles = UserDefaults.standard.integer(forKey: totalCyclesKey)

        // 加载每日重置日期
        loadDailyResetDate()

        // 检查是否需要重置（跨日检测）
        checkDailyReset()

        // 加载今日计数
        todayCountExponent = UserDefaults.standard.integer(forKey: todayKey)
        todayCycles = UserDefaults.standard.integer(forKey: todayCyclesKey)

        // 首先尝试读取新格式（整数指数）
        let exponent = UserDefaults.standard.integer(forKey: key)
        if exponent > 0 {
            countExponent = exponent
            return
        }

        // 兼容旧格式：如果存储的是 Decimal 字符串，需要转换
        if let countString = UserDefaults.standard.string(forKey: key),
           !countString.isEmpty,
           let decimalValue = Decimal(string: countString),
           decimalValue > Decimal(0) {

            // 从 Decimal 计算指数：log2(value) ≈ ln(value) / ln(2)
            // 但 Decimal 没有 log，所以用近似的二分查找
            var low = 0
            var high = 256  // 2^256 已经足够大
            var bestExp = 0

            while low <= high {
                let mid = (low + high) / 2
                let base = NSDecimalNumber(integerLiteral: 2)
                let candidate = base.raising(toPower: mid)
                let candidateDecimal = Decimal(string: candidate.stringValue) ?? Decimal(0)

                if candidateDecimal == decimalValue {
                    // 精确匹配
                    countExponent = mid
                    return
                } else if candidateDecimal < decimalValue {
                    bestExp = mid
                    low = mid + 1
                } else {
                    high = mid - 1
                }
            }

            // 使用最接近的指数
            countExponent = bestExp
        } else {
            // 没有旧数据，使用默认值 0
            countExponent = 0
        }
    }

    /// 保存计数的指数和总体循环数
    private func saveCount() {
        let key = "PrayerCount_\(selectedType.rawValue)"
        let totalCyclesKey = "TotalCycles_\(selectedType.rawValue)"
        let todayKey = "TodayCount_\(selectedType.rawValue)"
        let todayCyclesKey = "TodayCycles_\(selectedType.rawValue)"

        // 保存到本地 UserDefaults（不同步到 iCloud）
        UserDefaults.standard.set(countExponent, forKey: key)
        UserDefaults.standard.set(totalCycles, forKey: totalCyclesKey)

        // 保存今日计数
        UserDefaults.standard.set(todayCountExponent, forKey: todayKey)
        UserDefaults.standard.set(todayCycles, forKey: todayCyclesKey)

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

    /// 获取所有类型的计数
    func getAllCounts() -> [PrayerType: Int] {
        var counts: [PrayerType: Int] = [:]
        for type in PrayerType.allCases {
            let key = "PrayerCount_\(type.rawValue)"
            counts[type] = UserDefaults.standard.integer(forKey: key)
        }
        return counts
    }

    /// 获取总计数
    var totalCount: Int {
        let allCounts = getAllCounts()
        return allCounts.values.reduce(0, +)
    }

    /// 格式化计数显示为分离的数字和单位
    /// 返回 (数字字符串, 单位字符串)
    /// 例：(123, 万)、(456, 亿)、(0, "")
    func formatCountWithChineseUnitsSeparated(_ count: Decimal) -> (number: String, unit: String) {
        if count == Decimal(0) {
            return ("0", "")
        }

        let absCount = abs(count)
        let doubleValue = Double(truncating: absCount as NSDecimalNumber)

        // 单位体系：(阈值, 单位名称)
        let units: [(Double, String)] = [
            (1e68, "無量數"),
            (1e64, "不可思議"),
            (1e60, "那由他"),
            (1e56, "阿僧祇"),
            (1e52, "恒河沙"),
            (1e48, "極"),
            (1e44, "載"),
            (1e40, "正"),
            (1e36, "澗"),
            (1e32, "溝"),
            (1e28, "穣"),
            (1e24, "秭"),
            (1e20, "垓"),
            (1e16, "京"),
            (1e12, "兆"),
            (1e8, "億"),
            (1e4, "万"),
        ]

        // 小于 1 万时直接显示数字，无单位
        if absCount < Decimal(10000) {
            if doubleValue == floor(doubleValue) {
                return (String(format: "%.0f", doubleValue), "")
            }
            return (count.description, "")
        }

        // 从大到小查找合适的单位
        for (threshold, unitName) in units {
            if doubleValue >= threshold {
                let value = doubleValue / threshold
                let intValue = Int(round(value))
                return (String(intValue), unitName)
            }
        }

        // 如果没有合适的单位，直接返回数字
        if doubleValue == floor(doubleValue) {
            return (String(format: "%.0f", doubleValue), "")
        }
        return (count.description, "")
    }

    /// 格式化计数显示为数字+汉字单位组合
    /// 万进制系统：万、亿、兆、京、垓、秭、穣、溝、澗、正、載、極、恒河沙、阿僧祇、那由他、不可思議、無量數
    /// 例：123万、456亿、789兆、1.2無量數
    func formatCountWithChineseUnits(_ count: Decimal) -> String {
        if count == Decimal(0) {
            return "0"
        }

        let absCount = abs(count)
        let doubleValue = Double(truncating: absCount as NSDecimalNumber)

        // 单位体系：(阈值, 单位名称)
        let units: [(Double, String)] = [
            (1e68, "無量數"),
            (1e64, "不可思議"),
            (1e60, "那由他"),
            (1e56, "阿僧祇"),
            (1e52, "恒河沙"),
            (1e48, "極"),
            (1e44, "載"),
            (1e40, "正"),
            (1e36, "澗"),
            (1e32, "溝"),
            (1e28, "穣"),
            (1e24, "秭"),
            (1e20, "垓"),
            (1e16, "京"),
            (1e12, "兆"),
            (1e8, "億"),
            (1e4, "万"),
        ]

        // 小于 1 万时直接显示数字
        if absCount < Decimal(10000) {
            if doubleValue == floor(doubleValue) {
                return String(format: "%.0f", doubleValue)
            }
            return count.description
        }

        // 从大到小查找合适的单位
        for (threshold, unitName) in units {
            if doubleValue >= threshold {
                let value = doubleValue / threshold

                // 取整数部分（舍入到最近的整数）
                let intValue = Int(round(value))

                return String(intValue) + unitName
            }
        }

        // 如果没有合适的单位，直接返回数字
        if doubleValue == floor(doubleValue) {
            return String(format: "%.0f", doubleValue)
        }
        return count.description
    }
}