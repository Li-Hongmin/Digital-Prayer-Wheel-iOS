# watchOS Target 配置指南

本指南将帮助你在 Xcode 中为 Digital Prayer Wheel 项目添加 watchOS App Target。

---

## 前置准备

✅ 已完成的工作：
- [x] iOS 部署目标已修正（16.0）
- [x] Shared 代码已创建（跨平台共享）
- [x] watchOS 代码文件已创建
- [x] 自动补圈系统已实现（iOS 和 watchOS）

---

## 配置步骤

### 步骤 1：打开 Xcode 项目

```bash
cd /Users/lihongmin/Dev/Digital-Prayer-Wheel-iOS
open Digital-Prayer-Wheel-iOS.xcodeproj
```

---

### 步骤 2：创建 watchOS App Target

1. **在 Xcode 中**：
   - 点击项目导航器中的 `Digital-Prayer-Wheel-iOS` 项目文件（蓝色图标）
   - 在编辑器底部点击 `+` 按钮添加新 Target
   - 或者菜单：`File → New → Target...`

2. **选择模板**：
   - 平台选择：`watchOS`
   - 模板选择：`Watch App`（不是 Watch App for iOS App）
   - 点击 `Next`

3. **配置 Target**：
   ```
   Product Name: Digital-Prayer-Wheel-Watch
   Team: (选择你的开发团队)
   Organization Identifier: com.yourcompany
   Bundle Identifier: com.yourcompany.Digital-Prayer-Wheel-Watch
   Language: Swift
   ✅ Include Notification Scene: 否
   ```
   - 点击 `Finish`
   - 如果询问是否激活 Scheme，选择 `Activate`

---

### 步骤 3：配置 watchOS Target 设置

1. **选择 `Digital-Prayer-Wheel-Watch` target**

2. **General 标签**：
   ```
   Display Name: 数字转经轮
   Bundle Identifier: com.yourcompany.Digital-Prayer-Wheel-Watch
   Version: 1.0
   Build: 1
   Deployment Target: watchOS 10.0 ⚠️ 重要：设为 10.0 以支持 SE1
   Supported Destinations: watchOS
   ```

3. **Build Settings 标签**：
   - 搜索 `WATCHOS_DEPLOYMENT_TARGET`
   - 确保设置为 `10.0`

---

### 步骤 4：删除自动生成的文件

Xcode 会自动创建一些模板文件，我们已经手动创建了更好的版本，需要删除这些：

1. **在项目导航器中找到 `Digital-Prayer-Wheel-Watch` 文件夹**

2. **删除以下文件**（右键 → Delete → Move to Trash）：
   - `ContentView.swift`（如果存在，我们已有更好的版本）
   - `Digital_Prayer_Wheel_WatchApp.swift`（如果存在）
   - 其他自动生成的模板文件

---

### 步骤 5：添加我们的 watchOS 代码文件

1. **将 `watchOS/` 目录拖入 Xcode**：
   - 在 Finder 中找到 `/Users/lihongmin/Dev/Digital-Prayer-Wheel-iOS/watchOS/`
   - 将整个 `watchOS` 文件夹拖入 Xcode 的项目导航器
   - 在弹出对话框中：
     ```
     ✅ Copy items if needed: 否（文件已在项目内）
     ✅ Create groups: 是
     Add to targets: ✅ Digital-Prayer-Wheel-Watch
     ```
   - 点击 `Finish`

2. **验证文件包含**：
   ```
   watchOS/
   ├── PrayerWheelWatchApp.swift
   ├── Views/
   │   ├── ContentView.swift
   │   └── MinimalWheelView.swift
   ├── Services/
   │   └── BackgroundCalculator.swift (可能已移至 Shared)
   ├── Complications/
   │   └── PrayerComplication.swift
   └── Assets.xcassets/
   ```

---

### 步骤 6：添加 Shared 代码到 watchOS Target

1. **在项目导航器中找到 `Shared/` 文件夹**

2. **选中所有 Shared 文件**：
   - `Shared/Models/` 下的所有文件
   - `Shared/Services/` 下的所有文件

3. **为每个文件添加 watchOS Target**：
   - 选中文件
   - 在右侧 File Inspector（文件检查器）中
   - 找到 `Target Membership` 部分
   - ✅ 勾选 `Digital-Prayer-Wheel-Watch`

**需要添加到 watchOS Target 的文件**：
```
Shared/Models/
  ✅ PrayerText.swift
  ✅ AppSettings.swift
  ✅ DailyPrayerRecord.swift

Shared/Services/
  ✅ PrayerLibrary.swift
  ✅ PrayerStatistics.swift
  ✅ BackgroundCalculator.swift
```

---

### 步骤 7：配置 Watch App Icon

1. **准备图标**：
   - watchOS 需要多种尺寸的图标
   - 或者先跳过，稍后使用 Xcode 的 App Icon Generator

2. **（可选）添加图标**：
   - 在 `watchOS/Assets.xcassets/AppIcon.appiconset/`
   - 拖入不同尺寸的图标
   - 或使用在线工具生成：https://appicon.co/

---

### 步骤 8：配置 Complication (表盘复杂功能)

1. **创建 Widget Extension**：
   - 菜单：`File → New → Target...`
   - 选择 `watchOS → Widget Extension`
   - Product Name: `PrayerComplicationExtension`
   - 点击 `Finish`

2. **替换自动生成的 Widget 代码**：
   - 删除自动生成的文件
   - 将 `watchOS/Complications/PrayerComplication.swift` 添加到 Widget Extension Target

**或者暂时跳过这一步**，先确保主应用能运行，后续再添加表盘功能。

---

### 步骤 9：编译测试

1. **选择 watchOS 模拟器**：
   - 在 Xcode 顶部工具栏
   - 选择 Scheme: `Digital-Prayer-Wheel-Watch`
   - 选择 Destination: `Apple Watch SE (40mm)` 或类似模拟器

2. **构建项目**：
   ```
   ⌘ + B  (Command + B)
   ```

3. **运行项目**：
   ```
   ⌘ + R  (Command + R)
   ```

4. **预期结果**：
   - watchOS 模拟器启动
   - 显示转经轮界面
   - 自动旋转动画
   - 计数正常增加

---

## 常见问题排查

### 问题 1：编译错误 "Cannot find 'PrayerLibrary' in scope"

**解决方案**：
- 确保 `Shared/` 文件夹中的所有文件都添加到了 watchOS Target
- 检查 Target Membership（见步骤 6）

---

### 问题 2：watchOS Deployment Target 不兼容

**解决方案**：
```
1. 选择 Digital-Prayer-Wheel-Watch target
2. Build Settings
3. 搜索 "WATCHOS_DEPLOYMENT_TARGET"
4. 确保设置为 10.0（支持 Apple Watch SE1）
```

---

### 问题 3：找不到模拟器

**解决方案**：
```bash
# 1. 打开 Xcode Settings
⌘ + ,

# 2. 进入 Platforms 标签
# 3. 确保已安装 watchOS Simulator

# 或通过命令行安装：
xcodebuild -downloadPlatform watchOS
```

---

### 问题 4：Assets 图标缺失警告

**解决方案**：
- 暂时忽略，应用仍可运行
- 稍后使用工具生成：https://appicon.co/
- 或在 Xcode 中右键 AppIcon → Generate All Sizes

---

## 测试清单

配置完成后，请测试以下功能：

### watchOS 基础功能
- [ ] 应用启动成功
- [ ] 转经轮自动旋转
- [ ] 经文文字正常显示
- [ ] 计数正常增加
- [ ] 速度显示正确

### 自动补圈功能
- [ ] 关闭应用
- [ ] 等待 1-2 分钟
- [ ] 重新打开应用
- [ ] 显示补圈通知
- [ ] 计数已补充（应该增加约 30-60 圈，取决于转速）

### iOS 自动补圈
- [ ] iOS 应用关闭
- [ ] 等待几分钟
- [ ] 重新打开 iOS 应用
- [ ] 显示补圈提示弹窗
- [ ] 计数已补充

---

## 下一步工作

✅ watchOS Target 配置完成后：

1. **真机测试**：
   - 连接你的 Apple Watch SE1
   - 选择真机作为目标设备
   - 运行应用

2. **性能优化**：
   - 监控电池消耗
   - 优化动画帧率
   - 调整保存频率

3. **添加表盘复杂功能**（可选）：
   - 完成步骤 8 的 Widget Extension
   - 测试不同表盘样式

4. **分发测试**：
   - TestFlight 测试
   - 真实用户反馈

---

## 技术细节

### 项目架构
```
Digital-Prayer-Wheel-iOS/
├── Shared/                      # 跨平台共享
│   ├── Models/                  # 数据模型
│   │   ├── PrayerText.swift
│   │   ├── AppSettings.swift   (条件编译)
│   │   └── DailyPrayerRecord.swift
│   └── Services/                # 业务逻辑
│       ├── PrayerLibrary.swift
│       ├── PrayerStatistics.swift
│       └── BackgroundCalculator.swift  ⭐ 自动补圈
│
├── Digital-Prayer-Wheel-iOS/    # iOS 专属
│   ├── iOSApp.swift
│   ├── Views/
│   │   ├── iOSContentView.swift (已集成自动补圈)
│   │   └── ...
│   └── Utils/
│
└── watchOS/                     # watchOS 专属
    ├── PrayerWheelWatchApp.swift
    ├── Views/
    │   ├── ContentView.swift
    │   └── MinimalWheelView.swift  ⭐ 简约 UI
    ├── Complications/
    │   └── PrayerComplication.swift
    └── Assets.xcassets/
```

### 自动补圈算法
```swift
// Formula: 补充圈数 = 离线时间(分钟) × 转速(圈/分钟)
let missedRotations = (elapsedMinutes * rotationSpeed)

// 限制：最多补充 24 小时的圈数
let maxRotations = 24 * 60 * rotationSpeed
let compensated = min(missedRotations, maxRotations)
```

### 部署目标
- **iOS**: 16.0+（支持 iPhone 8 及更新机型）
- **watchOS**: 10.0+（支持 Apple Watch SE1, Series 6+）

---

## 需要帮助？

如果遇到任何问题：

1. **检查日志**：
   - Xcode 底部控制台输出
   - 查找 `🟢`、`🔴`、`⏰` 等标记的日志

2. **清理构建**：
   ```
   ⇧ + ⌘ + K  (Shift + Command + K)
   ```

3. **重置模拟器**：
   ```
   Device → Erase All Content and Settings
   ```

4. **提问时提供**：
   - 错误信息截图
   - Xcode 版本
   - watchOS 部署目标设置
   - 控制台日志

---

祝配置顺利！🙏

*Created by Claude on 2025/11/09*
