//
//  DailyPrayerRecord.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import Foundation

/// 每日转经记录
struct DailyPrayerRecord: Identifiable, Codable, Equatable {
    /// 唯一标识符
    let id: UUID

    /// 日期（只保留年月日，时分秒为0）
    var date: Date

    /// 经文类型
    var prayerType: String

    /// 当日转经次数（指数形式：2^countExponent）
    var countExponent: Int

    /// 当日总循环数（每转一次+1）
    var totalCycles: Int

    /// 初始化方法
    init(
        id: UUID = UUID(),
        date: Date,
        prayerType: String,
        countExponent: Int = 0,
        totalCycles: Int = 0
    ) {
        self.id = id
        // 确保日期只保留年月日
        self.date = Calendar.current.startOfDay(for: date)
        self.prayerType = prayerType
        self.countExponent = countExponent
        self.totalCycles = totalCycles
    }

    /// 获取当日转经次数（Decimal 值）
    var count: Decimal {
        let base = NSDecimalNumber(integerLiteral: 2)
        let result = base.raising(toPower: countExponent)
        return Decimal(string: result.stringValue) ?? Decimal(1)
    }

    /// 格式化日期显示
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    /// 简短日期显示（月-日）
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    /// 是否是今天
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}
