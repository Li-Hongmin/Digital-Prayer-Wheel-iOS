//
//  MinimalWheelView.swift
//  Digital Prayer Wheel Watch App
//
//  Created by Claude on 2025/11/09.
//  简约版转经轮界面 - Minimal prayer wheel UI for Apple Watch
//

import SwiftUI

struct MinimalWheelView: View {
    // Dependencies
    @ObservedObject var library: PrayerLibrary
    @ObservedObject var backgroundCalc: BackgroundCalculator

    // Animation state
    @State private var rotationAngle: Double = 0  // Current rotation angle
    @State private var currentText: String = ""  // Current prayer text
    @State private var timer: Timer? = nil  // Rotation timer
    @State private var showCompensationBadge: Bool = false  // Show compensation notification

    // Wheel mode selection
    @AppStorage("wheelMode") private var wheelMode: WheelMode = .minimal

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(.sRGB, red: 0.1, green: 0.05, blue: 0.15),
                             Color(.sRGB, red: 0.2, green: 0.1, blue: 0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: size * 0.05) {
                    // Prayer wheel visualization
                    WheelVisualization(
                        rotationAngle: rotationAngle,
                        size: size * 0.4
                    )

                    // Current prayer text
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(currentText)
                            .font(.system(size: size * 0.08, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                    }
                    .frame(height: size * 0.12)

                    // Stats display
                    VStack(spacing: size * 0.02) {
                        // Today's count
                        StatRow(
                            label: "今日",
                            value: "\(library.todayCount)",
                            size: size * 0.06
                        )

                        // Total cycles
                        StatRow(
                            label: "总计",
                            value: "\(library.totalCycles)",
                            size: size * 0.05
                        )

                        // Rotation speed
                        StatRow(
                            label: "速度",
                            value: "\(Int(library.rotationSpeed)) 圈/分",
                            size: size * 0.04
                        )
                    }
                }
                .padding(size * 0.05)

                // Compensation badge (temporary notification)
                if showCompensationBadge && backgroundCalc.missedRotations > 0 {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("补充 \(backgroundCalc.missedRotations) 圈")
                        }
                        .font(.caption2)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.bottom, 8)
                    }
                }
            }
        }
        .onAppear {
            startAutoRotation()
            showCompensationIfNeeded()
        }
        .onDisappear {
            stopAutoRotation()
        }
    }

    // MARK: - Helper methods

    /// Start automatic rotation based on rotation speed
    private func startAutoRotation() {
        // Get next text immediately
        if let text = library.getNextText() {
            currentText = text
        }

        // Calculate rotation interval based on speed
        // Speed is in rotations per minute, convert to seconds per rotation
        let rotationsPerMinute = library.rotationSpeed
        let secondsPerRotation = 60.0 / rotationsPerMinute

        // Start timer for automatic rotation
        timer = Timer.scheduledTimer(withTimeInterval: secondsPerRotation, repeats: true) { _ in
            withAnimation(.linear(duration: secondsPerRotation)) {
                // Update rotation angle (360 degrees per rotation)
                rotationAngle += 360
            }

            // Get next prayer text
            if let text = library.getNextText() {
                currentText = text
            }
        }

        print("▶️ Started auto-rotation: \(rotationsPerMinute) RPM")
    }

    /// Stop automatic rotation
    private func stopAutoRotation() {
        timer?.invalidate()
        timer = nil
        print("⏸️ Stopped auto-rotation")
    }

    /// Show compensation badge if rotations were added
    private func showCompensationIfNeeded() {
        if backgroundCalc.missedRotations > 0 {
            showCompensationBadge = true

            // Hide after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showCompensationBadge = false
                }
            }
        }
    }
}

// MARK: - Wheel Visualization Component

struct WheelVisualization: View {
    let rotationAngle: Double
    let size: CGFloat

    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.yellow.opacity(0.6), .orange.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: size * 0.08
                )
                .frame(width: size, height: size)

            // Inner decorative patterns (simulating prayer wheel engravings)
            ForEach(0..<6, id: \.self) { index in
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: size * 0.02, height: size * 0.3)
                    .offset(y: -size * 0.15)
                    .rotationEffect(.degrees(Double(index) * 60))
            }

            // Center Om symbol (simplified)
            Text("🙏")
                .font(.system(size: size * 0.3))
        }
        .rotationEffect(.degrees(rotationAngle))
        .shadow(color: .yellow.opacity(0.3), radius: size * 0.1)
    }
}

// MARK: - Stats Row Component

struct StatRow: View {
    let label: String
    let value: String
    let size: CGFloat

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: size, weight: .regular))
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            Text(value)
                .font(.system(size: size, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Wheel Mode Enum

enum WheelMode: String, CaseIterable {
    case minimal = "简约"
    case realistic = "仿真"
}

// MARK: - Preview

#Preview {
    MinimalWheelView(
        library: PrayerLibrary(),
        backgroundCalc: BackgroundCalculator()
    )
}
