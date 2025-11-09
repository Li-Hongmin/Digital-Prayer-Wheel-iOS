#!/bin/bash

# Digital Prayer Wheel - watchOS Target 创建脚本
# 使用方法：在 Xcode 中手动执行以下步骤

echo "=========================================="
echo "Digital Prayer Wheel - watchOS 配置向导"
echo "=========================================="
echo ""
echo "由于 Xcode 项目文件的复杂性，需要在 Xcode GUI 中完成配置"
echo ""
echo "请按照以下步骤操作："
echo ""
echo "步骤 1: 打开 Xcode 项目"
echo "--------------------------------------"
echo "cd /Users/lihongmin/Dev/Digital-Prayer-Wheel-iOS"
echo "open Digital-Prayer-Wheel-iOS.xcodeproj"
echo ""
echo "步骤 2: 创建 watchOS Target"
echo "--------------------------------------"
echo "1. 点击项目导航器中的 'Digital-Prayer-Wheel-iOS' (蓝色图标)"
echo "2. 在底部点击 '+' 按钮"
echo "3. 选择 'watchOS' → 'Watch App'"
echo "4. 配置如下："
echo "   Product Name: Digital-Prayer-Wheel-Watch"
echo "   Team: (选择你的开发团队)"
echo "   Bundle Identifier: (自动生成)"
echo "   Language: Swift"
echo "   ❌ Include Notification Scene: 否"
echo "5. 点击 'Finish'"
echo ""
echo "步骤 3: 配置部署目标"
echo "--------------------------------------"
echo "1. 选择 'Digital-Prayer-Wheel-Watch' target"
echo "2. General 标签 → Deployment Target → watchOS 10.0"
echo ""
echo "步骤 4: 添加代码文件"
echo "--------------------------------------"
echo "1. 删除自动生成的文件（ContentView.swift 等）"
echo "2. 将 'watchOS/' 文件夹拖入项目"
echo "3. 确保勾选 'Digital-Prayer-Wheel-Watch' target"
echo ""
echo "步骤 5: 运行测试"
echo "--------------------------------------"
echo "1. Scheme: Digital-Prayer-Wheel-Watch"
echo "2. Destination: Apple Watch SE (40mm) (2nd generation)"
echo "3. 按 ⌘ + R 运行"
echo ""
echo "=========================================="
echo "快速测试方法（推荐）"
echo "=========================================="
echo ""
echo "如果上述步骤太复杂，我可以帮你创建一个"
echo "独立的 watchOS 测试项目"
echo ""
read -p "是否创建独立测试项目？(y/n) " answer

if [ "$answer" = "y" ]; then
    echo ""
    echo "正在创建独立 watchOS 测试项目..."
    cd ..
    mkdir -p PrayerWheel-Watch-Test
    cd PrayerWheel-Watch-Test

    echo "请手动在 Xcode 中："
    echo "1. File → New → Project"
    echo "2. watchOS → Watch App"
    echo "3. Product Name: PrayerWheel-Watch-Test"
    echo "4. 然后将 watchOS/ 文件夹的代码复制进去"
else
    echo ""
    echo "请按照上述步骤在 Xcode 中配置"
fi

echo ""
echo "需要帮助？查看详细文档："
echo "cat WATCHOS_SETUP_GUIDE.md"
echo ""
