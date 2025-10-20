//
//  ShareImageGenerator.swift
//  Digital-Prayer-Wheel-iOS
//
//  Created by Claude on 2025/10/20.
//  功德分享图片生成工具
//

import SwiftUI
import UIKit

/// 图片生成工具类
class ShareImageGenerator {

    /// 将SwiftUI视图渲染为UIImage
    /// - Parameters:
    ///   - view: 要渲染的SwiftUI视图
    ///   - size: 目标尺寸
    /// - Returns: 渲染后的UIImage
    @MainActor
    static func render<Content: View>(_ view: Content, size: CGSize) -> UIImage? {
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = ProposedViewSize(size)

        // 使用2x缩放以获得高质量图片
        renderer.scale = 2.0

        return renderer.uiImage
    }

    /// 生成功德分享卡片图片
    /// - Parameters:
    ///   - prayerLibrary: 转经数据
    /// - Returns: 生成的UIImage
    @MainActor
    static func generateMeritCard(from prayerLibrary: PrayerLibrary) -> UIImage? {
        let (numberStr, unitStr) = prayerLibrary.formatCountWithChineseUnitsSeparated(prayerLibrary.currentCount)

        let cardView = MeritShareCardView(
            prayerType: prayerLibrary.selectedType.rawValue,
            totalCycles: prayerLibrary.totalCycles,
            exponentialCount: numberStr,
            exponentialUnit: unitStr,
            date: Date()
        )

        // 根据设备类型自动适配尺寸
        #if os(iOS)
        let size: CGSize
        if UIDevice.current.userInterfaceIdiom == .pad {
            size = CGSize(width: 1200, height: 1200)  // iPad 正方形
        } else {
            size = CGSize(width: 1080, height: 1920)  // iPhone 竖屏
        }
        #else
        let size = CGSize(width: 1080, height: 1920)
        #endif

        return render(cardView, size: size)
    }

    /// 保存图片到相册
    /// - Parameter image: 要保存的图片
    /// - Returns: 是否成功
    @MainActor
    static func saveToPhotoLibrary(_ image: UIImage) -> Bool {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        return true
    }
}

/// 系统分享Sheet包装
struct ActivityViewController: UIViewControllerRepresentable {
    let items: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
