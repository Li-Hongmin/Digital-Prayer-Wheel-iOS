# 快速开始指南

## 1. 基本使用（无需配置）

应用可以**直接使用**，无需任何配置：

1. 在 iPhone 或 iPad 上打开应用
2. 转经轮自动开始旋转
3. 今日功德会自动累计
4. 应用关闭后再打开会自动补充离线期间的转经次数

⚠️ **注意**：不配置 App Group 时，iOS 和 Watch 的数据是独立的。

## 2. 启用数据同步（推荐）

### 为什么要配置？

- ✅ iOS 和 Watch 数据自动同步
- ✅ 切换设备无缝衔接
- ✅ 数据自动合并，避免丢失
- ✅ **完全免费**，无需开发者账号

### 配置步骤（约 5 分钟）

#### 步骤 1: 为 iOS App 添加 App Group

1. 在 Xcode 中打开项目
2. 选择 **Digital-Prayer-Wheel-iOS** target
3. 点击 **Signing & Capabilities** 标签
4. 点击 **"+ Capability"**
5. 搜索并添加 **"App Groups"**
6. 点击 **"+"** 添加 Group ID：`group.com.yourname.digital-prayer-wheel`
   - 将 `yourname` 替换为您的名字或唯一标识
7. 勾选刚创建的 App Group

#### 步骤 2: 为 Watch App 添加 App Group

1. 在同一个项目中
2. 选择 **Watch App for iOS App Watch App** target
3. 重复步骤 1 的操作 3-7
4. ⚠️ **必须使用完全相同的 Group ID**

#### 步骤 3: 更新代码

打开文件：`Digital-Prayer-Wheel-iOS/Services/SharedDataManager.swift`

找到第 22 行，修改：

```swift
private static let appGroupID = "group.com.yourname.digital-prayer-wheel"
```

将 `yourname` 改为您在步骤 1 中使用的名称。

#### 步骤 4: 验证

1. 清理并重新编译项目（⌘+Shift+K 然后 ⌘+B）
2. 运行应用
3. 查看 Console 日志
4. 如果看到：`✅ Shared UserDefaults initialized with App Group: ...`，说明配置成功！

## 3. 测试同步功能

### 测试步骤

1. 在 iPhone 上打开应用，转几圈（等待计数更新）
2. 关闭 iPhone 应用
3. 在 Watch 上打开应用
4. 查看计数是否与 iPhone 一致
5. 在 Watch 上继续转几圈
6. 回到 iPhone 查看，应该看到合并后的数据

### 预期结果

- ✅ iPhone 和 Watch 显示相同的今日功德
- ✅ 总循环数是两个设备的最大值
- ✅ 转经速度在两个设备间同步

## 4. 常见问题

### Q: 必须配置 App Group 吗？

**A**: ❌ 不是必须的。不配置也可以正常使用，只是 iOS 和 Watch 的数据不会同步。

### Q: 免费账号可以用吗？

**A**: ✅ 可以！App Group 不需要付费开发者账号。

### Q: 需要联网吗？

**A**: ❌ 不需要。App Group 是本地共享，不需要网络。

### Q: 配置错了怎么办？

**A**: 重新配置即可，不会丢失数据。应用会保留本地备份。

### Q: 数据会实时同步吗？

**A**: ⚠️ 不是实时的，数据在以下时机同步：
- 应用启动时
- 每 10 分钟自动保存时
- 应用退出时

### Q: 可以改 Group ID 吗？

**A**: ✅ 可以，但需要：
1. 在两个 target 中都更改
2. 更新代码中的 `appGroupID`
3. ⚠️ 更改后之前的共享数据将无法访问（但本地数据保留）

## 5. 自动补转功能

### iOS 自动补转

- 关闭应用后，系统会记录时间和转速
- 再次打开时，根据离线时长自动补充转经次数
- 最多补充 24 小时的转经数
- 会显示提示："离线期间已为您补充 X 圈转经"

### Watch 自动补转

- 与 iOS 相同的机制
- 抬腕打开 Watch 应用时自动补充
- 自动计入今日功德

### 补转计算公式

```
补充圈数 = 离线时长（分钟）× 转经速度（圈/分钟）
```

例如：
- 离线 1 小时
- 转速 30 圈/分钟
- 补充：60 × 30 = 1800 圈

## 6. 进阶功能

### 调整转经速度

**iPhone/iPad**:
- 在设置中调整速度滑块
- 范围：6-600 圈/分钟

**Watch**:
- 旋转 Digital Crown（数码表冠）
- 实时调整，有触觉反馈

### 切换经文

1. 打开设置
2. 选择经文类型：
   - 六字大明咒
   - 心经
   - 南无阿弥陀佛
   - 南无观世音菩萨
3. 每种经文独立计数

### 查看统计

- **今日功德**：今天的转经次数（午夜重置）
- **累计天数**：总共修行的天数
- 点击"今日功德"可查看日历统计

## 7. 故障排除

### 配置不成功

1. 检查两个 target 的 Group ID 是否完全一致
2. 检查代码中的 `appGroupID` 是否已更新
3. 清理项目（⌘+Shift+K）并重新编译

### 数据不同步

1. 确认 App Group 配置正确
2. 查看 Console 日志是否有错误
3. 尝试重启应用
4. 检查是否在不同的 Apple ID 下安装

### Watch 计数不更新

1. 确保 Watch 应用正在运行
2. 检查是否进入了省电模式
3. 重启 Watch 应用

## 8. 数据备份

### 自动备份

- 本地 UserDefaults：设备本地
- 共享存储：App Group
- 每 10 分钟自动保存

### 手动备份

目前不支持手动导出，但数据存储在：
- 本地：`UserDefaults.standard`
- 共享：`UserDefaults(suiteName: "group.com.yourname.digital-prayer-wheel")`

## 9. 获取帮助

- 📖 详细配置指南：`APP_GROUP_SETUP.md`
- 📝 更新日志：`CHANGELOG_v1.2.md`
- 🐛 问题反馈：GitHub Issues
- 📧 邮件联系：[您的邮箱]

---

**祝您修行精进！** 🙏
