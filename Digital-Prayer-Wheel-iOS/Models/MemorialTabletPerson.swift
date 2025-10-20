//
//  MemorialTabletPerson.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import Foundation

/// 牌位人员信息
struct TabletPerson: Identifiable, Codable, Equatable {
    /// 唯一标识符
    let id: UUID

    /// 人员姓名
    var name: String

    /// 分类（吉祥牌位/往生牌位）
    var category: String

    /// 添加日期
    var createdDate: Date

    /// 备注信息（可选）
    var notes: String

    /// 初始化方法
    init(
        id: UUID = UUID(),
        name: String,
        category: String = "吉祥牌位",
        createdDate: Date = Date(),
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.createdDate = createdDate
        self.notes = notes
    }

    /// 格式化日期显示
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: createdDate)
    }
}
