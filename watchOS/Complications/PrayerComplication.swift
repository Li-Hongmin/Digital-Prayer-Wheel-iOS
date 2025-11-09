//
//  PrayerComplication.swift
//  Digital Prayer Wheel Watch App
//
//  Created by Claude on 2025/11/09.
//  表盘复杂功能 - Watch Face Complications
//

import WidgetKit
import SwiftUI

// MARK: - Complication Provider

struct PrayerComplicationProvider: TimelineProvider {
    typealias Entry = PrayerComplicationEntry

    // Placeholder for when no data is available
    func placeholder(in context: Context) -> PrayerComplicationEntry {
        PrayerComplicationEntry(
            date: Date(),
            todayCount: 108,
            totalCount: 10800,
            prayerType: "南无阿弥陀佛"
        )
    }

    // Snapshot for quick preview
    func getSnapshot(in context: Context, completion: @escaping (PrayerComplicationEntry) -> Void) {
        let entry = PrayerComplicationEntry(
            date: Date(),
            todayCount: loadTodayCount(),
            totalCount: loadTotalCount(),
            prayerType: loadPrayerType()
        )
        completion(entry)
    }

    // Timeline generation
    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerComplicationEntry>) -> Void) {
        var entries: [PrayerComplicationEntry] = []

        // Current entry
        let currentDate = Date()
        let entry = PrayerComplicationEntry(
            date: currentDate,
            todayCount: loadTodayCount(),
            totalCount: loadTotalCount(),
            prayerType: loadPrayerType()
        )
        entries.append(entry)

        // Future entries (update every hour)
        for hourOffset in 1..<24 {
            let futureDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let futureEntry = PrayerComplicationEntry(
                date: futureDate,
                todayCount: loadTodayCount(),
                totalCount: loadTotalCount(),
                prayerType: loadPrayerType()
            )
            entries.append(futureEntry)
        }

        // Timeline with hourly updates
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    // MARK: - Helper methods

    private func loadTodayCount() -> Int {
        // Load from UserDefaults (shared with main app)
        let type = loadPrayerType()
        let key = "TodayCount_\(type)"
        return UserDefaults.standard.integer(forKey: key)
    }

    private func loadTotalCount() -> Int {
        let type = loadPrayerType()
        let key = "TotalCycles_\(type)"
        return UserDefaults.standard.integer(forKey: key)
    }

    private func loadPrayerType() -> String {
        return UserDefaults.standard.string(forKey: "selectedPrayerType") ?? "南无阿弥陀佛"
    }
}

// MARK: - Complication Entry

struct PrayerComplicationEntry: TimelineEntry {
    let date: Date
    let todayCount: Int
    let totalCount: Int
    let prayerType: String
}

// MARK: - Complication Views

@main
struct PrayerComplicationBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        PrayerComplication()
    }
}

struct PrayerComplication: Widget {
    let kind: String = "PrayerComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerComplicationProvider()) { entry in
            PrayerComplicationView(entry: entry)
        }
        .configurationDisplayName("转经轮计数")
        .description("显示今日转经圈数")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner
        ])
    }
}

// MARK: - Complication UI

struct PrayerComplicationView: View {
    let entry: PrayerComplicationEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularComplicationView(entry: entry)

        case .accessoryRectangular:
            RectangularComplicationView(entry: entry)

        case .accessoryInline:
            InlineComplicationView(entry: entry)

        case .accessoryCorner:
            CornerComplicationView(entry: entry)

        default:
            Text("\(entry.todayCount)")
        }
    }
}

// MARK: - Circular Complication (Small round widget)

struct CircularComplicationView: View {
    let entry: PrayerComplicationEntry

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.yellow.opacity(0.3), .orange.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 2) {
                // Prayer wheel icon
                Text("🙏")
                    .font(.system(size: 16))

                // Today's count
                Text("\(entry.todayCount)")
                    .font(.system(size: 14, weight: .bold))
                    .minimumScaleFactor(0.5)
            }
        }
    }
}

// MARK: - Rectangular Complication (Wide widget)

struct RectangularComplicationView: View {
    let entry: PrayerComplicationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
            HStack {
                Text("🙏")
                Text(shortPrayerName)
                    .font(.system(size: 12, weight: .medium))
                Spacer()
            }

            // Stats
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("今日")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text("\(entry.todayCount)")
                        .font(.system(size: 14, weight: .bold))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("总计")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text(formatCount(entry.totalCount))
                        .font(.system(size: 12, weight: .semibold))
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
    }

    private var shortPrayerName: String {
        switch entry.prayerType {
        case "南无阿弥陀佛": return "阿弥陀佛"
        case "南无观世音菩萨": return "观音菩萨"
        case "六字大明咒": return "大明咒"
        case "般若波罗蜜多心经": return "心经"
        default: return "转经"
        }
    }
}

// MARK: - Inline Complication (Text only)

struct InlineComplicationView: View {
    let entry: PrayerComplicationEntry

    var body: some View {
        HStack(spacing: 4) {
            Text("🙏")
            Text("\(entry.todayCount)")
                .font(.system(size: 14, weight: .semibold))
        }
    }
}

// MARK: - Corner Complication (Corner arc widget)

struct CornerComplicationView: View {
    let entry: PrayerComplicationEntry

    var body: some View {
        ZStack {
            // Gauge background
            Gauge(value: Double(entry.todayCount), in: 0...1080) {
                // Empty label
            } currentValueLabel: {
                Text("\(entry.todayCount)")
                    .font(.system(size: 18, weight: .bold))
            }
            .gaugeStyle(.accessoryCircular)
        }
    }
}

// MARK: - Helper Functions

private func formatCount(_ count: Int) -> String {
    if count < 10000 {
        return "\(count)"
    } else if count < 100000000 {
        let wan = Double(count) / 10000.0
        return String(format: "%.1f万", wan)
    } else {
        let yi = Double(count) / 100000000.0
        return String(format: "%.1f亿", yi)
    }
}

// MARK: - Preview

#Preview("Circular", as: .accessoryCircular) {
    PrayerComplication()
} timeline: {
    PrayerComplicationEntry(date: .now, todayCount: 108, totalCount: 10800, prayerType: "南无阿弥陀佛")
}

#Preview("Rectangular", as: .accessoryRectangular) {
    PrayerComplication()
} timeline: {
    PrayerComplicationEntry(date: .now, todayCount: 108, totalCount: 10800, prayerType: "南无阿弥陀佛")
}
