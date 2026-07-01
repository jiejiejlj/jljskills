---
name: init
description: 配置项目级技术决策(框架 / 语言 / 样式 / 目录 / token 落地 / 部署等),产出 `docs/figma2web/project.md`。figma2web 管线的首个必跑 skill,其它 skill 都 gate 于它。仅当用户主动用 `/figma2web:init` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Write, Edit, AskUserQuestion
disable-model-invocation: true
---

# init — 配置项目技术决策

## 用途
figma2web 管线的地基。**纯交互式**收集团队在本项目上的技术决策,写成一份 `project.md`,让下游所有 skill 读它来适配,而不是把技术栈硬编码进 skill。**不读 Figma、不写应用代码、不建脚手架。**

核心心法:**逐项必答。** 每一项都要拿到确定值,不接受留空、不擅自默认;用户说「无所谓」时也要把默认值念出来请他确认。下游因此可以直接信任 `project.md`,不再做齐备性校验。

## 何时运行
仅当用户主动用 `/figma2web:init` 指令调用时运行。它是 figma2web 的**首个必跑** skill —— `config`/`page2doc`/`coding`/… 开工前都会检查 `project.md` 是否存在,不存在就回头提示先跑 `init`。

前提:**已有一个能本地跑的工程**(init 不负责脚手架初始化)。

## 产物(本 skill 是唯一写者)
- `docs/figma2web/project.md` —— 项目技术配置,所有下游 skill 只读。

## 流程骨架
1. **前置校验 + 首建 / 重配判定**:`project.md` 不存在 → 首建;已存在 → 预填式重配(载入现值逐项预填,只写变更)。
2. **逐项收集 10 项技术决策**:每项给默认值 + 理由,请用户确认或改。
3. **呈交确认(HARD GATE)**:完整配置列出请用户确认;任一项待定则回上一步补齐。
4. **写 `project.md` + 报告**,提示下一步跑 `config`。

> 完整分阶段流程、10 项字段清单与 `project.md` 模板见 [references/flow.md](references/flow.md) —— **动笔前先读它**。

## 红线
- **逐项必答**,不留空、不擅自默认;拿不准就停下问用户。
- HARD GATE **未经确认不写**;任一项待定绝不带缺口落盘。
- 重配时**只写变更项**,用户回车保留的原样不动。
- **不建脚手架、不读 Figma、不写应用代码** —— 越界即停。
