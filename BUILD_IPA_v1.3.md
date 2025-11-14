# 构建 v1.3 IPA 文件指南

## 快速方法：在 Xcode 中构建

由于 Watch App 图标与命令行工具有兼容性问题，推荐使用 Xcode GUI 构建。

### 步骤 1: 准备项目

1. 在 Xcode 中打开 `Digital-Prayer-Wheel-iOS.xcodeproj`
2. 选择 **Digital-Prayer-Wheel-iOS** scheme
3. 在顶部工具栏选择 **Any iOS Device (arm64)**

### 步骤 2: Archive

1. 菜单栏选择 **Product** → **Archive**
2. 等待编译完成（可能需要 2-5 分钟）

**如果遇到 Watch App 图标错误**：
- 这是 Xcode 26 的已知问题
- 建议临时移除 Watch target（见下方"临时移除 Watch"）

### 步骤 3: 导出 IPA

在 Organizer 窗口中：

1. 选择刚创建的 Archive
2. 点击 **Distribute App**
3. 选择 **Ad Hoc** 或 **Development**
4. 点击 **Next**
5. 选择 **Automatically manage signing**
6. 点击 **Export**
7. 选择保存位置

### 步骤 4: 重命名和验证

```bash
# 1. 重命名为 v1.3
mv "Digital-Prayer-Wheel-iOS.ipa" "Digital-Prayer-Wheel-v1.3.ipa"

# 2. 查看文件大小
stat -f%z "Digital-Prayer-Wheel-v1.3.ipa"
```

## 临时移除 Watch Target 的方法

如果编译时提示 Watch App 图标错误：

### 方法 A: 在 Scheme 中禁用

1. 点击顶部 scheme 选择器旁的 **Edit Scheme...**
2. 选择 **Build** 标签
3. 取消勾选 **Watch App for iOS App Watch App**
4. 点击 **Close**
5. 然后按照上面步骤 Archive

### 方法 B: 暂时删除 target

1. 在项目导航器中选择项目（蓝色图标）
2. 在 TARGETS 列表中找到 **Watch App for iOS App Watch App**
3. 右键点击 → **Delete**（只是从项目中移除，不删除文件）
4. Archive 完成后，再添加回来：
   - 点击底部 **+** 按钮
   - 添加回 Watch target

## 上传到 GitHub Pages

### 1. 切换到 altstore 分支

```bash
cd /Users/lihongmin/Dev/Digital-Prayer-Wheel-iOS
git checkout altstore
```

### 2. 复制 IPA 文件

```bash
# 从导出位置复制到 releases 目录
cp "path/to/Digital-Prayer-Wheel-v1.3.ipa" altstore/releases/
```

### 3. 获取文件大小

```bash
stat -f%z "altstore/releases/Digital-Prayer-Wheel-v1.3.ipa"
# 记录输出的数字
```

### 4. 更新 apps.json

编辑 `altstore/apps.json`，将 v1.3 的配置改为：

```json
{
  "version": "1.3",
  "buildVersion": "2",
  "downloadURL": "https://li-hongmin.github.io/Digital-Prayer-Wheel-iOS/altstore/releases/Digital-Prayer-Wheel-v1.3.ipa",
  "size": 实际文件大小,
  "minOSVersion": "16.0"
}
```

### 5. 提交并推送

```bash
git add altstore/releases/Digital-Prayer-Wheel-v1.3.ipa
git add altstore/apps.json
git commit -m "release: v1.3 真实 IPA 文件"
git push origin altstore
```

## 验证安装

等待 2-5 分钟后：

1. 在 AltStore 中刷新源
2. 尝试安装 v1.3
3. 验证功能：
   - 横屏布局是否正常
   - Watch 计数是否正常
   - 自动补转是否工作

## 当前状态

- ✅ 代码已完成（包括横屏布局）
- ✅ AltStore 配置已更新（v1.3）
- ⏳ 等待构建真实的 IPA 文件
- ⏳ 当前使用 v1.1 IPA 占位

## 如果命令行编译可用

如果 Watch 图标问题解决了，也可以尝试：

```bash
./build-ipa.sh
```

但基于之前的经验，推荐在 Xcode GUI 中操作。

---

**准备好后请按照上述步骤构建 IPA！** 🚀
