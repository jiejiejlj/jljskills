---
name: to-issues
description: 把 PRD 或计划拆成曳光弹式垂直切片 issue——每片纵穿全部层、完成即可独立演示；质检粒度与依赖后按依赖序发布到 issue 追踪器。仅当用户主动用 `/codeflow:to-issues` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Bash, Write, AskUserQuestion
disable-model-invocation: true
---

# to-issues — 曳光弹垂直切片拆解

## 1. 取材

优先用当前对话里已有的 PRD。用户传了 issue 引用（编号/URL/路径）时，按 `docs/jljskills/codeflow/issue-tracker.md` 的操作方式取其全文与既有评论。

## 2. 垂直切片铁律

把源材料切成曳光弹式 issue：每片纵穿全部集成层（schema、API、UI、测试），禁止横切单层。

- 完成的切片必须能独立演示或验证
- prefactor（先让改动变容易——"让改动变容易，再做那个容易的改动"）排最前，单列成片，不与功能切片混在一起
- 标题与描述用目标项目 `docs/jljskills/codeflow/CONTEXT.md` 的领域词汇（不存在则跳过）

## 3. 质检

把拟拆分方案编号列出，每条给：标题、Blocked by（依赖哪些其他切片，无则写明）、覆盖的用户故事（源材料有则列，没有可省）。

问用户三件事：粒度对不对（太粗/太细）、依赖关系对不对、要不要合并或再拆。迭代到用户认可，不认可不进入下一步。

## 4. 发布

按用户认可的拆分逐条发布，每条正文按 [references/issue-template.md](references/issue-template.md) 填写。发布顺序按依赖序——先发被依赖者，"Blocked by" 填真实 issue 标识，不是占位符。

按 `docs/jljskills/codeflow/issue-tracker.md` 的操作方式发布，并按该文件标记 agent-ready。追踪器未配置（文件不存在）时，先指路 `/codeflow:config`，跑完再回来发布。

源材料本身是某个 issue 拆出来的，不关闭、不修改那个父 issue。

---
> 内化自 mattpocock/skills 的 `skills/engineering/to-issues`（2026-07-05）。
