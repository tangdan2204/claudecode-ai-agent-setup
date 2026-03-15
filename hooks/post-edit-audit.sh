#!/bin/bash
# PostToolUse Hook - 编辑后审计日志 + 熔断计数检测
# 位置: ~/.claude/hooks/post-edit-audit.sh
# 触发: PostToolUse (matcher: Write|Edit)
# 机制: 记录所有源代码编辑，检测同文件反复编辑并发出熔断警告

set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 空文件路径则跳过
if [ -z "$FILE" ]; then
  exit 0
fi

# 只记录源代码和配置文件的编辑
if [[ "$FILE" =~ \.(ts|tsx|js|jsx|py|go|rs|java|vue|svelte|json|yaml|yml|toml|sh|md)$ ]]; then
  LOG_DIR="$HOME/.claude/logs"
  mkdir -p "$LOG_DIR"
  LOG_FILE="$LOG_DIR/edit-audit.log"

  # 追加审计日志
  echo "$TIMESTAMP | $TOOL | $FILE" >> "$LOG_FILE"

  # ============================================================
  # 熔断计数检测: 同一文件近期编辑次数
  # ============================================================
  if [ -f "$LOG_FILE" ]; then
    # 统计最近 30 条记录中同一文件的编辑次数
    RECENT_EDITS=$(tail -30 "$LOG_FILE" | grep -c "$FILE" || true)

    if [ "$RECENT_EDITS" -ge 8 ]; then
      echo "🔴 熔断警告: $FILE 已被编辑 ${RECENT_EDITS} 次（近30条记录内），强烈建议暂停并分析根因" >&2
      echo "建议: 1)检查是否陷入 fix 循环 2)换一种策略 3)请求用户介入" >&2
    elif [ "$RECENT_EDITS" -ge 5 ]; then
      echo "⚠️ 熔断预警: $FILE 已被编辑 ${RECENT_EDITS} 次（近30条记录内），注意是否在反复修改" >&2
    fi
  fi

  # 日志轮转: 超过 500 行时截断保留最近 200 行
  if [ -f "$LOG_FILE" ]; then
    LINE_COUNT=$(wc -l < "$LOG_FILE" | tr -d ' ')
    if [ "$LINE_COUNT" -gt 500 ]; then
      tail -200 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
    fi
  fi
fi

exit 0
