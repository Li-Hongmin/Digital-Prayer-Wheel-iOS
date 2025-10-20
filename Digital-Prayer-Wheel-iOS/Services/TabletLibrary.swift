//
//  TabletLibrary.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import Foundation
import SwiftUI
import Combine

/// 牌位数据管理类
@MainActor
class TabletLibrary: ObservableObject {
    /// 所有牌位人员列表
    @Published var persons: [TabletPerson] = []

    /// UserDefaults 存储键
    private let storageKey = "TabletPersons"

    init() {
        loadPersons()
    }

    // MARK: - CRUD 操作

    /// 添加新人员
    func addPerson(_ person: TabletPerson) {
        persons.append(person)
        savePersons()
    }

    /// 更新人员信息
    func updatePerson(_ person: TabletPerson) {
        if let index = persons.firstIndex(where: { $0.id == person.id }) {
            persons[index] = person
            savePersons()
        }
    }

    /// 删除人员
    func deletePerson(id: UUID) {
        persons.removeAll { $0.id == id }
        savePersons()
    }

    /// 删除多个人员（用于列表批量删除）
    func deletePersons(at offsets: IndexSet) {
        persons.remove(atOffsets: offsets)
        savePersons()
    }

    /// 获取指定 ID 的人员
    func getPerson(id: UUID) -> TabletPerson? {
        return persons.first { $0.id == id }
    }

    // MARK: - 数据持久化

    /// 从 UserDefaults 加载人员数据
    private func loadPersons() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            // 没有存储数据，使用空数组
            persons = []
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            persons = try decoder.decode([TabletPerson].self, from: data)
        } catch {
            print("加载牌位数据失败: \(error)")
            persons = []
        }
    }

    /// 保存人员数据到 UserDefaults
    private func savePersons() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(persons)

            // 保存到本地
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("保存牌位数据失败: \(error)")
        }
    }

    /// 清空所有数据（用于测试或重置）
    func clearAllPersons() {
        persons.removeAll()
        savePersons()
    }

    // MARK: - 辅助方法

    /// 获取人员总数
    var totalCount: Int {
        return persons.count
    }

    /// 按日期排序的人员列表（最新的在前）
    var sortedPersons: [TabletPerson] {
        return persons.sorted { $0.createdDate > $1.createdDate }
    }

    /// 按姓名排序的人员列表
    var sortedByName: [TabletPerson] {
        return persons.sorted { $0.name < $1.name }
    }

    // MARK: - 分类筛选

    /// 获取指定类别的人员列表
    func getPersons(byCategory category: String) -> [TabletPerson] {
        return persons.filter { $0.category == category }
    }

    /// 获取指定类别的人员列表（按日期排序）
    func getSortedPersons(byCategory category: String) -> [TabletPerson] {
        return persons
            .filter { $0.category == category }
            .sorted { $0.createdDate > $1.createdDate }
    }

    /// 获取吉祥牌位人员列表
    var auspiciousPersons: [TabletPerson] {
        return getSortedPersons(byCategory: "吉祥牌位")
    }

    /// 获取往生牌位人员列表
    var deceasedPersons: [TabletPerson] {
        return getSortedPersons(byCategory: "往生牌位")
    }
}
