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

    @State private var showHelp: Bool = false
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
            // 顶部栏：只有帮助和设置按钮
            HStack {
                Spacer()

                Button(action: { showHelp.toggle() }) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: scale.fontSize(16)))
                }
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "gear")
                        .font(.system(size: scale.fontSize(16)))
                }
            }
            .padding(.horizontal, scale.size(16))
            .padding(.top, scale.size(8))

            // 主内容区：左侧十大愿 + 中间转经筒和计数 + 右侧净业正因
            HStack(spacing: scale.size(16)) {
                // 左侧：普贤十大愿（两列显示，横屏自动展开）
                VStack {
                    SamanthabhadraVowsTwoColumnView(initiallyExpanded: true)

                    Spacer()
                }
                .frame(maxWidth: scale.size(260))

                // 中间：经文名、转经筒和计数
                VStack(spacing: scale.size(8)) {
                    // 经文名 - 转经筒上方
                    Text(prayerLibrary.selectedType.rawValue)
                        .font(.system(size: scale.fontSize(20), weight: .bold))
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                        .shadow(color: Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.8 * glowOpacity), radius: scale.size(12), x: 0, y: 0)
                        .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in
                            let timeMultiplier = Date().timeIntervalSinceReferenceDate * 0.33
                            let normalized = timeMultiplier.truncatingRemainder(dividingBy: 1.0)
                            glowOpacity = 0.4 + 0.6 * sin(normalized * .pi)
                        }
                        .padding(.bottom, scale.size(4))

                    // 转经筒主体
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

                        Circle()
                            .fill(Color(red: 0.99, green: 0.84, blue: 0.15))
                            .frame(width: scale.size(6), height: scale.size(6))

                        Text("卍")
                            .font(.system(size: scale.fontSize(100), weight: .bold))
                            .foregroundColor(.white)
                            .rotation3DEffect(
                                .degrees(rotation),
                                axis: (x: 0, y: 0, z: 1)
                            )
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

                    // 计数显示
                    VStack(spacing: scale.size(12)) {
                        let (numberStr, unitStr) = prayerLibrary.formatCountWithChineseUnitsSeparated(prayerLibrary.currentCount)

                        // 总转数
                        VStack(alignment: .center, spacing: scale.size(4)) {
                            Text("总转数")
                                .font(.system(size: scale.fontSize(12), weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.7))
                            Text("\(prayerLibrary.totalCycles)")
                                .font(.system(size: scale.fontSize(24), weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                        }
                        .frame(maxWidth: .infinity)

                        // 本次转经数
                        VStack(alignment: .center, spacing: scale.size(4)) {
                            Text("本次转经数")
                                .font(.system(size: scale.fontSize(12), weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.7))

                            HStack(spacing: 0) {
                                Text(numberStr)
                                    .font(.system(size: scale.fontSize(28), weight: .bold, design: .monospaced))
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
                        .frame(maxWidth: .infinity)
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
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
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
            // 延迟 0.3 秒后启动转经，避免启动时黑屏
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                startRotation()
            }
        }
        .onDisappear {
            stopRotation()
        }
        .sheet(isPresented: $showHelp) {
            iOSHelpView()
        }
        .sheet(isPresented: $showSettings) {
            iOSSettingsView(
                settings: AppSettings(),
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

            let completedRotations = floor(rotation / 360.0)

            if completedRotations > lastCompletedRotations {
                lastCompletedRotations = completedRotations

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
