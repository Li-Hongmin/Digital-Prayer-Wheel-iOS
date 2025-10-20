#!/usr/bin/swift

import Foundation
import AppKit

// 转经轮应用图标生成脚本
// 生成金黄色背景 + 卍字符的图标

func generateIcon(size: CGSize, scale: CGFloat = 1.0) -> NSImage? {
    let actualSize = CGSize(width: size.width * scale, height: size.height * scale)
    let image = NSImage(size: actualSize)

    image.lockFocus()

    // 金黄色渐变背景
    let gradient = NSGradient(colors: [
        NSColor(red: 0.99, green: 0.84, blue: 0.15, alpha: 1.0),
        NSColor(red: 0.96, green: 0.78, blue: 0.10, alpha: 1.0)
    ])
    gradient?.draw(in: NSRect(origin: .zero, size: actualSize), angle: -45)

    // 绘制圆形边框
    let borderPath = NSBezierPath(ovalIn: NSRect(
        x: actualSize.width * 0.05,
        y: actualSize.height * 0.05,
        width: actualSize.width * 0.9,
        height: actualSize.height * 0.9
    ))
    NSColor.white.setStroke()
    borderPath.lineWidth = actualSize.width * 0.03
    borderPath.stroke()

    // 绘制卍字
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: actualSize.width * 0.5, weight: .bold),
        .foregroundColor: NSColor.white
    ]
    let text = "卍" as NSString
    let textSize = text.size(withAttributes: attributes)
    let textRect = NSRect(
        x: (actualSize.width - textSize.width) / 2,
        y: (actualSize.height - textSize.height) / 2,
        width: textSize.width,
        height: textSize.height
    )
    text.draw(in: textRect, withAttributes: attributes)

    image.unlockFocus()
    return image
}

func saveImage(_ image: NSImage, to path: String) -> Bool {
    guard let tiffData = image.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
        return false
    }

    let url = URL(fileURLWithPath: path)
    do {
        try pngData.write(to: url)
        return true
    } catch {
        print("❌ 保存失败: \(error)")
        return false
    }
}

// 主程序
print("🎨 开始生成应用图标...")

let baseDir = "/Users/lihongmin/Dev/Digital-Prayer-Wheel-iOS/Digital-Prayer-Wheel-iOS/Assets.xcassets/AppIcon.appiconset"

// 需要生成的图标尺寸
let iconSizes: [(size: CGSize, scale: CGFloat, filename: String)] = [
    // iPhone
    (CGSize(width: 60, height: 60), 2.0, "Icon-60@2x.png"),      // 120x120
    (CGSize(width: 60, height: 60), 3.0, "Icon-60@3x.png"),      // 180x180
    // iPad
    (CGSize(width: 76, height: 76), 2.0, "Icon-76@2x.png"),      // 152x152
    (CGSize(width: 83.5, height: 83.5), 2.0, "Icon-83.5@2x.png"), // 167x167
    // App Store
    (CGSize(width: 1024, height: 1024), 1.0, "Icon-1024.png")    // 1024x1024
]

for (size, scale, filename) in iconSizes {
    if let icon = generateIcon(size: size, scale: scale) {
        let path = "\(baseDir)/\(filename)"
        if saveImage(icon, to: path) {
            let actualSize = Int(size.width * scale)
            print("✅ 已生成: \(filename) (\(actualSize)x\(actualSize))")
        } else {
            print("❌ 生成失败: \(filename)")
        }
    }
}

print("🎉 图标生成完成！")
