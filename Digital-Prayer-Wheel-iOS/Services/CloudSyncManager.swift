//
//  CloudSyncManager.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/20.
//

import Foundation
import Combine

/// iCloud 多设备同步管理器
/// 使用 NSUbiquitousKeyValueStore 实现简单快速的云同步
@MainActor
class CloudSyncManager: ObservableObject {
    static let shared = CloudSyncManager()

    private let cloudStore = NSUbiquitousKeyValueStore.default

    /// 同步状态
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?

    /// 是否启用 iCloud 同步
    @Published var isCloudSyncEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isCloudSyncEnabled, forKey: "CloudSyncEnabled")
            if isCloudSyncEnabled {
                syncAllDataToCloud()
            }
        }
    }

    private init() {
        // 从 UserDefaults 加载同步开关状态
        self.isCloudSyncEnabled = UserDefaults.standard.object(forKey: "CloudSyncEnabled") != nil
            ? UserDefaults.standard.bool(forKey: "CloudSyncEnabled")
            : true // 默认启用

        // 开始监听 iCloud 变化
        startObserving()

        // 注意：个人开发团队不支持 iCloud，此功能需要付费开发者账户
        // 首次同步已禁用（避免启动时出现错误日志）
    }

    // MARK: - 基础同步方法

    /// 保存数据到 iCloud
    func save<T>(_ value: T, forKey key: String) {
        guard isCloudSyncEnabled else {
            print("⚠️ iCloud 同步已禁用，跳过保存")
            return
        }

        let cloudKey = "iCloud_\(key)"

        if let intValue = value as? Int {
            cloudStore.set(Int64(intValue), forKey: cloudKey)
            print("✅ 已保存到 iCloud: \(cloudKey) = \(intValue)")
        } else if let doubleValue = value as? Double {
            cloudStore.set(doubleValue, forKey: cloudKey)
            print("✅ 已保存到 iCloud: \(cloudKey) = \(doubleValue)")
        } else if let stringValue = value as? String {
            cloudStore.set(stringValue, forKey: cloudKey)
            print("✅ 已保存到 iCloud: \(cloudKey) = \(stringValue)")
        } else if let boolValue = value as? Bool {
            cloudStore.set(boolValue, forKey: cloudKey)
            print("✅ 已保存到 iCloud: \(cloudKey) = \(boolValue)")
        } else if let dataValue = value as? Data {
            cloudStore.set(dataValue, forKey: cloudKey)
            print("✅ 已保存到 iCloud: \(cloudKey) = \(dataValue.count) bytes")
        }

        // 强制同步到云端
        let success = cloudStore.synchronize()
        print("☁️ iCloud 同步请求: \(success ? "成功" : "失败")")

        // 更新最后同步时间
        lastSyncDate = Date()
    }

    /// 从 iCloud 读取数据
    func load<T>(forKey key: String, defaultValue: T) -> T {
        guard isCloudSyncEnabled else { return defaultValue }

        let cloudKey = "iCloud_\(key)"

        if T.self == Int.self {
            let value = Int(cloudStore.longLong(forKey: cloudKey))
            return value as? T ?? defaultValue
        } else if T.self == Double.self {
            let value = cloudStore.double(forKey: cloudKey)
            return value as? T ?? defaultValue
        } else if T.self == String.self {
            let value = cloudStore.string(forKey: cloudKey) ?? ""
            return value as? T ?? defaultValue
        } else if T.self == Bool.self {
            let value = cloudStore.bool(forKey: cloudKey)
            return value as? T ?? defaultValue
        } else if T.self == Data.self {
            let value = cloudStore.data(forKey: cloudKey) ?? Data()
            return value as? T ?? defaultValue
        }

        return defaultValue
    }

    /// 检查 iCloud 中是否存在数据
    func hasCloudData(forKey key: String) -> Bool {
        let cloudKey = "iCloud_\(key)"
        return cloudStore.object(forKey: cloudKey) != nil
    }

    // MARK: - 监听云端变化

    /// 开始监听 iCloud 变化
    private func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cloudStoreDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloudStore
        )
    }

    /// iCloud 数据变化通知处理
    @objc private func cloudStoreDidChange(_ notification: Notification) {
        guard isCloudSyncEnabled else { return }

        Task { @MainActor in
            // 发送通知，让各个数据管理器更新本地数据
            NotificationCenter.default.post(
                name: .cloudDataDidChange,
                object: nil
            )

            lastSyncDate = Date()
        }
    }

    // MARK: - 批量同步

    /// 从云端同步所有数据到本地
    func syncFromCloud() {
        guard isCloudSyncEnabled else {
            print("⚠️ iCloud 同步已禁用，跳过从云端同步")
            return
        }

        print("🔄 开始从 iCloud 同步数据...")
        isSyncing = true

        // 触发同步
        let success = cloudStore.synchronize()
        print("☁️ iCloud 同步请求: \(success ? "成功" : "失败")")

        // 通知各数据管理器从 iCloud 加载
        NotificationCenter.default.post(
            name: .shouldSyncFromCloud,
            object: nil
        )
        print("📢 已发送同步通知给所有数据管理器")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isSyncing = false
            self.lastSyncDate = Date()
            print("✅ 同步完成")
        }
    }

    /// 将所有本地数据同步到云端
    func syncAllDataToCloud() {
        guard isCloudSyncEnabled else { return }

        // 通知各数据管理器上传数据
        NotificationCenter.default.post(
            name: .shouldSyncToCloud,
            object: nil
        )

        cloudStore.synchronize()
        lastSyncDate = Date()
    }

    /// 清除所有 iCloud 数据（用于测试或重置）
    func clearAllCloudData() {
        let dict = cloudStore.dictionaryRepresentation
        for key in dict.keys where key.hasPrefix("iCloud_") {
            cloudStore.removeObject(forKey: key)
        }
        cloudStore.synchronize()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    /// 云端数据发生变化
    static let cloudDataDidChange = Notification.Name("cloudDataDidChange")

    /// 应该从云端同步数据
    static let shouldSyncFromCloud = Notification.Name("shouldSyncFromCloud")

    /// 应该将数据同步到云端
    static let shouldSyncToCloud = Notification.Name("shouldSyncToCloud")
}
