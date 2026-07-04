---
name: re-page2doc
description: 设计在 Figma 侧改动后,对已有页面 spec 做 section 级差异更新(NEW/CHANGED/UNCHANGED,只重下变化切图,对位旧 refresh)。仅当用户主动用 `/figma2web:re-page2doc` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Write, Edit, Bash, AskUserQuestion, mcp__plugin_figma_figma
disable-model-invocation: true
---

# re-page2doc — spec 差异更新

## 用途
设计改动后**只更新变化的 section**,不整体重跑。全量重抓当前 Figma、逐 section 分类,NEW 完整文档化 / CHANGED 自刷新 / UNCHANGED 完全不动。对位旧 `refresh`。

核心心法:**全量重抓、以 B 表为基准比对**,用户无需标注改动范围。**不擅删、问用户。**

## 何时运行
仅当用户主动用 `/figma2web:re-page2doc` 指令调用时运行。前置:`project.md` + `tokens.md` + **已有 spec** 均存在;figma-mcp 可用;用户给(更新后的)Figma 页面链接。

## 产物(本 skill 与 `page2doc` 共同维护)
- `docs/figma2web/design/<page>/<section>.md` —— 只刷新 NEW/CHANGED,标 `status`。
- `docs/figma2web/assets/<page>/<section>/...` —— 只重下变化切图;`__ref.png` 同步。

## 流程骨架
1. **全量重抓**:读现有 spec 取各 section `frameNodeId` 逐个重抓当前 Figma;扫页面找新增 section;先不下切图。
2. **比对分类**:以 B 表为基准逐 section → NEW / CHANGED / UNCHANGED。
3. **确认分类(HARD GATE)**:三类清单 + 每个 CHANGED 的逐项具体改动。
4. **分头处理**:NEW 完整文档化;CHANGED 自刷新 spec + 只重下变化切图;UNCHANGED 不动。
5. **小结**,提示对 NEW/CHANGED 跑 `coding`(孤岛,不自动调)。

> 完整分阶段流程见 [references/flow.md](references/flow.md);spec 文件结构契约见 [../spec-structure/SKILL.md](../spec-structure/SKILL.md)(page2doc / re-page2doc / coding 三方共用的地基)—— **动笔前先读它俩**。

## 红线
- **全量重抓**,分类靠比对不靠目视;以 **B 表**为基准。
- HARD GATE 未确认不写;UNCHANGED **完全不动**,CHANGED **只重下变化切图**。
- section 改名 → 视为 NEW,旧 spec 标「疑似改名 / 已移除」**问用户**(删 / 留 / 手动改名保历史)。
- Figma 里已删的 section → 标「已移除」**问用户,不擅删**。
