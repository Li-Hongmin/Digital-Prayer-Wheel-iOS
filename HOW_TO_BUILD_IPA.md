# 如何构建 IPA 文件

## 方案 1: 使用 Xcode GUI（推荐）

### 步骤 1: 准备项目

1. 在 Xcode 中打开 `Digital-Prayer-Wheel-iOS.xcodeproj`
2. 确保选择了 **Digital-Prayer-Wheel-iOS** scheme
3. 在顶部工具栏选择 **Any iOS Device (arm64)**

### 步骤 2: Archive

1. 菜单栏选择 **Product** → **Archive**
2. 等待编译完成（可能需要几分钟）
3. 编译完成后会自动打开 **Organizer** 窗口

### 步骤 3: 导出 IPA

在 Organizer 窗口中：

1. 选择刚才创建的 Archive
2. 点击右侧的 **Distribute App** 按钮
3. 选择 **Ad Hoc** (或 **Development** 如果用于自己测试)
4. 点击 **Next**
5. 选择 **Automatically manage signing** (如果有开发者账号)
   - 或选择 **Manually manage signing** (免费账号)
6. 点击 **Next**
7. 选择导出位置
8. 点击 **Export**

### 步骤 4: 获取 IPA 文件

1. 导出的文件夹中会有一个 `.ipa` 文件
2. 重命名为 `Digital-Prayer-Wheel-v1.2.ipa`
3. 记录文件大小（用于更新 AltStore 配置）

## 方案 2: 使用命令行（如果方案 1 有问题）

⚠️ **注意**: 由于当前 Watch App 图标问题，命令行编译可能失败。建议先在 Xcode 中修复图标。

### 如果要尝试命令行：

```bash
# 1. 进入项目目录
cd /Users/lihongmin/Dev/Digital-Prayer-Wheel-iOS

# 2. 运行构建脚本
./build-ipa.sh
```

## 方案 3: 使用 Xcode 临时禁用 Watch target

如果 Watch App 图标问题导致无法编译：

### 临时移除 Watch target

1. 在 Xcode 中打开项目
2. 选择项目文件（蓝色图标）
3. 在左侧 TARGETS 列表中，右键点击 **Watch App for iOS App Watch App**
4. 选择 **Remove**（只是从编译中移除，不会删除文件）
5. 然后按照方案 1 操作

### 编译完成后恢复 Watch target

1. 选择项目文件
2. 在底部点击 **+** 按钮
3. 添加回 **Watch App for iOS App Watch App** target

## 更新 AltStore 配置

### 1. 获取 IPA 文件大小

```bash
# macOS 终端
stat -f%z "path/to/Digital-Prayer-Wheel-v1.2.ipa"

# 或者在 Finder 中
# 右键点击 IPA → 显示简介 → 查看文件大小（字节）
```

### 2. 更新 apps.json

编辑 `altstore/apps.json`，找到 v1.2 版本：

```json
{
  "version": "1.2",
  "buildVersion": "3",
  "size": 这里填入实际的文件大小（字节）,
  "downloadURL": "https://li-hongmin.github.io/Digital-Prayer-Wheel-iOS/altstore/releases/Digital-Prayer-Wheel-v1.2.ipa"
}
```

### 3. 上传 IPA 到 GitHub Pages

```bash
# 假设您的 GitHub Pages 仓库在同级目录
cp Digital-Prayer-Wheel-v1.2.ipa ../Digital-Prayer-Wheel-iOS-Pages/altstore/releases/

# 或者直接上传到您的 GitHub Pages 仓库
```

### 4. 提交更新

```bash
# 在 GitHub Pages 仓库中
cd ../Digital-Prayer-Wheel-iOS-Pages
git add altstore/releases/Digital-Prayer-Wheel-v1.2.ipa
git add altstore/apps.json  # 如果也更新了配置
git commit -m "Release v1.2: 数据同步与自动补转完善"
git push
```

## 验证 IPA

### 本地安装测试

1. 使用 **AltStore** 或 **Sideloadly** 安装到设备
2. 验证功能：
   - ✅ Watch 计数是否正常
   - ✅ 自动补转是否工作
   - ✅ 数据是否正确保存

### 检查 AltStore 源

1. 在浏览器访问：`https://li-hongmin.github.io/Digital-Prayer-Wheel-iOS/altstore/apps.json`
2. 验证 v1.2 的配置是否正确
3. 尝试通过 AltStore 安装

## 常见问题

### Q: 编译时提示 Watch App 图标错误？
**A**: 使用方案 3 临时移除 Watch target，只编译 iOS App。

### Q: 没有开发者账号可以导出 IPA 吗？
**A**: 可以，选择 **Development** 导出，但只能安装在您自己的设备上。

### Q: IPA 文件太大？
**A**:
- 确保使用 **Release** 配置
- 启用了 **Strip Swift Symbols**
- 没有包含调试符号

### Q: 如何验证 IPA 是否正确？
**A**:
```bash
# 查看 IPA 内容
unzip -l Digital-Prayer-Wheel-v1.2.ipa

# 查看 Info.plist
unzip -p Digital-Prayer-Wheel-v1.2.ipa 'Payload/*.app/Info.plist' | plutil -p -
```

## 快速检查清单

构建前：
- [ ] 已修复所有编译错误
- [ ] 版本号正确（1.2）
- [ ] Bundle Identifier 正确
- [ ] 部署目标是 iOS 16.0

导出后：
- [ ] IPA 文件存在
- [ ] 文件大小合理（1-2 MB）
- [ ] 已记录文件大小
- [ ] 已上传到 GitHub Pages
- [ ] 已更新 apps.json
- [ ] 已推送到远程仓库

---

**需要帮助？** 查看 `BUILD_NOTES.md` 了解更多编译问题的解决方案。
