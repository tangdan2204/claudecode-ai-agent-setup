<div align="center">

# ClaudeCode AI Agent Setup

### Transform Claude Code from a passive code editor into an autonomous intelligent engineer with a complete cognitive cycle

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)]()
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-green.svg)]()

[中文](./README.md) | [日本語](./README.ja.md) | [한국어](./README.ko.md)

**Author: Tangdan / 汤旦**

</div>

---

## Core Innovations

> **You are not a passive code editor. You are an intelligent engineer with a complete cognitive cycle.**

This project injects a complete autonomous agent system into Claude Code through **pure configuration** (zero code modification):

| Capability | Description | Traditional Claude Code |
|------------|-------------|------------------------|
| **7-Stage Cognitive Cycle** | Perceive→Think→Plan→Execute→Verify→Reflect→Evolve | Receive→Execute→Done |
| **8-Layer Defense-in-Depth** | Hard intercept + Monitoring + Soft constraints, AI cannot bypass | Prompt-only constraints |
| **Self-Learning Evolution** | Error tracking→Global audit→Rule hardening→Automation | No learning mechanism |
| **Three Departments Governance** | Decision/Review/Execution separation with veto power | No governance framework |
| **Evidence-Driven Verification** | Must provide actual test/build/lint output | "Should be fine" |
| **Unattended Execution** | Auto-routing + Auto-supervision + Auto-circuit-breaking | Requires constant human intervention |

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                Claude Code Agent System                       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─ Hard Security Layer (Hooks + settings.json) ─────────┐  │
│  │  Layer 0: settings.json deny (16 absolute rules)       │  │
│  │  Layer 1: safety-guard.sh  (meta-cmd + danger detect)  │  │
│  │  Layer 2: sensitive-filter.sh (15 secret patterns)     │  │
│  │  [exit 2 hard block — AI CANNOT bypass]                │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ Auxiliary Monitor Layer (Hooks) ─────────────────────┐  │
│  │  Layer 3: pre-compact-save.sh    (state snapshot)      │  │
│  │  Layer 4: post-compact-restore.sh (context recovery)   │  │
│  │  Layer 5: post-edit-audit.sh     (audit + breaker)     │  │
│  │  Layer 6: verify-before-stop.sh  (4-point checklist)   │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ Behavioral Layer (CLAUDE.md) ────────────────────────┐  │
│  │  Layer 7: Intelligent OS v1                            │  │
│  │  ├─ 7-Stage Cognitive Cycle                            │  │
│  │  ├─ Three Departments Governance Framework             │  │
│  │  ├─ Decision Tree Routing                              │  │
│  │  └─ 4-Layer Self-Learning Model                        │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ Memory Persistence Layer ────────────────────────────┐  │
│  │  MEMORY.md + recurring-patterns.md + compact-state.md  │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

---

## Key Innovations

### 1. Seven-Stage Cognitive Cycle

Every task goes through a complete cognitive loop: **Perceive** (intent recognition + context awareness + memory recall + risk assessment) → **Think** (proactively invoke specialist agents) → **Plan** (decision tree routes to optimal execution path) → **Execute** (test-as-you-go + report every 3 steps) → **Verify** (must provide actual test/build output) → **Reflect** (pattern detection + extrapolation) → **Evolve** (correction upgrade chain: 1x→record, 2x→rule, 3x→automation).

### 2. Eight-Layer Defense-in-Depth

- **Layers 0-2 (Hard Intercept)**: `settings.json` deny rules + `safety-guard.sh` (meta-command detection, L4 absolute prohibition, L3 high risk, credential leak) + `sensitive-filter.sh` (15 secret patterns including OpenAI/GitHub/AWS/GCP/Slack/npm/PyPI tokens). These use `exit 2` — **AI cannot bypass**.
- **Layers 3-6 (Auxiliary)**: State preservation, context recovery, edit auditing with circuit breaker (5x warning / 8x critical), completion verification (4 checks).
- **Layer 7 (Soft Constraints)**: CLAUDE.md behavioral instructions with L1-L4 security classification.

### 3. Three Departments Governance (三省六部)

Inspired by ancient Chinese governance:
- **Zhongshu Province (Decision)**: planner, architect, analyst, explore — drafts proposals only
- **Menxia Province (Review)**: critic, verifier, reviewers, hooks — has **veto power**
- **Shangshu Province (Execution)**: executor, deep-executor — executes approved plans only
- **Censorate (Independent Audit)**: safety-guard + sensitive-filter + post-edit-audit + verify-before-stop

### 4. Four-Layer Self-Learning Model

| Layer | Trigger | Action |
|-------|---------|--------|
| Fix & Audit | Every bug fix | Search same file/module for similar issues |
| Global Audit | Same pattern ≥2x | Grep entire project + create defense rules |
| Deep Reflection | Same pattern ≥3x | Root cause chain analysis + rule hardening + propose automation |
| Extrapolation | Pattern matured | Analogical reasoning + cross-project migration |

---

## Quick Start

### Prerequisites

- macOS or Linux
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- `jq` (`brew install jq`)
- [oh-my-claudecode (OMC)](https://github.com/anthropics/claude-code) plugin (optional, for multi-agent orchestration)

### One-Line Install

```bash
git clone https://github.com/tangdan2204/claudecode-ai-agent-setup.git
cd claudecode-ai-agent-setup
chmod +x install.sh && ./install.sh
```

### Manual Install

```bash
# 1. Create directories
mkdir -p ~/.claude/hooks ~/.claude/logs

# 2. Deploy configs
cp configs/settings.json ~/.claude/settings.json
cp configs/hooks.json ~/.claude/hooks/hooks.json
cp configs/CLAUDE.md ~/.claude/CLAUDE.md

# 3. Deploy hook scripts
cp hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# 4. Deploy memory files
mkdir -p ~/.claude/projects/-Users-$(whoami)/memory
cp memory/*.md ~/.claude/projects/-Users-$(whoami)/memory/

# 5. Verify
claude  # Start Claude Code and test
```

---

## File Structure

```
ClaudeCode-AI-Agent-Setup/
├── configs/
│   ├── settings.json         # Permission config + 16 deny rules
│   ├── hooks.json            # Hook routing table (7 lifecycle events)
│   └── CLAUDE.md             # Core behavioral instructions
├── hooks/
│   ├── safety-guard.sh       # Bash command security (exit 2 block)
│   ├── sensitive-filter.sh   # Sensitive info filter (exit 2 block)
│   ├── pre-compact-save.sh   # Pre-compression state save
│   ├── post-compact-restore.sh # Post-compression context recovery
│   ├── post-edit-audit.sh    # Edit audit + circuit breaker
│   ├── verify-before-stop.sh # Pre-completion 4-point check
│   └── macos-notify.sh       # macOS desktop notifications
├── memory/
│   ├── MEMORY.md             # Core memory index template
│   └── recurring-patterns.md # Pattern tracking table template
├── install.sh                # Auto-install script
├── PRD.md                    # Product Requirements Document
├── RESEARCH-REPORT.md        # 6-Dimension Scientific Research Report
├── QUICK-START.md            # Quick Start Guide
└── ONE-LINER.md              # One-liner setup prompt
```

---

## Design Philosophy

- **Pure Configuration**: No Claude Code source code modifications. Uses only official config mechanisms (`settings.json`, `hooks/`, `CLAUDE.md`, `memory/`).
- **Defense in Depth**: Intentional redundancy between layers. Even if prompts are bypassed, hard hooks (exit 2) still block dangerous operations.
- **SSOT Principle**: Every rule defined once. Memory files use pointer references, not copies.
- **Zero Invasion**: Fully compatible with Claude Code updates. Deploy in 5 minutes. Remove completely at any time.

---

## License

[MIT License](./LICENSE)

---

<div align="center">

**Designed and maintained by [Tangdan / 汤旦](https://github.com/tangdan2204)**

*Making every Claude Code a true intelligent engineer*

</div>
