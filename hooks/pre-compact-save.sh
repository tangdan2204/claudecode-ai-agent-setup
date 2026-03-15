#!/bin/bash
# 记忆保护 Hook - 上下文压缩前自动保存核心状态
# 位置: ~/.claude/hooks/pre-compact-save.sh
# 触发: PreCompact
# 机制: 将当前任务状态写入记忆文件，确保压缩后不丢失关键上下文

set -euo pipefail

MEMORY_DIR="$HOME/.claude/projects/-Users-$(whoami)/memory"
COMPACT_LOG="$MEMORY_DIR/compact-state.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 读取 stdin (PreCompact 事件数据)
INPUT=$(cat)
SOURCE=$(echo "$INPUT" | jq -r '.source // "auto"' 2>/dev/null)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)
CWD=$(echo "$INPUT" | jq -r '.cwd // "unknown"' 2>/dev/null)

# 确保目录存在
mkdir -p "$MEMORY_DIR"

# 写入压缩前状态快照
cat > "$COMPACT_LOG" << EOF
# 上下文压缩状态快照

> 自动保存于 $TIMESTAMP | 触发方式: $SOURCE | 会话: $SESSION_ID

## 工作目录
$CWD

## Git 状态
$(cd "$CWD" 2>/dev/null && git branch --show-current 2>/dev/null || echo "非 git 仓库")
$(cd "$CWD" 2>/dev/null && git status --short 2>/dev/null | head -20 || echo "无")

## 提示
压缩发生了。请立即读取以下文件恢复上下文:
1. ~/.claude/projects/-Users-$(whoami)/memory/MEMORY.md
2. 本文件 (compact-state.md)
3. 当前项目的 CLAUDE.md (如有)
EOF

# 注入上下文到 Claude（stdout 输出会被 Claude 读取）
echo "⚠️ 上下文压缩已触发。核心状态已保存到 $COMPACT_LOG。压缩后请先读取 MEMORY.md 恢复任务上下文，然后继续工作。禁止清空任务状态、用户意图、执行历史。"

exit 0
