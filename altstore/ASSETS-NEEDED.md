# AltStore 资源文件清单

在推送 altstore 分支之前，需要准备以下资源文件。

## 📋 必需文件

### 1. 源图标
**文件名**: `icon-512.png`
**尺寸**: 512x512 像素
**格式**: PNG
**用途**: 在 AltStore 源列表中显示

### 2. 应用图标
**文件名**: `app-icon-1024.png`
**尺寸**: 1024x1024 像素
**格式**: PNG
**用途**: 应用详情页显示
**获取方式**: 从 Xcode Assets.xcassets/AppIcon.appiconset/ 中导出

### 3. iPhone 截图（至少 3 张）
**目录**: `screenshots/`
**文件名**: `iphone-1.png`, `iphone-2.png`, `iphone-3.png`, `iphone-4.png`
**推荐尺寸**: 1170x2532 像素（iPhone 14 Pro）
**格式**: PNG
**建议内容**:
- `iphone-1.png`: 主转经轮界面
- `iphone-2.png`: 经文选择界面
- `iphone-3.png`: 设置界面
- `iphone-4.png`: 弹幕显示效果

**获取方式**:
1. 在 Xcode 中运行应用到模拟器（iPhone 14 Pro）
2. 使用 `Cmd + S` 截图
3. 重命名并放到 `altstore/screenshots/` 目录

### 4. iPad 截图（可选，2 张）
**目录**: `screenshots/`
**文件名**: `ipad-1.png`, `ipad-2.png`
**推荐尺寸**: 2048x2732 像素（iPad Pro 12.9-inch）
**格式**: PNG

### 5. IPA 文件
**目录**: `releases/`
**文件名**: `Digital-Prayer-Wheel-v1.0.ipa`
**获取方式**: 使用 `altstore-config/build-ipa.sh` 脚本构建

## 📝 可选文件

### 源横幅
**文件名**: `header.png`
**尺寸**: 3:2 比例（如 1500x1000）
**格式**: PNG 或 JPG
**用途**: 源详情页顶部展示

## 🚀 准备步骤

### 第 1 步：导出应用图标

```bash
# 找到你的应用图标文件
# 在 Xcode 项目中: Digital-Prayer-Wheel-iOS/Assets.xcassets/AppIcon.appiconset/

# 如果已经有 1024x1024 的图标，直接复制
cp "path/to/AppIcon-1024.png" altstore/app-icon-1024.png

# 同时作为源图标（或创建专门的源图标）
cp altstore/app-icon-1024.png altstore/icon-512.png
# 然后用图片编辑工具调整 icon-512.png 到 512x512
```

### 第 2 步：截取应用截图

```bash
# 1. 在 Xcode 中选择 iPhone 14 Pro 模拟器
# 2. 运行应用 (Cmd + R)
# 3. 在关键界面按 Cmd + S 截图
# 4. 截图会保存到桌面

# 移动截图到正确位置
mv ~/Desktop/Simulator\ Screen\ Shot*.png altstore/screenshots/
cd altstore/screenshots/
mv Simulator\ Screen\ Shot\ -\ * iphone-1.png  # 重命名截图
# 重复以上步骤获取多张截图
```

### 第 3 步：构建 IPA 文件

```bash
# 回到项目根目录
cd /Users/lihongmin/Dev/Digital-Prayer-Wheel-iOS

# 运行构建脚本
./altstore-config/build-ipa.sh

# 复制生成的 IPA 到 altstore 分支
git checkout altstore
cp build/Digital-Prayer-Wheel-v1.0.ipa altstore/releases/
```

## ✅ 检查清单

在推送 altstore 分支之前，确认以下文件存在：

- [ ] `altstore/icon-512.png` (512x512)
- [ ] `altstore/app-icon-1024.png` (1024x1024)
- [ ] `altstore/screenshots/iphone-1.png`
- [ ] `altstore/screenshots/iphone-2.png`
- [ ] `altstore/screenshots/iphone-3.png`
- [ ] `altstore/screenshots/iphone-4.png`
- [ ] `altstore/releases/Digital-Prayer-Wheel-v1.0.ipa`
- [ ] `altstore/apps.json` (已存在)
- [ ] `altstore/README.md` (已存在)

## 📤 推送步骤

准备好所有文件后：

```bash
# 确保在 altstore 分支
git checkout altstore

# 添加所有文件
git add altstore/

# 提交
git commit -m "chore: 添加 AltStore 资源文件（图标、截图、IPA）"

# 推送到 GitHub
git push origin altstore

# 切换回 main 分支
git checkout main
```

然后在 GitHub 仓库设置中启用 GitHub Pages，选择 `altstore` 分支。

---

**提示**: 如果 IPA 文件超过 100MB，需要使用 Git LFS 或外部托管服务。
