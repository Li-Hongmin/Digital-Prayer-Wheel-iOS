//
//  BuddhistTeachingsView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 佛学教导可折叠视图（往生正因、观无量寿佛经）
struct BuddhistTeachingsView: View {
    var initiallyExpanded: Bool = false
    @State private var expandedSections: Set<String> = []
    @Environment(\.responsiveScale) var responsiveScale

    let teachings = [
        (
            id: "vows",
            title: "普贤十大愿",
            icon: "book.circle.fill",
            content: [
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
        ),
        (
            id: "purelands",
            title: "净业正因",
            icon: "heart.circle.fill",
            content: [
                "1. 孝养父母，奉事师长；慈心不杀，修十善业。",
                "",
                "2. 受持三归，具足众戒，不犯威仪。",
                "",
                "3. 发菩提心，深信因果；读诵大乘，劝进行者。"
            ]
        )
    ]

    private func toggleSection(_ id: String) {
        if expandedSections.contains(id) {
            expandedSections.remove(id)
        } else {
            expandedSections.insert(id)
        }
    }

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()

        VStack(spacing: scale.size(8)) {
            ForEach(teachings, id: \.id) { teaching in
                VStack(spacing: 0) {
                    // 标题行
                    HStack(spacing: scale.size(8)) {
                        Image(systemName: teaching.icon)
                            .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                            .font(.system(size: scale.fontSize(12)))

                        Text(teaching.title)
                            .font(.system(size: scale.fontSize(12), weight: .semibold))
                            .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))

                        Spacer()

                        Image(systemName: expandedSections.contains(teaching.id) ? "chevron.up" : "chevron.down")
                            .font(.system(size: scale.fontSize(10), weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    .padding(.horizontal, scale.size(12))
                    .padding(.vertical, scale.size(8))
                    .background(Color(red: 0.18, green: 0.18, blue: 0.20))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            toggleSection(teaching.id)
                        }
                    }

                    // 内容区
                    if expandedSections.contains(teaching.id) {
                        VStack(alignment: .leading, spacing: scale.size(8)) {
                            if teaching.id == "vows" {
                                // 普贤十大愿 - 两行，每行5个
                                VStack(alignment: .leading, spacing: scale.size(6)) {
                                    // 第一行 1-5
                                    HStack(spacing: scale.size(12)) {
                                        ForEach(0..<5, id: \.self) { index in
                                            Text("\(index + 1). \(teaching.content[index])")
                                                .font(.system(size: scale.fontSize(10), weight: .regular))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }

                                    // 第二行 6-10
                                    HStack(spacing: scale.size(12)) {
                                        ForEach(5..<10, id: \.self) { index in
                                            Text("\(index + 1). \(teaching.content[index])")
                                                .font(.system(size: scale.fontSize(10), weight: .regular))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                            } else {
                                // 往生正因 - 常规排列
                                VStack(alignment: .leading, spacing: scale.size(6)) {
                                    ForEach(Array(teaching.content.enumerated()), id: \.offset) { index, line in
                                        if line.isEmpty {
                                            // 空行用于分隔
                                            Divider()
                                                .background(Color.white.opacity(0.1))
                                                .padding(.vertical, scale.size(2))
                                        } else {
                                            Text(line)
                                                .font(.system(size: scale.fontSize(11), weight: .regular))
                                                .foregroundColor(.white)
                                                .lineLimit(nil)
                                        }
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
            }
        }
        .onAppear {
            if initiallyExpanded {
                expandedSections = Set(teachings.map { $0.id })
            }
        }
    }
}

#Preview {
    BuddhistTeachingsView()
        .padding()
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
}
