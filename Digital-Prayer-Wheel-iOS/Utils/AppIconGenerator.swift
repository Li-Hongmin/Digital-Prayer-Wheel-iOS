//
//  AppIconGenerator.swift
//  Digital-Prayer-Wheel-iOS
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 应用图标生成器视图 - 完全模仿应用内转经轮设计
/// 使用：在 Preview 中显示，然后截图保存为 1024x1024
struct AppIconView: View {
    var body: some View {
        ZStack {
            // 深色背景（和应用背景一致）
            Color(red: 0.12, green: 0.12, blue: 0.14)

            // 完全复制应用内转经轮的设计
            ZStack {
                // 最外圈：金色渐变边框
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.99, green: 0.84, blue: 0.15),
                                Color(red: 0.96, green: 0.78, blue: 0.10)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 20
                    )
                    .frame(width: 800, height: 800)

                // 中间圆盘：金色渐变填充
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.90, green: 0.82, blue: 0.55),
                                Color(red: 0.75, green: 0.63, blue: 0.35)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 750, height: 750)

                // 内圈：金色线条
                Circle()
                    .stroke(Color(red: 0.99, green: 0.84, blue: 0.15), lineWidth: 10)
                    .frame(width: 700, height: 700)

                // 中心卍字符（白色，无旋转）
                Text("卍")
                    .font(.system(size: 500, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

/// 深色模式图标（背景更深）
struct AppIconViewDark: View {
    var body: some View {
        ZStack {
            // 深色渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.12, green: 0.12, blue: 0.14),  // 深灰
                    Color(red: 0.18, green: 0.18, blue: 0.20),  // 中灰
                    Color(red: 0.25, green: 0.22, blue: 0.20)   // 暖灰
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 外圈装饰环
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.99, green: 0.84, blue: 0.15),
                            Color(red: 1.0, green: 0.95, blue: 0.60)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 20
                )
                .frame(width: 850, height: 850)
                .shadow(color: Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.3), radius: 15, x: 0, y: 0)

            // 内圈金色环
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.95, blue: 0.60),
                            Color(red: 0.99, green: 0.84, blue: 0.15)
                        ]),
                        startPoint: .bottomTrailing,
                        endPoint: .topLeading
                    ),
                    lineWidth: 15
                )
                .frame(width: 750, height: 750)

            // 中心圆盘背景（深色）
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.35, green: 0.32, blue: 0.30),
                            Color(red: 0.25, green: 0.22, blue: 0.20),
                            Color(red: 0.15, green: 0.15, blue: 0.17)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 350
                    )
                )
                .frame(width: 700, height: 700)
                .shadow(color: Color.black.opacity(0.6), radius: 20, x: 0, y: 10)

            // 细圈装饰
            Circle()
                .stroke(Color(red: 0.99, green: 0.84, blue: 0.15), lineWidth: 8)
                .frame(width: 650, height: 650)

            // 中心卍字符（金色发光）
            Text("卍")
                .font(.system(size: 480, weight: .bold))
                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                .shadow(color: Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.8), radius: 30, x: 0, y: 0)
                .shadow(color: Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.5), radius: 15, x: 0, y: 0)

            // 中心小圆点
            Circle()
                .fill(Color(red: 0.99, green: 0.84, blue: 0.15))
                .frame(width: 30, height: 30)
                .shadow(color: Color(red: 0.99, green: 0.84, blue: 0.15).opacity(0.6), radius: 10, x: 0, y: 0)
        }
        .frame(width: 1024, height: 1024)
    }
}

/// Tinted 模式图标（单色调）
struct AppIconViewTinted: View {
    var body: some View {
        ZStack {
            // 单色背景
            Color(red: 0.99, green: 0.84, blue: 0.15)

            // 外圈
            Circle()
                .stroke(Color.white.opacity(0.9), lineWidth: 20)
                .frame(width: 850, height: 850)

            // 内圈
            Circle()
                .stroke(Color.white.opacity(0.7), lineWidth: 15)
                .frame(width: 750, height: 750)

            // 中心圆盘
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 700, height: 700)

            // 细圈
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 8)
                .frame(width: 650, height: 650)

            // 卍字符
            Text("卍")
                .font(.system(size: 480, weight: .bold))
                .foregroundColor(.white)

            // 中心点
            Circle()
                .fill(Color.white)
                .frame(width: 30, height: 30)
        }
        .frame(width: 1024, height: 1024)
    }
}

// MARK: - 图标导出助手

#if canImport(UIKit)
import UIKit

extension View {
    /// 将视图渲染为 UIImage
    @MainActor
    func asUIImage(size: CGSize = CGSize(width: 1024, height: 1024)) -> UIImage? {
        let controller = UIHostingController(rootView: self)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }

    /// 保存为 PNG 文件
    @MainActor
    func saveAsPNG(to url: URL, size: CGSize = CGSize(width: 1024, height: 1024)) -> Bool {
        guard let image = asUIImage(size: size),
              let data = image.pngData() else {
            return false
        }

        do {
            try data.write(to: url)
            return true
        } catch {
            print("保存图标失败: \(error)")
            return false
        }
    }
}
#endif

// MARK: - Previews

#Preview("标准图标 - 1024x1024") {
    AppIconView()
}

#Preview("深色模式图标") {
    AppIconViewDark()
}

#Preview("Tinted 图标") {
    AppIconViewTinted()
}

#Preview("并排对比") {
    HStack(spacing: 20) {
        AppIconView()
            .frame(width: 300, height: 300)
        AppIconViewDark()
            .frame(width: 300, height: 300)
        AppIconViewTinted()
            .frame(width: 300, height: 300)
    }
    .padding()
    .background(Color.gray)
}
