# 启用 iOS 自动补圈功能指南

当前 iOS 应用可以正常编译运行，但**自动补圈功能被临时禁用**了。

## 为什么被禁用？

因为 `BackgroundCalculator.swift` 文件在 `Shared/Services/` 目录中，还没有被添加到 iOS Target，所以编译器找不到这个类。

---

## 🔧 启用步骤（5分钟）

### 步骤 1：打开 Xcode

```bash
cd /Users/lihongmin/Dev/Digital-Prayer-Wheel-iOS
open Digital-Prayer-Wheel-iOS.xcodeproj
```

---

### 步骤 2：添加 Shared 文件夹到项目

1. **在 Finder 中**：
   - 打开 `/Users/lihongmin/Dev/Digital-Prayer-Wheel-iOS/Shared/`

2. **拖入 Xcode**：
   - 将整个 `Shared` 文件夹拖入 Xcode 的项目导航器
   - 推荐位置：`Digital-Prayer-Wheel-iOS` 项目根目录下

3. **配置对话框**：
   ```
   ✅ Copy items if needed: 否（文件已在正确位置）
   ✅ Create groups: 是
   ✅ Add to targets: 勾选 Digital-Prayer-Wheel-iOS
   ```

4. **点击 Finish**

---

### 步骤 3：验证文件已添加

在项目导航器中，你应该看到：

```
Digital-Prayer-Wheel-iOS (project)
├── Digital-Prayer-Wheel-iOS (folder)
├── Shared                            ← 新增
│   ├── Models
│   │   ├── PrayerText.swift
│   │   ├── AppSettings.swift
│   │   └── DailyPrayerRecord.swift
│   └── Services
│       ├── PrayerLibrary.swift
│       ├── PrayerStatistics.swift
│       └── BackgroundCalculator.swift  ← 关键文件
└── Products
```

---

### 步骤 4：取消注释代码

在 `Digital-Prayer-Wheel-iOS/Views/iOSContentView.swift` 文件中：

#### 4.1 取消注释变量声明（第 13-18 行）

**找到这些行**：
```swift
// TODO: 在 Xcode 中将 Shared/Services/BackgroundCalculator.swift 添加到 iOS Target 后取消注释
// @StateObject private var backgroundCalc = BackgroundCalculator()  // 自动补圈系统
@State private var showSettings: Bool = false
@State private var isLoading: Bool = true  // 加载状态
// @State private var showCompensationAlert: Bool = false  // 补圈提示
// @State private var compensatedCount: Int = 0  // 补充的圈数
```

**修改为**：
```swift
@StateObject private var backgroundCalc = BackgroundCalculator()  // 自动补圈系统
@State private var showSettings: Bool = false
@State private var isLoading: Bool = true  // 加载状态
@State private var showCompensationAlert: Bool = false  // 补圈提示
@State private var compensatedCount: Int = 0  // 补充的圈数
```

#### 4.2 取消注释函数调用（第 64-65 行和 78-79 行）

**找到这些行**：
```swift
.onAppear {
    initializeServices()
    // TODO: 启用自动补圈后取消注释
    // handleAppearance()  // 处理自动补圈
    ...
}
.onDisappear {
    // TODO: 启用自动补圈后取消注释
    // handleDisappearance()  // 保存状态以便下次补圈
    settings.finalizeSave()
}
```

**修改为**：
```swift
.onAppear {
    initializeServices()
    handleAppearance()  // 处理自动补圈
    ...
}
.onDisappear {
    handleDisappearance()  // 保存状态以便下次补圈
    settings.finalizeSave()
}
```

#### 4.3 取消注释弹窗（第 82-87 行）

**找到这些行**：
```swift
// TODO: 启用自动补圈后取消注释
// .alert("自动补圈", isPresented: $showCompensationAlert) {
//     Button("好的") { }
// } message: {
//     Text("离线期间已为您补充 \(compensatedCount) 圈转经\n\n🙏 修行不间断")
// }
```

**修改为**：
```swift
.alert("自动补圈", isPresented: $showCompensationAlert) {
    Button("好的") { }
} message: {
    Text("离线期间已为您补充 \(compensatedCount) 圈转经\n\n🙏 修行不间断")
}
```

#### 4.4 取消注释函数定义（第 98-136 行）

**找到这段**：
```swift
// TODO: 在 Xcode 中添加 BackgroundCalculator 到 Target 后取消注释这两个函数
/*
/// Handle app appearance - calculate and apply background compensation
...
*/
```

**删除开头的 `/*` 和结尾的 `*/`**，保留函数内容。

---

### 步骤 5：重新编译

```
⌘ + B  (Command + B)
```

应该**编译成功** ✅

---

### 步骤 6：测试自动补圈功能

1. **运行应用**：
   ```
   ⌘ + R  (Command + R)
   ```

2. **关闭应用**：
   - 在模拟器中点击 Home 键
   - 或停止 Xcode 运行

3. **等待 1-2 分钟**

4. **重新打开应用**：
   - 应该显示弹窗："离线期间已为您补充 XX 圈转经 🙏 修行不间断"
   - 计数应该增加了（约 30-60 圈，取决于转速）

---

## 🎯 预期效果

### 正常流程

```
[应用启动]
    ↓
计算离线时间：2 分钟
    ↓
计算补圈：2 分钟 × 30 圈/分 = 60 圈
    ↓
自动添加到计数
    ↓
[弹窗提示]
"离线期间已为您补充 60 圈转经 🙏 修行不间断"
    ↓
[用户点击"好的"]
    ↓
继续正常使用
```

---

## 📝 代码说明

### BackgroundCalculator 工作原理

```swift
// 1. 应用关闭时保存状态
backgroundCalc.saveBackgroundState(
    speed: 30.0,              // 当前转速
    prayerType: "南无阿弥陀佛"  // 当前经文
)

// 2. 应用启动时计算补圈
let missedRotations = backgroundCalc.calculateMissedRotations()
// 公式：补圈数 = (当前时间 - 关闭时间) / 60秒 × 转速

// 3. 自动添加到计数
for _ in 0..<missedRotations {
    _ = prayerLibrary.getNextText()  // 每次调用都会 +1
}
```

---

## ⚠️ 常见问题

### Q1: 编译错误 "Cannot find 'BackgroundCalculator' in scope"

**原因**：`Shared` 文件夹没有正确添加到 iOS Target

**解决**：
1. 选中 `Shared/Services/BackgroundCalculator.swift`
2. 在右侧 File Inspector（文件检查器）中
3. 找到 `Target Membership` 部分
4. ✅ 确保勾选了 `Digital-Prayer-Wheel-iOS`

### Q2: 补圈数量不对

**原因**：可能是转速设置不同

**验证**：
```swift
print("转速：\(prayerLibrary.rotationSpeed) 圈/分")
print("离线时长：\(elapsedMinutes) 分钟")
print("补圈数：\(missedRotations)")
```

### Q3: 没有显示弹窗

**检查**：
1. 是否等待了足够时间（至少 1 分钟）
2. 查看控制台日志：
   ```
   🟢 iOS App appeared
   ⏰ Background compensation: ...
   ✅ iOS: Compensated XX rotations
   ```

---

## 🚀 下一步

启用成功后：
1. 测试不同的离线时长
2. 验证不同转速下的补圈准确性
3. 继续配置 watchOS Target（见 `WATCHOS_SETUP_GUIDE.md`）

---

祝配置顺利！🙏

*Created on 2025/11/09*
