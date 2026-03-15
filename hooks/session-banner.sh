#!/bin/bash
# IronCensor SessionStart Hook - 启动横幅 + 防御状态摘要
# 位置: ~/.claude/hooks/session-banner.sh
# 触发: SessionStart
# 机制: 输出品牌横幅，统计当前规则数，exit 0 不阻止

set -euo pipefail

# 加载统一配置
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/configs/env.sh"
if [ -f "$ENV_FILE" ]; then
  # shellcheck source=/dev/null
  source "$ENV_FILE"
fi

RULES_DIR="${RULES_DIR:-$PROJECT_ROOT/rules}"

# 统计规则数
DENY_COUNT=24  # settings.json 中硬编码的 deny 规则数
CMD_COUNT=0
PATTERN_COUNT=0

CMD_FILE="$RULES_DIR/dangerous-commands.txt"
if [ -f "$CMD_FILE" ]; then
  CMD_COUNT=$(grep -cvE '^\s*#|^\s*$' "$CMD_FILE" 2>/dev/null || echo "0")
fi

PAT_FILE="$RULES_DIR/sensitive-patterns.txt"
if [ -f "$PAT_FILE" ]; then
  PATTERN_COUNT=$(grep -cvE '^\s*#|^\s*$' "$PAT_FILE" 2>/dev/null || echo "0")
fi

echo "⚔️ IronCensor v1.0 · 铁面御史已就位 | 防御: ${DENY_COUNT}条deny规则 ✅ | ${CMD_COUNT}条命令检测 ✅ | ${PATTERN_COUNT}种信息过滤 ✅"

exit 0
