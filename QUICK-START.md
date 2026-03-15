# 快速搭建指南

> 在任何新机器上 5 分钟内完成 ClaudeCode 智能体配置

---

## 前置条件

```bash
# 1. 确认 Claude Code 已安装
claude --version

# 2. 安装 jq（hook 脚本依赖）
brew install jq  # macOS
# 或 apt install jq  # Linux

# 3. 安装 oh-my-claudecode（OMC 多代理编排）
# 在 Claude Code 中运行: /omc-setup
```

---

## 自动安装（推荐）

将本工程目录复制到目标机器后，运行安装脚本：

```bash
cd ~/Desktop/ClaudeCode-智能体配置工程
chmod +x install.sh
./install.sh
```

---

## 手动安装

### 第一步：部署配置文件

```bash
# 创建目录结构
mkdir -p ~/.claude/hooks
mkdir -p ~/.claude/logs
mkdir -p ~/.claude/projects/-Users-$(whoami)/memory

# 复制核心配置
cp configs/settings.json ~/.claude/settings.json
cp configs/hooks.json ~/.claude/hooks/hooks.json
cp configs/CLAUDE.md ~/.claude/CLAUDE.md

# 复制 hook 脚本
cp hooks/*.sh ~/.claude/hooks/

# 赋予执行权限
chmod +x ~/.claude/hooks/*.sh

# 复制记忆文件
cp memory/MEMORY.md ~/.claude/projects/-Users-$(whoami)/memory/
cp memory/recurring-patterns.md ~/.claude/projects/-Users-$(whoami)/memory/
```

### 第二步：个性化配置

编辑 `~/.claude/settings.json`：
- 修改 `ANTHROPIC_BASE_URL` 为你的 API 代理地址（如直连则改为 `https://api.anthropic.com`）
- 修改 `ANTHROPIC_AUTH_TOKEN` 为你的 API Key（或保持 `PROXY_MANAGED`）

编辑 `~/.claude/CLAUDE.md`：
- 修改「语言偏好」为你的偏好语言
- 修改「编码规范」为你的项目规范

编辑 `~/.claude/hooks/pre-compact-save.sh`：
- 修改 `MEMORY_DIR` 中的用户名路径为你的实际用户名

### 第三步：验证安装

```bash
# 1. 检查 hook 脚本是否有执行权限
ls -la ~/.claude/hooks/*.sh

# 2. 检查 hooks.json 是否有效
cat ~/.claude/hooks/hooks.json | jq . > /dev/null && echo "✅ hooks.json 有效" || echo "❌ hooks.json 格式错误"

# 3. 检查 settings.json 是否有效
cat ~/.claude/settings.json | jq . > /dev/null && echo "✅ settings.json 有效" || echo "❌ settings.json 格式错误"

# 4. 启动 Claude Code 测试
claude
# 在会话中输入: 你好，请确认你的认知循环是否激活
```

### 第四步：安装 OMC 插件

在 Claude Code 会话中运行：
```
/omc-setup
```

这会自动安装 oh-my-claudecode 多代理编排系统，包括 17+ 专业 Agent 和 20+ Skill。

---

## 验证清单

安装完成后，逐项验证：

- [ ] `~/.claude/settings.json` 存在且 JSON 有效
- [ ] `~/.claude/hooks/hooks.json` 存在且 JSON 有效
- [ ] `~/.claude/hooks/safety-guard.sh` 有执行权限
- [ ] `~/.claude/hooks/sensitive-filter.sh` 有执行权限
- [ ] `~/.claude/hooks/pre-compact-save.sh` 有执行权限
- [ ] `~/.claude/hooks/post-compact-restore.sh` 有执行权限
- [ ] `~/.claude/hooks/post-edit-audit.sh` 有执行权限
- [ ] `~/.claude/hooks/verify-before-stop.sh` 有执行权限
- [ ] `~/.claude/hooks/macos-notify.sh` 有执行权限
- [ ] `~/.claude/CLAUDE.md` 包含「智能操作系统 v1」章节
- [ ] `~/.claude/projects/-Users-$(whoami)/memory/MEMORY.md` 存在
- [ ] `~/.claude/projects/-Users-$(whoami)/memory/recurring-patterns.md` 存在
- [ ] Claude Code 启动时 hook 无报错
- [ ] 输入危险命令被 safety-guard.sh 拦截

---

## 故障排查

### Hook 不生效
```bash
# 检查 hooks.json 路径是否正确
cat ~/.claude/hooks/hooks.json | jq '.hooks | keys'
# 应输出: ["Notification","PostToolUse","PreCompact","PreToolUse","SessionStart","SessionEnd","Stop"]

# 检查脚本路径是否存在
ls -la ~/.claude/hooks/*.sh
```

### 敏感信息检测误报
```bash
# 查看 sensitive-filter.sh 的正则模式
grep 'SENSITIVE_PATTERNS' ~/.claude/hooks/sensitive-filter.sh -A 10
```

### macOS 通知不弹出
```bash
# 手动测试 osascript
osascript -e 'display notification "测试通知" with title "Claude Code"'
# 如果不弹出，检查系统偏好设置 → 通知与专注 → 脚本编辑器
```
