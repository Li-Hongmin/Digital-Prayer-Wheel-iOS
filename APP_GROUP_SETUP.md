# App Group 配置指南

本文档说明如何配置 App Group 以实现 iOS 和 Watch 数据同步。

## 为什么需要 App Group？

App Group 允许 iOS 主应用和 Watch 应用共享数据存储，实现：
- ✅ **免费方案**：无需付费开发者账号
- ✅ **数据同步**：iOS 和 Watch 共享转经计数
- ✅ **自动合并**：智能合并两个设备的数据，取最大值避免数据丢失
- ✅ **每日重置**：午夜自动重置今日计数

## 配置步骤

### 1. 配置 iOS 主应用

1. 在 Xcode 中打开项目
2. 选择 **Digital-Prayer-Wheel-iOS** target
3. 点击 **Signing & Capabilities** 标签
4. 点击 **"+ Capability"** 按钮
5. 搜索并添加 **"App Groups"**
6. 点击 App Groups 下的 **"+"** 按钮
7. 输入 Group ID：`group.com.yourname.digital-prayer-wheel`
   - ⚠️ 注意：将 `yourname` 替换为您的开发者名称或其他唯一标识
8. 勾选刚创建的 App Group

### 2. 配置 Watch 应用

1. 在同一个 Xcode 项目中
2. 选择 **Watch App for iOS App Watch App** target
3. 重复上述步骤 3-8
4. ⚠️ **必须使用完全相同的 Group ID**：`group.com.yourname.digital-prayer-wheel`

### 3. 更新代码中的 App Group ID

打开文件：`Digital-Prayer-Wheel-iOS/Services/SharedDataManager.swift`

找到第 22 行，修改 App Group ID：

```swift
private static let appGroupID = "group.com.yourname.digital-prayer-wheel"
```

将 `yourname` 替换为您在第 1 步中使用的名称。

### 4. 验证配置

1. 编译并运行 iOS 应用
2. 查看 Xcode Console 日志
3. 如果看到以下消息，说明配置成功：
   ```
   ✅ Shared UserDefaults initialized with App Group: group.com.yourname.digital-prayer-wheel
   ```
4. 如果看到错误消息，检查：
   - App Group ID 是否在两个 target 中完全一致
   - 是否在 Capabilities 中勾选了 App Group
   - 代码中的 `appGroupID` 是否已更新

## 同步机制说明

### 数据合并策略

当 iOS 和 Watch 同时使用时，系统会自动合并数据：

- **今日计数**：取两个设备的最大值
- **总循环数**：取两个设备的最大值
- **转经速度**：最后修改的设备优先
- **经文类型**：最后修改的设备优先

### 每日重置

每天午夜（00:00），今日计数会自动重置为 0，但总循环数保持累计。

### 自动补转功能

当您关闭应用几小时后再打开，系统会根据：
- 离线时长
- 最后的转经速度

自动补充您在离线期间应该完成的转经次数。

**限制**：最多补充 24 小时的转经数，避免异常累积。

## 常见问题

### Q1: 免费 Apple ID 可以使用 App Group 吗？
**A**: ✅ 可以！App Groups 不需要付费开发者账号。

### Q2: App Group 需要联网吗？
**A**: ❌ 不需要。App Group 是本地共享存储，不需要网络连接。

### Q3: iOS 和 Watch 的数据会实时同步吗？
**A**: ⚠️ 不是实时的。数据在以下时机同步：
- 应用启动时
- 每次转经计数保存时（每 10 分钟或应用退出）
- 切换经文类型时

### Q4: 如果忘记配置 App Group 会怎样？
**A**: 应用仍然可以正常运行，但 iOS 和 Watch 的数据将完全独立，无法同步。

### Q5: 可以更改 App Group ID 吗？
**A**: ✅ 可以，但需要：
1. 在两个 target 中都更改
2. 更新代码中的 `appGroupID`
3. ⚠️ 更改后之前的数据将无法访问

## 技术细节

### 使用的技术

- **UserDefaults(suiteName:)**：App Group 共享存储
- **智能合并算法**：避免数据丢失
- **每日重置检测**：基于 `Calendar.startOfDay`
- **自动补转计算**：基于时间戳和转速

### 存储的数据

每种经文类型存储：
- 今日计数
- 总循环数
- 最后更新时间
- 每日重置时间戳

全局数据：
- 转经速度
- 当前选择的经文类型

### 性能优化

- ✅ 延迟保存：避免频繁写入磁盘
- ✅ 智能合并：只在数据不一致时合并
- ✅ 本地缓存：减少跨应用数据访问

## 开发者信息

如果您在配置过程中遇到问题，请：

1. 检查 Xcode Console 的错误日志
2. 验证 App Group ID 拼写
3. 确认两个 target 都已添加 Capability
4. 重新编译并清理项目（Clean Build Folder）

---

**提示**：配置完成后，建议测试一下同步功能，分别在 iOS 和 Watch 上转经，然后重启应用查看数据是否正确合并。
