# Improvement Examples(改进示例)

按维度与优先级、示范具体改进的 before/after 示例。

## Contents

- [Example 1: Effectiveness — Vague Purpose (P1)](#example-1-effectiveness--vague-purpose-p1)
- [Example 2: Verification — Missing Verification Commands (P1)](#example-2-verification--missing-verification-commands-p1)
- [Example 3: Best Practices — Side-Effect Skill Unguarded (P1)](#example-3-best-practices--side-effect-skill-unguarded-p1)
- [Example 4: Best Practices — Token Economy (P2)](#example-4-best-practices--token-economy-p2)
- [Example 5: Trigger Coverage — Short Description (P1)](#example-5-trigger-coverage--short-description-p1)
- [Example 6: Clarity — Inconsistent Terminology (P3)](#example-6-clarity--inconsistent-terminology-p3)
- [Pattern Recognition](#pattern-recognition)

## Example 1: Effectiveness — Vague Purpose (P1)

### Before

```markdown
## Overview

This skill processes data files and generates reports.
```

**Problem**:含糊——什么数据?什么报告?用户判断不了这个 skill 是否对口。

### After

```markdown
## Purpose

Analyzes CSV and JSON data files to produce summary statistics and comparison reports.
Handles single-file analysis and multi-file diff comparisons.

## When to Use

- Analyze CSV or JSON data files for summary statistics
- Compare two datasets for differences
- Extract counts, averages, and distributions from structured data

**Don't use for**: unstructured text, real-time streams, or database queries.
```

**Why**:具体的数据类型、输出类型、范围边界,让用户立刻能自我筛选进/出。

---

## Example 2: Verification — Missing Verification Commands (P1)

### Before

```markdown
## Steps

1. Create feature branch
2. Make changes
3. Commit with message
4. Push to remote
5. Create PR
```

**Problem**:任何一步后都没有验证——用户无从确认这个 skill 跑对了。

### After

```markdown
## Steps

1. Create feature branch
   - **Verify**: `git branch --show-current` shows the new branch name
2. Make changes
3. Commit with message
   - **Verify**: `git log --oneline -1` shows the expected commit message
4. Push to remote
   - **Verify**: `git status` shows "Your branch is up to date with origin"
5. Create PR
   - **Verify**: `gh pr view --web` opens the PR in browser

## Success Criteria

- Feature branch exists on remote
- Commit history is clean (no WIP commits)
- PR is created with correct base branch
- CI checks are passing
```

**Why**:每步的验证命令 + 显式成功标准定义了「做对了」长什么样。

---

## Example 3: Best Practices — Side-Effect Skill Unguarded (P1)

### Before

```yaml
---
name: auto-deploy
description: Deploys the current branch to staging or production.
---
```

**Problem**:会部署代码——一种若被自动触发可能造成宕机的副作用。无 invocation 护栏。

### After

```yaml
---
name: auto-deploy
description: Deploys the current branch to staging or production. Use when deploying, pushing to staging, releasing to prod, or shipping a build.
disable-model-invocation: true
---
```

**Why**:`disable-model-invocation: true` 确保这个 skill 只在用户显式调用时才跑,防住意外部署。

---

## Example 4: Best Practices — Token Economy (P2)

### Before(单个 700 行的 SKILL.md)

```markdown
---
name: api-client
description: Makes API calls with error handling and retry logic.
---

## Overview
...50 lines...

## Configuration
...80 lines...

## Error Handling
...100 lines...

## Authentication
...120 lines...

## Examples
...200 lines...

## Troubleshooting
...90 lines...
```

**Problem**:700 行每次调用都往上下文加载约 10k token——是 5k 预算的两倍。

### After(用 reference 重构后)

**SKILL.md**(约 120 行):

```markdown
---
name: api-client
description: Makes API calls with error handling and retry logic.
---

## Reference Files

- [configuration.md](references/configuration.md) - Setup and configuration options
- [error-handling.md](references/error-handling.md) - Error types and handling strategies
- [auth-patterns.md](references/auth-patterns.md) - Authentication methods
- [examples.md](references/examples.md) - Common usage scenarios

## Overview
...50 lines of key concepts...

## Quick Start
...20 lines of basic usage...
```

**Why**:SKILL.md 从约 10k 降到约 2k token。细节经 reference 按需加载。

---

## Example 5: Trigger Coverage — Short Description (P1)

### Before

```yaml
---
name: file-organizer
description: Organizes files in directories.
---
```

**Problem**:30 字符的 description,无触发短语。用户说「clean up this folder」找不到它。

### After

```yaml
---
name: file-organizer
description: Organizes files and folders into logical structures. Use when cleaning up directories, restructuring projects, sorting files by type, organizing messy folders, or planning file hierarchies.
---
```

**Why**:200+ 字符、多个触发短语,覆盖用户的自然查询。

---

## Example 6: Clarity — Inconsistent Terminology (P3)

### Before

```markdown
## Configuration

Set up the config file in your settings directory.
Configure the configuration options as needed.
Update your settings when the config changes.
```

**Problem**:通篇混用「config」「configuration」「settings」。

### After

```markdown
## Configuration

Set up the configuration file in your configuration directory.
Configure the options as needed.
Update your configuration when requirements change.
```

**Why**:一致使用「configuration」消除歧义,读来是单一权威口吻。

---

## Pattern Recognition

| 信号 | 常见改法 | 类别 |
| --------------------------------- | ------------------------------ | ---------------- |
| description <50 字符 | 用触发短语扩写 | Trigger Coverage |
| SKILL.md >500 行或 >5k token | 渐进式披露 | Best Practices |
| 多个术语变体 | 统一术语 | Clarity |
| 「适当处理」(含糊) | 加具体示例 | Effectiveness |
| 无成功标准 | 加验证步骤 | Verification |
| 有副作用的 skill、无护栏 | 加 `disable-model-invocation` | Best Practices |
| 无「when to use」节 | 加指引一节 | Effectiveness |
