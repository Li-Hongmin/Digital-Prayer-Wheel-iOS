//
//  PersonEditView.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

/// 人员添加/编辑表单视图
struct PersonEditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.responsiveScale) var responsiveScale
    @ObservedObject var tabletLibrary: TabletLibrary

    /// 牌位类别（吉祥牌位/往生牌位）
    let category: String

    /// 编辑模式：nil 表示新建，否则为编辑现有人员
    var editingPerson: TabletPerson?

    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var showValidationError: Bool = false

    var isEditing: Bool {
        editingPerson != nil
    }

    var body: some View {
        let scale = responsiveScale ?? ResponsiveScale()

        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("姓名（必填）", text: $name)
                        .font(.system(size: scale.fontSize(16)))

                    TextField("备注（可选）", text: $notes, axis: .vertical)
                        .font(.system(size: scale.fontSize(16)))
                        .lineLimit(3...6)
                }

                Section {
                    HStack {
                        Spacer()
                        Button("取消") {
                            dismiss()
                        }
                        .font(.system(size: scale.fontSize(16)))

                        Spacer()

                        Button(isEditing ? "保存" : "添加") {
                            savePerson()
                        }
                        .font(.system(size: scale.fontSize(16), weight: .semibold))
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)

                        Spacer()
                    }
                }
            }
            .navigationTitle(isEditing ? "编辑人员" : "添加人员")
            .navigationBarTitleDisplayMode(.inline)
            .alert("请输入姓名", isPresented: $showValidationError) {
                Button("确定", role: .cancel) { }
            }
        }
        .onAppear {
            if let person = editingPerson {
                name = person.name
                notes = person.notes
            }
        }
    }

    private func savePerson() {
        // 验证姓名不为空
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            showValidationError = true
            return
        }

        if let existingPerson = editingPerson {
            // 编辑现有人员
            var updatedPerson = existingPerson
            updatedPerson.name = trimmedName
            updatedPerson.notes = notes.trimmingCharacters(in: .whitespaces)
            // 保持原有类别不变
            tabletLibrary.updatePerson(updatedPerson)
        } else {
            // 添加新人员，使用传入的类别
            let newPerson = TabletPerson(
                name: trimmedName,
                category: category,
                createdDate: Date(),
                notes: notes.trimmingCharacters(in: .whitespaces)
            )
            tabletLibrary.addPerson(newPerson)
        }

        dismiss()
    }
}

#Preview("添加吉祥牌位人员") {
    PersonEditView(
        tabletLibrary: TabletLibrary(),
        category: "吉祥牌位",
        editingPerson: nil
    )
}

#Preview("添加往生牌位人员") {
    PersonEditView(
        tabletLibrary: TabletLibrary(),
        category: "往生牌位",
        editingPerson: nil
    )
}

#Preview("编辑现有人员") {
    PersonEditView(
        tabletLibrary: TabletLibrary(),
        category: "吉祥牌位",
        editingPerson: TabletPerson(
            name: "张三",
            category: "吉祥牌位",
            notes: "家人"
        )
    )
}
