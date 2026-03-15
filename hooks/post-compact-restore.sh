#!/bin/bash
# SessionStart:compact Hook - 压缩后自动注入恢复上下文
# 位置: ~/.claude/hooks/post-compact-restore.sh
# 触发: SessionStart (matcher: compact)
# 机制: 压缩后注入关键上下文+强制恢复检查列表

set -euo pipefail

MEMORY_DIR="$HOME/.claude/projects/-Users-$(whoami)/memory"
COMPACT_STATE="$MEMORY_DIR/compact-state.md"
PATTERNS_FILE="$MEMORY_DIR/recurring-patterns.md"

OUTPUT="🔄 上下文压缩恢复:"

# 注入 Git 状态
if git rev-parse --is-inside-work-tree &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
  LAST_COMMIT=$(git log --oneline -1 2>/dev/null || echo "无提交")
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  OUTPUT="$OUTPUT 分支=$BRANCH, 最近提交=$LAST_COMMIT, 未提交文件=$DIRTY."
fi

# 强制恢复检查列表（不是建议，是必须执行的步骤）
OUTPUT="$OUTPUT [MUST] 强制恢复检查列表（按顺序执行，禁止跳过）:"
OUTPUT="$OUTPUT 1)notepad_read(priority) → 恢复上次任务目标"
OUTPUT="$OUTPUT 2)project_memory_read → 恢复项目技术栈"
OUTPUT="$OUTPUT 3)读取 MEMORY.md → 恢复活跃项目状态"
OUTPUT="$OUTPUT 4)state_read → 检查中断的自动化任务"
OUTPUT="$OUTPUT 5)git status → 确认分支和变更"
OUTPUT="$OUTPUT 6)读取 recurring-patterns.md → 加载已知问题模式"

# 注入压缩前状态
if [ -f "$COMPACT_STATE" ]; then
  OUTPUT="$OUTPUT 7)读取 compact-state.md → 恢复压缩前工作进度"
fi

OUTPUT="$OUTPUT。禁止忽略此恢复流程，禁止从零开始。"

echo "$OUTPUT"
exit 0
