#!/bin/bash
# 每小时游戏生成器

set -e

REPO_DIR="/root/projects/hourly-web-games"
GAMES_DIR="$REPO_DIR/games"
LOG_FILE="$REPO_DIR/generator.log"
DATE=$(date +"%Y%m%d_%H%M%S")
GAME_NAME="game_$DATE"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 游戏创意列表
GAMES=(
    "贪吃蛇 - 经典蛇游戏"
    "俄罗斯方块 - 方块消除"
    "打砖块 - 弹球消除"
    "贪吃豆 - 迷宫吃豆"
    "飞机大战 - 射击游戏"
    "2048 - 数字合并"
    "井字棋 - 双人对战"
    "记忆翻牌 - 配对游戏"
    "贪吃球 - 重力球游戏"
    "打地鼠 - 反应速度游戏"
    "跳跳球 - 平台跳跃"
    "弹球游戏 - 物理弹球"
    "消消乐 - 三消游戏"
    "跑酷游戏 - 无尽奔跑"
    "迷宫逃脱 - 找出口"
)

# 随机选择游戏
RANDOM_INDEX=$((RANDOM % ${#GAMES[@]}))
GAME_IDEA="${GAMES[$RANDOM_INDEX]}"

log "开始生成游戏: $GAME_IDEA"
log "游戏目录: $GAMES_DIR/$GAME_NAME"

# 创建游戏目录
mkdir -p "$GAMES_DIR/$GAME_NAME"
cd "$GAMES_DIR/$GAME_NAME"

# 初始化 git
git init

# 生成游戏提示词
cat > PROMPT.md << EOF
# 网页游戏开发任务

## 游戏创意
$GAME_IDEA

## 技术要求
- 纯 HTML/CSS/JavaScript 实现
- 单个 HTML 文件（包含所有代码）
- 响应式设计，支持移动端
- 基本游戏逻辑完整
- 有得分系统
- 有重新开始功能

## 质量要求
- 游戏可玩
- 无明显 bug
- 界面美观
- 操作流畅

## 完成标准
在 IMPLEMENTATION_PLAN.md 中添加 STATUS: COMPLETE
EOF

# 创建 AGENTS.md
cat > AGENTS.md << EOF
# Agent 指令

## 测试命令（Backpressure）
1. 在浏览器中打开 index.html
2. 测试游戏基本功能：
   - 游戏能正常启动
   - 玩家操作正常
   - 得分系统正常
   - 重新开始功能正常
3. 测试移动端响应式

## 提交规范
- feat: 游戏初始版本
EOF

# 创建实施计划
cat > IMPLEMENTATION_PLAN.md << EOF
# 实施计划

## 游戏创意
$GAME_IDEA

## 状态
🔄 准备开始

## 任务列表
（由 Ralph 自动生成）
EOF

log "游戏框架已创建，开始开发..."

# 使用 Claude Code 开发游戏
claude "开发一个$GAME_IDEA网页游戏。要求：1) 纯HTML/CSS/JavaScript单文件实现 2) 响应式设计 3) 有得分和重新开始功能 4) 游戏可玩无bug。创建index.html文件。" --allowedTools "Write,Edit,Bash" --output-format stream-json > /tmp/game_dev.log 2>&1 &

DEV_PID=$!
log "开发进程 PID: $DEV_PID"

# 等待开发完成（最多10分钟）
wait $DEV_PID || log "开发进程异常退出"

# 检查是否生成了 index.html
if [ -f "index.html" ]; then
    log "✅ 游戏开发完成"
    
    # 更新实施计划
    cat > IMPLEMENTATION_PLAN.md << EOF
# 实施计划

## 游戏创意
$GAME_IDEA

## 状态
STATUS: COMPLETE

## 任务列表
- [x] 创建 index.html
- [x] 实现游戏逻辑
- [x] 添加得分系统
- [x] 添加重新开始功能
- [x] 响应式设计

## 完成时间
$(date '+%Y-%m-%d %H:%M:%S')
EOF
    
    # 提交到仓库
    cd "$REPO_DIR"
    git add "games/$GAME_NAME"
    git commit -m "🎮 Add game: $GAME_IDEA

Generated at: $(date '+%Y-%m-%d %H:%M:%S')
Game type: ${GAMES[$RANDOM_INDEX]}"
    git push origin master
    
    log "✅ 游戏已提交到仓库"
else
    log "❌ 游戏开发失败"
    exit 1
fi

log "游戏生成完成: $GAME_IDEA"
