//
//  BuddhistTeachingsView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 佛学教导可折叠视图（往生正因、观无量寿佛经）
struct BuddhistTeachingsView: View {
    @State private var expandedSections: Set<String> = []

    let teachings = [
        (
            id: "vows",
            title: "普贤十大愿",
            icon: "book.circle.fill",
            content: [
                "一者，礼敬诸佛",
                "二者，称赞如来",
                "三者，广修供养",
                "四者，忏悔业障",
                "五者，随喜功德",
                "六者，请转法轮",
                "七者，请佛住世",
                "八者，常随佛学",
                "九者，恒顺众生",
                "十者，普皆回向"
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
        VStack(spacing: 8) {
            ForEach(teachings, id: \.id) { teaching in
                VStack(spacing: 0) {
                    // 标题行
                    HStack(spacing: 8) {
                        Image(systemName: teaching.icon)
                            .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                            .font(.system(size: 12))

                        Text(teaching.title)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))

                        Spacer()

                        Image(systemName: expandedSections.contains(teaching.id) ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.18, green: 0.18, blue: 0.20))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            toggleSection(teaching.id)
                        }
                    }

                    // 内容区
                    if expandedSections.contains(teaching.id) {
                        VStack(alignment: .leading, spacing: 8) {
                            if teaching.id == "vows" {
                                // 普贤十大愿 - 两行，每行5个
                                VStack(alignment: .leading, spacing: 6) {
                                    // 第一行 1-5
                                    HStack(spacing: 12) {
                                        ForEach(0..<5, id: \.self) { index in
                                            Text("\(index + 1). \(teaching.content[index])")
                                                .font(.system(size: 10, weight: .regular))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }

                                    // 第二行 6-10
                                    HStack(spacing: 12) {
                                        ForEach(5..<10, id: \.self) { index in
                                            Text("\(index + 1). \(teaching.content[index])")
                                                .font(.system(size: 10, weight: .regular))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                            } else {
                                // 往生正因 - 常规排列
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(Array(teaching.content.enumerated()), id: \.offset) { index, line in
                                        if line.isEmpty {
                                            // 空行用于分隔
                                            Divider()
                                                .background(Color.white.opacity(0.1))
                                                .padding(.vertical, 2)
                                        } else {
                                            Text(line)
                                                .font(.system(size: 11, weight: .regular))
                                                .foregroundColor(.white)
                                                .lineLimit(nil)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                    }
                }
                .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                .cornerRadius(8)
            }
        }
    }
}

#Preview {
    BuddhistTeachingsView()
        .padding()
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
}
