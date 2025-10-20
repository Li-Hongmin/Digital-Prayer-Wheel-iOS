//
//  DailyChartView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 每日转经趋势图表
struct DailyChartView: View {
    @ObservedObject var statistics: PrayerStatistics
    let prayerType: String
    @Environment(\.responsiveScale) var responsiveScale

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()
        let recentRecords = statistics.getRecentRecords(days: 7, type: prayerType)

        VStack(alignment: .leading, spacing: scale.size(12)) {
            Text("最近7天趋势")
                .font(.system(size: scale.fontSize(16), weight: .bold))
                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))

            if recentRecords.isEmpty {
                // 空状态
                VStack(spacing: scale.size(8)) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: scale.fontSize(40)))
                        .foregroundColor(Color.white.opacity(0.3))
                    Text("暂无数据")
                        .font(.system(size: scale.fontSize(14)))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, scale.size(24))
            } else {
                // 图表
                BarChartView(records: recentRecords, scale: scale)
            }
        }
        .padding(scale.size(12))
        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        .cornerRadius(scale.size(12))
    }
}

/// 柱状图视图
struct BarChartView: View {
    let records: [DailyPrayerRecord]
    let scale: ResponsiveScale

    var body: some View {
        let maxCount = records.map { $0.totalCycles }.max() ?? 1

        HStack(alignment: .bottom, spacing: scale.size(4)) {
            ForEach(getLast7Days(), id: \.self) { date in
                VStack(spacing: scale.size(4)) {
                    // 柱子
                    let count = getCount(for: date)
                    let height = count > 0 ? CGFloat(count) / CGFloat(maxCount) * scale.size(80) : scale.size(2)

                    Rectangle()
                        .fill(
                            count > 0 ?
                                Color(red: 0.99, green: 0.84, blue: 0.15) :
                                Color.white.opacity(0.1)
                        )
                        .frame(height: max(scale.size(2), height))
                        .cornerRadius(scale.size(3))

                    // 日期标签
                    Text(dayString(date))
                        .font(.system(size: scale.fontSize(10), weight: .medium))
                        .foregroundColor(
                            Calendar.current.isDateInToday(date) ?
                                Color(red: 0.99, green: 0.84, blue: 0.15) :
                                Color.white.opacity(0.6)
                        )
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: scale.size(120))
    }

    private func getLast7Days() -> [Date] {
        let today = Calendar.current.startOfDay(for: Date())
        return (0..<7).compactMap { day in
            Calendar.current.date(byAdding: .day, value: -day, to: today)
        }.reversed()
    }

    private func getCount(for date: Date) -> Int {
        return records.first { record in
            Calendar.current.isDate(record.date, inSameDayAs: date)
        }?.totalCycles ?? 0
    }

    private func dayString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

#Preview {
    let stats = PrayerStatistics()

    // 添加示例数据
    for i in 0..<7 {
        if Calendar.current.date(byAdding: .day, value: -i, to: Date()) != nil {
            stats.updateTodayCount(
                for: "南无阿弥陀佛",
                countExponent: 8 + i,
                totalCycles: 100 * (i + 1)
            )
        }
    }

    return ZStack {
        Color(red: 0.12, green: 0.12, blue: 0.14)
        DailyChartView(
            statistics: stats,
            prayerType: "南无阿弥陀佛"
        )
        .padding()
    }
}
