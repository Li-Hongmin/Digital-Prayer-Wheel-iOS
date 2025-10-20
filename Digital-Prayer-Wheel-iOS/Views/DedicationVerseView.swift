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
    @Environment(\.responsiveScale) var responsiveScale

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

        VStack(spacing: 0) {
            // 标题
            HStack(spacing: scale.size(8)) {
                Image(systemName: "hands.sparkles.fill")
                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                    .font(.system(size: scale.fontSize(12)))

                Text("回向偈（\(settings.selectedDedicationVerse)）")
                    .font(.system(size: scale.fontSize(12), weight: .semibold))
                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))

                Spacer()
            }
            .padding(.horizontal, scale.size(12))
            .padding(.vertical, scale.size(8))
            .background(Color(red: 0.18, green: 0.18, blue: 0.20))

            // 回向偈内容
            VStack(alignment: .center, spacing: scale.size(4)) {
                ForEach(currentVerse, id: \.self) { line in
                    Text(line)
                        .font(.system(size: scale.fontSize(11), weight: .regular))
                        .foregroundColor(.white)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, scale.size(12))
            .padding(.vertical, scale.size(8))
            .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
        .cornerRadius(scale.size(8))
    }
}

#Preview {
    DedicationVerseView(settings: AppSettings())
        .padding()
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
}
