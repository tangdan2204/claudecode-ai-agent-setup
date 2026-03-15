# 核心记忆索引

## 用户档案
- 用户: [你的用户名]，macOS/Linux
- 语言: 中文交流，英文命名
- 编码: TypeScript 优先，React + Hooks，camelCase/PascalCase/kebab-case
- Git: Conventional Commits 格式
- 工具链: OMC 多代理编排系统

## 自动化配置 (v3 - 硬安全加固)
> 详细规则见 CLAUDE.md「无人值守全自动化执行体系 v3」章节（Single Source of Truth）
- 权限: Bash(*) 自动放行，硬安全层拦截危险操作
- 硬安全: 3个拦截型hook (safety-guard + sensitive-filter + pre-compact-save) + 4个辅助hook + settings.json deny (16条)
- 软安全: L1-L4分级 + 熔断 + 认知循环
- 执行路由: 决策树 → 简单直接/中等team/复杂ralph+team

## 强制规划监督规则 (永久生效)
> 详细规则见 CLAUDE.md「强制任务规划与监督规则」章节
- 核心原则: 先理解后修改 → 先规划后执行 → 全程监督 → 证据完成

## 体系文件索引
| 文件 | 职责 |
|------|------|
| [recurring-patterns.md](recurring-patterns.md) | 反复问题追踪（自我学习引擎） |

## Hook 文件 (硬安全层)
| 文件 | 事件 | 作用 |
|------|------|------|
| `~/.claude/hooks/safety-guard.sh` | PreToolUse:Bash | 正则拦截危险命令 |
| `~/.claude/hooks/sensitive-filter.sh` | PreToolUse:Write\|Edit | 记忆文件敏感信息检测 |
| `~/.claude/hooks/pre-compact-save.sh` | PreCompact | 压缩前保存状态快照 |
| `~/.claude/hooks/post-compact-restore.sh` | SessionStart:compact | 压缩后恢复上下文 |
| `~/.claude/hooks/post-edit-audit.sh` | PostToolUse:Write\|Edit | 编辑审计日志 |
| `~/.claude/hooks/verify-before-stop.sh` | Stop | 完成前检查 |
| `~/.claude/hooks/macos-notify.sh` | Notification | macOS桌面通知 |

## 恢复检查列表 (新会话必执行)
1. notepad_read(priority) → 恢复上次任务目标
2. project_memory_read → 恢复项目技术栈
3. 读取本文件 → 恢复活跃项目状态
4. state_read → 检查中断的自动化任务
5. git status → 确认分支和变更
6. 读取 recurring-patterns.md → 加载已知问题模式
