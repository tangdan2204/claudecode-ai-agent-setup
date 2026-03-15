# ClaudeCode 智能体配置工程 - 产品需求文档 (PRD)

> **版本**: v1.0 | **日期**: 2026-03-15 | **作者**: tangdan
> **一句话定义**: 将 Claude Code 从被动代码编辑器转变为拥有完整认知循环的自主智能工程师

---

## 1. 产品愿景

### 1.1 核心目标

将 Claude Code 打造为一个**全自主智能体**，具备以下七大核心能力：

| # | 能力 | 描述 | 实现层 |
|---|------|------|--------|
| 1 | **主动技能调用** | 根据任务性质自动选择 Agent/Skill，不等用户指定 | CLAUDE.md 行为指令 |
| 2 | **科学任务分配** | 多维评估矩阵自动判断复杂度，路由到最优执行路径 | CLAUDE.md + OMC Agent |
| 3 | **实时进度监督** | 边做边测、每 3 步汇报、15 分钟自动保存 | CLAUDE.md 执行协议 |
| 4 | **自我学习反省** | 错误模式追踪、被纠正时自动建立防御规则 | recurring-patterns.md |
| 5 | **举一反三** | 修一个 bug 时全局审计同类问题 | CLAUDE.md 第六章 |
| 6 | **自我进化** | 同一错误出现次数递增触发自动升级（记录→规则→自动化） | CLAUDE.md 第七章 |
| 7 | **证据验证** | 完成前必须提供测试/构建/lint 的实际输出 | CLAUDE.md 第五阶段 |

### 1.2 设计哲学

```
你不是一个被动的代码编辑器。你是一个拥有完整认知循环的智能工程师。
每个任务都必须经历：感知→思考→规划→执行→验证→反思→进化 的完整闭环。
```

### 1.3 架构概览

```
┌──────────────────────────────────────────────────────────────┐
│                    Claude Code 智能体系统                      │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─ 硬安全层 (Hooks) ─────────────────────────────────────┐  │
│  │  settings.json deny → safety-guard.sh → sensitive-     │  │
│  │  filter.sh → pre-compact-save.sh                       │  │
│  │  [AI 无法绕过，exit 2 直接阻止]                          │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ 行为指令层 (CLAUDE.md) ──────────────────────────────┐  │
│  │  智能操作系统 v1 (七阶段认知循环)                         │  │
│  │  ├─ 感知：意图识别 + 上下文感知 + 记忆唤醒               │  │
│  │  ├─ 思考：主动调用 Agent/Skill 分析                     │  │
│  │  ├─ 规划：复杂度矩阵 → 执行路径路由                     │  │
│  │  ├─ 执行：实时监督 + 边做边测                           │  │
│  │  ├─ 验证：证据清单 (测试/构建/lint)                     │  │
│  │  ├─ 反思：模式检测 + 举一反三                           │  │
│  │  └─ 进化：纠正升级 (记录→规则→自动化)                   │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ 记忆持久层 ──────────────────────────────────────────┐  │
│  │  MEMORY.md (核心索引) + recurring-patterns.md (模式库) │  │
│  │  + compact-state.md (压缩快照) + edit-audit.log (审计) │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ 多代理编排层 (OMC) ─────────────────────────────────┐  │
│  │  17+ Agent: explore/analyst/planner/architect/executor  │  │
│  │  /debugger/verifier/reviewer/test-engineer/...         │  │
│  │  Skills: autopilot/ralph/team/pipeline/plan/ralplan    │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ 辅助功能层 ──────────────────────────────────────────┐  │
│  │  macOS 桌面通知 + 完成前检查 + 编辑审计日志              │  │
│  │  + 压缩后上下文恢复                                     │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

---

## 2. 技术架构

### 2.1 文件结构

```
~/.claude/
├── CLAUDE.md                          # 核心行为指令（包含智能操作系统 v1）
├── settings.json                      # 权限配置 + deny 规则
├── hooks/
│   ├── hooks.json                     # Hook 路由表（7 个事件）
│   ├── safety-guard.sh                # Bash 命令安全防护 (PreToolUse:Bash)
│   ├── sensitive-filter.sh            # 记忆文件敏感信息过滤 (PreToolUse:Write|Edit)
│   ├── pre-compact-save.sh            # 压缩前状态保存 (PreCompact)
│   ├── post-compact-restore.sh        # 压缩后上下文恢复 (SessionStart:compact)
│   ├── post-edit-audit.sh             # 编辑审计日志 (PostToolUse:Write|Edit)
│   ├── verify-before-stop.sh          # 完成前检查 (Stop)
│   ├── macos-notify.sh                # macOS 桌面通知 (Notification)
│   └── hud-plus-guard.sh             # HUD 插件守护 (SessionStart)
├── logs/
│   └── edit-audit.log                 # 编辑操作审计日志（自动轮转）
└── projects/-Users-tangdan/memory/
    ├── MEMORY.md                      # 核心记忆索引
    ├── recurring-patterns.md          # 反复问题追踪表（自我学习引擎）
    ├── compact-state.md               # 压缩前状态快照（自动生成）
    ├── safety-framework.md            # 安全框架详细规则
    ├── automation-engine.md           # 自动化引擎详细规则
    ├── supervision-engine.md          # 监督引擎详细规则
    └── memory-policy.md               # 记忆策略详细规则
```

### 2.2 安全纵深防御体系

```
Layer 0: settings.json deny          → 16 条规则 (rm/mkfs/dd/chmod/SSH/hooks目录/系统文件)
Layer 1: safety-guard.sh (exit 2)    → 四层检测: 元命令包装器 → L4绝对禁止 → L3高风险 → 凭证泄露
Layer 2: sensitive-filter.sh (exit 2) → 15 种敏感信息模式检测 (含GCP/GitHub/AWS/npm/PyPI)
Layer 3: pre-compact-save.sh         → 压缩前状态自动保存
Layer 4: post-compact-restore.sh     → 压缩后强制恢复检查列表
Layer 5: post-edit-audit.sh          → 编辑审计日志 + 熔断计数检测
Layer 6: verify-before-stop.sh       → 完成前检查 (未提交/TODO/反复编辑/反思执行)
Layer 7: CLAUDE.md 软约束            → L1-L4 分级 + 认知循环 + 三省六部治理
```

### 2.3 认知循环 (七阶段)

```
感知 → 思考 → 规划 → 执行 → 验证 → 反思 → 进化
 │       │       │       │       │       │       │
 │       │       │       │       │       │       └─ 纠正升级链:
 │       │       │       │       │       │          1次→记录, 2次→规则, 3次→自动化
 │       │       │       │       │       └─ 模式检测 + 举一反三
 │       │       │       │       └─ 必须提供实际测试/构建输出
 │       │       │       └─ 边做边测 + 每3步汇报
 │       │       └─ 复杂度矩阵自动评估 → 路由执行路径
 │       └─ 主动调用 Agent/Skill（不等用户指定）
 └─ 意图识别 + 上下文感知 + 记忆唤醒 + 风险预判
```

### 2.4 自我学习四层模型

```
Layer 1: 修复即审计     → 每修一个 bug 在同文件/同模块搜索同类问题
Layer 2: 全局审计       → 同一模式 ≥2次 → Grep 全项目扫描 + 防御规则
Layer 3: 深度反省       → 同一模式 ≥3次 → 根因链分析 + 规则加固 + 提议自动化
Layer 4: 举一反三       → 类比推断 + 跨项目迁移 + 预防性建议
```

---

## 3. 配置清单

### 3.1 settings.json

**功能**: 权限控制 + 绝对禁止规则

- 16 条 deny 规则覆盖：根目录/家目录删除、磁盘格式化、dd 写入、chmod 777、SSH 密钥读写、hooks 目录写入保护、系统文件写入保护、fork bomb
- 环境变量配置（API 代理地址）
- statusLine HUD 配置

### 3.2 hooks.json

**功能**: Hook 事件路由表，注册 7 个生命周期事件

| 事件 | 触发时机 | 注册脚本 |
|------|----------|----------|
| SessionStart | 会话启动 | session-start.sh, hud-plus-guard.sh |
| SessionStart:compact | 压缩后恢复 | post-compact-restore.sh |
| SessionEnd | 会话结束 | session-end.sh |
| PreToolUse:Write\|Edit | 写入/编辑前 | track-changes.sh, analyze-anchors.sh, sensitive-filter.sh |
| PreToolUse:Bash | 执行命令前 | safety-guard.sh, validate-commit.sh |
| PostToolUse:Write\|Edit | 写入/编辑后 | post-edit-audit.sh |
| PreCompact | 上下文压缩前 | pre-compact-save.sh, save-context.sh |
| Stop | 完成前检查 | verify-before-stop.sh |
| Notification:error\|failed... | 错误通知 | feedback-capture.sh, auto-feedback.sh |
| Notification:idle\|permission | 用户通知 | macos-notify.sh |

### 3.3 Hook 脚本功能表

| 脚本 | 退出码 | 功能 |
|------|--------|------|
| safety-guard.sh | exit 2 阻止 | 四层 Bash 命令安全检测（元命令包装器 + L4 绝对禁止 + L3 高风险 + 凭证泄露） |
| sensitive-filter.sh | exit 2 阻止 | 记忆/配置文件写入时检测 15 种敏感信息模式（含 GCP/GitHub/AWS/npm/PyPI） |
| pre-compact-save.sh | exit 0 | 压缩前保存 Git 状态+工作目录到 compact-state.md |
| post-compact-restore.sh | exit 0 | 压缩后注入 Git 状态 + 强制恢复检查列表（7步） |
| post-edit-audit.sh | exit 0 | 记录源代码编辑到 edit-audit.log + 熔断计数检测（5次预警/8次警告） |
| verify-before-stop.sh | exit 0 | 检查未提交文件、新增 TODO/FIXME、反复编辑模式、反思阶段执行证据 |
| macos-notify.sh | exit 0 | macOS 桌面通知（任务完成/权限确认） |

### 3.4 CLAUDE.md 核心章节

| 章节 | 内容 | 优先级 |
|------|------|--------|
| 智能操作系统 v1 | 七阶段认知循环（感知→思考→规划→执行→验证→反思→进化） | 最高 |
| 无人值守体系 v3 | 纵深防御 + L1-L4 分级 + 熔断 + 自动推进 | 高 |
| 强制规划监督 | 先理解→规划→监督执行→完成验证，禁止盲改 | 高 |
| 自我学习机制 | 四层模型：修复审计→全局审计→深度反省→举一反三 | 高 |
| 上下文效率 | Token 优化规则（指定行范围、避免重复读取等） | 中 |
| 记忆压缩策略 | 压缩时必须保留的四类信息 + 丢弃优先级 | 中 |

---

## 4. 部署指南

### 4.1 前置条件

- macOS 或 Linux 系统
- Claude Code CLI 已安装
- oh-my-claudecode (OMC) 插件已安装（`/omc-setup` 或参考 OMC 官方文档）
- jq 命令行工具（`brew install jq`）

### 4.2 快速部署步骤

1. **复制配置文件**: 将 `configs/` 目录下的文件复制到 `~/.claude/` 对应位置
2. **复制 Hook 脚本**: 将 `hooks/` 目录下的 `.sh` 文件复制到 `~/.claude/hooks/`
3. **赋予执行权限**: `chmod +x ~/.claude/hooks/*.sh`
4. **复制记忆文件**: 将 `memory/` 目录下的文件复制到 `~/.claude/projects/-Users-$(whoami)/memory/`
5. **验证**: 启动 Claude Code，检查 hook 是否生效

详细步骤见 [QUICK-START.md](./QUICK-START.md)

---

## 5. 效果衡量

### 5.1 预期改善

| 指标 | 改善前 | 改善后 |
|------|--------|--------|
| 同类 bug 重复出现 | 无追踪机制 | 递减（四层学习模型） |
| 完成声明可信度 | "应该没问题" | 必须附带测试/构建输出 |
| 危险操作防护 | 仅靠提示词 | 5 层纵深防御（硬拦截） |
| 上下文压缩后恢复 | 从零开始 | 自动恢复 Git 状态+任务进度 |
| 任务规划质量 | 随机 | 复杂度矩阵自动评估+路由 |
| 错误自我修正 | 被动等待纠正 | 主动检测+升级+自动化 |

### 5.2 进化指标

- 同类问题出现频率随时间递减
- 规划准确度随项目经验积累提升
- 被用户纠正的次数越来越少
- 反复出现 3 次以上的模式触发自动化检测

---

## 6. 快速复制提示词

> 将以下提示词发送给任何新机器上的 Claude Code，它将自动理解并构建整个配置体系：

见 [ONE-LINER.md](./ONE-LINER.md)
