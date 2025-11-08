# AltStore 上架快速开始指南

5 步完成应用上架 AltStore！

## ⚡ 快速步骤

### 1️⃣ 准备图片资源（30 分钟）

创建以下图片并保存到 `altstore-assets/` 目录：

```bash
mkdir -p altstore-assets/screenshots
```

**必需图片**：
- `icon-512.png` - 512x512px（源图标）
- `app-icon-1024.png` - 1024x1024px（应用图标）
- `screenshots/iphone-*.png` - 至少 3 张截图

**获取应用图标**：
1. 打开 Xcode 项目
2. 找到 `Assets.xcassets/AppIcon.appiconset/`
3. 导出 1024x1024 的图标文件

**截图方法**：
1. 运行应用在模拟器中（推荐 iPhone 14 Pro）
2. `Cmd + S` 保存截图
3. 拍摄至少 3-5 个关键界面：
   - 主转经轮界面
   - 经文选择界面
   - 设置界面
   - 弹幕显示效果
   - 计数器展示

### 2️⃣ 构建 IPA 文件（15 分钟）

**检查并修正 iOS 部署目标**：

⚠️ **重要**：当前项目配置 `IPHONEOS_DEPLOYMENT_TARGET = 26.0` 不正确！

```bash
# 1. 打开 Xcode 项目
open Digital-Prayer-Wheel-iOS.xcodeproj

# 2. 在 Xcode 中：
# - 选择项目 → Build Settings
# - 搜索 "iOS Deployment Target"
# - 修改为：iOS 15.0 或 16.0

# 3. 同时更新 apps.json 中的 minOSVersion
```

**使用脚本构建**：

```bash
cd /Users/lihongmin/Dev/Digital-Prayer-Wheel-iOS

# 运行构建脚本
./altstore-config/build-ipa.sh
```

**或手动构建**：

1. 打开 Xcode
2. 选择 `Product` → `Archive`
3. 导出为 Ad Hoc
4. 保存 IPA 文件

### 3️⃣ 创建 GitHub 仓库（10 分钟）

**使用 GitHub CLI（推荐）**：

```bash
# 创建新仓库
cd ~/Documents
mkdir Digital-Prayer-Wheel-AltStore
cd Digital-Prayer-Wheel-AltStore

# 初始化
git init
echo "# 至诚转经轮 AltStore 源" > README.md

# 使用 GitHub CLI 创建远程仓库
gh repo create Digital-Prayer-Wheel-AltStore --public --source=. --remote=origin --push
```

**或在 GitHub 网站手动创建**：

1. 访问 https://github.com/new
2. 仓库名：`Digital-Prayer-Wheel-AltStore`
3. 设置为 Public
4. 点击 Create repository

### 4️⃣ 上传文件到 GitHub（15 分钟）

**目录结构**：

```bash
Digital-Prayer-Wheel-AltStore/
├── apps.json                   # 从 altstore-config/ 复制
├── icon-512.png               # 你准备的源图标
├── app-icon-1024.png         # 应用图标
├── screenshots/
│   └── iphone-*.png          # 截图文件
└── releases/
    └── Digital-Prayer-Wheel-v1.0.ipa  # 构建的 IPA
```

**复制文件**：

```bash
# 进入 AltStore 仓库
cd ~/Documents/Digital-Prayer-Wheel-AltStore

# 复制配置文件
cp /Users/lihongmin/Dev/Digital-Prayer-Wheel-iOS/altstore-config/apps.json .

# 创建目录
mkdir -p screenshots releases

# 复制图片资源
cp /path/to/your/icon-512.png .
cp /path/to/your/app-icon-1024.png .
cp /path/to/screenshots/*.png screenshots/

# 复制 IPA 文件
cp /Users/lihongmin/Dev/Digital-Prayer-Wheel-iOS/build/Digital-Prayer-Wheel-v1.0.ipa releases/
```

**更新 apps.json 中的 URL**：

```bash
# 替换所有 "你的用户名" 为你的实际 GitHub 用户名
# 可以使用文本编辑器或命令行：

# 假设你的 GitHub 用户名是 buddhist-dev
sed -i '' 's/你的用户名/buddhist-dev/g' apps.json
```

**提交并推送**：

```bash
git add .
git commit -m "Initial release: 至诚转经轮 v1.0"
git push origin main
```

### 5️⃣ 启用 GitHub Pages（5 分钟）

1. 访问仓库：`https://github.com/你的用户名/Digital-Prayer-Wheel-AltStore`
2. 点击 `Settings`
3. 左侧菜单选择 `Pages`
4. Source 选择 `main` 分支
5. 点击 `Save`
6. 等待 1-2 分钟部署完成

**验证部署**：

```bash
# 访问这个 URL，应该能看到 JSON 内容
# https://你的用户名.github.io/Digital-Prayer-Wheel-AltStore/apps.json

# 或使用 curl 测试
curl -I https://你的用户名.github.io/Digital-Prayer-Wheel-AltStore/apps.json
```

## 🎉 完成！

现在你可以在 iOS 设备上测试了：

### 测试步骤

1. 在 iPhone/iPad 上安装 AltStore（需要配合电脑端 AltServer）
2. 打开 AltStore → `Sources` 标签
3. 点击 `+` 添加源：
   ```
   https://你的用户名.github.io/Digital-Prayer-Wheel-AltStore/apps.json
   ```
4. 在 `Browse` 中找到「至诚转经轮」
5. 点击安装

## 🔧 常见问题

### Q1: IPA 文件太大（>100MB）怎么办？

**方案 A：使用 Git LFS**
```bash
git lfs install
git lfs track "*.ipa"
git add .gitattributes
git add releases/*.ipa
git commit -m "Add IPA via Git LFS"
git push
```

**方案 B：使用 Release Assets**
1. 在 GitHub 创建 Release
2. 上传 IPA 作为 Release Asset
3. 在 apps.json 中使用 Release 的下载链接

### Q2: 应用无法安装？

1. 检查 Bundle ID 是否匹配：`Li-Hongmin.Digital-Prayer-Wheel`
2. 确认 IPA 文件签名正确
3. 检查 iOS 版本要求（修正部署目标）

### Q3: 图片无法显示？

1. 确认文件名大小写匹配
2. 检查 GitHub Pages 是否部署成功
3. 访问图片 URL 确认可访问

### Q4: 部署目标版本问题？

当前项目配置有误（iOS 26.0 不存在），需要修改：

1. 打开 Xcode 项目
2. Project Settings → Build Settings
3. 搜索 "iOS Deployment Target"
4. 改为 iOS 15.0 或 16.0
5. 重新构建 IPA

## 📱 分享给用户

创建完成后，你可以分享以下内容给用户：

```
📱 至诚转经轮 - 藏传佛教修行助手

安装步骤：
1. 安装 AltStore (https://altstore.io)
2. 打开 AltStore → Sources → 点击 +
3. 添加源：https://你的用户名.github.io/Digital-Prayer-Wheel-AltStore/apps.json
4. 在 Browse 中安装「至诚转经轮」

功能特色：
🙏 四种经文支持
📈 指数增长计数
🎨 自定义弹幕
💾 自动保存
📱 支持 iPhone/iPad
```

## 📚 详细文档

- 完整指南：[README.md](README.md)
- GitHub 仓库结构：[github-repo-structure.md](github-repo-structure.md)
- AltStore 官方文档：https://faq.altstore.io

---

祝上架顺利！🙏
