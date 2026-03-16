#!/bin/bash
# 每小时游戏生成器 - 改进命名版 v2

set -e

REPO_DIR="/root/projects/hourly-web-games"
GAMES_DIR="$REPO_DIR/games"
LOG_FILE="$REPO_DIR/generator.log"
DATE=$(date +"%Y%m%d_%H%M%S")

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 游戏创意库（中文名 | 英文缩写）
GAMES=(
    "俄罗斯方块|tetris"
    "打砖块|breakout"
    "贪吃豆|pacman"
    "飞机大战|shooter"
    "2048|2048"
    "井字棋|tictactoe"
    "记忆翻牌|memory"
    "跳跳球|jump"
    "弹球游戏|pinball"
    "消消乐|match3"
    "跑酷游戏|runner"
    "迷宫逃脱|maze"
    "打地鼠|whackamole"
    "贪吃虫|worm"
    "接龙|solitaire"
)

# 随机选择
RANDOM_INDEX=$((RANDOM % ${#GAMES[@]}))
GAME_ENTRY="${GAMES[$RANDOM_INDEX]}"
GAME_NAME_CN=$(echo "$GAME_ENTRY" | cut -d'|' -f1)
GAME_NAME_EN=$(echo "$GAME_ENTRY" | cut -d'|' -f2)

# 新的命名格式: game_游戏缩写_YYYYMMDD_HHMMSS（日期在最后）
GAME_NAME="game_${GAME_NAME_EN}_${DATE}"

log "========================================="
log "开始生成游戏: $GAME_NAME_CN ($GAME_NAME_EN)"
log "游戏目录: $GAMES_DIR/$GAME_NAME"
log "========================================="

# 创建目录
mkdir -p "$GAMES_DIR/$GAME_NAME" || exit 1
cd "$GAMES_DIR/$GAME_NAME"

log "✅ 目录已创建"

# 生成游戏
log "调用 Claude Code 生成游戏..."

timeout 300 claude "创建一个$GAME_NAME_CN网页游戏。要求：1) 单个index.html文件 2) 纯HTML/CSS/JavaScript 3) 有得分和重新开始功能 4) 游戏可玩。直接创建index.html文件。" --allowedTools "Write,Edit,Bash" 2>&1 | tee /tmp/claude_output.log

# 检查结果
if [ -f "index.html" ]; then
    log "✅ index.html 已生成"
    
    # 测试
    SIZE=$(stat -c%s index.html 2>/dev/null || stat -f%z index.html)
    log "📊 文件大小: $SIZE bytes"
    
    # 创建 README
    cat > README.md << EOF
# $GAME_NAME_CN

## 游戏信息
- **中文名**: $GAME_NAME_CN
- **英文名**: $GAME_NAME_EN
- **创建时间**: $(date '+%Y-%m-%d %H:%M:%S')

## 如何玩
直接在浏览器中打开 index.html

---

[返回游戏列表](../)
EOF
    
    # 提交
    cd "$REPO_DIR"
    git add "games/$GAME_NAME"
    git commit -m "🎮 Add game: $GAME_NAME_CN ($GAME_NAME_EN)" || true
    git push origin master || true
    
    log "✅ 游戏已提交"
    log "📍 https://robertsong2019.github.io/hourly-web-games/games/$GAME_NAME/"
else
    log "❌ 游戏生成失败"
    exit 1
fi

log "========================================="
log "✅ 完成: $GAME_NAME_CN ($GAME_NAME_EN)"
log "========================================="
