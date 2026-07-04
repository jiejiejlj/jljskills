---
name: component
description: 交付前给 Figma **界面稿**做「散件收编」:扫描重复出现却未组件化的散件与游离克隆,识别应沉淀为 Figma component 的候选,逐条经用户裁定命名 / 变体归并后写回——原位替换为实例、外观零变化,产一份收编报告。仅当用户主动用 `/figma-optimize:component` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Write, Edit, AskUserQuestion, mcp__plugin_figma_figma
disable-model-invocation: true
---

# component — 界面稿散件收编

## 用途
面向**设计师**,在界面稿交付 / 长期维护前,把稿内**重复出现却仍是散件**的元素**收编**成 Figma components,让设计稿从「拷贝粘贴维护」升级为「组件单点维护」,开发拿到的也是成体系的组件而非散件。AI 在这里充当**同构检测器 / 收编执行者**:只揪可验证的同构重复,该不该成组件、叫什么名、变体怎么归并由设计师拍板。

核心心法:**收编 = 外观零变化。** 成立组件、原位替换为实例后,每一处视觉必须与收编前一致——组件化改的是结构,不是样子。候选逐个经用户裁定,**写回 Figma 前 HARD GATE 未确认不动手**。

## 何时运行
仅当用户主动用 `/figma-optimize:component` 指令调用时运行。前置:figma-mcp 可用(需读取,采纳项经 `use_figma` 写回;未认证先跑认证);拿到待收编的界面稿链接 / 范围。

**独立插件**:不依赖、不读写 figma2web 的任何产物(`project.md` / `tokens.md` / `design/` 等),不作为其流程一环;不依赖 superpowers。

## 产物(本 skill 是唯一写者)
- Figma 文件内新成立的 components + 各出现处的实例替换(写回产物)。
- `docs/jljskills/figma-optimize/component-<页面>-<日期>.md` —— 收编报告(可选落盘,报告阶段可改路径 / 不落盘)。

## 流程骨架
1. **前置校验**:figma-mcp 可用(未认证先认证);向用户索取待收编的界面稿链接 / 范围(不落盘,每次现问)。
2. **装载判据 + 摸底**:Read figma-facts 装载共享判据;`get_metadata` 盘全页结构,分清「已是实例」「已有组件」「散件」。
3. **扫描候选**:同构重复 ≥2 的散件;与已有组件同构却非其实例的**游离克隆**;单处但按设计系统惯例应组件化的自成一体单元。`get_screenshot` 逐候选取证。
4. **呈交候选清单(HARD GATE)**:每候选带出现处 / 建议组件名 / 变体归并方案 / 各处差异点;逐个采纳 / 跳过 / 调整。
5. **收编写回**:**先走 `figma-use` skill** → 成立 component(多状态先归并变体)→ 其余出现处原位替换为实例 → **每处 `get_screenshot` 比对收编前后外观零变化**。
6. **复审 + 收编报告**:采纳候选归零或仅剩有意保留;报告默认落 `docs/jljskills/figma-optimize/`,报告阶段允许改路径 / 不落盘。

> 完整分阶段流程与同构判据见 [references/flow.md](references/flow.md);组件化 API 配方见 [references/figma-api-cookbook.md](references/figma-api-cookbook.md) —— **动笔前先读它们**。

## 红线
- **HARD GATE 未确认不动 Figma**;调用 `use_figma` 之前**必先走 `figma-use` skill**;每处替换后 `get_screenshot` 比对,**外观零变化**,变了即修正或回滚该处。
- **不无中生有设计新组件** —— 只收编稿内既有元素;新造的只有组件结构(命名 / 变体轴),不新造视觉。
- 差异超出 variants / 实例覆写能表达的候选**不硬并**,把差异摆给用户裁定拆分。
- **不生成代码**;**不读写 figma2web 的任何产物**。
- 命名与「该不该成组件」的最终决定权归设计师;AI 只提供可验证的同构证据。
