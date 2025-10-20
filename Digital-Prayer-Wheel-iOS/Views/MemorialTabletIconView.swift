//
//  MemorialTabletIconView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 传统木质牌位图标视图
struct MemorialTabletIconView: View {
    @Environment(\.responsiveScale) var responsiveScale
    @State private var tapScale: CGFloat = 1.0

    /// 牌位标题
    let title: String

    /// 背景颜色
    let backgroundColor: Color

    /// 边框颜色
    let borderColor: Color

    /// 文字颜色
    let textColor: Color

    /// 点击事件处理
    let onTap: () -> Void

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()

        VStack(spacing: 0) {
            // 顶部莲花装饰
            Image(systemName: "leaf.fill")
                .font(.system(size: scale.fontSize(10)))
                .foregroundColor(borderColor)
                .rotationEffect(.degrees(180))
                .padding(.bottom, scale.size(2))

            // 牌位主体
            ZStack {
                // 彩色背景（红色或金黄色）
                RoundedRectangle(cornerRadius: scale.size(6))
                    .fill(backgroundColor)
                    .frame(width: scale.size(35), height: scale.size(100))

                // 边框（金色或黑色）
                RoundedRectangle(cornerRadius: scale.size(6))
                    .stroke(
                        borderColor,
                        lineWidth: scale.size(1.5)
                    )
                    .frame(width: scale.size(35), height: scale.size(100))

                // 竖排文字：黑色
                VStack(spacing: scale.size(4)) {
                    ForEach(Array(title.enumerated()), id: \.offset) { _, char in
                        Text(String(char))
                            .font(.system(size: scale.fontSize(16), weight: .bold, design: .serif))
                            .foregroundColor(textColor)
                    }
                }
                .shadow(color: textColor.opacity(0.2), radius: scale.size(1))
            }

            // 底部祥云装饰
            Image(systemName: "cloud.fill")
                .font(.system(size: scale.fontSize(8)))
                .foregroundColor(borderColor.opacity(0.5))
                .padding(.top, scale.size(2))
        }
        .scaleEffect(tapScale)
        .onTapGesture {
            // 点击动画
            withAnimation(.easeInOut(duration: 0.15)) {
                tapScale = 0.9
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    tapScale = 1.0
                }
            }
            onTap()
        }
        // 烛光效果的阴影
        .shadow(color: borderColor.opacity(0.3), radius: scale.size(8), x: 0, y: scale.size(2))
    }
}

#Preview("吉祥牌位") {
    ZStack {
        Color(red: 0.12, green: 0.12, blue: 0.14)
        MemorialTabletIconView(
            title: "吉祥牌位",
            backgroundColor: Color(red: 0.90, green: 0.11, blue: 0.14), // 红底
            borderColor: Color(red: 0.99, green: 0.84, blue: 0.15),     // 金边
            textColor: Color.black                                       // 黑字
        ) {
            print("吉祥牌位被点击")
        }
    }
}

#Preview("往生牌位") {
    ZStack {
        Color(red: 0.12, green: 0.12, blue: 0.14)
        MemorialTabletIconView(
            title: "往生牌位",
            backgroundColor: Color(red: 1.0, green: 0.84, blue: 0.0), // 金底
            borderColor: Color(red: 0.99, green: 0.84, blue: 0.15),   // 金边
            textColor: Color.black                                     // 黑字
        ) {
            print("往生牌位被点击")
        }
    }
}
