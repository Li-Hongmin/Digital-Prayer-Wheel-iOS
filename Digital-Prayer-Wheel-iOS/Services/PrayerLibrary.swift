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
    // 当前选择的经文类型
    @Published var selectedType: PrayerType = .amitabha {
        didSet {
            loadTextsForCurrentType()
            loadCount()
        }
    }

    // 当前计数的指数（存储形式：2^countExponent）
    // 这样只需存储一个整数，节省空间，精度无损
    @Published var countExponent: Int = 0

    // 总体转经数（总共转过多少次）
    // 每调用一次 incrementCount() 就 +1
    // 用于追踪用户长期的总转经数
    @Published var totalCycles: Int = 0

    // 当前计数的缓存值（避免重复计算）
    private var cachedCount: Decimal?
    private var cachedExponent: Int = -1

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
        loadCount()
        loadRotationSpeed()
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
    /// 这是一种指数增长方式，创造"加速度"的修行体验
    /// 2^0 → 2^1 → 2^2 → 2^3 → 2^4 ...
    /// 存储形式：只存储指数，节省空间
    /// 每次调用都增加总转数 totalCycles
    /// 上限：当 2^n 超过 1000×10^68 时自动重置为 0
    func incrementCount() {
        countExponent += 1
        totalCycles += 1  // 每转一次都增加总转数

        // 检查是否超过上限（2^236 ≈ 1.2×10^71，超过 1000×10^68）
        // 当达到上限时，重置 countExponent 为 0 重新开始，但 totalCycles 继续累加
        if countExponent > 235 {
            countExponent = 0
        }

        saveCount()
        cachedCount = nil  // 清除缓存，强制重新计算
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

        // 加载总体循环数
        totalCycles = UserDefaults.standard.integer(forKey: totalCyclesKey)

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
        // 保存为整数（指数形式）
        UserDefaults.standard.set(countExponent, forKey: key)
        // 保存总体循环数
        UserDefaults.standard.set(totalCycles, forKey: totalCyclesKey)
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