#!/bin/bash
# 安全防护 Hook - 硬拦截危险 Bash 命令
# 位置: ~/.claude/hooks/safety-guard.sh
# 触发: PreToolUse (matcher: Bash)
# 机制: exit 2 = 阻止执行, exit 0 = 放行

set -euo pipefail

# 读取 stdin JSON
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# 如果提取不到命令，放行（其他工具可能不是 Bash）
if [ -z "$COMMAND" ]; then
  exit 0
fi

# ============================================================
# 第零层: 命令包装器/间接执行检测 (元命令层)
# ============================================================

# eval、bash -c、sh -c 等命令包装器
if echo "$COMMAND" | grep -qEi '(^|\s|;|&&|\|\|)(eval\s|bash\s+-c|sh\s+-c|zsh\s+-c)'; then
  echo "⛔ 元命令阻止: 检测到命令包装器(eval/bash -c/sh -c)，需要审查内部命令" >&2
  echo "命令: $COMMAND" >&2
  exit 2
fi

# 通过脚本语言间接执行系统命令
if echo "$COMMAND" | grep -qEi '(python[23]?\s+-c|ruby\s+-e|perl\s+-e|node\s+-e)\s'; then
  echo "⛔ 元命令阻止: 检测到通过脚本语言间接执行命令" >&2
  echo "命令: $COMMAND" >&2
  exit 2
fi

# 反引号命令替换 (检测包含反引号的命令)
if echo "$COMMAND" | grep -qF '`'; then
  echo "🔴 L3 阻止: 检测到反引号命令替换，请使用明确的命令" >&2
  exit 2
fi

# ============================================================
# 第一层: 绝对禁止 (L4) - 无条件阻止
# ============================================================

# 删除家目录或根目录
if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|--force\s+)*(\/|~\/|\/Users\/|\$HOME)'; then
  echo "⛔ L4 阻止: 检测到对家目录或根目录的删除操作" >&2
  echo "命令: $COMMAND" >&2
  exit 2
fi

# rm -rf / 或 rm -rf ~
if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|--recursive\s+--force)\s+(/\s*$|~|/Users)'; then
  echo "⛔ L4 阻止: 检测到递归强制删除根/家目录" >&2
  exit 2
fi

# 修改 SSH 密钥
if echo "$COMMAND" | grep -qE '(rm|mv|cp|cat\s*>|echo\s.*>)\s*.*\.ssh/(id_|authorized_keys|known_hosts|config)'; then
  echo "⛔ L4 阻止: 检测到修改 SSH 密钥/配置的操作" >&2
  exit 2
fi

# 执行远程脚本 (curl|bash, wget|sh 等)
if echo "$COMMAND" | grep -qE '(curl|wget)\s+.*\|\s*(ba)?sh'; then
  echo "⛔ L4 阻止: 检测到从远程 URL 下载并执行脚本" >&2
  exit 2
fi

# curl 下载后执行 (两步操作)
if echo "$COMMAND" | grep -qE '(curl|wget)\s+.*-o\s+\S+\s*&&\s*(ba)?sh\s'; then
  echo "⛔ L4 阻止: 检测到下载文件后执行的两步攻击模式" >&2
  exit 2
fi

# find -delete 对根/家目录 (等效 rm -rf 操作)
if echo "$COMMAND" | grep -qE 'find\s+(\/|~\/|\/Users\/|\$HOME)\s.*-delete'; then
  echo "⛔ L4 阻止: 检测到 find -delete 对根/家目录的等效删除操作" >&2
  exit 2
fi

# Fork bomb
if echo "$COMMAND" | grep -qE ':\(\)\s*\{.*\|.*&\s*\}\s*;'; then
  echo "⛔ L4 阻止: 检测到 fork bomb" >&2
  exit 2
fi

# chmod 777 对敏感路径
if echo "$COMMAND" | grep -qE 'chmod\s+(777|a\+rwx)\s+(\/|~|\.ssh|\.claude|\.env)'; then
  echo "⛔ L4 阻止: 检测到对敏感路径设置 777 权限" >&2
  exit 2
fi

# ============================================================
# 第二层: 高风险拦截 (L3) - 阻止并告知 Claude 原因
# ============================================================

# git push --force / git push -f / git push +branch (所有强推变体)
if echo "$COMMAND" | grep -qE 'git\s+push\s+(-[a-zA-Z]*f|--force|--force-with-lease)'; then
  echo "🔴 L3 阻止: git push --force 是不可逆操作，需用户确认后手动执行" >&2
  exit 2
fi
if echo "$COMMAND" | grep -qE 'git\s+push\s+\S+\s+\+'; then
  echo "🔴 L3 阻止: git push +branch 等效于 force push，需用户确认" >&2
  exit 2
fi

# 普通 git push (L3 确认区 — 与 CLAUDE.md 分级对齐)
if echo "$COMMAND" | grep -qE 'git\s+push(\s|$)'; then
  echo "🔴 L3 阻止: git push 需用户确认后执行（代码推送为不可逆共享操作）" >&2
  exit 2
fi

# git reset --hard
if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  echo "🔴 L3 阻止: git reset --hard 会丢失未提交更改，需用户确认" >&2
  exit 2
fi

# git clean -f
if echo "$COMMAND" | grep -qE 'git\s+clean\s+(-[a-zA-Z]*f|--force)'; then
  echo "🔴 L3 阻止: git clean -f 会删除未追踪文件，需用户确认" >&2
  exit 2
fi

# sudo 操作 (包括 command sudo, env sudo, 链式命令中的 sudo)
if echo "$COMMAND" | grep -qE '(^|\s|;|&&|\|\|)(sudo|doas)\s'; then
  echo "🔴 L3 阻止: sudo/doas 提权操作需用户明确授权" >&2
  exit 2
fi
if echo "$COMMAND" | grep -qE '(command|env)\s+sudo\s'; then
  echo "🔴 L3 阻止: 检测到通过 command/env 包装的 sudo 提权" >&2
  exit 2
fi

# 修改系统配置文件 (增加 printf/python/perl/ruby/awk 等写入工具)
if echo "$COMMAND" | grep -qE '(cat|echo|printf|tee|sed|awk|perl|python[23]?|ruby|>)\s*.*(/etc/|\.bashrc|\.zshrc|\.bash_profile|\.zprofile)'; then
  echo "🔴 L3 阻止: 检测到修改系统配置文件，需用户确认" >&2
  exit 2
fi

# 杀死所有进程
if echo "$COMMAND" | grep -qE 'kill(all)?\s+(-9\s+)?(-1|0)\b'; then
  echo "🔴 L3 阻止: 检测到批量杀进程操作" >&2
  exit 2
fi

# mkfs / 格式化磁盘
if echo "$COMMAND" | grep -qE 'mkfs|fdisk|dd\s+if=.*of=/dev/'; then
  echo "⛔ L4 阻止: 检测到磁盘格式化/写入操作" >&2
  exit 2
fi

# ============================================================
# 第三层: 敏感信息防护
# ============================================================

# 打印环境变量中可能含密钥的内容到外部
if echo "$COMMAND" | grep -qE '(echo|printf|cat)\s.*\$(.*KEY|.*SECRET|.*TOKEN|.*PASSWORD|.*CREDENTIAL).*\|\s*(curl|wget|nc)'; then
  echo "⛔ L4 阻止: 检测到可能泄露凭证到外部服务" >&2
  exit 2
fi

# ============================================================
# 通过所有检查，放行
# ============================================================
exit 0
