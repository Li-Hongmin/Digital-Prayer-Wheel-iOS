//
//  ResponsiveScale.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 响应式缩放计算器
struct ResponsiveScale {
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    // 基准尺寸：iPhone 14
    static let portraitBaseWidth: CGFloat = 393   // 竖屏宽度
    static let landscapeBaseWidth: CGFloat = 852  // 横屏宽度（竖屏的高度）

    init(geometry: GeometryProxy) {
        self.screenWidth = geometry.size.width
        self.screenHeight = geometry.size.height
    }

    // 默认初始化器（使用竖屏基准尺寸，缩放因子为1.0）
    init() {
        self.screenWidth = Self.portraitBaseWidth
        self.screenHeight = Self.landscapeBaseWidth
    }

    /// 计算缩放因子（智能判断横竖屏，使用对应基准）
    var scaleFactor: CGFloat {
        if screenWidth > screenHeight {
            // 横屏：基于宽度，横屏基准是 852
            return screenWidth / Self.landscapeBaseWidth
        } else {
            // 竖屏：基于宽度，竖屏基准是 393
            return screenWidth / Self.portraitBaseWidth
        }
    }

    /// 缩放尺寸（用于转经筒、间距等）
    func size(_ baseSize: CGFloat) -> CGFloat {
        baseSize * scaleFactor
    }

    /// 缩放字体（纯线性等比例缩放，保持所有元素比例一致）
    func fontSize(_ baseSize: CGFloat) -> CGFloat {
        baseSize * scaleFactor
    }
}

/// Environment Key for scale factor
struct ScaleFactorKey: EnvironmentKey {
    static let defaultValue: ResponsiveScale? = nil
}

extension EnvironmentValues {
    var responsiveScale: ResponsiveScale? {
        get { self[ScaleFactorKey.self] }
        set { self[ScaleFactorKey.self] = newValue }
    }
}
