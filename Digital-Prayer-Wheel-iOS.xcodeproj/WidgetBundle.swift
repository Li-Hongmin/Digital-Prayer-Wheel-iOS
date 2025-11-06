//
//  WidgetBundle.swift
//  Digital-Prayer-Wheel
//
//  小组件包配置文件
//  Created by Claude on 2025/10/23.
//

import WidgetKit
import SwiftUI

/// 小组件包 - 统一管理所有小组件
@main
struct PrayerWheelWidgetBundle: WidgetBundle {
    var body: some Widget {
        PrayerWheelWidget()
        // 可以在这里添加更多小组件
        // PrayerWheelLiveActivity() // 如果需要实时活动
    }
}

// MARK: - URL Scheme 处理
extension URL {
    
    /// 转经筒应用的 URL Scheme
    static let prayerWheelScheme = "prayerwheel"
    
    /// 小组件深层链接
    enum PrayerWheelDeepLink {
        case open           // 打开应用主页
        case start          // 启动转经
        case settings       // 打开设置
        case statistics     // 查看统计
        
        var url: URL {
            switch self {
            case .open:
                return URL(string: "\(URL.prayerWheelScheme)://open")!
            case .start:
                return URL(string: "\(URL.prayerWheelScheme)://start")!
            case .settings:
                return URL(string: "\(URL.prayerWheelScheme)://settings")!
            case .statistics:
                return URL(string: "\(URL.prayerWheelScheme)://statistics")!
            }
        }
    }
}

// MARK: - 应用主入口扩展（处理小组件链接）
extension iOSContentView {
    
    /// 处理小组件的深层链接
    /// 需要在 iOSContentView 中添加此方法
    func handleWidgetURL(_ url: URL) {
        guard url.scheme == URL.prayerWheelScheme else { return }
        
        switch url.host {
        case "open":
            // 打开应用主页 - 无需特殊操作
            break
            
        case "start":
            // 启动转经
            // 可以自动开始转经或者提供快速启动
            // 这里需要与现有的转经逻辑集成
            break
            
        case "settings":
            // 打开设置页面
            showSettings = true
            
        case "statistics":
            // 显示统计信息
            // 可以导航到统计页面或显示统计弹窗
            break
            
        default:
            break
        }
    }
}