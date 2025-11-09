#!/usr/bin/swift

import Foundation
import AppKit

// 转经轮应用图标生成脚本
// 生成金黄色背景 + 卍字符的图标

func generateIcon(size: CGSize, scale: CGFloat = 1.0) -> NSImage? {
    let actualSize = CGSize(width: size.width * scale, height: size.height * scale)
    let image = NSImage(size: actualSize)

    image.lockFocus()

    // 深色背景（和应用背景一致）
    let bgColor = NSColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0)
    bgColor.setFill()
    NSRect(origin: .zero, size: actualSize).fill()

    let center = CGPoint(x: actualSize.width / 2, y: actualSize.height / 2)
    let radius = actualSize.width * 0.40

    // 外圈：金色渐变描边
    let outerCircle = NSBezierPath(
        ovalIn: NSRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )
    )
    let outerGradient = NSGradient(colors: [
        NSColor(red: 0.99, green: 0.84, blue: 0.15, alpha: 1.0),
        NSColor(red: 0.96, green: 0.78, blue: 0.10, alpha: 1.0)
    ])
    outerGradient?.draw(in: outerCircle, angle: -45)

    // 中间圆盘：金色渐变填充
    let middleRadius = radius * 0.9375
    let middleCircle = NSBezierPath(
        ovalIn: NSRect(
            x: center.x - middleRadius,
            y: center.y - middleRadius,
            width: middleRadius * 2,
            height: middleRadius * 2
        )
    )
    let middleGradient = NSGradient(colors: [
        NSColor(red: 0.90, green: 0.82, blue: 0.55, alpha: 1.0),
        NSColor(red: 0.75, green: 0.63, blue: 0.35, alpha: 1.0)
    ])
    middleGradient?.draw(in: middleCircle, angle: -45)

    // 内圈：金色描边
    let innerRadius = radius * 0.875
    let innerCircle = NSBezierPath(
        ovalIn: NSRect(
            x: center.x - innerRadius,
            y: center.y - innerRadius,
            width: innerRadius * 2,
            height: innerRadius * 2
        )
    )
    NSColor(red: 0.99, green: 0.84, blue: 0.15, alpha: 1.0).setStroke()
    innerCircle.lineWidth = actualSize.width * 0.01
    innerCircle.stroke()

    // 绘制卍字（白色）
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: actualSize.width * 0.48, weight: .bold),
        .foregroundColor: NSColor.white
    ]
    let text = "卍" as NSString
    let textSize = text.size(withAttributes: attributes)
    let textRect = NSRect(
        x: (actualSize.width - textSize.width) / 2,
        y: (actualSize.height - textSize.height) / 2 - actualSize.height * 0.02,
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
    // iPhone Notification (20pt)
    (CGSize(width: 20, height: 20), 2.0, "Icon-20@2x.png"),      // 40x40
    (CGSize(width: 20, height: 20), 3.0, "Icon-20@3x.png"),      // 60x60
    // iPhone Settings (29pt)
    (CGSize(width: 29, height: 29), 2.0, "Icon-29@2x.png"),      // 58x58
    (CGSize(width: 29, height: 29), 3.0, "Icon-29@3x.png"),      // 87x87
    // iPhone Spotlight (40pt)
    (CGSize(width: 40, height: 40), 2.0, "Icon-40@2x.png"),      // 80x80
    (CGSize(width: 40, height: 40), 3.0, "Icon-40@3x.png"),      // 120x120
    // iPhone App (60pt)
    (CGSize(width: 60, height: 60), 2.0, "Icon-60@2x.png"),      // 120x120
    (CGSize(width: 60, height: 60), 3.0, "Icon-60@3x.png"),      // 180x180
    // iPad Notifications (20pt)
    (CGSize(width: 20, height: 20), 1.0, "Icon-20@1x.png"),      // 20x20
    (CGSize(width: 20, height: 20), 2.0, "Icon-20@2x-ipad.png"), // 40x40
    // iPad Settings (29pt)
    (CGSize(width: 29, height: 29), 1.0, "Icon-29@1x.png"),      // 29x29
    (CGSize(width: 29, height: 29), 2.0, "Icon-29@2x-ipad.png"), // 58x58
    // iPad Spotlight (40pt)
    (CGSize(width: 40, height: 40), 1.0, "Icon-40@1x.png"),      // 40x40
    (CGSize(width: 40, height: 40), 2.0, "Icon-40@2x-ipad.png"), // 80x80
    // iPad App (76pt)
    (CGSize(width: 76, height: 76), 1.0, "Icon-76@1x.png"),      // 76x76
    (CGSize(width: 76, height: 76), 2.0, "Icon-76@2x.png"),      // 152x152
    // iPad Pro (83.5pt)
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
