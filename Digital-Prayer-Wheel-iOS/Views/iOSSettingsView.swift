//
//  iOSSettingsView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// iOS-specific settings view
struct iOSSettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var prayerLibrary: PrayerLibrary
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("应用设置")
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
                    VStack(alignment: .leading, spacing: 12) {
                        // 经文选择
                        VStack(alignment: .leading, spacing: 8) {
                            Text("选择经文")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)

                            HStack(spacing: 10) {
                                Picker("", selection: $settings.selectedPrayerType) {
                                    ForEach(PrayerType.allCases) { type in
                                        Text(type.rawValue).tag(type.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity)
                                .onChange(of: settings.selectedPrayerType) { _, newValue in
                                    if let prayerType = PrayerType(rawValue: newValue) {
                                        prayerLibrary.setType(prayerType)
                                    }
                                }
                            }

                            if let prayerType = PrayerType(rawValue: settings.selectedPrayerType) {
                                Text(prayerType.description)
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                        // 重置计数
                        VStack(alignment: .leading, spacing: 8) {
                            Text("管理计数")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)

                            Button(action: {
                                prayerLibrary.resetCount()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.clockwise")
                                    Text("重置计数")
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                        // 转经速度设置
                        VStack(alignment: .leading, spacing: 8) {
                            Text("转经速度")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)

                            let speedLevels = [
                                ("慢", 6),
                                ("标准", 30),
                                ("快", 60),
                                ("飞速", 600)
                            ]

                            Picker("速度", selection: Binding(
                                get: { speedLevels.firstIndex(where: { $0.1 == Int(prayerLibrary.rotationSpeed) }) ?? 1 },
                                set: { if $0 < speedLevels.count {
                                    prayerLibrary.rotationSpeed = Double(speedLevels[$0].1)
                                }}
                            )) {
                                ForEach(0..<speedLevels.count, id: \.self) { index in
                                    Text(speedLevels[index].0)
                                        .font(.system(size: 12, weight: .medium))
                                        .tag(index)
                                }
                            }
                            .pickerStyle(.segmented)

                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("当前速度")
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundColor(.secondary)

                                    let rps = prayerLibrary.rotationSpeed / 60.0
                                    Text("\(Int(prayerLibrary.rotationSpeed)) 圈/分钟 • \(String(format: "%.1f", rps)) 圈/秒")
                                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.primary)
                                }

                                Spacer()
                            }

                            VStack(spacing: 4) {
                                Text("精细调整")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)

                                Slider(value: $prayerLibrary.rotationSpeed, in: 6...600, step: 1)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                        // 应用行为设置
                        VStack(alignment: .leading, spacing: 8) {
                            Text("应用行为")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)

                            VStack(spacing: 12) {
                                // 防止息屏
                                Toggle(isOn: $settings.keepScreenOn) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "sun.max.fill")
                                            .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                            .frame(width: 20)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("防止息屏")
                                                .font(.system(size: 13, weight: .semibold))
                                            Text("转经时保持屏幕常亮")
                                                .font(.system(size: 10, weight: .regular))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .tint(Color(red: 0.99, green: 0.84, blue: 0.15))

                                Divider()

                                // 后台运行
                                Toggle(isOn: $settings.keepBackgroundActive) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "play.circle.fill")
                                            .foregroundColor(Color(red: 0.99, green: 0.84, blue: 0.15))
                                            .frame(width: 20)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("后台运行")
                                                .font(.system(size: 13, weight: .semibold))
                                            Text("切换到其他应用时继续转经")
                                                .font(.system(size: 10, weight: .regular))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .tint(Color(red: 0.99, green: 0.84, blue: 0.15))
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                        // 回向偈选择
                        VStack(alignment: .leading, spacing: 8) {
                            Text("回向偈")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)

                            Picker("回向偈", selection: $settings.selectedDedicationVerse) {
                                Text("回向偈一").tag(1)
                                Text("回向偈二").tag(2)
                                Text("回向偈三").tag(3)
                                Text("回向偈四").tag(4)
                            }
                            .pickerStyle(.segmented)

                            // 预览当前选择的回向偈
                            let verses: [Int: [String]] = [
                                1: ["愿以此功德。庄严佛净土。", "上报四重恩。下济三途苦。"],
                                2: ["愿以此功德，普及于一切。", "我等与众生，皆共成佛道。"],
                                3: ["愿我临近命终时，尽除一切诸障碍，", "面见彼佛阿弥陀，即得往生安乐刹。"],
                                4: ["愿生西方净土中，九品莲花为父母。", "花开见佛悟无生，不退菩萨为伴侣。"]
                            ]
                            let currentVerse = verses[settings.selectedDedicationVerse] ?? verses[1]!

                            VStack(alignment: .center, spacing: 3) {
                                // 第一行（前两句）
                                HStack(spacing: 6) {
                                    Text(currentVerse[0])
                                        .font(.system(size: 9, weight: .regular))
                                        .foregroundColor(.secondary)
                                    if currentVerse.count > 1 {
                                        Text(currentVerse[1])
                                            .font(.system(size: 9, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                }

                                // 第二行（后两句）
                                if currentVerse.count > 2 {
                                    HStack(spacing: 6) {
                                        if currentVerse.count > 2 {
                                            Text(currentVerse[2])
                                                .font(.system(size: 9, weight: .regular))
                                                .foregroundColor(.secondary)
                                        }
                                        if currentVerse.count > 3 {
                                            Text(currentVerse[3])
                                                .font(.system(size: 9, weight: .regular))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                        Spacer()
                    }
                }
            }
            .padding(16)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    iOSSettingsView(
        settings: AppSettings(),
        prayerLibrary: PrayerLibrary()
    )
}
