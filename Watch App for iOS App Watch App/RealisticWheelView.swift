//
//  RealisticWheelView.swift
//  Digital Prayer Wheel Watch App
//
//  Created by Claude on 2025/11/09.
//  仿真版 - 完全复刻 iOS 转经轮，精简文字
//

import SwiftUI

struct RealisticWheelView: View {
    @ObservedObject var library: PrayerLibrary
    @ObservedObject var backgroundCalc: BackgroundCalculator

    @State private var rotation: Double = 0
    @State private var rotationTimer: Timer?
    @State private var isRotating: Bool = false
    @State private var glowOpacity: Double = 0.6
    @State private var accumulatedRotation: Double = 0  // Accumulated rotation for counting

    private var timePerRotation: Double {
        60.0 / library.rotationSpeed
    }

    private var anglePerFrame: Double {
        360.0 / (timePerRotation * 30.0)
    }

    var body: some View {
        GeometryReader { geometry in
            let screenSize = min(geometry.size.width, geometry.size.height)
            let wheelSize = screenSize * 0.75  // 75% of screen for the wheel

            ZStack {
                // Background
                Color(red: 0.12, green: 0.12, blue: 0.14)
                    .ignoresSafeArea()
                    .focusable(true)
                    .digitalCrownRotation(
                        $library.rotationSpeed,
                        from: 6,
                        through: 600,
                        by: 6,
                        sensitivity: .medium,
                        isContinuous: false,
                        isHapticFeedbackEnabled: true
                    )

                // Prayer Wheel (居中最大化)
                ZStack {
                    // Outer golden ring
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
                        .frame(width: wheelSize, height: wheelSize)

                    // Inner filled circle
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
                        .frame(width: wheelSize * 0.94, height: wheelSize * 0.94)

                    // Inner ring
                    Circle()
                        .stroke(Color(red: 0.99, green: 0.84, blue: 0.15), lineWidth: 2)
                        .frame(width: wheelSize * 0.88, height: wheelSize * 0.88)

                    // Swastika symbol (rotating)
                    Text("卍")
                        .font(.system(size: wheelSize * 0.62, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotation))
                        .offset(y: -2)
                }

                // Overlay: Title and stats in corners
                VStack(spacing: 0) {
                    // Top: Prayer name (贴顶)
                    HStack {
                        Text(library.selectedType.rawValue)
                            .font(.system(size: screenSize * 0.07, weight: .bold))
                            .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                            .shadow(
                                color: Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.8 * glowOpacity),
                                radius: 8
                            )
                        Spacer()
                    }
                    .padding(.leading, 8)

                    Spacer()

                    // Bottom corners: Stats (与 iOS 一致)
                    HStack(alignment: .bottom) {
                        // Bottom-left: Today merit (今日功德)
                        VStack(alignment: .leading, spacing: 0) {
                            Text("今日功德")
                                .font(.system(size: screenSize * 0.045))
                                .foregroundColor(Color.white.opacity(0.6))
                            Text("\(library.todayCount)")
                                .font(.system(size: screenSize * 0.11, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                        }

                        Spacer()

                        // Bottom-right: Total days (累计天数)
                        VStack(alignment: .trailing, spacing: 0) {
                            Text("累计天数")
                                .font(.system(size: screenSize * 0.045))
                                .foregroundColor(Color.white.opacity(0.6))
                            HStack(spacing: 2) {
                                Text("\(calculateTotalDays())")
                                    .font(.system(size: screenSize * 0.11, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                Text("天")
                                    .font(.system(size: screenSize * 0.07))
                                    .foregroundColor(Color.white.opacity(0.7))
                            }
                        }
                    }
                    .padding(.bottom, 8)
                    .padding(.horizontal, 8)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .onAppear {
            startRotation()
        }
        .onDisappear {
            stopRotation()
        }
        .onChange(of: library.rotationSpeed) { newValue in
            // Restart rotation with new speed
            stopRotation()
            startRotation()
            print("⚡ Speed changed to: \(Int(newValue)) RPM")
        }
    }

    // MARK: - Helper Functions

    /// Calculate total practice days (累计转经天数)
    private func calculateTotalDays() -> Int {
        let uniqueDays = Set(library.statistics.dailyRecords.map {
            Calendar.current.startOfDay(for: $0.date)
        }).count
        return uniqueDays
    }

    // MARK: - Rotation Control

    private func startRotation() {
        isRotating = true
        accumulatedRotation = 0  // Reset accumulated rotation

        rotationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.linear(duration: 1.0 / 30.0)) {
                    rotation += anglePerFrame
                    accumulatedRotation += anglePerFrame
                }

                // Increment count every full rotation (360 degrees)
                if accumulatedRotation >= 360.0 {
                    // Complete one rotation, increment count
                    library.incrementCount()
                    accumulatedRotation -= 360.0  // Reset for next rotation
                    print("✅ Completed one rotation - Count: \(library.todayCount)")
                }

                // Reset visual rotation to prevent overflow
                if rotation >= 360.0 {
                    rotation -= 360.0
                }

                // Glow effect
                glowOpacity = 0.6 + sin(rotation * .pi / 180.0) * 0.2
            }
        }

        print("▶️ Started rotation at \(library.rotationSpeed) RPM")
    }

    private func stopRotation() {
        rotationTimer?.invalidate()
        rotationTimer = nil
        isRotating = false
        print("⏸️ Stopped rotation")
    }
}

#Preview {
    RealisticWheelView(
        library: PrayerLibrary(),
        backgroundCalc: BackgroundCalculator()
    )
}
