//
//  MemorialTabletCardView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 牌位人员列表卡片视图
struct MemorialTabletCardView: View {
    @Environment(\.responsiveScale) var responsiveScale
    @ObservedObject var tabletLibrary: TabletLibrary
    @Binding var isPresented: Bool

    /// 牌位类别（吉祥牌位/往生牌位）
    let category: String

    @State private var showAddPerson: Bool = false
    @State private var editingPerson: TabletPerson?
    @State private var personToDelete: TabletPerson?
    @State private var showDeleteConfirmation: Bool = false

    /// 获取当前类别的人员列表
    private var categoryPersons: [TabletPerson] {
        tabletLibrary.getSortedPersons(byCategory: category)
    }

    /// 根据类别返回背景颜色
    private var backgroundColor: Color {
        switch category {
        case "吉祥牌位":
            return Color(red: 0.90, green: 0.11, blue: 0.14) // 红底
        case "往生牌位":
            return Color(red: 1.0, green: 0.84, blue: 0.0)   // 金底
        default:
            return Color(red: 0.90, green: 0.11, blue: 0.14) // 默认红底
        }
    }

    /// 金色边框
    private let borderColor = Color(red: 0.99, green: 0.84, blue: 0.15)

    /// 黑色文字
    private let textColor = Color.black

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()

        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text(category)
                    .font(.system(size: scale.fontSize(20), weight: .bold))
                    .foregroundColor(textColor)

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: scale.fontSize(24)))
                        .foregroundColor(textColor.opacity(0.5))
                }
            }
            .padding(.horizontal, scale.size(16))
            .padding(.vertical, scale.size(12))
            .background(backgroundColor)

            Divider()
                .background(borderColor)

            // 人员列表
            if categoryPersons.isEmpty {
                // 空状态
                VStack(spacing: scale.size(16)) {
                    Spacer()

                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: scale.fontSize(50)))
                        .foregroundColor(textColor.opacity(0.3))

                    Text("暂无人员")
                        .font(.system(size: scale.fontSize(16)))
                        .foregroundColor(textColor.opacity(0.6))

                    Text("点击下方按钮添加\(category)对象")
                        .font(.system(size: scale.fontSize(14)))
                        .foregroundColor(textColor.opacity(0.5))

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // 人员列表
                ScrollView {
                    VStack(spacing: scale.size(12)) {
                        ForEach(categoryPersons) { person in
                            PersonRowView(
                                person: person,
                                onEdit: {
                                    editingPerson = person
                                },
                                onDelete: {
                                    personToDelete = person
                                    showDeleteConfirmation = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, scale.size(16))
                    .padding(.vertical, scale.size(12))
                }
            }

            Divider()
                .background(borderColor)

            // 底部操作栏
            Button(action: {
                showAddPerson = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: scale.fontSize(20)))
                    Text("添加人员")
                        .font(.system(size: scale.fontSize(16), weight: .semibold))
                }
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, scale.size(12))
            }
            .background(backgroundColor.opacity(0.9))
        }
        .background(backgroundColor)
        .cornerRadius(scale.size(12))
        .overlay(
            RoundedRectangle(cornerRadius: scale.size(12))
                .stroke(borderColor, lineWidth: 2)
        )
        .shadow(color: borderColor.opacity(0.3), radius: scale.size(10), x: 0, y: scale.size(4))
        .sheet(isPresented: $showAddPerson) {
            PersonEditView(
                tabletLibrary: tabletLibrary,
                category: category,
                editingPerson: nil
            )
        }
        .sheet(item: $editingPerson) { person in
            PersonEditView(
                tabletLibrary: tabletLibrary,
                category: category,
                editingPerson: person
            )
        }
        .alert("确认删除", isPresented: $showDeleteConfirmation, presenting: personToDelete) { person in
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                tabletLibrary.deletePerson(id: person.id)
            }
        } message: { person in
            Text("确定要删除 \(person.name) 吗？")
        }
    }
}

/// 单个人员行视图
struct PersonRowView: View {
    @Environment(\.responsiveScale) var responsiveScale
    let person: TabletPerson
    let onEdit: () -> Void
    let onDelete: () -> Void

    /// 获取类别对应的行背景色（稍微深一点，增加对比度）
    private var rowBackgroundColor: Color {
        switch person.category {
        case "吉祥牌位":
            return Color(red: 0.75, green: 0.09, blue: 0.12) // 深红底
        case "往生牌位":
            return Color(red: 0.85, green: 0.71, blue: 0.0)   // 深金底
        default:
            return Color(red: 0.75, green: 0.09, blue: 0.12) // 默认深红底
        }
    }

    private let borderColor = Color(red: 0.99, green: 0.84, blue: 0.15)
    private let textColor = Color.black

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()

        HStack(spacing: scale.size(12)) {
            // 左侧图标
            Image(systemName: "person.circle.fill")
                .font(.system(size: scale.fontSize(32)))
                .foregroundColor(borderColor)

            // 中间信息
            VStack(alignment: .leading, spacing: scale.size(4)) {
                Text(person.name)
                    .font(.system(size: scale.fontSize(16), weight: .semibold))
                    .foregroundColor(textColor)

                HStack(spacing: scale.size(8)) {
                    Text(person.formattedDate)
                        .font(.system(size: scale.fontSize(12)))
                        .foregroundColor(textColor.opacity(0.7))

                    if !person.notes.isEmpty {
                        Text("•")
                            .foregroundColor(textColor.opacity(0.5))
                        Text(person.notes)
                            .font(.system(size: scale.fontSize(12)))
                            .foregroundColor(textColor.opacity(0.7))
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            // 右侧操作按钮
            HStack(spacing: scale.size(8)) {
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: scale.fontSize(24)))
                        .foregroundColor(textColor.opacity(0.6))
                }

                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: scale.fontSize(24)))
                        .foregroundColor(textColor.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, scale.size(12))
        .padding(.vertical, scale.size(10))
        .background(rowBackgroundColor)
        .cornerRadius(scale.size(10))
        .overlay(
            RoundedRectangle(cornerRadius: scale.size(10))
                .stroke(borderColor.opacity(0.5), lineWidth: 1)
        )
    }
}

#Preview("吉祥牌位") {
    struct PreviewContainer: View {
        @State private var isPresented = true
        let library: TabletLibrary

        init() {
            let lib = TabletLibrary()
            lib.addPerson(TabletPerson(name: "张三", category: "吉祥牌位", notes: "家人"))
            lib.addPerson(TabletPerson(name: "李四", category: "吉祥牌位", notes: "朋友"))
            lib.addPerson(TabletPerson(name: "王五", category: "吉祥牌位", notes: "师长"))
            self.library = lib
        }

        var body: some View {
            ZStack {
                Color(red: 0.12, green: 0.12, blue: 0.14)
                    .ignoresSafeArea()

                MemorialTabletCardView(
                    tabletLibrary: library,
                    isPresented: $isPresented,
                    category: "吉祥牌位"
                )
                .frame(maxWidth: 400, maxHeight: 500)
                .padding()
            }
        }
    }

    return PreviewContainer()
}

#Preview("往生牌位") {
    struct PreviewContainer: View {
        @State private var isPresented = true
        let library: TabletLibrary

        init() {
            let lib = TabletLibrary()
            lib.addPerson(TabletPerson(name: "李奶奶", category: "往生牌位", notes: "祖母"))
            lib.addPerson(TabletPerson(name: "王爷爷", category: "往生牌位", notes: "祖父"))
            self.library = lib
        }

        var body: some View {
            ZStack {
                Color(red: 0.12, green: 0.12, blue: 0.14)
                    .ignoresSafeArea()

                MemorialTabletCardView(
                    tabletLibrary: library,
                    isPresented: $isPresented,
                    category: "往生牌位"
                )
                .frame(maxWidth: 400, maxHeight: 500)
                .padding()
            }
        }
    }

    return PreviewContainer()
}
