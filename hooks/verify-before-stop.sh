#!/bin/bash
# Stop Hook - 完成前自动检查 + 证据清单验证
# 位置: ~/.claude/hooks/verify-before-stop.sh
# 触发: Stop
# 机制: 检查未提交更改、新增 TODO、编辑审计日志中的反复修改模式
# 配置来源: configs/env.sh (统一阈值)

set -euo pipefail

INPUT=$(cat)

# 防止无限循环：如果已经在 stop hook 中，直接放行
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null)
if [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

CWD=$(echo "$INPUT" | jq -r '.cwd // "."' 2>/dev/null)
cd "$CWD" 2>/dev/null || exit 0

# ============================================================
# 加载统一配置
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/configs/env.sh"
if [ -f "$ENV_FILE" ]; then
  # shellcheck source=/dev/null
  source "$ENV_FILE"
fi

HOT_THRESHOLD="${HOT_FILE_THRESHOLD:-5}"
HOT_LOOKBACK="${HOT_FILE_LOOKBACK:-20}"
PATTERN_TIMEOUT="${PATTERNS_UPDATE_TIMEOUT:-60}"

WARNINGS=""

# ============================================================
# 检查 1: 未提交的 Git 更改
# ============================================================
if git rev-parse --is-inside-work-tree &>/dev/null; then
  CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$CHANGES" -gt 0 ]; then
    WARNINGS="${WARNINGS}⚠️ 有 ${CHANGES} 个文件未提交。"
  fi
fi

# ============================================================
# 检查 2: 新增的 TODO/FIXME
# ============================================================
if git rev-parse --is-inside-work-tree &>/dev/null; then
  NEW_TODOS=$(git diff --cached --unified=0 2>/dev/null | grep -c '^\+.*TODO\|^\+.*FIXME\|^\+.*HACK' || true)
  if [ "$NEW_TODOS" -gt 0 ]; then
    WARNINGS="${WARNINGS} ⚠️ 新增了 ${NEW_TODOS} 个 TODO/FIXME 标记。"
  fi
fi

# ============================================================
# 检查 3: 编辑审计日志 — 检测反复修改同文件的模式
# ============================================================
LOG_FILE="${EDIT_AUDIT_LOG:-$HOME/.claude/logs/edit-audit.log}"
if [ -f "$LOG_FILE" ]; then
  # 检查最近 N 条 JSONL 记录中是否有文件被编辑 >= 阈值次
  HOT_FILES=$(tail -"$HOT_LOOKBACK" "$LOG_FILE" | jq -r '.file // empty' 2>/dev/null | grep -v '^$' | sort | uniq -c | sort -rn | awk -v t="$HOT_THRESHOLD" '$1 >= t {print $1 "次: " $2}')
  if [ -n "$HOT_FILES" ]; then
    WARNINGS="${WARNINGS} ⚠️ 以下文件被反复编辑（可能陷入fix循环）: ${HOT_FILES}。"
  fi
fi

# ============================================================
# 检查 4: recurring-patterns.md 是否在本次会话中被更新过（反思阶段执行证据）
# ============================================================
PATTERNS_FILE="$HOME/.claude/projects/-Users-$(whoami)/memory/recurring-patterns.md"
if [ -f "$PATTERNS_FILE" ]; then
  if [ "$(find "$PATTERNS_FILE" -mmin +"$PATTERN_TIMEOUT" 2>/dev/null)" ]; then
    WARNINGS="${WARNINGS} 💡 recurring-patterns.md 超过${PATTERN_TIMEOUT}分钟未更新，请确认是否执行了反思阶段。"
  fi
fi

if [ -n "$WARNINGS" ]; then
  echo "完成前检查:${WARNINGS} 请确认这些是预期行为。" >&2
fi

exit 0
