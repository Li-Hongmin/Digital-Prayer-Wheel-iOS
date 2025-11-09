//
//  ContentView.swift
//  Digital Prayer Wheel Watch App
//
//  Created by Claude on 2025/11/09.
//

import SwiftUI

struct ContentView: View {
    // Prayer library - shared business logic
    @StateObject private var prayerLibrary = PrayerLibrary()

    // Background calculator - auto-compensation system
    @StateObject private var backgroundCalc = BackgroundCalculator()

    // App settings
    @StateObject private var settings = AppSettings()

    var body: some View {
        // Only realistic wheel view
        RealisticWheelView(
            library: prayerLibrary,
            backgroundCalc: backgroundCalc
        )
        .onAppear {
            handleAppearance()
        }
        .onDisappear {
            handleDisappearance()
        }
    }

    // MARK: - Lifecycle handlers

    /// Handle app appearance - calculate and apply background compensation
    private func handleAppearance() {
        print("🟢 Watch App appeared")

        // Calculate missed rotations during offline period
        let missedCount = backgroundCalc.calculateMissedRotations()

        if missedCount > 0 {
            // Add missed rotations to count
            Task { @MainActor in
                for _ in 0..<missedCount {
                    _ = prayerLibrary.getNextText()
                }
            }

            print("✅ Compensated \(missedCount) rotations")
        }
    }

    /// Handle app disappearance - save state for next compensation
    private func handleDisappearance() {
        print("🔴 Watch App will disappear")

        // Save current state for background compensation
        backgroundCalc.saveBackgroundState(
            speed: prayerLibrary.rotationSpeed,
            prayerType: prayerLibrary.selectedType.rawValue
        )

        // Save prayer counts
        prayerLibrary.finalizeCount()

        // Save settings
        settings.finalizeSave()
    }
}

#Preview {
    ContentView()
}
