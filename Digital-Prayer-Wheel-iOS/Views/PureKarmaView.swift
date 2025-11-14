//
//  PureKarmaView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 净业正因单独可折叠视图
struct PureKarmaView: View {
    var initiallyExpanded: Bool = true  // 默认展开
    @State private var isExpanded: Bool = true  // 默认展开
    @Environment(\.responsiveScale) var responsiveScale

    let content = [
        ["孝养父母，奉事师长；", "慈心不杀，修十善业。"],
        ["受持三归，具足众戒，", "不犯威仪。"],
        ["发菩提心，深信因果；", "读诵大乘，劝进行者。"]
    ]

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()

        VStack(spacing: 0) {
            // 标题行
            HStack(spacing: scale.size(8)) {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                    .font(.system(size: scale.fontSize(16)))

                Text("净业正因")
                    .font(.system(size: scale.fontSize(16), weight: .semibold))
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

            // 内容区
            if isExpanded {
                VStack(alignment: .leading, spacing: scale.size(12)) {
                    ForEach(Array(content.enumerated()), id: \.offset) { index, lines in
                        HStack(alignment: .top, spacing: scale.size(8)) {
                            Text("\(index + 1)")
                                .font(.system(size: scale.fontSize(18), weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))

                            VStack(alignment: .leading, spacing: scale.size(4)) {
                                ForEach(lines, id: \.self) { line in
                                    Text(line)
                                        .font(.system(size: scale.fontSize(18), weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(nil)
                                }
                            }
                        }

                        if index < content.count - 1 {
                            Divider()
                                .background(Color.white.opacity(0.1))
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
    PureKarmaView()
        .padding()
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
}
