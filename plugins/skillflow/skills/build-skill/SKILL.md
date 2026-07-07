---
name: build-skill
description: 写一个新的 Claude Code skill——先装载 design-skill-rules 的判据,再照判据把 SKILL.md 与 references 落地。仅当用户主动用 `/skillflow:build-skill` 指令调用时使用。
allowed-tools: Read, Write, Edit
disable-model-invocation: true
---

# build-skill — 照判据造一个 skill

## 用途

造一个新 skill 的**声明式入口**:先装载 `design-skill-rules` 的判据,再照判据把文件落到位。判断归基石,本文只管**手怎么动、落哪**。

## 驱动思想:skill 写作判据

动手前,`Read ../design-skill-rules/SKILL.md` 装载全套判据(可预测、调用取舍、信息层级与渐进式披露、引导词、五种失败模式;术语在其 `references/GLOSSARY.md`)。之后每一步都用它的语言,一个词不许漂移。

## 流程

1. **锚定要造的 skill**。问清:它做什么、何时该触发、产出什么。完成标准:能一句话说清「做什么 + 何时用」,否则先问、别开写。
2. **定 invocation**。按判据的决策规则:只有「模型须自主触发」或「别的 skill 要够到」才 model-invoked,否则 `disable-model-invocation: true`。完成标准:调用方式有明确理由,不靠默认。
3. **命名并建骨架**。三处 name 一致(目录名 / frontmatter `name` / 命名空间 `/<plugin>:<skill>`);目录扁平,一层到底 `skills/<name>/SKILL.md`。完成标准:三处 name 逐一核对一致。
4. **写 description**。按判据:前置引导词、一个 branch 一条触发、不复述正文身份。user-invoked 的写成一行面向人的摘要 + 调用约定。
5. **落正文与 references**。每个 step 带可检查的完成标准;渐进式披露——每个 branch 都需要的内联,只有部分够到的推进 `references/*.md`,正文用相对链接当指针。
6. **自检**。逐句跑 no-op 测试(跟默认行为比没改变的整句删,别精简);对照五种失败模式——提前收工 / 重复 / 沉积 / 蔓延 / 空操作。完成标准:五种失败模式各过一遍。

## 可选:借现成脚手架

需要更省事的落地时,可选用已有写作能力当脚手架(装判据这一步仍归 `design-skill-rules`):

- `skill-creator`——从零建 / 改 skill、跑 eval。
- `superpowers:writing-skills`——创建 / 编辑 / 校验 skill。

用不用随你;它们只管机械落地,判据永远以 `design-skill-rules` 为准。

## 输出落位

skill 是代码/配置,落目标项目的 `skills/<name>/SKILL.md`(+ `references/`),不落 docs。若目标仓是 plugin marketplace,按该仓自己的约定登记(如 jljskills 的三处登记),本 skill 不代劳。

## 红线

- **判据不自造**:凡「什么算好 skill」的判断,一律 `Read ../design-skill-rules/SKILL.md`,不在本文另立一套。
