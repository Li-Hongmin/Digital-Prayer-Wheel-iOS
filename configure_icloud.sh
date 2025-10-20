#!/bin/bash

# 配置 iCloud 的脚本
# 在 Xcode 项目中添加 entitlements 配置

PROJECT_FILE="Digital-Prayer-Wheel-iOS.xcodeproj/project.pbxproj"
ENTITLEMENTS_PATH="Digital-Prayer-Wheel-iOS/Digital-Prayer-Wheel-iOS.entitlements"

echo "🔧 开始配置 iCloud entitlements..."

# 备份原文件
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"
echo "✅ 已备份项目文件"

# 在 buildSettings 中添加 CODE_SIGN_ENTITLEMENTS
# 使用 sed 在 DEVELOPMENT_TEAM 后面添加
sed -i '' '/DEVELOPMENT_TEAM = Z87QA5VWM9;/a\
				CODE_SIGN_ENTITLEMENTS = "Digital-Prayer-Wheel-iOS/Digital-Prayer-Wheel-iOS.entitlements";
' "$PROJECT_FILE"

echo "✅ 已添加 CODE_SIGN_ENTITLEMENTS 配置"
echo ""
echo "📋 请在 Xcode 中验证："
echo "   1. 在 Xcode 中打开项目"
echo "   2. 选择 Target → Build Settings"
echo "   3. 搜索 'Code Signing Entitlements'"
echo "   4. 确认值为: Digital-Prayer-Wheel-iOS/Digital-Prayer-Wheel-iOS.entitlements"
echo ""
echo "🎯 然后必须在真机上测试（模拟器不支持 iCloud）"
