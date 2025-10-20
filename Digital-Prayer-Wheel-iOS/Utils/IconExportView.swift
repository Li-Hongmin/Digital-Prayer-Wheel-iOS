//
//  IconExportView.swift
//  Digital-Prayer-Wheel-iOS
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 图标导出工具视图
/// 用于将生成的图标保存到相册或文件
struct IconExportView: View {
    @State private var exportStatus: String = "准备导出图标"
    @State private var showShareSheet = false
    @State private var imageToShare: UIImage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("应用图标生成器")
                    .font(.title.bold())
                    .padding(.top, 40)

                // 预览图标
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        VStack {
                            AppIconView()
                                .frame(width: 200, height: 200)
                                .cornerRadius(44)  // iOS 图标圆角
                            Text("标准模式")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack {
                            AppIconViewDark()
                                .frame(width: 200, height: 200)
                                .cornerRadius(44)
                            Text("深色模式")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack {
                            AppIconViewTinted()
                                .frame(width: 200, height: 200)
                                .cornerRadius(44)
                            Text("Tinted 模式")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }

                Divider()

                // 导出按钮
                VStack(spacing: 15) {
                    Button(action: {
                        exportIcon(type: .standard)
                    }) {
                        Label("导出标准图标 (1024x1024)", systemImage: "square.and.arrow.down")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        exportIcon(type: .dark)
                    }) {
                        Label("导出深色图标 (1024x1024)", systemImage: "moon.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        exportIcon(type: .tinted)
                    }) {
                        Label("导出 Tinted 图标 (1024x1024)", systemImage: "paintpalette.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        exportAllIcons()
                    }) {
                        Label("导出全部三个图标", systemImage: "square.3.layers.3d")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                // 状态提示
                Text(exportStatus)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer()

                // 使用说明
                VStack(alignment: .leading, spacing: 8) {
                    Text("使用说明：")
                        .font(.headline)
                    Text("1. 点击导出按钮保存图标到相册")
                    Text("2. 从相册中复制图标")
                    Text("3. 在 Xcode 中打开 Assets.xcassets")
                    Text("4. 将图标粘贴到 AppIcon 中")
                    Text("5. 确保图标尺寸为 1024x1024")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = imageToShare {
                ShareSheet(items: [image])
            }
        }
    }

    enum IconType {
        case standard, dark, tinted
    }

    @MainActor
    private func exportIcon(type: IconType) {
        let view: AnyView
        let name: String

        switch type {
        case .standard:
            view = AnyView(AppIconView())
            name = "标准图标"
        case .dark:
            view = AnyView(AppIconViewDark())
            name = "深色图标"
        case .tinted:
            view = AnyView(AppIconViewTinted())
            name = "Tinted 图标"
        }

        if let image = view.asUIImage() {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            exportStatus = "\(name)已保存到相册 ✓"

            // 也准备分享
            imageToShare = image
        } else {
            exportStatus = "导出失败 ✗"
        }
    }

    @MainActor
    private func exportAllIcons() {
        var successCount = 0

        // 导出标准图标
        if let image = AppIconView().asUIImage() {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            successCount += 1
        }

        // 导出深色图标
        if let image = AppIconViewDark().asUIImage() {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            successCount += 1
        }

        // 导出 Tinted 图标
        if let image = AppIconViewTinted().asUIImage() {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            successCount += 1
        }

        exportStatus = "已保存 \(successCount) 个图标到相册 ✓"
    }
}

// MARK: - ShareSheet for iOS

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    IconExportView()
}
