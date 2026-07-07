---
name: review-skill
description: 审一个 Claude Code skill——三阶段 lint(结构 PASS/WARN/FAIL)→ score(六维加权 + 质量档位)→ improve(P1–P5 处方),只读不改。仅当用户主动用 `/skillflow:review-skill` 指令调用时使用。
allowed-tools: Read, Glob, Grep, Bash
disable-model-invocation: true
---

本 skill 只分析、只报告。它不改动文件——把发现摆出来,由用户决定采纳哪些。**报告用简体中文产出**(维度名、`PASS/WARN/FAIL`、`P1–P5`、档位名等术语保留英文)。

## Reference 文件

- [dimensions.md](references/dimensions.md) —— 六个加权质量维度:评分 rubric、证据、改进套路
- [lint-rules.md](references/lint-rules.md) —— skill 的结构校验检查(PASS/WARN/FAIL)
- [prioritization.md](references/prioritization.md) —— 建议的 P1–P5 影响/成本矩阵
- [scoring-examples.md](references/scoring-examples.md) —— 校准:真实 skill 评估 + 打分理由
- [improvement-examples.md](references/improvement-examples.md) —— 按维度的 before/after 修复示例
- [report-template.md](assets/report-template.md) —— 统一的三阶段报告格式
- [design-skill-rules](../design-skill-rules/SKILL.md) —— 「什么算好 skill」的判据基石(评分维度背后的定性内核)

## Scoping(圈定范围)

- 当前工作目录即项目根
- 以 `<project-root>/.claude/` 为定制目录
- 当项目根本身就是 `~/.claude/` 时,定制目录就是项目根本身
- 若以参数传入某个具体文件或目录,直接审那个目标
- 查 `settings.json` 做集成校验

进入定制目录后,定位目标 skill:`skills/<name>/SKILL.md`。

## 三个阶段

**Phase 1 — Lint**:结构校验。每项检查报 PASS、WARN 或 FAIL。规则见 [lint-rules.md](references/lint-rules.md)。lint 的失败为评分提供背景(如缺 description → Trigger Coverage = 1)。

**Phase 2 — Score**:六维表(Effectiveness 28%、Clarity 22%、Best Practices 17%、Documentation 15%、Verification 10%、Trigger Coverage 8%)。质量档位表(Production Ready 4.5–5.0、Good 3.5–4.4、Needs Work 2.5–3.4、Poor 1.5–2.4、Unusable 1.0–1.4)。rubric 见 [dimensions.md](references/dimensions.md)。

**Phase 3 — Improve**:每条发现变成一条建议,带维度、影响/成本、优先级(P1–P5)与具体改法。P1 在前。矩阵见 [prioritization.md](references/prioritization.md)。

## 流程

1. 定位目标 skill。若不存在,报 FAIL 并停在评分之前。
2. 跑结构 lint 检查([lint-rules.md](references/lint-rules.md))
3. 逐维评分([dimensions.md](references/dimensions.md))
4. 算加权总分,定质量档位
5. 生成分级建议([prioritization.md](references/prioritization.md))
6. 校验:加权求和算术无误;档位与分数区间相符
7. 产出报告([report-template.md](assets/report-template.md))

## 打分原则

- **Be specific(具体)** —— 拿确切的原文、行号、文件当证据
- **Be fair(公允)** —— 顾及这个 skill 本来的范围与类型
- **Be consistent(一致)** —— 对所有 skill 用同一套标准
- **Be calibrated(校准)** —— 5 分是典范;锚点见 [scoring-examples.md](references/scoring-examples.md)

## 不适用于

- 审某段 git diff 找 bug —— 用 `/code-review`
- 审应用/项目代码(非 harness 文件)—— {本仓对应技能待补;philoserf 原指 `code-audit`}
- 仅针对新发布的 Claude Code 版本评估配置 —— {本仓对应技能待补;philoserf 原指 `cc-release-review`}
