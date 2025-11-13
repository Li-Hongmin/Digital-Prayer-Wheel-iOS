# v1.2 更新日志

**发布日期**: 2025-11-10

## 🎉 重大功能

### 1. iOS 和 Watch 数据同步
- ✅ 使用 **App Group** 实现数据共享（免费方案）
- ✅ 无需付费开发者账号即可使用
- ✅ 智能数据合并：自动取最大值，避免数据丢失
- ✅ 支持所有经文类型的数据同步
- ✅ 自动同步转经速度和经文类型选择

### 2. 自动补转功能完善
- ✅ iOS 主应用已集成 BackgroundCalculator
- ✅ Watch 应用自动补转正常工作
- ✅ 离线期间根据时长和转速自动补充圈数
- ✅ 最多补充 24 小时的转经数（避免异常累积）
- ✅ 启动时显示补圈提示（iOS）

### 3. 存储机制优化
- ✅ 双重备份：本地 UserDefaults + 共享存储
- ✅ 优先从共享存储加载数据
- ✅ 保存时同步到两个位置
- ✅ 向后兼容：未配置 App Group 时使用本地存储

## 🐛 Bug 修复

### Watch 应用
- 🐛 **修复计数不准确的问题**：改进旋转角度累积算法
- 🐛 **修复今日功德不统计的问题**：使用 `accumulatedRotation` 精确计算完整圈数
- 🐛 **优化计数逻辑**：每 360 度触发一次计数

### 数据同步
- 🐛 确保 iOS 和 Watch 数据不会相互覆盖
- 🐛 修复每日重置时的数据丢失问题
- 🐛 优化数据合并逻辑

## 📚 文档更新

### 新增文档
- ✅ `APP_GROUP_SETUP.md`: 详细的 App Group 配置指南
- ✅ `CHANGELOG_v1.2.md`: 本更新日志

### AltStore 配置
- ✅ 更新 `altstore/apps.json`: 添加 v1.2 版本信息
- ✅ 更新 `altstore-config/apps.json`: 测试配置同步更新
- ✅ 更新应用描述：强调数据同步功能

## 🔧 技术细节

### 新增文件
1. **SharedDataManager.swift** (260+ 行)
   - App Group 共享存储管理器
   - 智能数据合并算法
   - 每日重置检测
   - 向后兼容处理

2. **APP_GROUP_SETUP.md** (140+ 行)
   - 配置步骤说明
   - 常见问题解答
   - 技术细节说明

### 修改文件
1. **PrayerLibrary.swift**
   - 集成 SharedDataManager
   - 修改加载/保存逻辑使用共享存储
   - 保留本地存储作为备份

2. **RealisticWheelView.swift** (Watch)
   - 新增 `accumulatedRotation` 状态变量
   - 改进计数触发逻辑
   - 优化日志输出

3. **AltStore 配置文件**
   - 添加 v1.2 版本条目
   - 更新功能描述
   - 添加配置说明

## 📊 性能优化

- ✅ 减少磁盘写入：使用去抖动保存机制
- ✅ 智能缓存：避免重复读取共享存储
- ✅ 延迟初始化：避免启动阻塞
- ✅ 批量保存：每 10 分钟或应用退出时保存

## 🎯 配置要求

### 必需配置（数据同步）
1. 在 Xcode 中为 iOS 和 Watch target 添加 App Group capability
2. 使用相同的 Group ID：`group.com.yourname.digital-prayer-wheel`
3. 更新 `SharedDataManager.swift` 中的 `appGroupID` 常量

### 可选配置
- 如果不配置 App Group，应用仍可正常运行
- iOS 和 Watch 数据将完全独立
- 自动补转功能不受影响

## 🚀 下一步计划

### 建议的改进
- [ ] 添加同步状态指示器（UI 显示同步时间）
- [ ] 实现数据冲突解决策略选项
- [ ] 添加手动同步按钮
- [ ] 支持历史数据导出

### 潜在功能
- [ ] iCloud 云备份（需要开发者账号）
- [ ] 数据统计图表
- [ ] 多设备排行榜
- [ ] 社交分享功能

## 📝 升级指南

### 从 v1.1 升级到 v1.2

1. **更新代码**：拉取最新代码
2. **配置 App Group**：按照 `APP_GROUP_SETUP.md` 操作
3. **更新 App Group ID**：修改 `SharedDataManager.swift` 第 22 行
4. **重新编译**：清理并重新构建项目
5. **测试同步**：分别在 iOS 和 Watch 上测试

### 数据迁移
- ✅ **无需手动迁移**：首次运行时自动合并数据
- ✅ **数据安全**：保留本地备份
- ✅ **智能合并**：取最大值避免数据丢失

## ⚠️ 已知限制

1. **App Group 配置**
   - 需要 Xcode 配置（约 5 分钟）
   - 需要唯一的 Bundle ID

2. **同步时机**
   - 非实时同步
   - 应用启动时同步
   - 每次保存时同步（10 分钟间隔）

3. **网络要求**
   - **不需要网络**：App Group 是本地共享
   - 仅在同一设备的 iOS 和 Watch 之间同步

## 🙏 致谢

感谢所有用户的反馈和建议！

特别感谢：
- Apple 的 App Group 技术文档
- WatchOS 开发社区
- SwiftUI 开发者社区

---

**版本**: 1.2.0 (Build 3)
**提交哈希**: c7347bd
**发布平台**: AltStore, Sideloadly, 自签名
**支持系统**: iOS 16.0+, watchOS 8.0+
