#!/usr/bin/env swift

import Foundation
import SwiftUI
import AppKit

/// macOS 版本的图标生成视图（与 iOS 版本完全相同的设计）
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

// MARK: - macOS 渲染助手（使用 ImageRenderer）

@MainActor
@available(macOS 13.0, *)
func renderViewToImage<V: View>(_ view: V, size: CGSize) -> NSImage? {
    let renderer = ImageRenderer(content: view)
    renderer.proposedSize = ProposedViewSize(size)

    // 使用 1.0 scale 生成精确的 1024x1024 图像
    renderer.scale = 1.0

    return renderer.nsImage
}

@MainActor
func saveImageAsPNG(_ image: NSImage, to url: URL) -> Bool {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("❌ 无法转换为 CGImage")
        return false
    }

    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
        print("❌ 无法生成 PNG 数据")
        return false
    }

    do {
        try pngData.write(to: url)
        return true
    } catch {
        print("❌ 保存失败: \(error)")
        return false
    }
}

// MARK: - 主函数

@MainActor
func exportIcon() async {
    print("🎨 开始生成应用图标...")

    let view = AppIconView()
    let size = CGSize(width: 1024, height: 1024)

    print("📐 渲染图标视图 (1024x1024)...")

    guard let image = renderViewToImage(view, size: size) else {
        print("❌ 渲染失败")
        exit(1)
    }

    print("✅ 渲染完成")

    // 获取项目路径
    let currentPath = FileManager.default.currentDirectoryPath
    let iconPath = "\(currentPath)/Digital-Prayer-Wheel-iOS/Assets.xcassets/AppIcon.appiconset/1024x1024.png"
    let iconURL = URL(fileURLWithPath: iconPath)

    print("💾 保存到: \(iconPath)")

    if saveImageAsPNG(image, to: iconURL) {
        print("✅ 图标导出成功！")
        print("📍 文件位置: \(iconPath)")
    } else {
        print("❌ 保存失败")
        exit(1)
    }
}

// 运行导出
await exportIcon()
print("🎉 完成！")
