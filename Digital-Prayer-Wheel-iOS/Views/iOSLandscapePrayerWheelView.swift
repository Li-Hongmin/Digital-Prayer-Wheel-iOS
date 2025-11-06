//
//  iOSLandscapePrayerWheelView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI
import Combine

/// iOS landscape prayer wheel view
struct iOSLandscapePrayerWheelView: View {
    @ObservedObject var prayerLibrary: PrayerLibrary
    @ObservedObject var settings: AppSettings
    @Binding var showSettings: Bool
    @Environment(\.responsiveScale) var responsiveScale

    @StateObject var tabletLibrary = TabletLibrary()
    @ObservedObject private var loadingManager = WheelLoadingManager.shared
    @State private var showHelp: Bool = false
    @State private var showLeftTablet: Bool = false
    @State private var showRightTablet: Bool = false
    @State private var showCalendar: Bool = false
    @State private var rotation: Double = 0
    @State private var rotationTimer: Timer?
    @State private var isRotating: Bool = false
    @State private var localRotationSpeed: Double = 30
    @State private var lastCompletedRotations: Double = 0
    @State private var wheelTapScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.6
    @State private var showLoadingCompleteBanner: Bool = false
    @State private var loadingCompleteScale: CGFloat = 1.0

    private var timePerRotation: Double {
        60.0 / localRotationSpeed
    }

    private var anglePerFrame: Double {
        360.0 / (timePerRotation * 30.0)
    }

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()

        VStack(spacing: scale.size(8)) {
            // 装载完成横幅
            if showLoadingCompleteBanner, let data = loadingManager.loadedData {
                HStack(spacing: scale.size(8)) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: scale.fontSize(16)))
                        .foregroundColor(.green)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("装载完成！")
                            .font(.system(size: scale.fontSize(13), weight: .bold))
                            .foregroundColor(.white)

                        Text("轮内已装载 \(formatCount(data.repeatCount)) 遍")
                            .font(.system(size: scale.fontSize(11)))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()
                }
                .padding(.horizontal, scale.size(12))
                .padding(.vertical, scale.size(8))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.8))
                )
                .padding(.horizontal, scale.size(16))
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // 最顶部：功课名居中，按钮在右侧
            ZStack {
                // 经文名 + 装载信息（居中层）
                VStack(spacing: scale.size(4)) {
                    Text(prayerLibrary.selectedType.rawValue)
                        .font(.system(size: scale.fontSize(22), weight: .bold))
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                        .shadow(
                            color: Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.8 * glowOpacity),
                            radius: scale.size(12),
                            x: 0,
                            y: 0
                        )

                    // 装载信息
                    if loadingManager.isLoaded, let data = loadingManager.loadedData {
                        HStack(spacing: scale.size(4)) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: scale.fontSize(10)))
                            Text("轮内：\(formatCount(data.repeatCount)) 遍")
                        }
                        .font(.system(size: scale.fontSize(10), weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    }
                }
                .frame(maxWidth: .infinity)

                // 帮助和设置按钮（右上角层）
                HStack {
                    Spacer()
                    Button(action: { showHelp.toggle() }) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: scale.fontSize(16)))
                    }
                    // TODO: 分享功能暂时隐藏，待完善后启用
                    // Button(action: { startVideoRecording() }) {
                    //     Image(systemName: videoRecorder.isRecording ? "record.circle.fill" : "video.circle")
                    //         .font(.system(size: scale.fontSize(16)))
                    //         .foregroundColor(videoRecorder.isRecording ? .red : Color(red: 0.99, green: 0.84, blue: 0.15))
                    // }
                    // .disabled(videoRecorder.isRecording)
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gear")
                            .font(.system(size: scale.fontSize(16)))
                    }
                }
            }
            .padding(.horizontal, scale.size(16))
            .padding(.top, scale.size(8))

            // 可滚动内容区域
            ScrollView {
                VStack(spacing: scale.size(8)) {
                    // 转经筒主体 + 牌位图标
                    HStack(spacing: scale.size(16)) {
                        // 左侧牌位图标（吉祥牌位-红底金边黑字）
                        MemorialTabletIconView(
                            title: "吉祥牌位",
                            backgroundColor: Color(red: 0.90, green: 0.11, blue: 0.14), // 红底
                            borderColor: Color(red: 0.99, green: 0.84, blue: 0.15),     // 金边
                            textColor: Color.black                                       // 黑字
                        ) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showLeftTablet.toggle()
                                if showLeftTablet {
                                    showRightTablet = false
                                }
                            }
                        }

                        // 转经筒
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
                                    lineWidth: scale.size(3)
                                )
                                .frame(width: scale.size(160), height: scale.size(160))

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
                                .frame(width: scale.size(150), height: scale.size(150))

                            Circle()
                                .stroke(Color(red: 0.99, green: 0.84, blue: 0.15), lineWidth: scale.size(2))
                                .frame(width: scale.size(140), height: scale.size(140))

                            ZStack(alignment: .center) {
                                Text("卍")
                                    .font(.system(size: scale.fontSize(100), weight: .bold))
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(rotation))
                                    .offset(y: scale.size(-2))  // Slight upward offset to center visually

                                // Display loaded count in center (small text at bottom)
                                if loadingManager.isLoaded, let data = loadingManager.loadedData {
                                    VStack {
                                        Spacer()
                                        Text(formatCountShort(data.repeatCount))
                                            .font(.system(size: scale.fontSize(10), weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                            .padding(.bottom, scale.size(10))
                                    }
                                    .frame(width: scale.size(140), height: scale.size(140))
                                }
                            }
                        }
                        .frame(height: scale.size(180))
                        .scaleEffect(wheelTapScale * loadingCompleteScale)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                wheelTapScale = 0.95
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    wheelTapScale = 1.0
                                }
                            }
                            if isRotating {
                                stopRotation()
                            } else {
                                startRotation()
                            }
                        }

                        // 右侧牌位图标（往生牌位-金底金边黑字）
                        MemorialTabletIconView(
                            title: "往生牌位",
                            backgroundColor: Color(red: 1.0, green: 0.84, blue: 0.0), // 金底
                            borderColor: Color(red: 0.99, green: 0.84, blue: 0.15),   // 金边
                            textColor: Color.black                                     // 黑字
                        ) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showRightTablet.toggle()
                                if showRightTablet {
                                    showLeftTablet = false
                                }
                            }
                        }
                    }

                    // 计数显示 - 左右分布
                    let multiplier = loadingManager.multiplier
                    let todayMerit = prayerLibrary.todayCount * multiplier

                    // 计算累计转经天数（有记录的天数）
                    let totalDays = Set(prayerLibrary.statistics.dailyRecords.map {
                        Calendar.current.startOfDay(for: $0.date)
                    }).count

                    HStack(spacing: scale.size(16)) {
                        // 左侧：今日功德（左对齐，可点击查看日历）
                        VStack(alignment: .leading, spacing: scale.size(4)) {
                            HStack(spacing: scale.size(4)) {
                                Text("今日功德")
                                    .font(.system(size: scale.fontSize(12), weight: .semibold))
                                    .foregroundColor(Color.white.opacity(0.7))
                                Image(systemName: "calendar")
                                    .font(.system(size: scale.fontSize(10)))
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.6))
                            }

                            VStack(alignment: .leading, spacing: scale.size(2)) {
                                Text("\(formatCount(todayMerit))")
                                    .font(.system(size: scale.fontSize(24), weight: .bold, design: .monospaced))
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))

                                // Always display physical rotation count (small text)
                                Text("(\(prayerLibrary.todayCount) 圈)")
                                    .font(.system(size: scale.fontSize(9), weight: .regular))
                                    .foregroundColor(Color.white.opacity(multiplier > 1 ? 0.5 : 0.0))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showCalendar = true
                            }
                        }

                        // 右侧：累计天数（右对齐）
                        VStack(alignment: .trailing, spacing: scale.size(4)) {
                            Text("累计天数")
                                .font(.system(size: scale.fontSize(12), weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.7))

                            VStack(alignment: .trailing, spacing: scale.size(2)) {
                                HStack(spacing: scale.size(4)) {
                                    Text("\(totalDays)")
                                        .font(.system(size: scale.fontSize(28), weight: .bold, design: .monospaced))
                                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))

                                    Text("天")
                                        .font(.system(size: scale.fontSize(16), weight: .semibold))
                                        .foregroundColor(Color.white.opacity(0.7))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal, scale.size(12))
                    .padding(.vertical, scale.size(12))

                    // 佛学教导 - 下方（普贤十大愿 + 往生正因，竖屏自动展开）
                    BuddhistTeachingsView(initiallyExpanded: true)
                        .padding(.horizontal, scale.size(16))
                        .padding(.vertical, scale.size(8))

                    // 回向偈 - 最下方
                    DedicationVerseView(settings: settings)
                        .padding(.horizontal, scale.size(16))
                        .padding(.bottom, scale.size(8))
                }
            }
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
        .overlay(
            Group {
                // 牌位覆盖层（录制时不显示进度UI，保持画面干净）
                if showLeftTablet || showRightTablet {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showLeftTablet = false
                                showRightTablet = false
                            }
                        }

                    MemorialTabletCardView(
                        tabletLibrary: tabletLibrary,
                        isPresented: showLeftTablet ? $showLeftTablet : $showRightTablet,
                        category: showLeftTablet ? "吉祥牌位" : "往生牌位"
                    )
                    .frame(maxWidth: scale.size(360), maxHeight: scale.size(500))
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                }

                // 日历统计覆盖层
                if showCalendar {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showCalendar = false
                            }
                        }

                    CalendarStatsView(
                        statistics: prayerLibrary.statistics,
                        prayerLibrary: prayerLibrary,
                        isPresented: $showCalendar
                    )
                    .frame(maxWidth: scale.size(450), maxHeight: scale.size(650))
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
        )
        .onChange(of: prayerLibrary.rotationSpeed) { _, newSpeed in
            localRotationSpeed = newSpeed
            if isRotating {
                stopRotation()
                startRotation()
            }
        }
        .onAppear {
            localRotationSpeed = prayerLibrary.rotationSpeed

            // Debug: Print loading status
            print("🔍 主界面加载")
            print("   - loadingManager.isLoaded: \(loadingManager.isLoaded)")
            print("   - loadingManager.loadedData: \(loadingManager.loadedData?.prayerType ?? "nil")")
            if let data = loadingManager.loadedData {
                print("   - 装载数量: \(data.repeatCount)")
            }

            // 启动标题发光循环动画（使用原生动画引擎，无需Timer）
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowOpacity = 1.0
            }

            // 监听装载完成通知
            NotificationCenter.default.addObserver(
                forName: .wheelLoadingComplete,
                object: nil,
                queue: .main
            ) { _ in
                showLoadingCompleteAnimation()
            }

            // 延迟 0.3 秒后启动转经，避免启动时黑屏
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                startRotation()
            }
        }
        .onDisappear {
            stopRotation()
            prayerLibrary.finalizeCount()  // 保存未保存的计数
        }
        .sheet(isPresented: $showHelp) {
            iOSHelpView()
        }
        .sheet(isPresented: $showSettings) {
            iOSSettingsView(
                settings: settings,  // 使用传入的共享实例，避免重复创建
                prayerLibrary: prayerLibrary
            )
        }
    }

    private func startRotation() {
        guard rotationTimer == nil else { return }

        isRotating = true
        lastCompletedRotations = 0
        rotation = 0

        rotationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { _ in
            rotation += anglePerFrame

            // 防止rotation无限增长，每转一圈重置
            // 这样可以避免浮点数精度问题和内存浪费
            if rotation >= 360.0 {
                rotation -= 360.0

                DispatchQueue.main.async {
                    self.prayerLibrary.incrementCount()
                }
            }
        }
    }

    private func stopRotation() {
        rotationTimer?.invalidate()
        rotationTimer = nil
        isRotating = false
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 100000000 {
            return "\(count / 100000000) 亿"
        } else if count >= 10000 {
            return "\(count / 10000) 万"
        } else {
            return "\(count)"
        }
    }

    private func formatCountShort(_ count: Int) -> String {
        if count >= 100000000 {
            return "\(count / 100000000)亿"
        } else if count >= 10000 {
            return "\(count / 10000)万"
        } else {
            return "\(count)"
        }
    }

    private func showLoadingCompleteAnimation() {
        // Show banner
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            showLoadingCompleteBanner = true
        }

        // Prayer wheel scale animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            loadingCompleteScale = 1.2
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.2)) {
            loadingCompleteScale = 1.0
        }

        // Hide banner after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                showLoadingCompleteBanner = false
            }
        }
    }
}

#Preview {
    @Previewable @State var showSettings = false
    return iOSLandscapePrayerWheelView(
        prayerLibrary: PrayerLibrary(),
        settings: AppSettings(),
        showSettings: $showSettings
    )
}
