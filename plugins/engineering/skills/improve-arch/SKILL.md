---
name: improve-arch
description: 扫描代码库找深化机会（shallow → deep），以可视化 HTML 报告呈现候选项，用户选定后走设计树拷问。仅当用户主动用 `/engineering:improve-arch` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Agent, AskUserQuestion
disable-model-invocation: true
---

# improve-arch — 深化机会

## 用途

浮出架构摩擦，提出**深化机会**——把 shallow module 重构成 deep module 的候选项。目标是可测试性与 AI 可导航性。三阶段：探索 → HTML 报告 → 拷问。

## 前置

1. Read `../design-rules/SKILL.md` 装载词汇与判据——每条建议都用它的术语，一个词不许漂移。
2. 读 `docs/jljskills/engineering/CONTEXT.md`（领域词汇表）与 `docs/jljskills/engineering/adr/`（已定决策）——领域名词用 CONTEXT.md 的，ADR 记录的决策不重新争论。两者不存在则跳过，不报错、不创建。

## 阶段一：探索

用 Agent 工具（subagent_type=Explore）走查代码库。不跟僵硬的启发式——有机探索，记录你在哪里感到摩擦：

- 理解一个概念要在多个小 module 间来回跳？
- 哪里 shallow——interface 几乎和 implementation 一样复杂？
- 哪里为了可测试性抽出了纯函数，但真正的 bug 藏在调用它们的地方（没有 locality）？
- 哪里紧耦合的 module 泄漏跨过 seam？
- 哪些部分没有测试，或透过现有 interface 很难测？

对每个疑似 shallow 的地方做**删除测试**：删掉它，复杂度是集中还是搬家？「会集中」才是你要的信号。

完成标准：每个候选项（1）通过删除测试——答案是「复杂度会集中」；（2）能指出具体文件。说不出文件的候选丢弃。

## 阶段二：HTML 报告

按 [references/html-report.md](references/html-report.md) 写一份自包含 HTML 到 OS 临时目录（`$TMPDIR`，无则 `/tmp`；Windows 用 `%TEMP%`；文件名 `architecture-review-<时间戳>.html`），不落仓库。写完自动打开（Linux `xdg-open`、macOS `open`、Windows `start`）并告知用户绝对路径。

每个候选项一张卡片：Title、徽章行（推荐强度 + 依赖类别）、Files、before/after 图、Problem 一句、Solution 一句、Wins 列表、ADR 冲突警示（如适用）。报告末尾必有 **Top recommendation**：先做哪个、为什么。

- **领域名词用 CONTEXT.md 的，架构名词用 design-rules 的。** CONTEXT.md 定义了 Order，就说「Order intake module」——不说「FooBarHandler」，也不说「Order service」。
- **ADR 冲突**：候选与现有 ADR 相抵时，只有摩擦真实到值得重开决策才列出，并在卡片上明确标注冲突及重开理由。别把 ADR 禁止的理论重构全列一遍。

完成标准：Wins 用 locality / leverage 措辞（禁「更易维护」「更干净」）；每卡有 before/after 图；末尾有 Top recommendation。

**本阶段不许提 interface 设计。** 报告写完只问一句：「想探索哪一个？」

## 阶段三：拷问

用户选定候选后，按 `../grilling/SKILL.md` 走设计树。

决策晶化时副作用当场发生，按 `../domain-modeling/SKILL.md` 落笔：

- 深化后的 module 要用 CONTEXT.md 里没有的概念命名？把词加进 CONTEXT.md（文件不存在则惰性创建）。
- 对话中锐化了某个模糊术语？当场更新 CONTEXT.md。
- 用户以承重理由否决候选？提议记 ADR：「要不要记成 ADR，免得未来的架构审查再提同一个建议？」——只在理由真会被未来的探索者需要时才提；短暂性理由（「现在不值得」）和不言自明的理由跳过。
- 想为深化后的 module 探索多种 interface？走 `../design-rules/references/design-it-twice.md` 的并行子代理模式。

---
> 内化自 mattpocock/skills 的 `skills/engineering/improve-codebase-architecture`（2026-07-03）。
