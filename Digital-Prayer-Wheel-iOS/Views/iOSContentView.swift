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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.12, blue: 0.14)
                .ignoresSafeArea()

            VStack {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    // iPad: Use landscape view for horizontal orientation
                    iPadPrayerWheelView(
                        prayerLibrary: prayerLibrary,
                        showSettings: $showSettings
                    )
                } else {
                    // iPhone: Choose layout based on orientation
                    if horizontalSizeClass == .regular && verticalSizeClass == .compact {
                        // iPhone 横屏：三栏布局
                        iOSLandscapePrayerWheelView(
                            prayerLibrary: prayerLibrary,
                            showSettings: $showSettings
                        )
                    } else {
                        // iPhone 竖屏：纵向布局
                        iOSPrayerWheelView(
                            prayerLibrary: prayerLibrary,
                            showSettings: $showSettings
                        )
                    }
                }
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
        }
    }

    private func initializeServices() {
        // 从AppSettings加载经文选择
        if let prayerType = PrayerType(rawValue: settings.selectedPrayerType) {
            prayerLibrary.setType(prayerType)
        }
    }
}

#Preview {
    iOSContentView()
}
