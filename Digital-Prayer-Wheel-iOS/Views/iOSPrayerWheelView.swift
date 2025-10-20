//
//  iOSPrayerWheelView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI
import Combine

/// iOS-specific prayer wheel view with vertical layout
struct iOSPrayerWheelView: View {
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
        VStack(spacing: 8) {
            // 顶部：帮助和设置按钮
            HStack {
                Spacer()
                Button(action: { showHelp.toggle() }) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 16))
                }
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "gear")
                        .font(.system(size: 16))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            Spacer()

            // 主内容区：经文名、转经筒和计数（纵向布局）
            VStack(spacing: 8) {
                // 经文名
                Text(prayerLibrary.selectedType.rawValue)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                    .shadow(color: Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.8 * glowOpacity), radius: 12, x: 0, y: 0)
                    .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in
                        let timeMultiplier = Date().timeIntervalSinceReferenceDate * 0.33
                        let normalized = timeMultiplier.truncatingRemainder(dividingBy: 1.0)
                        glowOpacity = 0.4 + 0.6 * sin(normalized * .pi)
                    }
                    .padding(.bottom, 4)

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
                            lineWidth: 3
                        )
                        .frame(width: 160, height: 160)

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
                        .frame(width: 150, height: 150)

                    Circle()
                        .stroke(Color(red: 0.99, green: 0.84, blue: 0.15), lineWidth: 2)
                        .frame(width: 140, height: 140)

                    Circle()
                        .fill(Color(red: 0.99, green: 0.84, blue: 0.15))
                        .frame(width: 6, height: 6)

                    Text("卍")
                        .font(.system(size: 100, weight: .bold))
                        .foregroundColor(.white)
                        .rotation3DEffect(
                            .degrees(rotation),
                            axis: (x: 0, y: 0, z: 1)
                        )
                }
                .frame(height: 180)
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

                // 计数显示 - 纵向布局
                VStack(spacing: 12) {
                    let (numberStr, unitStr) = prayerLibrary.formatCountWithChineseUnitsSeparated(prayerLibrary.currentCount)

                    // 总转数
                    VStack(alignment: .center, spacing: 4) {
                        Text("总转数")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.7))
                        Text("\(prayerLibrary.totalCycles)")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                    }
                    .frame(maxWidth: .infinity)

                    // 本次转经数
                    VStack(alignment: .center, spacing: 4) {
                        Text("本次转经数")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.7))

                        HStack(spacing: 0) {
                            Text(numberStr)
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                .lineLimit(1)
                                .scaleEffect(countScale)

                            VStack(spacing: 0) {
                                Text(unitStr)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                    .lineLimit(1)
                                    .truncationMode(.tail)

                                Text("次")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(Color.white.opacity(0.7))
                            }
                            .frame(minWidth: 70, alignment: .center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            // 佛学教导 - 下方（普贤十大愿 + 往生正因）
            BuddhistTeachingsView()
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
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
    return iOSPrayerWheelView(
        prayerLibrary: PrayerLibrary(),
        showSettings: $showSettings
    )
}
