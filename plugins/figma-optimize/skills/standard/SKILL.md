---
name: standard
description: 交付 / 维护前评审 Figma **设计规范板本身**:AI 作标准体系守门人,读全量 variables / text styles,逐维度(变量完整性 / token 化纯净度 / 命名规范 / 字阶字体 / 收敛)揪出体系问题,辨别库变量 vs 裸 hex 避免误判,逐条经用户裁定后写回或给自改说明,产一份标准体系评审报告。仅当用户主动用 `/figma-optimize:standard` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Write, Edit, AskUserQuestion, mcp__plugin_figma_figma
disable-model-invocation: true
---

# standard — 交付前设计规范板体系评审

## 用途
面向**设计师**,在设计规范板交付或长期维护之前,审查规范板**本身**是否成体系,弥合「标准散乱」与「开发要一套可信 token」之间的鸿沟。AI 在这里充当**标准体系守门人**:检查变量 / 文本样式是否成体系、是否已 token 化、命名是否规范,而不是审查某个具体界面稿。

核心心法:**AI 只揪可验证的体系问题(缺档 / 未 token 化 / 命名不规范 / 近似重复),取值与审美归设计师。** 每条建议都得经用户裁定,**写回 Figma 前 HARD GATE 未确认不动手**。

## 何时运行
仅当用户主动用 `/figma-optimize:standard` 指令调用时运行。前置:figma-mcp 可用(需读取,采纳项经 `use_figma` 写回;未认证先跑认证);拿到待审的**设计规范板**链接 / 范围。

**独立插件**(分工契约见 [../../README.md](../../README.md)):只写回 Figma、不落项目代码;不读写 figma2web 的任何产物;不依赖 superpowers。

## 产物(本 skill 是唯一写者)
- `docs/jljskills/figma-optimize/standard-<板名>-<日期>.md` —— 标准体系评审报告(可选落盘,报告阶段可改路径 / 不落盘)。

## 流程骨架
1. **前置校验**:figma-mcp 可用(未认证先认证);向用户索取待审**规范板**链接 / 范围(不落盘,每次现问)。
2. **读全量体系**:先 Read [figma-facts](../figma-facts/SKILL.md) 装载共享判据(flow P1 硬性步骤);`use_figma` 三源读全量;`get_variable_defs` 仅快览;辨 token vs 裸 hex 以 figma-facts 判据为准。
3. **逐维度评审**:按 S-A~S-E 五维审查变量集合完整性、token 化纯净度、命名规范、字阶字体标准、收敛,产带严重度的建议列表。
4. **逐条裁定(HARD GATE)**:逐维度、逐条呈交,用户选 采纳 / 跳过 / 再调;**写入 Figma 前必须确认,未确认不得改动**。
5. **采纳项二次选择**:每条采纳的问题,用户再选「我自改」还是「让 AI 改」。
6. **写回 / 自改说明**:「让 AI 改」→ **先走 `figma-use` skill** → `use_figma` 写入(重命名变量 / 绑定 / 收敛 token)→ 每处 `get_screenshot` 校验;「我自改」→ 给可照做的明确改法说明。
7. **复审**:体系问题理想归零,或仅剩用户有意保留、报告标注的例外。
8. **标准体系评审报告**:默认落 `docs/jljskills/figma-optimize/`,报告阶段允许改路径 / 不落盘。

> 完整分阶段流程见 [references/flow.md](references/flow.md);体系向评审清单见 [references/checklist.md](references/checklist.md);Figma API 配方见 [references/figma-api-cookbook.md](references/figma-api-cookbook.md);报告模板见 [references/report-template.md](references/report-template.md) —— **动笔前先读它们**。

## 红线
- **HARD GATE 未确认不动 Figma**;调用 `use_figma` 之前**必先走 `figma-use` skill**,每处改完 `get_screenshot` 校验。
- **不生成代码**、不做 design→code;**不读写 figma2web 的任何产物**,不复用其文件。
- **不替设计师做审美裁决**,不无中生有设计新体系 —— 只审既有规范板并按用户裁定优化。
- 数值 / 命名类靠 `use_figma` 精确审计;**token 化审计判据(库变量 vs 裸 hex)以 [figma-facts](../figma-facts/SKILL.md) 为准**——判据正文不在本文件复述,动笔前必已由 flow P1 装载。
