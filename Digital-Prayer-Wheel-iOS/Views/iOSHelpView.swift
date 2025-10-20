//
//  iOSHelpView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// iOS-specific help view with user guide
struct iOSHelpView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("使用帮助")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 基本操作
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "hand.tap.fill")
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                    .frame(width: 24)
                                Text("基本操作")
                                    .font(.system(size: 14, weight: .semibold))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("• 打开应用时，转经筒会自动旋转开始计数")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.secondary)

                                Text("• 点击转经筒可暂停或恢复旋转")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.secondary)

                                Text("• 长按转经筒可获得更多选项")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                        // 计数说明
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "number.circle.fill")
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                    .frame(width: 24)
                                Text("计数说明")
                                    .font(.system(size: 14, weight: .semibold))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("本次转经数")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.primary)

                                Text("显示当前修行周期内的转经数。采用指数增长方式，每完成一圈转经筒就翻倍增长，创造加速度的修行体验。")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)

                                Text("总转数")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.top, 4)

                                Text("记录当前经文的所有转经累计数。每旋转一圈就增加 1，用于追踪长期的修行成果。")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                        // 经文选择
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "book.fill")
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                    .frame(width: 24)
                                Text("经文类型")
                                    .font(.system(size: 14, weight: .semibold))
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 8) {
                                    Text("🕉️")
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("六字大明咒")
                                            .font(.system(size: 12, weight: .semibold))
                                        Text("嗡嘛呢叭咪吽 - 观音菩萨心咒，具有无边功德")
                                            .font(.system(size: 10, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                }

                                HStack(spacing: 8) {
                                    Text("📿")
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("心经")
                                            .font(.system(size: 12, weight: .semibold))
                                        Text("般若波罗蜜多心经，佛法精髓")
                                            .font(.system(size: 10, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                }

                                HStack(spacing: 8) {
                                    Text("☀️")
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("南无阿弥陀佛")
                                            .font(.system(size: 12, weight: .semibold))
                                        Text("阿弥陀佛佛号，净土法门")
                                            .font(.system(size: 10, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                }

                                HStack(spacing: 8) {
                                    Text("✨")
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("南无观世音菩萨")
                                            .font(.system(size: 12, weight: .semibold))
                                        Text("观世音菩萨佛号，大慈大悲")
                                            .font(.system(size: 10, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                        // 佛学教导
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "book.pages.fill")
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                    .frame(width: 24)
                                Text("佛学教导")
                                    .font(.system(size: 14, weight: .semibold))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("普贤十大愿")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.primary)

                                Text("普贤菩萨的十大行愿，是修行成佛的根本法门。包括礼敬诸佛、称赞如来、广修供养等十项殊胜大愿。")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)

                                Text("净业正因")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.top, 4)

                                Text("出自《观无量寿佛经》，是往生净土的三种正因。包括孝养父母奉事师长、受持三归具足众戒、发菩提心深信因果三大福业。")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)

                                Text("点击界面下方的可折叠卡片即可查看完整内容。")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                        // 速度调整
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "speedometer")
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                    .frame(width: 24)
                                Text("速度调整")
                                    .font(.system(size: 14, weight: .semibold))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("在应用设置中可以调整转经筒的旋转速度：")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.secondary)

                                Text("• 慢 - 6 圈/分钟，适合深度冥想")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)

                                Text("• 标准 - 30 圈/分钟，平衡速度")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)

                                Text("• 快 - 60 圈/分钟，高效修行")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)

                                Text("• 飞速 - 600 圈/分钟，快速积累")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                        // 数据持久化
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                    .frame(width: 24)
                                Text("修行建议")
                                    .font(.system(size: 14, weight: .semibold))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("• 每日坚持，持之以恒效果最佳")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.secondary)

                                Text("• 选择自己相应的经文类型进行修持")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.secondary)

                                Text("• 根据自己的修行速度调整转经筒的旋转速度")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.secondary)

                                Text("• 你的计数数据会自动保存，无需担心丢失")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
            .padding(16)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    iOSHelpView()
}
