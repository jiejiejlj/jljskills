---
name: re-config
description: 设计标准 / 变量在 Figma 侧改动后,差异化同步 `docs/figma2web/tokens.md` 与 `app/tailwind.config.*`(只改变化项,对位旧 resetup)。仅当用户主动用 `/figma2web:re-config` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Write, Edit, AskUserQuestion, mcp__plugin_figma_figma
disable-model-invocation: true
---

# re-config — 设计标准差异同步

## 用途
设计标准 / 变量在 Figma 侧改了之后,把 `tokens.md` 与 `tailwind.config.*` **只更新变化项**,不整体重跑。对位旧 `resetup`。**不维护变更日志**(改动历史靠 git)。

核心心法:**靠数值比对分类,不靠目视。** NEW/CHANGED 逐项确认前后具体值;某项在 Figma 被删不擅删,标「已移除」问用户。

## 何时运行
仅当用户主动用 `/figma2web:re-config` 指令调用时运行。前置需 `project.md` + 已有的 `tokens.md` 都存在(缺后者 → 提示先跑 `config`)。读 Figma,需 figma-mcp 可用。

## 产物(本 skill 与 `config` 共同维护)
- `docs/figma2web/tokens.md` —— 只更新 NEW/CHANGED(值 + 来源),UNCHANGED 原样。
- `app/tailwind.config.*` —— 据更新后的 `tokens.md` 同步重新生成。

## 流程骨架
1. **前置校验**:`project.md` + `tokens.md` 存在;figma-mcp 可用;向用户索取标准面板 Figma 链接。
2. **重抓当前标准**(同 `config` P1:优先 variables,fallback 代表帧)。
3. **diff 分类**:与现有 `tokens.md` 逐项比对 → NEW / CHANGED / UNCHANGED,含**来源演进**。
4. **确认分类(HARD GATE)**:三类清单 + 每个 NEW/CHANGED 的前后具体值,逐项确认。
5. **写回**(同一运行内一起写)+ 小结。

> 完整分阶段流程与边界(删除 / 读不到)见 [references/flow.md](references/flow.md) —— **动笔前先读它**。

## 红线
- 分类**靠数值比对**,不靠目视。
- HARD GATE 未确认不写;写回时 UNCHANGED **原样不动**。
- Figma 里被删的项 → 标「已移除」**问用户**,不擅删。
- tailwind.config 始终据更新后的 `tokens.md` 生成,保两者不漂移。
