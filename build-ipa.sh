#!/bin/bash
# Digital Prayer Wheel iOS - IPA 构建脚本
# 使用 Xcode 命令行工具构建发布版 IPA

set -e  # 遇到错误时退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Digital Prayer Wheel iOS - IPA 构建${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 项目配置
PROJECT_NAME="Digital-Prayer-Wheel-iOS"
SCHEME="Digital-Prayer-Wheel-iOS"
CONFIGURATION="Release"
VERSION="1.2"
BUILD_DIR="build"
ARCHIVE_PATH="${BUILD_DIR}/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="${BUILD_DIR}/ipa"
IPA_NAME="Digital-Prayer-Wheel-v${VERSION}.ipa"

echo -e "${YELLOW}配置信息:${NC}"
echo "  项目: ${PROJECT_NAME}"
echo "  Scheme: ${SCHEME}"
echo "  版本: ${VERSION}"
echo "  配置: ${CONFIGURATION}"
echo ""

# 清理旧的构建文件
echo -e "${YELLOW}清理旧的构建文件...${NC}"
if [ -d "${BUILD_DIR}" ]; then
    rm -rf "${BUILD_DIR}"
fi
mkdir -p "${BUILD_DIR}"

# 创建 ExportOptions.plist
echo -e "${YELLOW}创建导出配置...${NC}"
cat > "${BUILD_DIR}/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>teamID</key>
    <string>Z87QA5VWM9</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
</dict>
</plist>
EOF

# Archive 项目
echo -e "${YELLOW}正在 Archive 项目...${NC}"
echo "  这可能需要几分钟..."
xcodebuild archive \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -archivePath "${ARCHIVE_PATH}" \
    -destination 'generic/platform=iOS' \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    DEVELOPMENT_TEAM="" \
    | grep -E "^\*\*|error:|warning:" || true

if [ ! -d "${ARCHIVE_PATH}" ]; then
    echo -e "${RED}❌ Archive 失败！${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Archive 完成${NC}"
echo ""

# 导出 IPA
echo -e "${YELLOW}导出 IPA...${NC}"
xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${EXPORT_PATH}" \
    -exportOptionsPlist "${BUILD_DIR}/ExportOptions.plist" \
    | grep -E "^\*\*|error:|warning:" || true

# 检查 IPA 是否生成
if [ -f "${EXPORT_PATH}/${PROJECT_NAME}.ipa" ]; then
    # 重命名为版本化的文件名
    mv "${EXPORT_PATH}/${PROJECT_NAME}.ipa" "${EXPORT_PATH}/${IPA_NAME}"

    # 获取文件大小
    IPA_SIZE=$(stat -f%z "${EXPORT_PATH}/${IPA_NAME}")
    IPA_SIZE_MB=$(echo "scale=2; ${IPA_SIZE}/1048576" | bc)

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✅ 构建成功！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${GREEN}IPA 文件位置:${NC}"
    echo "  ${EXPORT_PATH}/${IPA_NAME}"
    echo ""
    echo -e "${GREEN}文件大小:${NC}"
    echo "  ${IPA_SIZE} bytes (${IPA_SIZE_MB} MB)"
    echo ""
    echo -e "${YELLOW}下一步:${NC}"
    echo "  1. 将 IPA 复制到 GitHub Pages:"
    echo "     cp \"${EXPORT_PATH}/${IPA_NAME}\" ../Digital-Prayer-Wheel-iOS-Pages/altstore/releases/"
    echo ""
    echo "  2. 更新 AltStore apps.json 中的 size 字段为: ${IPA_SIZE}"
    echo ""
    echo "  3. 提交并推送到 GitHub"
    echo ""
else
    echo -e "${RED}❌ IPA 导出失败！${NC}"
    exit 1
fi
