# AltStore 上架配置指南

本目录包含将「至诚转经轮」应用上架到 AltStore 所需的所有配置文件。

## 📁 文件说明

- `apps.json` - AltStore 源配置文件（核心文件）
- 本 README - 完整上架指南

## 🚀 上架步骤

### 第 1 步：创建 GitHub 仓库托管源

1. 在 GitHub 创建新的公开仓库（建议命名：`Digital-Prayer-Wheel-AltStore`）
2. 克隆到本地或直接在 GitHub 网页上传文件

### 第 2 步：准备所需资源

需要准备以下文件并上传到仓库：

```
Digital-Prayer-Wheel-AltStore/
├── apps.json                    # 源配置文件（已生成）
├── icon-512.png                 # 源图标（512x512px）
├── header.png                   # 源横幅（可选，推荐 3:2 比例）
├── app-icon-1024.png           # 应用图标（1024x1024px）
├── screenshots/
│   ├── iphone-1.png            # iPhone 截图（1170x2532px 推荐）
│   ├── iphone-2.png
│   ├── iphone-3.png
│   ├── iphone-4.png
│   ├── ipad-1.png              # iPad 截图（2048x2732px 推荐）
│   └── ipad-2.png
└── releases/
    └── Digital-Prayer-Wheel-v1.0.ipa  # 应用 IPA 文件
```

#### 资源准备指南

**图标制作**：
- 源图标 (icon-512.png): 512x512px，代表你的源的品牌形象
- 应用图标 (app-icon-1024.png): 从 Xcode Assets.xcassets 中导出 1024x1024 的图标
- 横幅 (header.png): 可选，3:2 比例（如 1500x1000px），展示在源的详情页

**截图获取**：
1. 在模拟器中运行应用
2. 使用快捷键 `Cmd+S` 截图
3. iPhone 推荐尺寸：1170x2532px (iPhone 14 Pro)
4. iPad 推荐尺寸：2048x2732px (iPad Pro 12.9-inch)
5. 至少准备 3-5 张 iPhone 截图，展示核心功能

### 第 3 步：构建 IPA 文件

#### 方式 A：使用 Xcode（需要 Apple Developer 账户）

1. 打开 Xcode 项目
2. 选择 `Product` → `Archive`
3. 在 Organizer 中选择 Archive，点击 `Distribute App`
4. 选择 `Ad Hoc` 或 `Development`
5. 选择签名配置，导出 IPA

#### 方式 B：使用免费证书自签名（无需付费账户）

```bash
# 1. 在 Xcode 中使用个人免费证书签名
# 设置 → Signing & Capabilities → Team 选择你的个人账号

# 2. 构建项目
xcodebuild -scheme Digital-Prayer-Wheel-iOS \
  -configuration Release \
  -archivePath ./build/app.xcarchive \
  archive

# 3. 导出 IPA（需要创建 ExportOptions.plist）
xcodebuild -exportArchive \
  -archivePath ./build/app.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist ExportOptions.plist
```

**ExportOptions.plist 示例**：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>teamID</key>
    <string>Z87QA5VWM9</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

#### 方式 C：使用 GitHub Actions 自动构建（推荐）

稍后可以配置 CI/CD 自动化构建流程。

### 第 4 步：配置 GitHub Pages

1. 在 GitHub 仓库中，进入 `Settings` → `Pages`
2. Source 选择 `main` 分支
3. 点击 Save
4. 等待几分钟，GitHub Pages 会部署你的文件
5. 你的源 URL 将是：`https://你的用户名.github.io/Digital-Prayer-Wheel-AltStore/apps.json`

### 第 5 步：更新 apps.json 中的 URL

将 `apps.json` 中所有 `https://你的用户名.github.io/...` 替换为你的实际 GitHub Pages URL。

例如，如果你的 GitHub 用户名是 `buddhist-dev`，则替换为：
```
https://buddhist-dev.github.io/Digital-Prayer-Wheel-AltStore/
```

### 第 6 步：测试和发布

1. 在 iOS 设备上安装 AltStore（需要配合 AltServer）
2. 打开 AltStore，进入 `Sources` 标签
3. 点击右上角 `+` 号
4. 输入你的源 URL：`https://你的用户名.github.io/Digital-Prayer-Wheel-AltStore/apps.json`
5. 添加成功后，在 Browse 标签中应该能看到「至诚转经轮」
6. 点击下载安装测试

## ⚠️ 重要注意事项

### Bundle Identifier 确认
当前配置使用的 Bundle ID 是：`YunQIAI.Digital-Prayer-Wheel`
- 确保这与你实际构建的 IPA 中的 Bundle ID 一致
- 可在 Xcode 项目设置中确认

### iOS 版本要求
当前配置 `minOSVersion` 为 `15.0`，但项目配置显示 `IPHONEOS_DEPLOYMENT_TARGET = 26.0`（似乎有误）。

建议：
1. 检查 Xcode 项目设置
2. 将部署目标改为合理的版本（如 iOS 15.0 或 16.0）
3. 更新 `apps.json` 中的 `minOSVersion` 字段

### 应用签名
- 使用个人免费证书签名的应用每 7 天需重新签名
- 使用付费开发者证书的应用可持续 1 年
- AltStore 可以自动重新签名，但需要定期连接电脑

### 大文件存储
GitHub 仓库有 100MB 单文件限制：
- 如果 IPA 文件超过 100MB，考虑使用 Git LFS
- 或使用其他托管服务（如 Cloudflare R2、Backblaze B2）

## 📱 用户安装指南

创建完成后，可以分享以下安装步骤给用户：

### 安装 AltStore
1. 访问 altstore.io 下载 AltStore（需要配合 AltServer）
2. 按照官方教程在 iOS 设备上安装 AltStore

### 添加源并安装应用
1. 打开 AltStore，进入 `Sources` 标签
2. 点击右上角 `+`，添加源：
   ```
   https://你的用户名.github.io/Digital-Prayer-Wheel-AltStore/apps.json
   ```
3. 在 `Browse` 标签中找到「至诚转经轮」
4. 点击安装

## 🔄 更新应用

当你发布新版本时：

1. 构建新的 IPA 文件
2. 上传到 `releases/` 目录，命名如 `Digital-Prayer-Wheel-v1.1.ipa`
3. 在 `apps.json` 的 `versions` 数组**最前面**添加新版本信息：

```json
{
  "version": "1.1",
  "buildVersion": "2",
  "date": "2025-02-01T10:00:00+08:00",
  "localizedDescription": "版本 1.1 更新内容\n• 新功能...",
  "downloadURL": "https://你的用户名.github.io/Digital-Prayer-Wheel-AltStore/releases/Digital-Prayer-Wheel-v1.1.ipa",
  "minOSVersion": "15.0"
}
```

4. 可选：在 `news` 数组中添加更新公告

## 🎨 自定义建议

### 主题色选择
- 源的主题色 `tintColor`: `"D4AF37"` (金色，象征佛教庄严)
- 应用主题色: `"8B4513"` (棕色，传统经轮木质色)

可以根据实际应用配色调整这些颜色。

### 描述优化
- `localizedDescription` 可以使用 Markdown 格式
- 突出核心功能和特色
- 可以添加使用场景说明

## 📞 问题排查

### 源无法添加
- 检查 `apps.json` 格式是否正确（使用 JSON 验证工具）
- 确认 GitHub Pages 已成功部署
- 检查 URL 是否可访问

### 应用无法安装
- 确认 IPA 文件签名正确
- 检查 Bundle ID 是否匹配
- 确认 iOS 版本符合要求

### 图片无法显示
- 确认图片 URL 可访问
- 检查图片格式（推荐 PNG）
- 确认尺寸符合要求

## 📚 参考资源

- [AltStore 官方文档](https://faq.altstore.io/)
- [创建源指南](https://faq.altstore.io/developers/make-a-source)
- [JSON Schema](https://faq.altstore.io/developers/make-a-source#apps-json-schema)

---

祝上架顺利！🙏
