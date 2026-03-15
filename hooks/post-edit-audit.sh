#!/bin/bash
# PostToolUse Hook - 编辑后审计日志（JSONL 结构化格式）+ 熔断计数检测
# 位置: ~/.claude/hooks/post-edit-audit.sh
# 触发: PostToolUse (matcher: Write|Edit)
# 机制: 以 JSONL 格式记录所有源代码编辑，按 session 分组检测熔断
# 输出格式: {"ts":"...","tool":"...","file":"...","session":"...","cumulative_edits":N}

set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
SESSION=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)
TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

# 空文件路径则跳过
if [ -z "$FILE" ]; then
  exit 0
fi

# 只记录源代码和配置文件的编辑
if [[ "$FILE" =~ \.(ts|tsx|js|jsx|py|go|rs|java|vue|svelte|json|yaml|yml|toml|sh|md)$ ]]; then
  LOG_DIR="$HOME/.claude/logs"
  mkdir -p "$LOG_DIR"
  LOG_FILE="$LOG_DIR/edit-audit.log"

  # ============================================================
  # 熔断计数: 先统计，再写入（确保当前编辑也被计入）
  # ============================================================
  RECENT_EDITS=1
  if [ -f "$LOG_FILE" ]; then
    # 统计最近 30 条记录中同一文件的编辑次数
    RECENT_EDITS=$(( $(tail -30 "$LOG_FILE" | grep -c "\"file\":\"$FILE\"" || true) + 1 ))
  fi

  # 追加 JSONL 格式审计日志
  echo "{\"ts\":\"$TIMESTAMP\",\"tool\":\"$TOOL\",\"file\":\"$FILE\",\"session\":\"$SESSION\",\"cumulative_edits\":$RECENT_EDITS}" >> "$LOG_FILE"

  # ============================================================
  # 熔断警告输出
  # ============================================================
  if [ "$RECENT_EDITS" -ge 8 ]; then
    echo "🔴 熔断硬阻止: $FILE 已被编辑 ${RECENT_EDITS} 次（近30条记录内），强制暂停" >&2
    echo "必须: 1)检查是否陷入 fix 循环 2)启动降级协议 Level 3 3)请求用户介入" >&2
    exit 2
  elif [ "$RECENT_EDITS" -ge 5 ]; then
    echo "⚠️ 熔断预警: $FILE 已被编辑 ${RECENT_EDITS} 次（近30条记录内），注意是否在反复修改" >&2
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
