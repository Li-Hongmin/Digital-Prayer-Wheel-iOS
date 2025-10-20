//
//  MonthCalendarView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 月历视图
struct MonthCalendarView: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    @ObservedObject var statistics: PrayerStatistics
    let prayerType: String
    @Environment(\.responsiveScale) var responsiveScale

    private let calendar = Calendar.current
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()

        VStack(spacing: scale.size(12)) {
            // 月份选择器
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: scale.fontSize(16), weight: .semibold))
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                }

                Spacer()

                Text(monthYearString)
                    .font(.system(size: scale.fontSize(18), weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: scale.fontSize(16), weight: .semibold))
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                }
            }
            .padding(.horizontal, scale.size(8))

            // 星期标题
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: scale.fontSize(12), weight: .medium))
                        .foregroundColor(Color.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                }
            }

            // 日历网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: scale.size(8)) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            hasRecord: hasRecord(for: date),
                            scale: scale
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        // 占位空格（月初/月末的空白）
                        Color.clear
                            .frame(height: scale.size(40))
                    }
                }
            }
        }
        .padding(scale.size(12))
        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        .cornerRadius(scale.size(12))
    }

    // MARK: - 辅助方法

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: currentMonth)
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let numberOfDays = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0

        var days: [Date?] = []

        // 添加月初的空白
        for _ in 0..<(firstWeekday - 1) {
            days.append(nil)
        }

        // 添加当月的每一天
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }

        return days
    }

    private func hasRecord(for date: Date) -> Bool {
        return statistics.dailyRecords.contains { record in
            record.prayerType == prayerType &&
            calendar.isDate(record.date, inSameDayAs: date) &&
            record.totalCycles > 0
        }
    }

    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

/// 日历单元格
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasRecord: Bool
    let scale: ResponsiveScale

    var body: some View {
        VStack(spacing: scale.size(2)) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: scale.fontSize(14), weight: isToday ? .bold : .regular))
                .foregroundColor(
                    isSelected ? .black :
                    isToday ? Color(red: 0.99, green: 0.84, blue: 0.15) :
                    .white
                )

            // 记录标记点
            if hasRecord {
                Circle()
                    .fill(Color(red: 0.99, green: 0.84, blue: 0.15))
                    .frame(width: scale.size(4), height: scale.size(4))
            } else {
                Spacer()
                    .frame(height: scale.size(4))
            }
        }
        .frame(height: scale.size(40))
        .frame(maxWidth: .infinity)
        .background(
            isSelected ?
                Color(red: 0.99, green: 0.84, blue: 0.15) :
                Color.clear
        )
        .cornerRadius(scale.size(6))
        .overlay(
            isToday && !isSelected ?
                RoundedRectangle(cornerRadius: scale.size(6))
                    .stroke(Color(red: 0.99, green: 0.84, blue: 0.15), lineWidth: 2) :
                nil
        )
    }
}

#Preview {
    @Previewable @State var currentMonth = Date()
    @Previewable @State var selectedDate = Date()
    let stats = PrayerStatistics()

    return ZStack {
        Color(red: 0.12, green: 0.12, blue: 0.14)
        MonthCalendarView(
            currentMonth: $currentMonth,
            selectedDate: $selectedDate,
            statistics: stats,
            prayerType: "南无阿弥陀佛"
        )
        .padding()
    }
}
