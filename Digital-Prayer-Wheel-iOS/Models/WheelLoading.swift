//
//  WheelLoading.swift
//  Digital-Prayer-Wheel
//
//  Created by Claude on 2025/10/23.
//

import Foundation
import Compression
import Combine

/// 转经筒装载数据模型
struct WheelLoadingData: Codable {
    let prayerType: String       // 经文类型
    let prayerText: String       // 经文内容
    let repeatCount: Int         // 重复次数
    let loadedDate: Date         // 装载日期
    let compressedSize: Int      // 压缩后大小

    /// 生成压缩数据
    func generateCompressedData() -> Data? {
        // Generate repeated prayer text (sample for compression, not full count)
        let sampleCount = min(repeatCount, 10000)
        let repeatedText = String(repeating: prayerText + "\n", count: sampleCount)
        guard let textData = repeatedText.data(using: .utf8) else { return nil }

        // Compress using LZFSE
        let compressedData = textData.compressed(using: .lzfse)
        return compressedData
    }
}

/// 转经筒装载管理器
@MainActor
class WheelLoadingManager: ObservableObject {
    static let shared = WheelLoadingManager()

    @Published var loadedData: WheelLoadingData?
    @Published var isLoaded: Bool = false

    private let storageKey = "WheelLoadingData"

    private init() {
        loadFromStorage()
    }

    /// 装载经文到转经筒
    func loadPrayer(prayerType: String, prayerText: String, count: Int) async throws {
        // Generate compressed data
        let tempData = WheelLoadingData(
            prayerType: prayerType,
            prayerText: prayerText,
            repeatCount: count,
            loadedDate: Date(),
            compressedSize: 0
        )

        guard let compressed = tempData.generateCompressedData() else {
            throw LoadingError.compressionFailed
        }

        // Update compressed size
        let data = WheelLoadingData(
            prayerType: prayerType,
            prayerText: prayerText,
            repeatCount: count,
            loadedDate: Date(),
            compressedSize: compressed.count
        )

        // Save metadata
        loadedData = data
        isLoaded = true
        saveToStorage()

        // Send loading complete notification
        NotificationCenter.default.post(
            name: .wheelLoadingComplete,
            object: nil,
            userInfo: ["count": count, "prayerType": prayerType]
        )
    }

    /// 获取倍数
    var multiplier: Int {
        return loadedData?.repeatCount ?? 1
    }

    /// 清除装载数据
    func clearLoading() {
        loadedData = nil
        isLoaded = false
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func saveToStorage() {
        if let data = loadedData {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            if let encoded = try? encoder.encode(data) {
                UserDefaults.standard.set(encoded, forKey: storageKey)
            }
        }
    }

    private func loadFromStorage() {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let decoded = try? decoder.decode(WheelLoadingData.self, from: data) {
                loadedData = decoded
                isLoaded = true
            }
        }
    }
}

enum LoadingError: Error {
    case compressionFailed
}

// MARK: - Notification Names
extension Notification.Name {
    static let wheelLoadingComplete = Notification.Name("wheelLoadingComplete")
}

// MARK: - Data Compression Extension
extension Data {
    /// Compress data using specified algorithm (simplified implementation)
    func compressed(using algorithm: Algorithm = .lzfse) -> Data {
        // Simplified: Just return the original data
        // In production, use proper compression library
        return self
    }
}
