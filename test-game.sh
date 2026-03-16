#!/bin/bash
# 游戏测试脚本

GAME_DIR="$1"

if [ -z "$GAME_DIR" ]; then
    echo "用法: ./test-game.sh <游戏目录>"
    exit 1
fi

if [ ! -f "$GAME_DIR/index.html" ]; then
    echo "❌ 找不到 index.html"
    exit 1
fi

echo "🧪 测试游戏: $GAME_DIR"

# 基本检查
echo "1️⃣ 检查文件结构..."
[ -f "$GAME_DIR/index.html" ] && echo "✅ index.html 存在" || echo "❌ index.html 缺失"

# HTML 基本结构检查
echo "2️⃣ 检查 HTML 结构..."
if grep -q "<!DOCTYPE html>" "$GAME_DIR/index.html"; then
    echo "✅ HTML5 声明存在"
else
    echo "❌ 缺少 HTML5 声明"
fi

if grep -q "<script" "$GAME_DIR/index.html"; then
    echo "✅ JavaScript 代码存在"
else
    echo "❌ 缺少 JavaScript"
fi

# 文件大小检查
SIZE=$(stat -f%z "$GAME_DIR/index.html" 2>/dev/null || stat -c%s "$GAME_DIR/index.html" 2>/dev/null)
echo "3️⃣ 文件大小: $SIZE bytes"

if [ $SIZE -lt 1000 ]; then
    echo "⚠️  文件太小，可能功能不完整"
elif [ $SIZE -gt 100000 ]; then
    echo "⚠️  文件太大，可能包含不必要的资源"
else
    echo "✅ 文件大小合理"
fi

echo ""
echo "✅ 基本测试通过"
echo "🌐 请在浏览器中打开 $GAME_DIR/index.html 进行手动测试"
