//
//  PrayerWheelWidget.swift
//  Digital-Prayer-Wheel
//
//  数字转经筒小组件实现
//  Created by Claude on 2025/10/23.
//

import WidgetKit
import SwiftUI
import Intents

// MARK: - 小组件配置
struct PrayerWheelWidget: Widget {
    let kind: String = "PrayerWheelWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerWheelProvider()) { entry in
            PrayerWheelWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    // 深色背景，与应用主题一致
                    Color(red: 0.12, green: 0.12, blue: 0.14)
                }
        }
        .configurationDisplayName("数字转经筒")
        .description("随时查看今日转经功德，快速启动转经。")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled() // 去除默认边距，获得更多空间
    }
}

// MARK: - 时间轴提供者
struct PrayerWheelProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerWheelEntry {
        PrayerWheelEntry(
            date: Date(),
            todayCount: 108,
            totalCount: 10800,
            currentPrayerType: "大悲咒"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerWheelEntry) -> ()) {
        // 从 UserDefaults 读取实际数据
        let todayCount = UserDefaults(suiteName: "group.digital-prayer-wheel")?.integer(forKey: "todayCount") ?? 0
        let totalCount = UserDefaults(suiteName: "group.digital-prayer-wheel")?.integer(forKey: "totalCount") ?? 0
        let prayerType = UserDefaults(suiteName: "group.digital-prayer-wheel")?.string(forKey: "currentPrayerType") ?? "大悲咒"
        
        let entry = PrayerWheelEntry(
            date: Date(),
            todayCount: todayCount,
            totalCount: totalCount,
            currentPrayerType: prayerType
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let todayCount = UserDefaults(suiteName: "group.digital-prayer-wheel")?.integer(forKey: "todayCount") ?? 0
        let totalCount = UserDefaults(suiteName: "group.digital-prayer-wheel")?.integer(forKey: "totalCount") ?? 0
        let prayerType = UserDefaults(suiteName: "group.digital-prayer-wheel")?.string(forKey: "currentPrayerType") ?? "大悲咒"
        
        let currentDate = Date()
        let entry = PrayerWheelEntry(
            date: currentDate,
            todayCount: todayCount,
            totalCount: totalCount,
            currentPrayerType: prayerType
        )

        // 每15分钟更新一次
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))

        completion(timeline)
    }
}

// MARK: - 小组件数据模型
struct PrayerWheelEntry: TimelineEntry {
    let date: Date
    let todayCount: Int
    let totalCount: Int
    let currentPrayerType: String
    
    // 格式化计数显示
    var formattedTotalCount: (number: String, unit: String) {
        if totalCount < 10000 {
            return ("\(totalCount)", "")
        } else if totalCount < 100000000 {
            let wan = totalCount / 10000
            return ("\(wan)", "万")
        } else {
            let yi = totalCount / 100000000
            return ("\(yi)", "亿")
        }
    }
}

// MARK: - 小组件视图
struct PrayerWheelWidgetEntryView: View {
    var entry: PrayerWheelProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - 小尺寸小组件 (今日计数)
struct SmallWidgetView: View {
    let entry: PrayerWheelEntry
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.15, green: 0.15, blue: 0.17),
                    Color(red: 0.12, green: 0.12, blue: 0.14)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 8) {
                // 转经筒图标 - 带旋转动画
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.99, green: 0.84, blue: 0.15),
                                    Color(red: 0.96, green: 0.78, blue: 0.10)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 50, height: 50)
                    
                    Text("卍")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                        .rotationEffect(.degrees(rotation))
                }
                .onAppear {
                    withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
                
                // 今日计数
                VStack(spacing: 2) {
                    Text("今日转经")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(entry.todayCount)")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    Text("次")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(12)
        }
        .widgetURL(URL(string: "prayerwheel://open"))
    }
}

// MARK: - 中尺寸小组件 (转经筒 + 统计)
struct MediumWidgetView: View {
    let entry: PrayerWheelEntry
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.15, green: 0.15, blue: 0.17),
                    Color(red: 0.12, green: 0.12, blue: 0.14)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 16) {
                // 左侧：转经筒
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.90, green: 0.82, blue: 0.55),
                                        Color(red: 0.75, green: 0.63, blue: 0.35)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .stroke(Color(red: 0.99, green: 0.84, blue: 0.15), lineWidth: 2)
                            .frame(width: 55, height: 55)
                        
                        Text("卍")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(rotation))
                    }
                    .onAppear {
                        withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
                    
                    Text(entry.currentPrayerType)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                        .lineLimit(1)
                }
                
                // 右侧：统计信息
                VStack(alignment: .leading, spacing: 8) {
                    // 今日转经数
                    VStack(alignment: .leading, spacing: 2) {
                        Text("今日转经")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(entry.todayCount) 次")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                    }
                    
                    // 累计功德
                    VStack(alignment: .leading, spacing: 2) {
                        Text("累计功德")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        let (number, unit) = entry.formattedTotalCount
                        HStack(spacing: 0) {
                            Text(number)
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                            if !unit.isEmpty {
                                Text(unit + " 次")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                            } else {
                                Text(" 次")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // 启动按钮提示
                    Text("轻触启动转经")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
        }
        .widgetURL(URL(string: "prayerwheel://start"))
    }
}

// MARK: - 大尺寸小组件 (完整功德统计)
struct LargeWidgetView: View {
    let entry: PrayerWheelEntry
    @State private var rotation: Double = 0
    @State private var glowOpacity: Double = 0.6
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.15, green: 0.15, blue: 0.17),
                    Color(red: 0.12, green: 0.12, blue: 0.14)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 12) {
                // 顶部：经文名称和转经筒
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("当前功课")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(entry.currentPrayerType)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                            .shadow(
                                color: Color(red: 0.99, green: 0.84, blue: 0.15).opacity(glowOpacity),
                                radius: 8,
                                x: 0,
                                y: 0
                            )
                    }
                    
                    Spacer()
                    
                    // 转经筒
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.90, green: 0.82, blue: 0.55),
                                        Color(red: 0.75, green: 0.63, blue: 0.35)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                        
                        Circle()
                            .stroke(Color(red: 0.99, green: 0.84, blue: 0.15), lineWidth: 2)
                            .frame(width: 65, height: 65)
                        
                        Text("卍")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(rotation))
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                // 中部：功德统计
                HStack(spacing: 20) {
                    // 今日转经
                    VStack(spacing: 4) {
                        Text("今日转经")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(entry.todayCount)")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                        
                        Text("次")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 累计功德
                    VStack(spacing: 4) {
                        Text("累计功德")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        let (number, unit) = entry.formattedTotalCount
                        HStack(spacing: 0) {
                            Text(number)
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                            if !unit.isEmpty {
                                Text(unit)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                            }
                        }
                        
                        Text("次")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                // 底部：简化的修行提醒
                VStack(spacing: 4) {
                    Text("南无阿弥陀佛")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                    
                    Text("一心念佛 功德无量")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // 提示文字
                Text("轻触启动转经修行")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
        }
        .onAppear {
            // 转经筒旋转动画
            withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            // 标题发光动画
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowOpacity = 1.0
            }
        }
        .widgetURL(URL(string: "prayerwheel://start"))
    }
}

// MARK: - 预览
#Preview(as: .systemSmall) {
    PrayerWheelWidget()
} timeline: {
    PrayerWheelEntry(date: Date(), todayCount: 108, totalCount: 10800, currentPrayerType: "大悲咒")
    PrayerWheelEntry(date: Date().addingTimeInterval(3600), todayCount: 216, totalCount: 11016, currentPrayerType: "六字真言")
}

#Preview(as: .systemMedium) {
    PrayerWheelWidget()
} timeline: {
    PrayerWheelEntry(date: Date(), todayCount: 108, totalCount: 1080000, currentPrayerType: "大悲咒")
}

#Preview(as: .systemLarge) {
    PrayerWheelWidget()
} timeline: {
    PrayerWheelEntry(date: Date(), todayCount: 324, totalCount: 108000000, currentPrayerType: "阿弥陀佛圣号")
}