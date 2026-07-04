---
name: config
description: 经一个代表设计规范的 Figma 链接抽取设计标准(色板 / 字体族 / 字号阶 / 间距网格 / 圆角 / 阴影 / 渐变),文档化为 `docs/jljskills/figma2web/tokens.md` 并落实为可用的 `tailwind.config.*`。`init` 之后、建页面前的地基。仅当用户主动用 `/figma2web:config` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Write, Edit, AskUserQuestion, mcp__plugin_figma_figma
disable-model-invocation: true
---

# config — 打通设计 token

## 用途
`init` 之后、建页面前的**地基**。读一个代表设计规范的 Figma 链接,把设计标准**文档化 + 落实为可用 token**:`tokens.md`(source of truth)+ `tailwind.config.*`(据 tokens.md 生成)。让后续 `page2doc`/`coding` 的样式有据可依、避免魔法值。

核心心法:**tokens.md 是唯一真源,tailwind.config 每次据它重新生成**,天然不漂移。抽不到 / 命名不规范就**停下问用户**,不自行归并。

## 何时运行
仅当用户主动用 `/figma2web:config` 指令调用时运行。前置需 `init` 已产出 `project.md`。读 Figma,需 figma-mcp 可用(未认证先跑认证)。

## 产物(本 skill 与 `re-config` 共同维护)
- `docs/jljskills/figma2web/tokens.md` —— 设计标准文档(值 + Figma 变量 + token + 来源),**source of truth**。
- `app/tailwind.config.*` —— 可用 token(theme),每次据 `tokens.md` 重新生成。

## 流程骨架
1. **前置校验**:`project.md` 存在;figma-mcp 可用;向用户索取一个代表设计规范的 Figma 链接(不落盘,每次现问)。
2. **抽取设计标准**:优先读 variables,无变量则 fallback 代表帧归纳;7 个维度;标注来源。
3. **建立映射**:变量路径直译为 tailwind theme key;不符合结构的命名停下问。
4. **呈交确认(HARD GATE)**:设计标准表请用户确认。
5. **写两产物**(同一运行内一起写,保一致)+ 报告,提示下一步 `page2doc`。

> 完整分阶段流程、7 维度、直译规则与 `tokens.md` 模板见 [references/flow.md](references/flow.md) —— **动笔前先读它**。

## 红线
- **tokens.md 是真源**,tailwind.config 据它生成,绝不各写一套导致漂移。
- 抽不到 / 命名不符 tailwind 结构 → **停下问用户**,不臆测归并。
- HARD GATE 未确认不写;每个值必须标**来源**(Figma 变量 / 代表帧归纳 / 人工)。
- 既无 variables 也取不到代表帧 → 引导用户手填核心标准(至少色板 + 字体 + 网格基数),标来源=人工。
