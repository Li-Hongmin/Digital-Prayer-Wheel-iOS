//
//  DedicationVerseView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 回向偈显示视图
struct DedicationVerseView: View {
    @ObservedObject var settings: AppSettings
    var compactMode: Bool = false  // 紧凑模式（横屏底部使用）
    @Environment(\.responsiveScale) var responsiveScale
    @State private var isExpanded: Bool = true  // 默认展开

    let verses = [
        1: [
            "愿以此功德。庄严佛净土。",
            "上报四重恩。下济三途苦。",
            "若有见闻者。悉发菩提心。",
            "尽此一报身。同生极乐国。"
        ],
        2: [
            "愿以此功德，普及于一切。",
            "我等与众生，皆共成佛道。",
            "愿以此功德，平等施一切，",
            "同发菩提心，往生安乐国。"
        ],
        3: [
            "愿我临近命终时，尽除一切诸障碍，",
            "面见彼佛阿弥陀，即得往生安乐刹。"
        ],
        4: [
            "愿生西方净土中，九品莲花为父母。",
            "花开见佛悟无生，不退菩萨为伴侣。"
        ]
    ]

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()
        let currentVerse = verses[settings.selectedDedicationVerse] ?? verses[1]!

        if compactMode {
            // 紧凑模式：横屏底部横向两行显示，无折叠功能
            VStack(alignment: .center, spacing: scale.size(4)) {
                // 标题（小号）
                HStack(spacing: scale.size(6)) {
                    Image(systemName: "hands.sparkles.fill")
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                        .font(.system(size: scale.fontSize(10)))

                    Text("回向偈")
                        .font(.system(size: scale.fontSize(10), weight: .semibold))
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                }

                // 内容 - 两行横向显示
                VStack(alignment: .center, spacing: scale.size(3)) {
                    // 第一行
                    HStack(spacing: scale.size(8)) {
                        ForEach(0..<min(2, currentVerse.count), id: \.self) { index in
                            Text(currentVerse[index])
                                .font(.system(size: scale.fontSize(11), weight: .regular))
                                .foregroundColor(.white)
                        }
                    }

                    // 第二行
                    if currentVerse.count > 2 {
                        HStack(spacing: scale.size(8)) {
                            ForEach(2..<currentVerse.count, id: \.self) { index in
                                Text(currentVerse[index])
                                    .font(.system(size: scale.fontSize(11), weight: .regular))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, scale.size(12))
            .padding(.vertical, scale.size(6))
            .background(Color(red: 0.15, green: 0.15, blue: 0.17))
            .cornerRadius(scale.size(6))
        } else {
            // 正常模式：可折叠
            VStack(spacing: 0) {
                // 标题
                HStack(spacing: scale.size(8)) {
                    Image(systemName: "hands.sparkles.fill")
                        .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                        .font(.system(size: scale.fontSize(12)))

                    Text("回向偈")
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

                // 回向偈内容 - 两行显示
                if isExpanded {
                    VStack(alignment: .center, spacing: scale.size(3)) {
                    // 第一行
                    HStack(spacing: scale.size(8)) {
                        ForEach(0..<min(2, currentVerse.count), id: \.self) { index in
                            Text(currentVerse[index])
                                .font(.system(size: scale.fontSize(13), weight: .regular))
                                .foregroundColor(.white)
                        }
                    }

                    // 第二行
                    if currentVerse.count > 2 {
                        HStack(spacing: scale.size(8)) {
                            ForEach(2..<currentVerse.count, id: \.self) { index in
                                Text(currentVerse[index])
                                    .font(.system(size: scale.fontSize(13), weight: .regular))
                                    .foregroundColor(.white)
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
}

#Preview {
    DedicationVerseView(settings: AppSettings())
        .padding()
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
}
