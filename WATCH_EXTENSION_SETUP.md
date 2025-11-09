# 🎯 Watch App Extension 配置指南

将独立的 watchOS Target 重新配置为 iOS 的 Watch Extension，以便打包进单一 IPA 供 AltStore 分发。

---

## 📋 配置步骤

### 步骤 1：删除现有的独立 watchOS Target

**在 Xcode 中**：

1. **打开项目**：
   ```bash
   open Digital-Prayer-Wheel-iOS.xcodeproj
   ```

2. **选择项目文件**（左侧蓝色图标）

3. **在 TARGETS 列表中找到**：
   - `Digital-Prayer-Wheel-Watch`
   - `Digital-Prayer-Wheel-Watch Watch App`

4. **删除这些 Target**：
   - 选中 Target
   - 按 `Delete` 键
   - 确认删除

5. **删除文件引用**（但保留文件）：
   - 在项目导航器中，右键点击 `Digital-Prayer-Wheel-Watch Watch App` 文件夹
   - 选择 `Delete`
   - 选择 **`Remove Reference`**（不要选 Move to Trash）

---

### 步骤 2：创建 Watch App Extension

**在 Xcode 中**：

1. **添加新 Target**：
   - 选中项目文件
   - 点击底部 `+` 按钮
   - 或菜单：`File → New → Target`

2. **选择模板**：
   - 平台：`watchOS`
   - 模板：`Watch App for iOS App` ⭐ 注意是 "for iOS App"
   - 点击 `Next`

3. **配置信息**：
   ```
   Product Name: PrayerWheelWatch
   Embed in Application: Digital-Prayer-Wheel-iOS ⭐ 重要
   Bundle Identifier: Li-Hongmin.Digital-Prayer-Wheel.watchkitapp
   Language: Swift
   User Interface: SwiftUI
   Include Notification Scene: ❌ 不勾选
   ```

4. **点击 `Finish`**

5. **激活 Scheme**：点击 `Activate`

---

### 步骤 3：配置部署目标

1. **选择新创建的 `PrayerWheelWatch` target**

2. **General 标签**：
   - `Deployment Target` → 设为 `watchOS 10.0`

3. **Build Settings 标签**：
   - 搜索 `WATCHOS_DEPLOYMENT_TARGET`
   - 确保设为 `10.0`

---

### 步骤 4：替换自动生成的代码

**删除模板文件**：
1. 在项目导航器中找到新创建的 `PrayerWheelWatch` 文件夹
2. 删除里面的 `.swift` 文件（`ContentView.swift` 等）
   - 右键 → `Delete` → `Move to Trash`

**添加我们的代码**：
1. 将以下文件从 `Digital-Prayer-Wheel-Watch-Backup/` 拖入 `PrayerWheelWatch` 文件夹：
   - `ContentView.swift`
   - `RealisticWheelView.swift`
   - `MinimalWheelView.swift`（可选，目前未使用）

2. 弹出对话框选择：
   ```
   ✅ Copy items if needed: 是
   ✅ Create groups: 是
   ✅ Add to targets: 勾选 PrayerWheelWatch
   ```

**添加图标**：
1. 删除自动生成的 `Assets.xcassets/AppIcon`
2. 将 `Digital-Prayer-Wheel-Watch-Backup/Assets.xcassets/AppIcon.appiconset/` 拖入
   - 包含所有 watch-*.png 和 Icon-1024.png

---

### 步骤 5：添加共享文件到 Watch Extension

**选中以下文件**（在 `Digital-Prayer-Wheel-iOS/` 中）：

```
Models/
  ✅ PrayerText.swift
  ✅ AppSettings.swift
  ✅ DailyPrayerRecord.swift (如果有)

Services/
  ✅ PrayerLibrary.swift
  ✅ PrayerStatistics.swift
  ✅ BackgroundCalculator.swift
```

**为每个文件添加 Target Membership**：
1. 选中文件
2. 右侧 `File Inspector`（⌥ + ⌘ + 1）
3. `Target Membership` 部分
4. ✅ 勾选 `PrayerWheelWatch`

---

### 步骤 6：编译测试

1. **选择 iOS Scheme**：
   - Scheme: `Digital-Prayer-Wheel-iOS`
   - Destination: `iPhone 15`（模拟器）

2. **编译**：
   ```
   ⌘ + B
   ```

3. **运行**：
   ```
   ⌘ + R
   ```

4. **验证**：
   - iOS 应用正常运行
   - 自动补圈功能正常

---

### 步骤 7：测试 watchOS Extension

1. **选择 Watch Scheme**：
   - Scheme: `PrayerWheelWatch`
   - Destination: `Apple Watch SE (40mm)`

2. **运行**：
   ```
   ⌘ + R
   ```

3. **验证**：
   - watchOS 应用正常运行
   - 转经轮正常旋转
   - 自动补圈功能正常

---

### 步骤 8：归档并导出 IPA

1. **归档**：
   - 菜单：`Product → Archive`
   - 或选择 Scheme 为 iOS，然后 `⌘ + Shift + B`

2. **等待归档完成**

3. **在 Organizer 窗口**：
   - 选择刚创建的归档
   - 点击 `Distribute App`
   - 选择 `Development` 或 `Ad Hoc`
   - 选择导出位置

4. **验证 IPA 包含 watchOS**：
   ```bash
   unzip -l Digital-Prayer-Wheel-iOS.ipa | grep Watch
   ```

   应该看到：
   ```
   Watch/Digital-Prayer-Wheel-iOS.app/...
   ```

---

## ✅ 完成后验证清单

- [ ] iOS Target 编译成功
- [ ] watchOS Extension 编译成功
- [ ] 归档成功（包含两个平台）
- [ ] IPA 中包含 `Watch/` 文件夹
- [ ] IPA 文件大小增加（约 800KB+）

---

## ⚠️ 常见问题

### Q1: 找不到 "Watch App for iOS App" 模板

**解决**：
- 确保选择 `watchOS` 平台
- 向下滚动找到 `Watch App for iOS App`
- 如果还是找不到，选择 `Watch App` 然后在配置时指定 embed

### Q2: 编译报错 "Multiple commands produce"

**解决**：
- 确保没有重复的文件
- 检查 Target Membership，每个文件只应该在需要的 Target 中

### Q3: Watch 应用无法安装

**解决**：
- 确保 iOS 应用先安装
- Watch 应用依赖 iOS 应用才能安装

---

## 📝 预期结果

完成后的项目结构：

```
Digital-Prayer-Wheel-iOS/
├── Digital-Prayer-Wheel-iOS/          # iOS 主应用
│   ├── Models/
│   ├── Services/
│   └── Views/
├── PrayerWheelWatch/                   # ⭐ Watch Extension
│   ├── ContentView.swift
│   ├── RealisticWheelView.swift
│   └── Assets.xcassets/
└── Digital-Prayer-Wheel-iOS.xcodeproj
```

**归档后的 IPA 结构**：
```
Digital-Prayer-Wheel-iOS.ipa
└── Payload/
    └── Digital-Prayer-Wheel-iOS.app/
        ├── Digital-Prayer-Wheel-iOS (主应用)
        └── Watch/                      # ⭐ Watch 应用
            └── PrayerWheelWatch.app/
```

---

## 🚀 下一步

配置完成后：
1. 生成新的 IPA（v1.1）
2. 更新 AltStore apps.json
3. 测试安装
4. 发布！

---

需要帮助？每一步都可以问我！🙏

*Created on 2025/11/09*
