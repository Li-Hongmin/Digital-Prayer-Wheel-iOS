//
//  VideoRecorder.swift
//  Digital-Prayer-Wheel-iOS
//
//  Created by Claude on 2025/10/20.
//  转经视频录制工具 - 使用 ReplayKit 录制5秒转经视频
//

import Foundation
import ReplayKit
import UIKit
import SwiftUI
import Combine
import AVFoundation

/// 视频录制管理器
@MainActor
class VideoRecorder: NSObject, ObservableObject {
    static let shared = VideoRecorder()

    @Published var isRecording: Bool = false
    @Published var recordingProgress: Double = 0.0  // 0.0 - 1.0
    @Published var recordingError: String?

    private let recorder = RPScreenRecorder.shared()
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var startTime: Date?
    private let recordingDuration: TimeInterval = 5.0  // 5秒

    private override init() {
        super.init()
    }

    /// 开始录制5秒视频
    /// - Parameter completion: 录制完成回调，返回视频URL或nil
    func startRecording(completion: @escaping (URL?) -> Void) {
        // 检查录制权限
        guard recorder.isAvailable else {
            recordingError = "录屏功能不可用"
            completion(nil)
            return
        }

        // 检查是否已在录制
        guard !isRecording else {
            recordingError = "正在录制中，请稍候"
            completion(nil)
            return
        }

        // 重置状态
        recordingError = nil
        recordingProgress = 0.0
        isRecording = true
        startTime = Date()

        // 准备视频文件
        let videoURL = createVideoFileURL()

        // 设置AVAssetWriter
        guard setupAssetWriter(url: videoURL) else {
            recordingError = "初始化视频写入器失败"
            isRecording = false
            completion(nil)
            return
        }

        // 开始捕获屏幕
        recorder.startCapture { [weak self] sampleBuffer, bufferType, error in
            guard let self = self else { return }

            if let error = error {
                Task { @MainActor in
                    self.recordingError = "捕获失败: \(error.localizedDescription)"
                    self.stopCapture()
                    completion(nil)
                }
                return
            }

            // 只处理视频帧（忽略音频）
            guard bufferType == .video else { return }

            // 写入视频帧
            self.appendSampleBuffer(sampleBuffer)

            // 检查是否已录制5秒
            if let start = self.startTime {
                let elapsed = Date().timeIntervalSince(start)

                Task { @MainActor in
                    self.recordingProgress = min(elapsed / self.recordingDuration, 1.0)
                }

                if elapsed >= self.recordingDuration {
                    // 录制完成
                    Task { @MainActor in
                        self.stopCapture()
                        self.finishWriting(url: videoURL, completion: completion)
                    }
                }
            }
        } completionHandler: { [weak self] error in
            if let error = error {
                Task { @MainActor in
                    self?.recordingError = "启动捕获失败: \(error.localizedDescription)"
                    self?.isRecording = false
                    completion(nil)
                }
            }
        }
    }

    /// 创建视频文件URL
    private func createVideoFileURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "merit_video_\(Int(Date().timeIntervalSince1970)).mp4"
        return tempDir.appendingPathComponent(fileName)
    }

    /// 设置AVAssetWriter
    private func setupAssetWriter(url: URL) -> Bool {
        do {
            // 删除已存在的文件
            try? FileManager.default.removeItem(at: url)

            // 创建AVAssetWriter
            assetWriter = try AVAssetWriter(url: url, fileType: .mp4)

            // 获取屏幕尺寸
            // TODO: iOS 26+ 应该从视图上下文获取，但录制器类中暂时保留此方法
            let screenSize = UIScreen.main.bounds.size
            let screenScale = UIScreen.main.scale
            let videoWidth = Int(screenSize.width * screenScale)
            let videoHeight = Int(screenSize.height * screenScale)

            // 视频编码设置
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: videoWidth,
                AVVideoHeightKey: videoHeight,
                AVVideoCompressionPropertiesKey: [
                    AVVideoAverageBitRateKey: 6_000_000,  // 6 Mbps
                    AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
                ]
            ]

            // 创建视频输入
            videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            videoInput?.expectsMediaDataInRealTime = true

            // 添加输入到writer
            if let videoInput = videoInput, assetWriter?.canAdd(videoInput) == true {
                assetWriter?.add(videoInput)
                return true
            }

            return false
        } catch {
            print("❌ 设置AssetWriter失败: \(error)")
            return false
        }
    }

    /// 写入视频帧
    private func appendSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let assetWriter = assetWriter,
              let videoInput = videoInput else {
            return
        }

        // 开始写入会话（第一帧时）
        if assetWriter.status == .unknown {
            let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: startTime)
        }

        // 写入帧数据
        if assetWriter.status == .writing && videoInput.isReadyForMoreMediaData {
            videoInput.append(sampleBuffer)
        }
    }

    /// 停止捕获
    private func stopCapture() {
        recorder.stopCapture { error in
            if let error = error {
                print("⚠️ 停止捕获时出错: \(error.localizedDescription)")
            }
        }
    }

    /// 完成写入并返回URL
    private func finishWriting(url: URL, completion: @escaping (URL?) -> Void) {
        guard let writer = assetWriter else {
            Task { @MainActor in
                recordingError = "写入器未初始化"
                isRecording = false
            }
            completion(nil)
            return
        }

        // 标记输入完成
        videoInput?.markAsFinished()

        // 完成写入
        writer.finishWriting { [weak self] in
            let status = writer.status
            let error = writer.error

            Task { @MainActor in
                guard let self = self else { return }

                self.isRecording = false

                if status == .completed {
                    print("✅ 视频已保存: \(url.path())")
                    completion(url)
                } else if let error = error {
                    self.recordingError = "保存失败: \(error.localizedDescription)"
                    completion(nil)
                } else {
                    self.recordingError = "未知错误"
                    completion(nil)
                }

                // 清理
                self.assetWriter = nil
                self.videoInput = nil
            }
        }
    }

    /// 取消录制
    func cancelRecording() {
        stopCapture()
        assetWriter?.cancelWriting()
        assetWriter = nil
        videoInput = nil
        isRecording = false
        recordingProgress = 0.0
    }
}

