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

    // 基准尺寸：iPhone 14 (393 x 852)
    static let baseWidth: CGFloat = 393
    static let baseHeight: CGFloat = 852

    init(geometry: GeometryProxy) {
        self.screenWidth = geometry.size.width
        self.screenHeight = geometry.size.height
    }

    // 默认初始化器（使用基准尺寸，缩放因子为1.0）
    init() {
        self.screenWidth = Self.baseWidth
        self.screenHeight = Self.baseHeight
    }

    /// 计算缩放因子（基于较小的比例，避免元素超出屏幕）
    var scaleFactor: CGFloat {
        min(
            screenWidth / Self.baseWidth,
            screenHeight / Self.baseHeight
        )
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
