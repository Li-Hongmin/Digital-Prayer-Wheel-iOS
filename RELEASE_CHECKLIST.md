# v1.2 发布检查清单

## 📋 发布前准备

### 代码准备
- [x] Watch 计数问题已修复
- [x] 自动补转功能已实现
- [x] 数据同步代码已完成（可选功能）
- [x] 条件编译已添加（iOS/watchOS）
- [x] 部署目标改为 iOS 16.0
- [x] 所有文档已更新

### 测试（建议在 Xcode 中）
- [ ] iOS App 可以正常编译运行
- [ ] Watch App 可以正常编译运行
- [ ] 转经计数功能正常
- [ ] 自动补转功能正常
- [ ] 数据保存和加载正常

## 🔨 构建 IPA

### 方案 A: Xcode GUI（推荐）

1. [ ] 在 Xcode 中打开项目
2. [ ] 选择 "Digital-Prayer-Wheel-iOS" scheme
3. [ ] 选择 "Any iOS Device"
4. [ ] Product → Archive
5. [ ] Distribute App → Ad Hoc
6. [ ] 导出 IPA 文件
7. [ ] 重命名为 `Digital-Prayer-Wheel-v1.2.ipa`
8. [ ] 记录文件大小（字节）

### 方案 B: 修复 Watch 图标后命令行构建

如果遇到 Watch App 图标错误：

1. [ ] 在 Xcode 中修复 Watch App 图标
   - 删除 AppIcon
   - 重新添加图标资源
   - 使用 Xcode 图标生成工具

2. [ ] 运行构建脚本
   ```bash
   ./build-ipa.sh
   ```

3. [ ] IPA 位于 `build/ipa/Digital-Prayer-Wheel-v1.2.ipa`

### 方案 C: 临时移除 Watch target

1. [ ] 在 Xcode 中移除 Watch App target
2. [ ] 只编译 iOS App
3. [ ] 按方案 A 导出 IPA
4. [ ] 编译完成后恢复 Watch target

## 📤 上传到 GitHub Pages

### 1. 获取文件信息

```bash
# 获取 IPA 文件大小
stat -f%z "path/to/Digital-Prayer-Wheel-v1.2.ipa"
# 记录输出的数字（字节）
```

### 2. 复制 IPA 到 GitHub Pages

```bash
# 假设您的 GitHub Pages 仓库在同级目录
cp Digital-Prayer-Wheel-v1.2.ipa ../Digital-Prayer-Wheel-iOS-Pages/altstore/releases/

# 或者手动复制到正确的位置
```

### 3. 更新 apps.json

编辑 GitHub Pages 仓库中的 `altstore/apps.json`：

```json
{
  "version": "1.2",
  "buildVersion": "3",
  "date": "2025-11-14T18:00:00+08:00",  // 更新为实际发布时间
  "size": 文件实际大小（字节）,  // 更新为实际大小
  "downloadURL": "https://li-hongmin.github.io/Digital-Prayer-Wheel-iOS/altstore/releases/Digital-Prayer-Wheel-v1.2.ipa"
}
```

### 4. 提交到 GitHub

```bash
cd ../Digital-Prayer-Wheel-iOS-Pages
git add altstore/releases/Digital-Prayer-Wheel-v1.2.ipa
git add altstore/apps.json
git commit -m "Release v1.2: 数据同步与自动补转完善"
git push origin main
```

## ✅ 验证发布

### 1. 检查 GitHub Pages

- [ ] 访问 https://li-hongmin.github.io/Digital-Prayer-Wheel-iOS/altstore/apps.json
- [ ] 验证 v1.2 配置正确
- [ ] 访问 IPA 下载链接，确认可以下载

### 2. AltStore 测试

- [ ] 在 AltStore 中添加源（如果还没有）
- [ ] 刷新源
- [ ] 查看 v1.2 是否出现
- [ ] 尝试安装 v1.2

### 3. 功能验证

安装后测试：
- [ ] iOS App 正常启动
- [ ] Watch App 正常启动（如果包含）
- [ ] 转经计数功能正常
- [ ] 今日功德统计正常
- [ ] 自动补转功能正常（关闭几分钟后再打开）
- [ ] 数据保存功能正常（重启 App 数据不丢失）

## 📣 发布公告（可选）

### 更新主仓库 README

- [ ] 在项目 README.md 中添加 v1.2 更新说明
- [ ] 更新功能列表
- [ ] 更新版本号

### GitHub Release

- [ ] 创建 GitHub Release
- [ ] 标签：v1.2
- [ ] 标题：v1.2 - 数据同步与自动补转完善
- [ ] 内容：参考 `CHANGELOG_v1.2.md`
- [ ] 附件：上传 IPA 文件（可选）

## 🐛 问题排查

### 如果 IPA 无法安装

1. 检查设备 iOS 版本（需要 16.0+）
2. 检查签名是否正确
3. 检查 Bundle ID 是否冲突
4. 使用 Sideloadly 重新签名

### 如果功能不正常

1. 查看 Console 日志
2. 检查是否需要配置 App Group
3. 验证数据是否保存到 UserDefaults

### 如果无法构建 IPA

1. 参考 `BUILD_NOTES.md`
2. 参考 `HOW_TO_BUILD_IPA.md`
3. 尝试在 Xcode 中修复 Watch App 图标
4. 或使用方案 C 临时移除 Watch target

## 📊 发布后监控

### 1-3 天内

- [ ] 关注用户反馈
- [ ] 监控安装量
- [ ] 检查是否有崩溃报告
- [ ] 准备 hotfix（如果需要）

### 1-2 周内

- [ ] 收集用户建议
- [ ] 规划下一版本功能
- [ ] 更新文档（如果需要）

## 📝 当前状态

**代码状态**: ✅ 已完成
- 所有功能已实现
- 所有已知问题已修复
- 文档已完善

**待完成**:
1. 在 Xcode 中构建 IPA
2. 上传 IPA 到 GitHub Pages
3. 更新 apps.json 中的实际文件大小
4. 测试安装和功能

**预计时间**: 30-60 分钟

---

## 快速命令参考

```bash
# 1. 构建 IPA（如果命令行可用）
./build-ipa.sh

# 2. 查看 IPA 大小
stat -f%z "build/ipa/Digital-Prayer-Wheel-v1.2.ipa"

# 3. 复制到 GitHub Pages
cp "build/ipa/Digital-Prayer-Wheel-v1.2.ipa" ../Digital-Prayer-Wheel-iOS-Pages/altstore/releases/

# 4. 提交 GitHub Pages
cd ../Digital-Prayer-Wheel-iOS-Pages
git add altstore/
git commit -m "Release v1.2"
git push

# 5. 验证
open "https://li-hongmin.github.io/Digital-Prayer-Wheel-iOS/altstore/apps.json"
```

---

**准备好了吗？** 开始构建和发布 v1.2！ 🚀
