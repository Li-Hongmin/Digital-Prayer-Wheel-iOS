//
//  iOSContentView.swift
//  Digital-Prayer-Wheel
//
//  iOS app entry point and main content view
//

import SwiftUI

struct iOSContentView: View {
    @StateObject private var settings = AppSettings()
    @StateObject private var prayerLibrary = PrayerLibrary()
    @State private var showSettings: Bool = false
    @State private var isLoading: Bool = true  // 加载状态

    var body: some View {
        GeometryReader { geometry in
            let scale = ResponsiveScale(geometry: geometry)

            ZStack {
                Color(red: 0.12, green: 0.12, blue: 0.14)
                    .ignoresSafeArea()

                if !isLoading {
                    // 主内容视图
                    VStack {
                        // 根据屏幕宽高比选择布局（iPhone 和 iPad 通用）
                        if geometry.size.width > geometry.size.height {
                            // 横屏：三栏布局（左侧十大愿 + 中间转经筒 + 右侧净业正因）
                            iOSLandscapePrayerWheelView(
                                prayerLibrary: prayerLibrary,
                                settings: settings,
                                showSettings: $showSettings
                            )
                        } else {
                            // 竖屏：纵向布局（上方转经筒 + 下方教导内容）
                            iOSPrayerWheelView(
                                prayerLibrary: prayerLibrary,
                                settings: settings,
                                showSettings: $showSettings
                            )
                        }
                    }
                    .environment(\.responsiveScale, scale)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    // 加载指示器视图
                    LoadingView()
                        .transition(.opacity)
                }
            }
            .sheet(isPresented: $showSettings) {
                iOSSettingsView(
                    settings: settings,
                    prayerLibrary: prayerLibrary
                )
            }
            .onAppear {
                initializeServices()

                // 延迟结束加载状态，确保UI流畅过渡
                Task {
                    try? await Task.sleep(nanoseconds: 300_000_000)  // 0.3秒
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isLoading = false
                        }
                    }
                }
            }
            .onDisappear {
                settings.finalizeSave()  // 确保退出时保存所有设置
            }
        }
    }

    private func initializeServices() {
        // 从AppSettings加载经文选择
        if let prayerType = PrayerType(rawValue: settings.selectedPrayerType) {
            prayerLibrary.setType(prayerType)
        }
    }
}

/// 启动加载视图
struct LoadingView: View {
    @State private var rotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 24) {
            // 转经筒图标（旋转动画）
            ZStack {
                // 外圈金色光晕
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.3),
                                Color(red: 0.96, green: 0.78, blue: 0.10).opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulseScale)

                // 中心卍字符（旋转）
                Text("卍")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                    .rotationEffect(.degrees(rotation))
            }
            .onAppear {
                // 持续旋转动画
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    rotation = 360
                }

                // 脉冲动画
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulseScale = 1.2
                }
            }

            // 加载文字
            VStack(spacing: 8) {
                Text("启动中...")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))

                Text("正在加载转经数据")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

#Preview("Content View") {
    iOSContentView()
}

#Preview("Loading View") {
    ZStack {
        Color(red: 0.12, green: 0.12, blue: 0.14)
            .ignoresSafeArea()
        LoadingView()
    }
}
