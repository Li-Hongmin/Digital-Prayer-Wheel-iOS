//
//  iOSLandscapePrayerWheelView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI
import Combine

/// iOS 横屏祈祷轮视图（三栏布局：左侧十大愿 + 中间转经筒 + 右侧计数/净业正因）
struct iOSLandscapePrayerWheelView: View {
    @ObservedObject var prayerLibrary: PrayerLibrary
    @ObservedObject var settings: AppSettings
    @Binding var showSettings: Bool
    @Environment(\.responsiveScale) var responsiveScale

    @StateObject var tabletLibrary = TabletLibrary()
    @State private var showHelp: Bool = false
    @State private var showLeftTablet: Bool = false
    @State private var showRightTablet: Bool = false
    @State private var showCalendar: Bool = false
    @State private var rotation: Double = 0
    @State private var rotationTimer: Timer?
    @State private var isRotating: Bool = false
    @State private var localRotationSpeed: Double = 30
    @State private var lastCompletedRotations: Double = 0
    @State private var countScale: CGFloat = 1.0
    @State private var wheelTapScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.6

    private var timePerRotation: Double {
        60.0 / localRotationSpeed
    }

    private var anglePerFrame: Double {
        360.0 / (timePerRotation * 30.0)
    }

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()

        VStack(spacing: 0) {
            // 最顶部：功课名居中，按钮在右侧
            ZStack {
                // 经文名（居中层）- 使用原生动画替代高频Timer
                Text(prayerLibrary.selectedType.rawValue)
                    .font(.system(size: scale.fontSize(22), weight: .bold))
                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                    .shadow(
                        color: Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.8 * glowOpacity),
                        radius: scale.size(12),
                        x: 0,
                        y: 0
                    )
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
                // 主内容区：左侧十大愿 + 中间转经筒和计数 + 右侧净业正因
                HStack(spacing: scale.size(16)) {
                // 左侧：普贤十大愿（两列显示，横屏自动展开）
                VStack {
                    SamanthabhadraVowsTwoColumnView(initiallyExpanded: true)

                    Spacer()
                }
                .frame(maxWidth: scale.size(260))

                // 中间：转经筒和计数（纵向布局，左右添加牌位）
                VStack(spacing: scale.size(8)) {

                    // 转经筒主体 + 牌位图标（横向排列）
                    HStack(spacing: scale.size(12)) {
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

                        Text("卍")
                            .font(.system(size: scale.fontSize(100), weight: .bold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(rotation))  // 使用2D旋转，性能更好
                        }
                        .frame(height: scale.size(180))
                        .scaleEffect(wheelTapScale)
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
                    let (numberStr, unitStr) = prayerLibrary.formatCountWithChineseUnitsSeparated(prayerLibrary.currentCount)

                    HStack(spacing: scale.size(16)) {
                        // 左侧：今日总转数（左对齐，可点击查看日历）
                        VStack(alignment: .leading, spacing: scale.size(4)) {
                            HStack(spacing: scale.size(4)) {
                                Text("今日总转数")
                                    .font(.system(size: scale.fontSize(12), weight: .semibold))
                                    .foregroundColor(Color.white.opacity(0.7))
                                Image(systemName: "calendar")
                                    .font(.system(size: scale.fontSize(10)))
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.6))
                            }
                            Text("\(prayerLibrary.todayCycles)")
                                .font(.system(size: scale.fontSize(24), weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showCalendar = true
                            }
                        }

                        // 右侧：指数级转经数（右对齐）
                        VStack(alignment: .trailing, spacing: scale.size(4)) {
                            Text("指数级转经数")
                                .font(.system(size: scale.fontSize(12), weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.7))

                            HStack(spacing: 0) {
                                Text(numberStr)
                                    .font(.system(size: scale.fontSize(22), weight: .bold, design: .monospaced))
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                    .lineLimit(1)
                                    .scaleEffect(countScale)

                                VStack(spacing: 0) {
                                    Text(unitStr)
                                        .font(.system(size: scale.fontSize(14), weight: .bold))
                                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                        .lineLimit(1)
                                        .truncationMode(.tail)

                                    Text("次")
                                        .font(.system(size: scale.fontSize(10), weight: .semibold))
                                        .foregroundColor(Color.white.opacity(0.7))
                                }
                                .frame(minWidth: scale.size(70), alignment: .center)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal, scale.size(12))
                    .padding(.vertical, scale.size(12))

                    Spacer()
                }

                // 右侧：净业正因（横屏自动展开）
                VStack {
                    PureKarmaView(initiallyExpanded: true)

                    Spacer()
                }
                .frame(maxWidth: scale.size(240))
                }
                .padding(.horizontal, scale.size(12))
                .padding(.vertical, scale.size(8))

                // 回向偈 - 最下方（横屏）
                DedicationVerseView(settings: settings)
                    .padding(.horizontal, scale.size(16))
                    .padding(.bottom, scale.size(8))
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
        .onChange(of: prayerLibrary.countExponent) { _, _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                countScale = 1.2
            }
            withAnimation(.easeInOut(duration: 0.2).delay(0.1)) {
                countScale = 1.0
            }
        }
        .onChange(of: prayerLibrary.rotationSpeed) { _, newSpeed in
            localRotationSpeed = newSpeed
            if isRotating {
                stopRotation()
                startRotation()
            }
        }
        .onAppear {
            localRotationSpeed = prayerLibrary.rotationSpeed

            // 启动标题发光循环动画（使用原生动画引擎，无需Timer）
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowOpacity = 1.0
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
}

#Preview {
    @Previewable @State var showSettings = false
    return iOSLandscapePrayerWheelView(
        prayerLibrary: PrayerLibrary(),
        settings: AppSettings(),
        showSettings: $showSettings
    )
}
