# GitHub Pages 配置指南

## 目标

将 GitHub Pages 从 altstore 分支切换到 main 分支。

## 配置步骤

### 1. 打开 GitHub 仓库设置

1. 访问：https://github.com/Li-Hongmin/Digital-Prayer-Wheel-iOS
2. 点击顶部 **Settings** 标签
3. 在左侧菜单找到 **Pages**

### 2. 修改 Pages 源

在 "Build and deployment" 部分：

1. **Source**: 保持 "Deploy from a branch"
2. **Branch**:
   - 从下拉菜单选择 **main**
   - 目录选择 **/ (root)**
3. 点击 **Save** 按钮

### 3. 等待部署

- GitHub 会自动触发部署
- 通常需要 2-5 分钟
- 页面顶部会显示部署状态

### 4. 验证部署

等待部署完成后，访问以下链接验证：

```bash
# 1. 检查 apps.json 是否可访问
curl -I https://li-hongmin.github.io/Digital-Prayer-Wheel-iOS/altstore/apps.json

# 2. 检查 v1.3 IPA 是否可下载
curl -I https://li-hongmin.github.io/Digital-Prayer-Wheel-iOS/altstore/releases/Digital-Prayer-Wheel-v1.3.ipa

# 3. 查看 JSON 内容
curl https://li-hongmin.github.io/Digital-Prayer-Wheel-iOS/altstore/apps.json | python3 -m json.tool | head -50
```

### 5. 预期结果

✅ **成功标志**：
- apps.json 返回 200 状态码
- v1.3 IPA 返回 200 状态码
- JSON 内容包含 v1.3 配置
- minOSVersion 为 16.0

❌ **如果失败**：
- 检查 Pages 是否启用
- 检查分支选择是否正确
- 等待更长时间（最多 10 分钟）
- 查看 GitHub Actions 日志

## 配置完成后

### 在 AltStore 中测试

1. 打开 AltStore
2. 刷新源
3. 查看是否显示 v1.3
4. 尝试安装

### 删除 altstore 分支

确认 Pages 工作正常后，执行：

```bash
# 删除远程 altstore 分支
git push origin --delete altstore

# 删除本地 altstore 分支
git branch -d altstore
```

## 故障排查

### 问题 1: Pages 部署失败

**检查**：
- GitHub Actions 标签，查看部署日志
- 确认 main 分支有 altstore/ 目录
- 确认 apps.json 格式正确

### 问题 2: 404 错误

**检查**：
- URL 路径是否正确
- 等待更长时间（清除 CDN 缓存）
- 尝试添加 `?t=timestamp` 参数破坏缓存

### 问题 3: AltStore 无法识别

**检查**：
- apps.json 格式是否正确
- version 和 minOSVersion 字段是否存在
- downloadURL 是否可访问

## 当前状态

- ✅ main 分支已准备就绪
- ✅ altstore/ 目录包含 v1.3 配置和 IPA
- ✅ .gitignore 已更新
- ⏳ 等待 GitHub Pages 配置

## 完成后的工作流

### 日常开发
```bash
# 1. 在 main 分支开发
git checkout main

# 2. 修改代码
# ... 开发工作 ...

# 3. 提交代码
git add .
git commit -m "feat: 新功能"
git push origin main
```

### 发布新版本
```bash
# 1. 在 Xcode 中构建 IPA

# 2. 复制 IPA 到 releases
cp path/to/new.ipa altstore/releases/Digital-Prayer-Wheel-v1.4.ipa

# 3. 更新 apps.json
# 编辑版本号、大小、描述等

# 4. 提交并推送
git add altstore/
git commit -m "release: v1.4"
git push origin main

# 5. GitHub Pages 自动部署（2-5 分钟）

# 6. 验证并通知用户
```

---

**配置完成后，只需要维护 main 分支！** 🎉
