# ⚡ watchOS 应用快速测试指南

## 最简单的方法（5分钟）

### 步骤 1: 打开 Xcode

```bash
cd /Users/lihongmin/Dev/Digital-Prayer-Wheel-iOS
open Digital-Prayer-Wheel-iOS.xcodeproj
```

---

### 步骤 2: 创建 watchOS Target

**在 Xcode 中**：

1. **点击项目文件**（左侧导航器最顶部的蓝色图标）

2. **点击底部的 `+` 号**（在 TARGETS 列表下方）

3. **选择模板**：
   - 平台：`watchOS`
   - 模板：`Watch App`
   - 点击 `Next`

4. **填写信息**：
   ```
   Product Name: PrayerWheelWatch
   Team: (选择你的团队)
   Organization Identifier: (保持默认)
   Bundle Identifier: (自动生成)
   Language: Swift
   User Interface: SwiftUI
   Include Notification Scene: ❌ 不勾选
   ```
   - 点击 `Finish`
   - 弹出询问是否激活 Scheme → 点击 `Activate`

---

### 步骤 3: 设置部署目标

1. **选中刚创建的 `PrayerWheelWatch` target**

2. **在 General 标签中**：
   - 找到 `Minimum Deployments`
   - `watchOS` 设为 `10.0`

---

### 步骤 4: 替换代码

**删除自动生成的文件**：
1. 在左侧找到 `PrayerWheelWatch` 文件夹
2. 删除里面的所有 `.swift` 文件（右键 → Delete → Move to Trash）

**添加我们的代码**：
1. 在 Finder 中打开：`/Users/lihongmin/Dev/Digital-Prayer-Wheel-iOS/watchOS/`
2. 将以下文件拖入 Xcode 的 `PrayerWheelWatch` 文件夹：
   - `PrayerWheelWatchApp.swift`
   - `Views/ContentView.swift`
   - `Views/MinimalWheelView.swift`
3. 弹出对话框：
   - ✅ Copy items if needed: **勾选**
   - ✅ Create groups: **勾选**
   - ✅ Add to targets: 勾选 `PrayerWheelWatch`
   - 点击 `Finish`

**添加共享代码**：
1. 在左侧找到原有的 `Digital-Prayer-Wheel-iOS` → `Models` 文件夹
2. 选中以下文件（按住 ⌘ 多选）：
   - `PrayerText.swift`
   - `DailyPrayerRecord.swift`
3. 在右侧 `File Inspector`（文件检查器）中
4. 找到 `Target Membership` 部分
5. ✅ 勾选 `PrayerWheelWatch`

6. 同样方式处理 `Services` 文件夹中的：
   - `PrayerLibrary.swift`
   - `PrayerStatistics.swift`
   - `BackgroundCalculator.swift`

---

### 步骤 5: 运行测试

1. **选择 Scheme**：
   - 点击 Xcode 顶部工具栏的 Scheme 下拉菜单
   - 选择 `PrayerWheelWatch`

2. **选择模拟器**：
   - 点击 Destination 下拉菜单
   - 选择 `Apple Watch SE (40mm) (2nd generation)`

3. **运行**：
   ```
   按 ⌘ + R
   或点击 ▶️ 播放按钮
   ```

4. **预期效果**：
   - watchOS 模拟器启动
   - 显示 iPhone 界面（watchOS 模拟器依赖 iPhone）
   - 然后显示 Apple Watch 界面
   - 看到转经轮自动旋转！

---

## 🎯 测试自动补圈功能

1. **在模拟器中打开 watch 应用**
2. **查看当前计数**（例如：今日 10 圈）
3. **关闭模拟器或停止运行** (⌘ + .)
4. **等待 2 分钟**
5. **重新运行** (⌘ + R)
6. **查看计数** - 应该增加了约 60 圈（2分钟 × 30圈/分）

---

## ⚠️ 常见问题

### Q: 编译报错 "Cannot find 'PrayerLibrary' in scope"

**解决**：
1. 检查 `PrayerLibrary.swift` 的 Target Membership
2. 确保勾选了 `PrayerWheelWatch`

### Q: 模拟器启动失败

**解决**：
```bash
# 重置模拟器
xcrun simctl shutdown all
xcrun simctl erase all
```

### Q: 找不到 watchOS 模拟器

**解决**：
1. Xcode → Settings (⌘ + ,)
2. Platforms 标签
3. 安装 watchOS Simulator

---

## 🚀 更简单的测试方法（如果上面太复杂）

创建一个全新的独立 watchOS 项目：

```bash
# 1. 在 Xcode 中
File → New → Project

# 2. 选择
watchOS → Watch App

# 3. 命名
Product Name: TestPrayerWheel

# 4. 完成后
# 将 watchOS/ 文件夹的代码复制到新项目
# 运行测试

# 优点：独立项目，不影响现有 iOS 项目
# 缺点：需要重复配置
```

---

## 💡 推荐流程

1. ✅ **先测试 iOS 版本的自动补圈**（已经可以用了）
2. ⏳ **然后按照本文档配置 watchOS Target**
3. 🎉 **最后测试 watchOS 应用**

---

需要帮助？看不懂哪一步？告诉我，我可以提供截图或更详细的说明！🙏
