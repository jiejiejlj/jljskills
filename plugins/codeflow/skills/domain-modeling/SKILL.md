---
name: domain-modeling
description: 领域建模：挑战冲突术语、锐化模糊词、术语当场落笔进 CONTEXT.md，按三条件门槛记 ADR。仅当用户主动用 `/codeflow:domain-modeling` 指令调用、或其他 skill 显式指路时使用。
allowed-tools: Read, Grep, Glob, Edit, Write, AskUserQuestion
disable-model-invocation: true
---

# domain-modeling — 术语当场落笔

## 用途

在设计过程中**主动**打磨项目的领域模型：挑战术语、编造边界场景、词汇和决策一敲定立刻写下来。只是*读* CONTEXT.md 查词不算本 skill——那是任何 skill 一句话就能做的习惯。本 skill 用于**改**模型，不是消费模型。

它是本插件组的**记忆层**：CONTEXT.md 让 improve-arch 的报告说领域名词、让 design-it-twice 的并行子代理命名一致；ADR 让已否决的建议不被未来的架构审查重提。除被其他 skill 指路接入外，典型的主动调用时机：接手术语混乱的项目建词汇表、重要设计讨论前钉死领域语言、重大决策拍板后趁热记 ADR。

## 文件结构

本插件组在目标项目里的文档统一收在 `docs/jljskills/codeflow/` 下。单 context（多数仓库）：该目录下一个 `CONTEXT.md`（领域词汇表）+ `adr/`（决策记录）。该目录存在 `CONTEXT-MAP.md` 则是多 context 仓库，各 context 词汇表在 `contexts/<名>.md`。格式细节见 [references/context-format.md](references/context-format.md)。

**文件惰性创建**——有东西要写才建：第一个术语敲定时建 CONTEXT.md，第一条 ADR 要记时建 adr/；上级目录不存在则连同建出。

## 会话中的五个动作

1. **对照词汇表挑战**。用户用词与 CONTEXT.md 现有定义冲突时当场指出：「词汇表定义 cancellation 是 X，你说的像是 Y——是哪个？」
2. **锐化模糊词**。用户用了模糊或超载的词，提议精确的规范词：「你说 account——指 Customer 还是 User？这是两个东西。」
3. **编造边界场景**。讨论概念关系时，发明压边界的具体场景，逼用户把概念之间的分界说精确。
4. **对照代码查证**。用户陈述的机制要与代码核对；发现矛盾当面摆出：「代码里取消的是整个 Order，你刚说可以部分取消——哪个对？」
5. **当场更新 CONTEXT.md**。术语一敲定立刻写，不攒批。条目格式见 [references/context-format.md](references/context-format.md)。

完成标准：会话结束时，本次敲定的每个术语都已在 CONTEXT.md 里有条目——遗漏数为零。

## ADR：三条件齐备才提议

1. **难逆**——之后反悔的成本是实打实的
2. **无上下文会困惑**——未来读代码的人会想「当年为什么这么干？」
3. **真实取舍**——存在真的备选项，且是为具体理由选的这个

缺任何一条就跳过。模板、编号与够格决策清单见 [references/adr-format.md](references/adr-format.md)。

## 红线

- **CONTEXT.md 只是词汇表**：不装实现细节、不当 spec、不当草稿本。

---
> 内化自 mattpocock/skills 的 `skills/engineering/domain-modeling`（2026-07-03）。
