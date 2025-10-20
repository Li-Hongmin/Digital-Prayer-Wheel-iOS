//
//  SamanthabhadraVowsView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 普贤十大愿展示视图
struct SamanthabhadraVowsView: View {
    @State private var isExpanded: Bool = false

    let vows = [
        ("礼敬诸佛", "礼敬诸佛"),
        ("称赞如来", "称赞如来"),
        ("广修供养", "广修供养"),
        ("忏悔业障", "忏悔业障"),
        ("随喜功德", "随喜功德"),
        ("请转法轮", "请转法轮"),
        ("请佛住世", "请佛住世"),
        ("常随佛学", "常随佛学"),
        ("恒顺众生", "恒顺众生"),
        ("普皆回向", "普皆回向")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 标题行
            HStack(spacing: 4) {
                Image(systemName: "book.circle.fill")
                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                    .font(.system(size: 12))

                Text("普贤十大愿")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(red: 0.18, green: 0.18, blue: 0.20))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }

            // 内容区
            if isExpanded {
                VStack(spacing: 6) {
                    ForEach(Array(vows.enumerated()), id: \.offset) { index, vow in
                        HStack(spacing: 8) {
                            Text("\(index + 1)")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                .frame(width: 16)

                            Text(vow.0)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white)

                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)

                        if index < vows.count - 1 {
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 12)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
            }
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
        .cornerRadius(8)
    }
}

#Preview {
    SamanthabhadraVowsView()
        .padding()
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
}
