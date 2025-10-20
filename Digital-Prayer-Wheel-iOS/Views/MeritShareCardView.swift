//
//  MeritShareCardView.swift
//  Digital-Prayer-Wheel-iOS
//
//  Created by Claude on 2025/10/20.
//  功德分享卡片视图 - 生成精美的分享图片
//

import SwiftUI

/// 功德分享卡片视图
/// 根据设备自动适配尺寸：iPhone (1080x1920) / iPad (1200x1200)
struct MeritShareCardView: View {
    let prayerType: String
    let totalCycles: Int
    let exponentialCount: String
    let exponentialUnit: String
    let date: Date

    // 根据设备类型自动计算卡片尺寸
    private var cardSize: CGSize {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad: 正方形，适合社交媒体
            return CGSize(width: 1200, height: 1200)
        } else {
            // iPhone: 竖屏比例
            return CGSize(width: 1080, height: 1920)
        }
        #else
        return CGSize(width: 1080, height: 1920)
        #endif
    }

    private var isSquare: Bool {
        cardSize.width == cardSize.height
    }

    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.12, green: 0.12, blue: 0.14),  // 深灰
                    Color(red: 0.18, green: 0.18, blue: 0.20),  // 中灰
                    Color(red: 0.25, green: 0.22, blue: 0.20)   // 暖灰
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: isSquare ? 40 : 60) {
                Spacer()

                // 顶部标题
                VStack(spacing: 12) {
                    Text("功德分享")
                        .font(.system(size: isSquare ? 48 : 56, weight: .bold))
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))

                    Text(prayerType)
                        .font(.system(size: isSquare ? 36 : 42, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }

                // 中间转经筒图标
                ZStack {
                    // 外圈装饰
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.99, green: 0.84, blue: 0.15),
                                    Color(red: 1.0, green: 0.95, blue: 0.60)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSquare ? 15 : 20
                        )
                        .frame(width: isSquare ? 320 : 380, height: isSquare ? 320 : 380)
                        .shadow(color: Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.3), radius: 20, x: 0, y: 0)

                    // 内圈
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.95, blue: 0.60),
                                    Color(red: 0.99, green: 0.84, blue: 0.15)
                                ]),
                                startPoint: .bottomTrailing,
                                endPoint: .topLeading
                            ),
                            lineWidth: isSquare ? 12 : 15
                        )
                        .frame(width: isSquare ? 280 : 320, height: isSquare ? 280 : 320)

                    // 中心圆盘
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.35, green: 0.32, blue: 0.30),
                                    Color(red: 0.25, green: 0.22, blue: 0.20),
                                    Color(red: 0.15, green: 0.15, blue: 0.17)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: isSquare ? 140 : 160
                            )
                        )
                        .frame(width: isSquare ? 260 : 300, height: isSquare ? 260 : 300)
                        .shadow(color: Color.black.opacity(0.6), radius: 25, x: 0, y: 10)

                    // 中心卍字符
                    Text("卍")
                        .font(.system(size: isSquare ? 180 : 220, weight: .bold))
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                        .shadow(color: Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.8), radius: 30, x: 0, y: 0)
                        .shadow(color: Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.5), radius: 15, x: 0, y: 0)
                }
                .padding(.vertical, isSquare ? 30 : 50)

                // 数据展示区
                VStack(spacing: isSquare ? 30 : 40) {
                    // 总转数
                    VStack(spacing: 8) {
                        Text("总转数")
                            .font(.system(size: isSquare ? 24 : 28, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))

                        Text("\(totalCycles)")
                            .font(.system(size: isSquare ? 48 : 56, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                    }

                    // 指数级转经数
                    VStack(spacing: 8) {
                        Text("指数级转经数")
                            .font(.system(size: isSquare ? 24 : 28, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))

                        HStack(spacing: 8) {
                            Text(exponentialCount)
                                .font(.system(size: isSquare ? 48 : 56, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)

                            VStack(spacing: 4) {
                                Text(exponentialUnit)
                                    .font(.system(size: isSquare ? 28 : 32, weight: .bold))
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))

                                Text("次")
                                    .font(.system(size: isSquare ? 20 : 24, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                }
                .padding(.horizontal, 60)

                Spacer()

                // 底部日期和应用名
                VStack(spacing: 12) {
                    Text(formatDate(date))
                        .font(.system(size: isSquare ? 20 : 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))

                    Text("数字转经轮")
                        .font(.system(size: isSquare ? 18 : 22, weight: .semibold))
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.8))
                }
                .padding(.bottom, isSquare ? 40 : 60)
            }
        }
        .frame(width: cardSize.width, height: cardSize.height)
    }

    // 格式化日期
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

#Preview("iPhone 卡片") {
    MeritShareCardView(
        prayerType: "南无阿弥陀佛",
        totalCycles: 12345,
        exponentialCount: "1024",
        exponentialUnit: "万",
        date: Date()
    )
}

#Preview("iPad 卡片") {
    MeritShareCardView(
        prayerType: "六字大明咒",
        totalCycles: 98765,
        exponentialCount: "256",
        exponentialUnit: "亿",
        date: Date()
    )
}
