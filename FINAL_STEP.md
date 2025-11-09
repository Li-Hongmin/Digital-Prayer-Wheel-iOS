# 🎯 最后一步：添加共享文件到 watchOS Target

你现在看到 "Hello World" 是因为 watchOS 应用还缺少共享的业务逻辑代码。

## ✅ 已完成
- ContentView.swift 已替换为转经轮代码
- MinimalWheelView.swift 已创建

## ⏳ 需要做的（5分钟）

### 在 Xcode 中添加共享文件到 watchOS Target

**步骤**：

1. **打开 Xcode 项目**（如果还没打开）

2. **找到以下文件**（在左侧项目导航器中）：
   ```
   Digital-Prayer-Wheel-iOS/
   ├── Models/
   │   ├── PrayerText.swift          ← 选中这个
   │   ├── AppSettings.swift         ← 选中这个
   │   └── DailyPrayerRecord.swift   ← 选中这个
   └── Services/
       ├── PrayerLibrary.swift       ← 选中这个
       ├── PrayerStatistics.swift    ← 选中这个
       └── BackgroundCalculator.swift ← 选中这个
   ```

3. **添加到 watchOS Target**（对每个文件）：
   - 选中文件（点击文件名）
   - 在右侧打开 **File Inspector**（文件检查器）
     - 快捷键：⌥ + ⌘ + 1
     - 或菜单：View → Inspectors → File
   - 找到 **Target Membership** 部分
   - ✅ **勾选** `Digital-Prayer-Wheel-Watch Watch App`

4. **验证**：
   - 6 个文件都应该勾选了 watchOS Target
   - 同时保持 iOS Target 也勾选

5. **重新编译**：
   ```
   ⌘ + B  (编译)
   ⌘ + R  (运行)
   ```

---

## 🎉 预期效果

编译成功后，在 watchOS 模拟器上你会看到：

```
╔════════════════════╗
║   🙏 转经轮         ║
║  (自动旋转动画)     ║
║                    ║
║  南无阿弥陀佛       ║
║                    ║
║  今日: 10 圈       ║
║  总计: 108 圈      ║
║  速度: 30 圈/分    ║
╚════════════════════╝
```

---

## 📸 操作截图说明

### 步骤 1: 选中文件
![](选中 PrayerLibrary.swift)

### 步骤 2: 打开 File Inspector
![](右侧面板 → File Inspector → 第一个标签)

### 步骤 3: 勾选 Target Membership
![](找到 Target Membership → 勾选 watchOS Target)

---

## ⚠️ 如果编译报错

### 错误：Cannot find 'PrayerLibrary' in scope

**原因**：文件没有正确添加到 watchOS Target

**解决**：
1. 检查 Target Membership 是否勾选
2. Clean Build Folder：⇧ + ⌘ + K
3. 重新编译：⌘ + B

---

### 错误：Duplicate symbol

**原因**：文件被重复添加了

**解决**：
1. 确保文件只在 iOS 和 watchOS 各出现一次
2. 不要复制文件，只勾选 Target Membership

---

## 🚀 快捷方法（批量添加）

如果你觉得一个个添加太慢：

1. **选中所有需要的文件**：
   - 按住 ⌘ 键
   - 依次点击 6 个文件

2. **打开 File Inspector**：
   - ⌥ + ⌘ + 1

3. **一次性勾选**：
   - Target Membership → 勾选 `Digital-Prayer-Wheel-Watch Watch App`

---

## 📝 检查清单

完成后确认：

- [ ] PrayerText.swift → watchOS Target ✅
- [ ] AppSettings.swift → watchOS Target ✅
- [ ] DailyPrayerRecord.swift → watchOS Target ✅
- [ ] PrayerLibrary.swift → watchOS Target ✅
- [ ] PrayerStatistics.swift → watchOS Target ✅
- [ ] BackgroundCalculator.swift → watchOS Target ✅
- [ ] 编译成功 ✅
- [ ] 运行看到转经轮界面 ✅
- [ ] 转经轮自动旋转 ✅

---

## 💡 完成后

你就可以：

1. **测试自动补圈**：
   - 运行应用
   - 停止运行（⌘ + .）
   - 等待 2 分钟
   - 重新运行
   - 看到补圈提示

2. **调整转速**：
   - 在代码中修改默认转速
   - 或后续添加设置界面

3. **真机测试**：
   - 将应用部署到你的 Apple Watch SE1

---

完成后告诉我，我们一起庆祝！🎉

*Last updated: 2025/11/09*
