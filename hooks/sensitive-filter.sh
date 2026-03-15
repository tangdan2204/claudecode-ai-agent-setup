#!/bin/bash
# 写入安全 Hook - 检测记忆文件中的敏感信息
# 位置: ~/.claude/hooks/sensitive-filter.sh
# 触发: PreToolUse (matcher: Write|Edit)
# 机制: 当写入记忆文件时，检查内容是否含密钥/密码

set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
CONTENT=""

# 检查写入敏感目录的操作（记忆目录 + 项目目录 + 配置文件）
if [[ ! "$FILE_PATH" =~ \.claude/.*memory|\.claude/.*CLAUDE|\.omc/|\.env$ ]]; then
  exit 0
fi

# 提取内容 (Write 有 content, Edit 有 new_string)
if [ "$TOOL_NAME" = "Write" ]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty' 2>/dev/null)
elif [ "$TOOL_NAME" = "Edit" ]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty' 2>/dev/null)
fi

if [ -z "$CONTENT" ]; then
  exit 0
fi

# 检测敏感信息模式
SENSITIVE_PATTERNS=(
  'sk-[a-zA-Z0-9]{20,}'           # OpenAI/Anthropic API keys
  'ghp_[a-zA-Z0-9]{36}'           # GitHub personal access tokens
  'gho_[a-zA-Z0-9]{36}'           # GitHub OAuth tokens
  'ghs_[a-zA-Z0-9]{36}'           # GitHub server-to-server tokens
  'glpat-[a-zA-Z0-9\-]{20,}'      # GitLab tokens
  'xox[bpsa]-[a-zA-Z0-9\-]+'      # Slack tokens
  'AKIA[0-9A-Z]{16}'              # AWS access keys
  'AIza[0-9A-Za-z_-]{35}'         # Google Cloud API keys
  'ya29\.[0-9A-Za-z_-]+'          # Google OAuth tokens
  'npm_[a-zA-Z0-9]{36}'           # npm tokens
  'pypi-[a-zA-Z0-9]{60,}'         # PyPI tokens
  'Bearer\s+[a-zA-Z0-9\-._~+/]+=*' # Bearer tokens
  'password\s*[:=]\s*["\x27][^"\x27]{4,}' # password = "xxx"
  'secret\s*[:=]\s*["\x27][^"\x27]{4,}'   # secret = "xxx"
  'api[_-]?key\s*[:=]\s*["\x27][^"\x27]{8,}' # api_key = "xxx"
)

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
  if echo "$CONTENT" | grep -qEi "$pattern"; then
    echo "⛔ 安全阻止: 检测到敏感信息（API Key/Token/密码）即将写入记忆文件" >&2
    echo "文件: $FILE_PATH" >&2
    echo "请将敏感信息替换为 [REDACTED] 后重试" >&2
    exit 2
  fi
done

exit 0
