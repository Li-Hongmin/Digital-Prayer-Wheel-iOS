//
//  PrayerStatistics.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import Foundation
import SwiftUI
import Combine

/// 转经统计管理类
@MainActor
class PrayerStatistics: ObservableObject {
    /// 所有每日转经记录
    @Published var dailyRecords: [DailyPrayerRecord] = []

    /// UserDefaults 存储键前缀
    private let storageKeyPrefix = "PrayerRecords"

    init() {
        loadRecords()
    }

    // MARK: - 今日记录管理

    /// 获取今日记录
    func getTodayRecord(for prayerType: String) -> DailyPrayerRecord? {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyRecords.first { record in
            record.prayerType == prayerType &&
            Calendar.current.isDate(record.date, inSameDayAs: today)
        }
    }

    /// 更新今日计数
    func updateTodayCount(for prayerType: String, countExponent: Int, totalCycles: Int) {
        let today = Calendar.current.startOfDay(for: Date())

        if let index = dailyRecords.firstIndex(where: { record in
            record.prayerType == prayerType &&
            Calendar.current.isDate(record.date, inSameDayAs: today)
        }) {
            // 更新现有记录
            dailyRecords[index].countExponent = countExponent
            dailyRecords[index].totalCycles = totalCycles
        } else {
            // 创建新记录
            let newRecord = DailyPrayerRecord(
                date: today,
                prayerType: prayerType,
                countExponent: countExponent,
                totalCycles: totalCycles
            )
            dailyRecords.append(newRecord)
        }

        saveRecords()
    }

    // MARK: - 查询方法

    /// 获取指定日期范围的记录
    func getRecords(from startDate: Date, to endDate: Date, type: String) -> [DailyPrayerRecord] {
        return dailyRecords.filter { record in
            record.prayerType == type &&
            record.date >= startDate &&
            record.date <= endDate
        }.sorted { $0.date < $1.date }
    }

    /// 获取最近 N 天的记录
    func getRecentRecords(days: Int, type: String) -> [DailyPrayerRecord] {
        let today = Calendar.current.startOfDay(for: Date())
        guard let startDate = Calendar.current.date(byAdding: .day, value: -(days - 1), to: today) else {
            return []
        }
        return getRecords(from: startDate, to: today, type: type)
    }

    // MARK: - 统计计算

    /// 计算连续修行天数
    func calculateStreak(for prayerType: String) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        var streak = 0
        var currentDate = today

        while true {
            let hasRecord = dailyRecords.contains { record in
                record.prayerType == prayerType &&
                Calendar.current.isDate(record.date, inSameDayAs: currentDate) &&
                record.totalCycles > 0
            }

            if hasRecord {
                streak += 1
                guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
            } else {
                break
            }
        }

        return streak
    }

    /// 获取本周统计
    func getWeeklySummary(for prayerType: String) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        guard let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return 0
        }

        let records = getRecords(from: startOfWeek, to: today, type: prayerType)
        return records.reduce(0) { $0 + $1.totalCycles }
    }

    /// 获取本月统计
    func getMonthlySummary(for prayerType: String) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        guard let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: today)) else {
            return 0
        }

        let records = getRecords(from: startOfMonth, to: today, type: prayerType)
        return records.reduce(0) { $0 + $1.totalCycles }
    }

    /// 获取总统计
    func getTotalSummary(for prayerType: String) -> Int {
        return dailyRecords
            .filter { $0.prayerType == prayerType }
            .reduce(0) { $0 + $1.totalCycles }
    }

    /// 获取平均每日转经数（最近30天）
    func getAverageDailyCount(for prayerType: String) -> Int {
        let recent = getRecentRecords(days: 30, type: prayerType)
        guard !recent.isEmpty else { return 0 }

        let total = recent.reduce(0) { $0 + $1.totalCycles }
        return total / recent.count
    }

    /// 获取最大单日转经数
    func getMaxDailyCount(for prayerType: String) -> Int {
        return dailyRecords
            .filter { $0.prayerType == prayerType }
            .map { $0.totalCycles }
            .max() ?? 0
    }

    // MARK: - 数据持久化

    /// 保存所有记录到 UserDefaults
    private func saveRecords() {
        // 按经文类型分组保存
        let groupedRecords = Dictionary(grouping: dailyRecords) { $0.prayerType }

        for (prayerType, records) in groupedRecords {
            let key = "\(storageKeyPrefix)_\(prayerType)"

            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(records)
                UserDefaults.standard.set(data, forKey: key)
            } catch {
                print("保存转经记录失败: \(error)")
            }
        }
    }

    /// 从 UserDefaults 加载所有记录
    private func loadRecords() {
        var allRecords: [DailyPrayerRecord] = []

        // 遍历所有经文类型
        for prayerType in PrayerType.allCases {
            let key = "\(storageKeyPrefix)_\(prayerType.rawValue)"

            guard let data = UserDefaults.standard.data(forKey: key) else {
                continue
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let records = try decoder.decode([DailyPrayerRecord].self, from: data)
                allRecords.append(contentsOf: records)
            } catch {
                print("加载转经记录失败: \(error)")
            }
        }

        dailyRecords = allRecords
    }

    /// 清空所有记录（用于测试或重置）
    func clearAllRecords() {
        dailyRecords.removeAll()
        for prayerType in PrayerType.allCases {
            let key = "\(storageKeyPrefix)_\(prayerType.rawValue)"
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
