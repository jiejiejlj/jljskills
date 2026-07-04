---
name: implement
description: 按 PRD 与单个 issue 实施一片工作：在预约 seam 上驱动 tdd 逐片红绿，完工跑 review 双轴审查后提交。仅当用户主动用 `/codeflow:implement` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Agent, AskUserQuestion
disable-model-invocation: true
---

# implement — 按 issue 实施

实施用户指定的 PRD / issue 描述的工作（按 `docs/jljskills/codeflow/issue-tracker.md` 取全文；一次只做一个 issue）。

1. 确认本片工作的预约 seam（PRD 测试决策里有则沿用，没有则先与用户确认）。
2. Read `../tdd/SKILL.md`，在预约 seam 上按它逐片红绿推进。
3. 类型检查与单测试文件常跑，全量测试套件收尾跑一次。
4. 完工 Read `../review/SKILL.md` 做双轴审查（固定点=本次开工前的 commit），处理发现的问题。
5. commit 到当前分支；issue 状态按 issue-tracker.md 更新。

多 issue 的工程每个 issue 开新会话执行（issue 已独立可认领），跨会话衔接用 `/support:handoff`——见插件 README 的流程约定。
