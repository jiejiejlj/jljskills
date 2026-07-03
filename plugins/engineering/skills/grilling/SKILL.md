---
name: grilling
description: 对选定的深化候选走设计树拷问：约束 → seam 位置 → interface 形状 → 藏什么 → 哪些测试存活，收敛出 interface 草图。仅当用户主动用 `/engineering:grilling` 指令调用、或 improve-arch 第三阶段显式指路时使用。
allowed-tools: Read, Grep, Glob, Agent, Write, Edit, AskUserQuestion
disable-model-invocation: true
---

# grilling — 走设计树

## 用途

对一个**待设计的深化**逐分支拷问，目标是**收敛出 interface 形状**——不是压出问题（那是 `/project:grill` 对已成形方案干的事），而是和用户一起把设计树走完，直到能写出深化后 module 的 interface 草图。

## 前置

若本会话尚未装载词汇，先 Read `../design-rules/SKILL.md`——拷问全程用它的术语。

## 流程

1. **锚定候选**。确认要设计的深化：涉及哪些文件、当前哪里 shallow、依赖属于哪一类（对照 `../design-rules/references/deepening.md` 的四分类）。没有候选时先问「要设计的深化是什么」。

2. **走设计树，从最上游开始**。决策之间有依赖，上游塌了下游全塌。按序逐分支：
   - **约束**：新 interface 必须满足什么（性能、兼容、部署形态）？
   - **Seam 位置**：seam 放哪？这与「后面放什么」是两个决策，先定位置。
   - **Interface 形状**：几个入口？参数长什么样？错误怎么暴露？
   - **Seam 后面藏什么**：哪些现有 module 被吸收成 implementation？哪些保持独立？
   - **哪些测试存活**：现有测试哪些迁到新 interface、哪些删（replace, don't layer）？

3. **拷问纪律**（每个分支内）：
   - **一次只问一题**，等回应再继续——一次抛多题会把人问懵。
   - 每题附**推荐答案 + 理由**，能枚举选项的用 AskUserQuestion。
   - **能查代码回答的自己查**，不拿去问用户。
   - 每分支结论**当场登记**，不攒到最后凭记忆。

4. **收尾：interface 草图**。全部分支走完时，输出深化后 module 的 interface 草图：方法、参数、不变量、错误模式，外加依赖策略（哪类依赖、几个 adapter）。

完成标准：**写不出 interface 草图 = 分支没走完**——回到没走透的分支继续，不得以「大方向已清楚」收工。

## 红线

- 用户想比较多种 interface 方案时，切到 `../design-rules/references/design-it-twice.md` 的并行子代理模式，不在单线拷问里硬比。
- 拷问中敲定新术语、或用户以承重理由否决候选时，按 `../domain-modeling/SKILL.md` 当场落笔（CONTEXT.md / ADR）。

---
> 内化自 mattpocock/skills 的 `skills/productivity/grilling`，流程骨架参考本仓库 `project:grill` 补强（2026-07-03）。
