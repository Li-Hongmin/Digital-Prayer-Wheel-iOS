//
//  CalendarStatsView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 转经日历统计视图
struct CalendarStatsView: View {
    @ObservedObject var statistics: PrayerStatistics
    @ObservedObject var prayerLibrary: PrayerLibrary
    @Binding var isPresented: Bool
    @Environment(\.responsiveScale) var responsiveScale

    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()

        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("转经日历")
                    .font(.system(size: scale.fontSize(20), weight: .bold))
                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: scale.fontSize(24)))
                        .foregroundColor(Color.white.opacity(0.7))
                }
            }
            .padding(.horizontal, scale.size(16))
            .padding(.vertical, scale.size(12))
            .background(Color(red: 0.15, green: 0.15, blue: 0.17))

            Divider()
                .background(Color(red: 0.99, green: 0.84, blue: 0.15))

            ScrollView {
                VStack(spacing: scale.size(16)) {
                    // 连续修行天数
                    StreakBadgeView(
                        streak: statistics.calculateStreak(for: prayerLibrary.selectedType.rawValue)
                    )
                    .padding(.horizontal, scale.size(16))
                    .padding(.top, scale.size(12))

                    // 统计汇总卡片
                    StatsSummarySection(
                        statistics: statistics,
                        prayerType: prayerLibrary.selectedType.rawValue
                    )
                    .padding(.horizontal, scale.size(16))

                    // 月历
                    MonthCalendarView(
                        currentMonth: $currentMonth,
                        selectedDate: $selectedDate,
                        statistics: statistics,
                        prayerType: prayerLibrary.selectedType.rawValue
                    )
                    .padding(.horizontal, scale.size(16))

                    // 选中日期详情
                    SelectedDateDetailView(
                        date: selectedDate,
                        statistics: statistics,
                        prayerType: prayerLibrary.selectedType.rawValue
                    )
                    .padding(.horizontal, scale.size(16))

                    // 最近7天图表
                    DailyChartView(
                        statistics: statistics,
                        prayerType: prayerLibrary.selectedType.rawValue
                    )
                    .padding(.horizontal, scale.size(16))
                    .padding(.bottom, scale.size(16))
                }
            }
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
        .cornerRadius(scale.size(12))
        .overlay(
            RoundedRectangle(cornerRadius: scale.size(12))
                .stroke(Color(red: 0.99, green: 0.84, blue: 0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.5), radius: scale.size(10), x: 0, y: scale.size(4))
    }
}

/// 连续修行天数徽章
struct StreakBadgeView: View {
    let streak: Int
    @Environment(\.responsiveScale) var responsiveScale

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()

        HStack(spacing: scale.size(12)) {
            Image(systemName: "flame.fill")
                .font(.system(size: scale.fontSize(32)))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: scale.size(4)) {
                Text("连续修行")
                    .font(.system(size: scale.fontSize(14), weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))

                HStack(spacing: scale.size(4)) {
                    Text("\(streak)")
                        .font(.system(size: scale.fontSize(28), weight: .bold))
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                    Text("天")
                        .font(.system(size: scale.fontSize(16), weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.7))
                }
            }

            Spacer()
        }
        .padding(scale.size(16))
        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        .cornerRadius(scale.size(12))
    }
}

/// 统计汇总区域
struct StatsSummarySection: View {
    @ObservedObject var statistics: PrayerStatistics
    let prayerType: String
    @Environment(\.responsiveScale) var responsiveScale

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()

        VStack(spacing: scale.size(12)) {
            Text("统计汇总")
                .font(.system(size: scale.fontSize(16), weight: .bold))
                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: scale.size(12)) {
                StatCard(title: "今日", value: getTodayCount(), scale: scale)
                StatCard(title: "本周", value: statistics.getWeeklySummary(for: prayerType), scale: scale)
                StatCard(title: "本月", value: statistics.getMonthlySummary(for: prayerType), scale: scale)
                StatCard(title: "总计", value: statistics.getTotalSummary(for: prayerType), scale: scale)
            }
        }
    }

    private func getTodayCount() -> Int {
        if let todayRecord = statistics.getTodayRecord(for: prayerType) {
            return todayRecord.totalCycles
        }
        return 0
    }
}

/// 单个统计卡片
struct StatCard: View {
    let title: String
    let value: Int
    let scale: ResponsiveScale

    var body: some View {
        VStack(spacing: scale.size(6)) {
            Text(title)
                .font(.system(size: scale.fontSize(12), weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))

            Text("\(value)")
                .font(.system(size: scale.fontSize(20), weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, scale.size(12))
        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        .cornerRadius(scale.size(8))
    }
}

/// 选中日期详情
struct SelectedDateDetailView: View {
    let date: Date
    @ObservedObject var statistics: PrayerStatistics
    let prayerType: String
    @Environment(\.responsiveScale) var responsiveScale

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()
        let record = statistics.dailyRecords.first { record in
            record.prayerType == prayerType &&
            Calendar.current.isDate(record.date, inSameDayAs: date)
        }

        VStack(alignment: .leading, spacing: scale.size(8)) {
            Text("选中日期")
                .font(.system(size: scale.fontSize(14), weight: .bold))
                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))

            HStack {
                Text(formattedDate(date))
                    .font(.system(size: scale.fontSize(16), weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                if let record = record {
                    Text("\(record.totalCycles) 次")
                        .font(.system(size: scale.fontSize(18), weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                } else {
                    Text("无记录")
                        .font(.system(size: scale.fontSize(14)))
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
        }
        .padding(scale.size(12))
        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        .cornerRadius(scale.size(8))
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 E"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var isPresented = true
    let stats = PrayerStatistics()
    let library = PrayerLibrary()

    // 添加示例数据
    stats.updateTodayCount(for: "南无阿弥陀佛", countExponent: 10, totalCycles: 1024)

    return ZStack {
        Color.black.ignoresSafeArea()

        CalendarStatsView(
            statistics: stats,
            prayerLibrary: library,
            isPresented: $isPresented
        )
        .frame(maxWidth: 500, maxHeight: 700)
        .padding()
    }
}
