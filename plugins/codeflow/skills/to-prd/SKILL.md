---
name: to-prd
description: 把当前对话综合成 PRD 并发布到 issue 追踪器——不再采访用户，只做综合；测试 seam 先行并与用户确认。仅当用户主动用 `/codeflow:to-prd` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Bash, Write, AskUserQuestion
disable-model-invocation: true
---

# to-prd — 对话综合成 PRD

## 1. 只综合，不采访

素材是当前对话与代码库认知，不开新一轮访谈。缺口标注为开放问题，写进 PRD 让用户或后续环节补——想采访用户，回 `/support:interview2doc`；想边拷问边落笔术语，回 `/codeflow:grill-with-docs`。

## 2. seam 先行

写 PRD 前，先勾画测试 seam 并与用户确认。优先复用既有 seam；新 seam 放可行的最高处；全库理想数量是一个。seam 词汇 Read `../design-deep-module/SKILL.md`（驱动思想：深模块）。确认通过再进入下一步，没确认不动笔写 PRD。

## 3. 写 PRD

按 [references/prd-template.md](references/prd-template.md) 的七节展开。领域名词取 `docs/jljskills/codeflow/CONTEXT.md`（不存在则跳过，不报错）。

禁写具体文件路径与代码片段——这些东西过期得快。唯一例外：原型产出的决策性片段（状态机、schema、类型形状），注明来自原型，裁到决策相关部分，不贴整份原型。

## 4. 发布

按 `docs/jljskills/codeflow/issue-tracker.md` 的操作方式发布 PRD，并按该文件标记 agent-ready。追踪器未配置（文件不存在）时，先指路 `/codeflow:config`，跑完再回来发布。

---
> 内化自 mattpocock/skills 的 `skills/engineering/to-prd`（2026-07-05）。
