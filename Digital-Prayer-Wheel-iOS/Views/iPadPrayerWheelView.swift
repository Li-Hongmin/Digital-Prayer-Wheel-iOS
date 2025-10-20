//
//  iPadPrayerWheelView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//  iPad-specific prayer wheel view with horizontal landscape layout

import SwiftUI
import Combine

/// iPad-specific prayer wheel view with horizontal split layout
struct iPadPrayerWheelView: View {
    @ObservedObject var prayerLibrary: PrayerLibrary
    @Binding var showSettings: Bool

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
        VStack(spacing: 0) {
            // 顶部栏：经文名字 + 帮助 + 设置
            HStack {
                Text(prayerLibrary.selectedType.rawValue)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                    .shadow(color: Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.8 * glowOpacity), radius: 16, x: 0, y: 0)
                    .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in
                        let timeMultiplier = Date().timeIntervalSinceReferenceDate * 0.33
                        let normalized = timeMultiplier.truncatingRemainder(dividingBy: 1.0)
                        glowOpacity = 0.4 + 0.6 * sin(normalized * .pi)
                    }

                Spacer()

                Button(action: { showHelp.toggle() }) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 18))
                }
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "gear")
                        .font(.system(size: 18))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(red: 0.15, green: 0.15, blue: 0.18))

            // 主内容区：左侧转经筒 + 右侧计数
            HStack(spacing: 40) {
                // 左侧：转经筒
                VStack {
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
                                lineWidth: 4
                            )
                            .frame(width: 280, height: 280)

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
                            .frame(width: 270, height: 270)

                        Circle()
                            .stroke(Color(red: 0.99, green: 0.84, blue: 0.15), lineWidth: 2)
                            .frame(width: 250, height: 250)

                        Circle()
                            .stroke(Color(red: 0.96, green: 0.78, blue: 0.10), lineWidth: 1)
                            .frame(width: 230, height: 230)

                        Circle()
                            .fill(Color(red: 0.99, green: 0.84, blue: 0.15))
                            .frame(width: 10, height: 10)

                        Text("卍")
                            .font(.system(size: 200, weight: .bold))
                            .foregroundColor(.white)
                            .rotation3DEffect(
                                .degrees(rotation),
                                axis: (x: 0, y: 0, z: 1)
                            )
                    }
                    .frame(height: 300)
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

                    Spacer()
                }

                // 右侧：计数显示和普贤十大愿（纵向排列）
                VStack(spacing: 16) {
                    // 普贤十大愿
                    SamanthabhadraVowsView()

                    let (numberStr, unitStr) = prayerLibrary.formatCountWithChineseUnitsSeparated(prayerLibrary.currentCount)

                    // 总转数
                    VStack(alignment: .center, spacing: 6) {
                        Text("总转数")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.7))
                        Text("\(prayerLibrary.totalCycles)")
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(red: 0.18, green: 0.18, blue: 0.20))
                    .cornerRadius(12)

                    // 本次转经数
                    VStack(alignment: .center, spacing: 6) {
                        Text("本次转经数")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.7))

                        HStack(spacing: 0) {
                            Text(numberStr)
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .scaleEffect(countScale)
                                .frame(maxWidth: 80, alignment: .trailing)

                            VStack(spacing: 0) {
                                Text(unitStr)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                    .lineLimit(1)
                                    .truncationMode(.tail)

                                Text("次")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color.white.opacity(0.7))
                            }
                            .frame(minWidth: 90, alignment: .center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(red: 0.18, green: 0.18, blue: 0.20))
                    .cornerRadius(12)

                    Spacer()
                }
                .frame(maxWidth: 240)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Spacer()
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
            startRotation()
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
    return iPadPrayerWheelView(
        prayerLibrary: PrayerLibrary(),
        showSettings: $showSettings
    )
}
