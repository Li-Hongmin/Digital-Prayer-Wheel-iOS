//
//  SamanthabhadraVowsTwoColumnView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 普贤十大愿两列展示视图（iPhone 下方）
struct SamanthabhadraVowsTwoColumnView: View {
    var initiallyExpanded: Bool = false
    @State private var isExpanded: Bool = false
    @Environment(\.responsiveScale) var responsiveScale

    let vows = [
        "礼敬诸佛",
        "称赞如来",
        "广修供养",
        "忏悔业障",
        "随喜功德",
        "请转法轮",
        "请佛住世",
        "常随佛学",
        "恒顺众生",
        "普皆回向"
    ]

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()

        VStack(spacing: 0) {
            // 标题
            HStack(spacing: scale.size(8)) {
                Image(systemName: "book.circle.fill")
                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                    .font(.system(size: scale.fontSize(12)))

                Text("普贤十大愿")
                    .font(.system(size: scale.fontSize(12), weight: .semibold))
                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: scale.fontSize(10), weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.6))
            }
            .padding(.horizontal, scale.size(12))
            .padding(.vertical, scale.size(8))
            .background(Color(red: 0.18, green: 0.18, blue: 0.20))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }

            // 两列布局
            if isExpanded {
                HStack(spacing: scale.size(20)) {
                // 左列 - 前 5 个
                VStack(alignment: .leading, spacing: scale.size(8)) {
                    ForEach(0..<5, id: \.self) { index in
                        HStack(spacing: scale.size(8)) {
                            Text("\(index + 1)")
                                .font(.system(size: scale.fontSize(13), weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                .frame(width: scale.size(18))

                            Text(vows[index])
                                .font(.system(size: scale.fontSize(13), weight: .medium))
                                .foregroundColor(.white)

                            Spacer()
                        }
                    }
                }

                // 右列 - 后 5 个
                VStack(alignment: .leading, spacing: scale.size(8)) {
                    ForEach(5..<10, id: \.self) { index in
                        HStack(spacing: scale.size(8)) {
                            Text("\(index + 1)")
                                .font(.system(size: scale.fontSize(13), weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                .frame(width: scale.size(18))

                            Text(vows[index])
                                .font(.system(size: scale.fontSize(13), weight: .medium))
                                .foregroundColor(.white)

                            Spacer()
                        }
                    }
                }
            }
            .padding(.horizontal, scale.size(12))
            .padding(.vertical, scale.size(8))
            .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        }
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
        .cornerRadius(scale.size(8))
        .onAppear {
            isExpanded = initiallyExpanded
        }
    }
}

#Preview {
    SamanthabhadraVowsTwoColumnView()
        .padding()
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
}
