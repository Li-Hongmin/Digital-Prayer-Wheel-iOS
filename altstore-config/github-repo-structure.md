# GitHub 仓库结构示例

创建一个新的公开 GitHub 仓库用于托管 AltStore 源。

## 推荐仓库名称

`Digital-Prayer-Wheel-AltStore` 或 `digital-prayer-wheel-altstore`

## 目录结构

```
Digital-Prayer-Wheel-AltStore/
│
├── apps.json                          # AltStore 源配置文件（必需）
│
├── README.md                          # 仓库说明和用户安装指南
│
├── icon-512.png                       # 源图标 512x512px（必需）
├── app-icon-1024.png                 # 应用图标 1024x1024px（必需）
├── header.png                         # 源横幅图片（可选）
│
├── screenshots/                       # 应用截图目录
│   ├── iphone/
│   │   ├── 1-main-wheel.png          # 主转经轮界面
│   │   ├── 2-prayer-selection.png    # 经文选择界面
│   │   ├── 3-settings.png            # 设置界面
│   │   ├── 4-barrage-display.png     # 弹幕显示效果
│   │   └── 5-counter.png             # 计数器展示
│   │
│   └── ipad/
│       ├── 1-main-landscape.png      # iPad 横屏主界面
│       └── 2-settings-ipad.png       # iPad 设置界面
│
└── releases/                          # IPA 文件存放目录
    ├── Digital-Prayer-Wheel-v1.0.ipa
    └── Digital-Prayer-Wheel-v1.1.ipa  # 未来版本
```

## 文件准备清单

### ✅ 必需文件

- [ ] `apps.json` - 已生成，需要更新 URL
- [ ] `icon-512.png` - 源的图标
- [ ] `app-icon-1024.png` - 应用图标（从 Xcode Assets 导出）
- [ ] 至少 3 张 iPhone 截图
- [ ] `releases/Digital-Prayer-Wheel-v1.0.ipa` - 构建的 IPA 文件

### 📋 推荐文件

- [ ] `README.md` - 用户安装说明
- [ ] `header.png` - 源的横幅图片
- [ ] 2 张 iPad 截图（如果支持 iPad）

### 🎨 图片规格要求

| 图片类型 | 尺寸 | 格式 | 用途 |
|---------|------|------|------|
| 源图标 | 512x512 | PNG | 在 AltStore 源列表中显示 |
| 应用图标 | 1024x1024 | PNG | 应用详情页显示 |
| 源横幅 | 建议 3:2 比例 | PNG/JPG | 源详情页顶部展示 |
| iPhone 截图 | 1170x2532 | PNG | iPhone 详情页展示 |
| iPad 截图 | 2048x2732 | PNG | iPad 详情页展示 |

## 创建仓库步骤

### 1. 在 GitHub 上创建仓库

```bash
# 在 GitHub 网站上创建新仓库
# 或使用 GitHub CLI:
gh repo create Digital-Prayer-Wheel-AltStore --public
```

### 2. 本地初始化并推送

```bash
cd Digital-Prayer-Wheel-AltStore
git init
git add .
git commit -m "Initial commit: AltStore source for 至诚转经轮"
git branch -M main
git remote add origin https://github.com/你的用户名/Digital-Prayer-Wheel-AltStore.git
git push -u origin main
```

### 3. 启用 GitHub Pages

1. 进入仓库 Settings
2. 左侧菜单选择 Pages
3. Source 选择 `main` 分支
4. Root 选择 `/ (root)`
5. 点击 Save
6. 等待部署完成（约 1-2 分钟）

### 4. 验证部署

访问以下 URL 确认文件可访问：

- 源配置：`https://你的用户名.github.io/Digital-Prayer-Wheel-AltStore/apps.json`
- 应用图标：`https://你的用户名.github.io/Digital-Prayer-Wheel-AltStore/app-icon-1024.png`

## 示例 README.md

为你的 AltStore 仓库创建一个用户友好的 README：

```markdown
# 至诚转经轮 - AltStore 源

藏传佛教修行助手的 AltStore 分发源。

## 📱 安装应用

### 第 1 步：安装 AltStore

1. 访问 [altstore.io](https://altstore.io) 下载 AltStore
2. 按照官方教程在 iOS 设备上安装

### 第 2 步：添加本源

1. 打开 AltStore 应用
2. 点击 `Sources` 标签
3. 点击右上角 `+` 号
4. 输入源地址：
   ```
   https://你的用户名.github.io/Digital-Prayer-Wheel-AltStore/apps.json
   ```
5. 点击 `Add`

### 第 3 步：安装应用

1. 进入 `Browse` 标签
2. 找到「至诚转经轮」
3. 点击 `GET` 或 `INSTALL`

## ✨ 应用功能

- 🙏 四种经文选择
- 📈 指数增长计数系统
- 🎨 自定义弹幕显示
- 💾 自动保存进度
- 📱 支持 iPhone 和 iPad

## 🔄 更新日志

### v1.0 (2025-01-15)
- 首次发布
- 核心转经轮功能
- 四种经文支持

## 📞 支持

如有问题，请在 [主仓库](https://github.com/你的用户名/Digital-Prayer-Wheel-iOS) 提交 Issue。
```

## ⚠️ 注意事项

### IPA 文件大小限制

GitHub 有 100MB 单文件限制：
- 如果 IPA < 100MB：直接上传到仓库
- 如果 IPA > 100MB：使用 Git LFS 或外部托管

### 使用 Git LFS（如果需要）

```bash
# 安装 Git LFS
git lfs install

# 追踪 IPA 文件
git lfs track "*.ipa"
git add .gitattributes

# 正常提交
git add releases/*.ipa
git commit -m "Add IPA file via Git LFS"
git push
```

### 外部托管方案

如果不想使用 GitHub 存储 IPA：

1. **Cloudflare R2**（推荐，免费）
2. **Backblaze B2**
3. **自己的服务器**

然后在 `apps.json` 中使用外部 URL。

## 🎯 下一步

1. ✅ 创建 GitHub 仓库
2. ✅ 准备所有图片资源
3. ✅ 构建 IPA 文件
4. ✅ 上传所有文件
5. ✅ 启用 GitHub Pages
6. ✅ 更新 `apps.json` 中的 URL
7. ✅ 测试安装流程
8. ✅ 分享给用户
