---
name: grill-with-docs
description: 主流程入口：按 grill 的手法拷问方案，同时按 build-context 当场沉淀术语与 ADR——拷问留下纸面痕迹。仅当用户主动用 `/codeflow:grill-with-docs` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, WebFetch, Edit, Write, AskUserQuestion
disable-model-invocation: true
---

# grill-with-docs — 拷问 + 落笔

Read `../grill/SKILL.md` 与 `../build-context/SKILL.md`，然后：

- 按 grill 的流程拷问用户给的方案 / 计划 / 需求；
- 全程叠加 build-context 的五个动作——术语一敲定当场写进 `docs/jljskills/codeflow/CONTEXT.md`，满足三条件门槛的决策当场记 ADR。

与两个成员 skill 的分工：只想拷问不留档 → `/codeflow:grill`；不在拷问、只想改领域模型 → `/codeflow:build-context`。本 skill = 两者同时开动，是主流程（拷问 → to-prd → to-issues → implement）的一号位。
