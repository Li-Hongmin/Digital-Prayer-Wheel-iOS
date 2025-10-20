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

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.12, green: 0.12, blue: 0.14)
                    .ignoresSafeArea()

                VStack {
                    // 根据屏幕宽高比选择布局（iPhone 和 iPad 通用）
                    if geometry.size.width > geometry.size.height {
                        // 横屏：三栏布局（左侧十大愿 + 中间转经筒 + 右侧净业正因）
                        iOSLandscapePrayerWheelView(
                            prayerLibrary: prayerLibrary,
                            showSettings: $showSettings
                        )
                    } else {
                        // 竖屏：纵向布局（上方转经筒 + 下方教导内容）
                        iOSPrayerWheelView(
                            prayerLibrary: prayerLibrary,
                            showSettings: $showSettings
                        )
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
