//
//  PrayerText.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/19.
//

import Foundation

/// 经文类型枚举
enum PrayerType: String, CaseIterable, Identifiable {
    case mantra = "六字大明咒"
    case heartSutra = "心经"
    case amitabha = "南无阿弥陀佛"
    case guanyin = "南无观世音菩萨"

    var id: String { rawValue }

    /// 获取经文内容数组
    var texts: [String] {
        switch self {
        case .mantra:
            return [
                "嗡嘛呢叭咪吽"
            ]
        case .heartSutra:
            return [
                "观自在菩萨",
                "行深般若波罗蜜多时",
                "照见五蕴皆空",
                "度一切苦厄",
                "舍利子",
                "色不异空",
                "空不异色",
                "色即是空",
                "空即是色",
                "受想行识",
                "亦复如是",
                "舍利子",
                "是诸法空相",
                "不生不灭",
                "不垢不净",
                "不增不减",
                "是故空中无色",
                "无受想行识",
                "无眼耳鼻舌身意",
                "无色声香味触法",
                "无眼界",
                "乃至无意识界",
                "无无明",
                "亦无无明尽",
                "乃至无老死",
                "亦无老死尽",
                "无苦集灭道",
                "无智亦无得",
                "以无所得故",
                "菩提萨埵",
                "依般若波罗蜜多故",
                "心无挂碍",
                "无挂碍故",
                "无有恐怖",
                "远离颠倒梦想",
                "究竟涅槃"
            ]
        case .amitabha:
            return [
                "南无阿弥陀佛"
            ]
        case .guanyin:
            return [
                "南无观世音菩萨"
            ]
        }
    }

    /// 获取计数单位
    var countUnit: String {
        switch self {
        case .mantra:
            return "句"
        case .heartSutra:
            return "句"
        case .amitabha:
            return "声"
        case .guanyin:
            return "声"
        }
    }

    /// 获取经文描述
    var description: String {
        switch self {
        case .mantra:
            return "观音菩萨心咒，具有无边功德"
        case .heartSutra:
            return "般若波罗蜜多心经，佛法精髓"
        case .amitabha:
            return "阿弥陀佛佛号，净土法门"
        case .guanyin:
            return "观世音菩萨佛号，大慈大悲"
        }
    }

    /// 获取图标名称（可用于未来的图标显示）
    var iconName: String {
        switch self {
        case .mantra:
            return "lotus"
        case .heartSutra:
            return "book"
        case .amitabha:
            return "sun.max"
        case .guanyin:
            return "hands.sparkles"
        }
    }
}

/// 经文消息模型
struct PrayerMessage: Identifiable {
    let id = UUID()
    let text: String
    let type: PrayerType
    let createdAt: Date

    init(text: String, type: PrayerType) {
        self.text = text
        self.type = type
        self.createdAt = Date()
    }
}