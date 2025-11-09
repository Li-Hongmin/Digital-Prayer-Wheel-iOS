#!/bin/bash

# Digital Prayer Wheel iOS - Instruments 性能分析脚本
# 使用方法: ./profile_app.sh [cpu|memory|leaks|animation|energy]

set -e

ANALYSIS_TYPE=${1:-cpu}
APP_NAME="Digital-Prayer-Wheel-iOS"
SCHEME="Digital-Prayer-Wheel-iOS"
DEVICE="iPhone 15"

echo "🔍 开始 Instruments 性能分析..."
echo "📱 设备: $DEVICE"
echo "📊 分析类型: $ANALYSIS_TYPE"
echo ""

# 构建 Release 版本（性能分析必须用 Release）
echo "🔨 构建 Release 版本..."
xcodebuild -scheme "$SCHEME" \
    -configuration Release \
    -destination "platform=iOS Simulator,name=$DEVICE" \
    -derivedDataPath ./DerivedData \
    build

APP_PATH="./DerivedData/Build/Products/Release-iphonesimulator/$APP_NAME.app"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ 找不到 app: $APP_PATH"
    exit 1
fi

echo "✅ 构建完成: $APP_PATH"
echo ""

# 根据分析类型选择 Instruments 模板
case "$ANALYSIS_TYPE" in
    cpu)
        TEMPLATE="Time Profiler"
        OUTPUT="cpu_profile.trace"
        echo "🔥 CPU 性能分析 - 将测量函数执行时间和热点"
        ;;
    memory)
        TEMPLATE="Allocations"
        OUTPUT="memory_profile.trace"
        echo "💾 内存分配分析 - 将追踪内存使用和分配模式"
        ;;
    leaks)
        TEMPLATE="Leaks"
        OUTPUT="leaks_profile.trace"
        echo "🚰 内存泄漏检测 - 将查找未释放的内存"
        ;;
    animation)
        TEMPLATE="Core Animation"
        OUTPUT="animation_profile.trace"
        echo "🎨 GPU/渲染性能分析 - 将测量帧率和渲染开销"
        ;;
    energy)
        TEMPLATE="Energy Log"
        OUTPUT="energy_profile.trace"
        echo "🔋 电池消耗分析 - 将测量能耗和资源使用"
        ;;
    *)
        echo "❌ 未知的分析类型: $ANALYSIS_TYPE"
        echo "可用类型: cpu, memory, leaks, animation, energy"
        exit 1
        ;;
esac

echo ""
echo "⏱️  将录制 30 秒性能数据..."
echo "💡 提示: 启动后请在 app 中执行以下操作："
echo "   1. 点击转经轮开始转动"
echo "   2. 调整设置（速度、透明度等）"
echo "   3. 切换横屏/竖屏"
echo "   4. 打开牌位功能"
echo ""
echo "按 Enter 开始..."
read

# 启动 Instruments
# -t 指定模板
# -l 限制录制时间（30秒）
# -w 指定设备
instruments \
    -t "$TEMPLATE" \
    -D "$OUTPUT" \
    -l 30000 \
    -w "$DEVICE (16.0)" \
    "$APP_PATH" \
    2>&1 | grep -v "DTServiceHub"

echo ""
echo "✅ 性能分析完成！"
echo "📄 结果保存在: $OUTPUT"
echo ""
echo "📊 打开结果文件:"
echo "   open $OUTPUT"
echo ""
echo "💡 分析提示:"

case "$ANALYSIS_TYPE" in
    cpu)
        echo "   - 查看 Call Tree，找到占用 CPU 最多的函数"
        echo "   - 关注 'Self Weight %' 列（函数自身占用）"
        echo "   - 查找 > 5% 的热点函数"
        ;;
    memory)
        echo "   - 查看 Allocations List，按大小排序"
        echo "   - 关注 'Persistent Bytes' 持久内存"
        echo "   - 查找内存持续增长的对象"
        ;;
    leaks)
        echo "   - 红色标记表示内存泄漏"
        echo "   - 查看泄漏的对象类型和调用栈"
        echo "   - 重点检查 Timer、Closure、Delegate"
        ;;
    animation)
        echo "   - 查看 FPS 图表，理想值 60fps"
        echo "   - 红色区域表示掉帧"
        echo "   - 查看 'Offscreen-Rendered' 离屏渲染次数"
        ;;
    energy)
        echo "   - 查看 CPU、GPU、Network、Location 能耗"
        echo "   - 关注 'Energy Impact' 能耗级别"
        echo "   - 降低 'High' 级别的能耗项"
        ;;
esac

echo ""
echo "🔄 想再次分析？运行:"
echo "   ./profile_app.sh cpu      # CPU 分析"
echo "   ./profile_app.sh memory   # 内存分析"
echo "   ./profile_app.sh leaks    # 泄漏检测"
echo "   ./profile_app.sh animation # GPU 分析"
echo "   ./profile_app.sh energy   # 电池分析"
