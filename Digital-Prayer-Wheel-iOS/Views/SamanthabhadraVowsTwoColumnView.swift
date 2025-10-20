//
//  SamanthabhadraVowsTwoColumnView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 普贤十大愿两列展示视图（iPhone 下方）
struct SamanthabhadraVowsTwoColumnView: View {
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
        VStack(spacing: 0) {
            // 标题
            Text("普贤十大愿")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                .padding(.vertical, 8)

            // 两列布局
            HStack(spacing: 20) {
                // 左列 - 前 5 个
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<5, id: \.self) { index in
                        HStack(spacing: 8) {
                            Text("\(index + 1)")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                .frame(width: 16)

                            Text(vows[index])
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white)

                            Spacer()
                        }
                    }
                }

                // 右列 - 后 5 个
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(5..<10, id: \.self) { index in
                        HStack(spacing: 8) {
                            Text("\(index + 1)")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                .frame(width: 16)

                            Text(vows[index])
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white)

                            Spacer()
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        .cornerRadius(8)
    }
}

#Preview {
    SamanthabhadraVowsTwoColumnView()
        .padding()
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
}
