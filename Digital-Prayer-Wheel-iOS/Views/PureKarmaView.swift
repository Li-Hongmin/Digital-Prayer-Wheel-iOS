//
//  PureKarmaView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 净业正因单独可折叠视图
struct PureKarmaView: View {
    @State private var isExpanded: Bool = false

    let content = [
        "1. 孝养父母，奉事师长；慈心不杀，修十善业。",
        "",
        "2. 受持三归，具足众戒，不犯威仪。",
        "",
        "3. 发菩提心，深信因果；读诵大乘，劝进行者。"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 标题行
            HStack(spacing: 8) {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                    .font(.system(size: 12))

                Text("净业正因")
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
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(content.enumerated()), id: \.offset) { index, line in
                        if line.isEmpty {
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
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
            }
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
        .cornerRadius(8)
    }
}

#Preview {
    PureKarmaView()
        .padding()
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
}
