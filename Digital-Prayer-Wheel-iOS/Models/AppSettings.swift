//
//  AppSettings.swift
//  Digital-Prayer-Wheel
//
//  Created by YunQiAI on 2025/03/20.
//  Modified by Claude on 2025/10/19.
//

import Foundation
import SwiftUI
import Combine

class AppSettings: ObservableObject {
    // 经文选择
    @Published var selectedPrayerType: String {
        didSet {
            saveSettings()
        }
    }

    // 弹幕显示类型（全屏/底端）
    @Published var barrageDisplayType: String {
        didSet {
            saveSettings()
        }
    }

    // 弹幕设置
    @Published var barrageSpeed: Double {
        didSet {
            saveSettings()
        }
    }

    @Published var barrageDirection: String {
        didSet {
            saveSettings()
        }
    }

    // 弹幕字体大小
    @Published var barrageFontSize: Double {
        didSet {
            saveSettings()
        }
    }

    // 弹幕透明度
    @Published var barrageOpacity: Double {
        didSet {
            saveSettings()
        }
    }

    // 弹幕间隔时间滑块值 (0-100)
    @Published var barrageIntervalSlider: Double {
        didSet {
            saveSettings()
        }
    }

    // 窗口前置设置
    @Published var windowAlwaysOnTop: Bool {
        didSet {
            saveSettings()
        }
    }

    // 防止息屏设置
    @Published var keepScreenOn: Bool {
        didSet {
            saveSettings()
            applyScreenSettings()
        }
    }

    // 保持后台运行设置
    @Published var keepBackgroundActive: Bool {
        didSet {
            saveSettings()
        }
    }

    // 回向偈选择（1-4）
    @Published var selectedDedicationVerse: Int {
        didSet {
            saveSettings()
        }
    }

    init(
        selectedPrayerType: String = "南无阿弥陀佛",  // 默认经文
        barrageDisplayType: String = "fullscreen",  // 默认全屏弹幕
        barrageSpeed: Double = 100.0,
        barrageDirection: String = "rightToLeft",
        barrageFontSize: Double = 18.0,
        barrageOpacity: Double = 1.0,
        barrageIntervalSlider: Double = 70.0,  // 默认对应0.8秒左右
        windowAlwaysOnTop: Bool = false,
        keepScreenOn: Bool = true,  // 默认打开防止息屏
        keepBackgroundActive: Bool = true,  // 默认打开后台运行
        selectedDedicationVerse: Int = 1  // 默认回向偈一
    ) {
        // 从UserDefaults加载设置
        self.selectedPrayerType = UserDefaults.standard.string(forKey: "selectedPrayerType") ?? selectedPrayerType
        self.barrageDisplayType = UserDefaults.standard.string(forKey: "barrageDisplayType") ?? barrageDisplayType
        self.barrageSpeed = UserDefaults.standard.double(forKey: "barrageSpeed") > 0 ? UserDefaults.standard.double(forKey: "barrageSpeed") : barrageSpeed
        self.barrageDirection = UserDefaults.standard.string(forKey: "barrageDirection") ?? barrageDirection
        self.barrageFontSize = UserDefaults.standard.double(forKey: "barrageFontSize") > 0 ? UserDefaults.standard.double(forKey: "barrageFontSize") : barrageFontSize
        self.barrageOpacity = UserDefaults.standard.double(forKey: "barrageOpacity") > 0 ? UserDefaults.standard.double(forKey: "barrageOpacity") : barrageOpacity
        self.barrageIntervalSlider = UserDefaults.standard.object(forKey: "barrageIntervalSlider") != nil ? UserDefaults.standard.double(forKey: "barrageIntervalSlider") : barrageIntervalSlider
        self.windowAlwaysOnTop = UserDefaults.standard.bool(forKey: "windowAlwaysOnTop")

        // 加载防止息屏和后台运行设置，默认为 true
        self.keepScreenOn = UserDefaults.standard.object(forKey: "keepScreenOn") != nil ? UserDefaults.standard.bool(forKey: "keepScreenOn") : keepScreenOn
        self.keepBackgroundActive = UserDefaults.standard.object(forKey: "keepBackgroundActive") != nil ? UserDefaults.standard.bool(forKey: "keepBackgroundActive") : keepBackgroundActive

        // 加载回向偈选择
        let savedVerse = UserDefaults.standard.integer(forKey: "selectedDedicationVerse")
        self.selectedDedicationVerse = (savedVerse >= 1 && savedVerse <= 4) ? savedVerse : selectedDedicationVerse

        // 应用屏幕设置
        applyScreenSettings()
    }
    
    // 保存设置到UserDefaults
    private func saveSettings() {
        UserDefaults.standard.set(selectedPrayerType, forKey: "selectedPrayerType")
        UserDefaults.standard.set(barrageDisplayType, forKey: "barrageDisplayType")
        UserDefaults.standard.set(barrageSpeed, forKey: "barrageSpeed")
        UserDefaults.standard.set(barrageDirection, forKey: "barrageDirection")
        UserDefaults.standard.set(barrageFontSize, forKey: "barrageFontSize")
        UserDefaults.standard.set(barrageOpacity, forKey: "barrageOpacity")
        UserDefaults.standard.set(barrageIntervalSlider, forKey: "barrageIntervalSlider")
        UserDefaults.standard.set(windowAlwaysOnTop, forKey: "windowAlwaysOnTop")
        UserDefaults.standard.set(keepScreenOn, forKey: "keepScreenOn")
        UserDefaults.standard.set(keepBackgroundActive, forKey: "keepBackgroundActive")
        UserDefaults.standard.set(selectedDedicationVerse, forKey: "selectedDedicationVerse")
    }

    // 应用屏幕设置
    private func applyScreenSettings() {
        #if os(iOS)
        UIApplication.shared.isIdleTimerDisabled = keepScreenOn
        #endif
    }

    // MARK: - 指数分布映射函数

    /// 将滑块值(0-100)转换为实际间隔时间(0.001-10秒)
    /// 使用指数分布：interval = 0.001 * pow(10000, sliderValue/100.0)
    var barrageInterval: Double {
        return 0.001 * pow(10000.0, barrageIntervalSlider / 100.0)
    }

    /// 将间隔时间转换为滑块值(用于界面显示)
    func sliderValueFromInterval(_ interval: Double) -> Double {
        return log(interval / 0.001) / log(10000.0) * 100.0
    }

    /// 格式化显示间隔时间
    var barrageIntervalDisplayText: String {
        let interval = barrageInterval
        if interval < 0.01 {
            return String(format: "%.0fms", interval * 1000)
        } else if interval < 1.0 {
            return String(format: "%.2fs", interval)
        } else {
            return String(format: "%.1fs", interval)
        }
    }
}
