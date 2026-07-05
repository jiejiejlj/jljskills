---
name: build-context
description: 维护目标项目的领域记忆：按 design-domain-model 的判据出手，术语当场落笔进 CONTEXT.md，过三条件门槛的决策记 ADR。仅当用户主动用 `/codeflow:build-context` 指令调用、或其他 skill 显式指路时使用。
allowed-tools: Read, Grep, Glob, Edit, Write, AskUserQuestion
disable-model-invocation: true
---

# build-context — 术语当场落笔

**驱动思想：领域建模**——Read `../design-domain-model/SKILL.md` 装载判据（三原则、三病灶、四手法内核、ADR 门槛）。判断归它，本文只管**手怎么动、写到哪**。

## 用途

在设计过程中**主动**打磨项目的领域模型：发现病灶就出招，词汇和决策一敲定立刻写下来。只是*读* CONTEXT.md 查词不算本 skill——那是任何 skill 一句话就能做的习惯。本 skill 用于**改**模型，不是消费模型。

它是本插件组的**记忆层**：CONTEXT.md 让 improve-arch 的报告说领域名词、让 design-it-twice 的并行子代理命名一致；ADR 让已否决的建议不被未来的架构审查重提。除被其他 skill 指路接入外，典型的主动调用时机：接手术语混乱的项目建词汇表、重要设计讨论前钉死领域语言、重大决策拍板后趁热记 ADR。

## 文件结构

本插件组在目标项目里的文档统一收在 `docs/jljskills/codeflow/` 下。单 context（多数仓库）：该目录下一个 `CONTEXT.md`（领域词汇表）+ `adr/`（决策记录）。该目录存在 `CONTEXT-MAP.md` 则是多 context 仓库，各 context 词汇表在 `contexts/<名>.md`。格式细节见 [references/context-format.md](references/context-format.md)。

**文件惰性创建**——有东西要写才建：第一个术语敲定时建 CONTEXT.md，第一条 ADR 要记时建 adr/；上级目录不存在则连同建出。

## 会话中的五个动作

前四招的「何时出手」按驱动思想的四手法内核判断，这里是执行口径；第五步是本 skill 的独有职责：

1. **挑战**：「词汇表定义 cancellation 是 X，你说的像是 Y——是哪个？」
2. **锐化**：「你说 account——指 Customer 还是 User？这是两个东西。」
3. **边界场景压测**：发明压边界的具体场景，逼用户把概念分界说精确。
4. **代码对质**：「代码里取消的是整个 Order，你刚说可以部分取消——哪个对？」
5. **当场更新 CONTEXT.md**：术语一敲定立刻写，不攒批。条目格式见 [references/context-format.md](references/context-format.md)。

完成标准：会话结束时，本次敲定的每个术语都已在 CONTEXT.md 里有条目——遗漏数为零。

## 记 ADR

过驱动思想的三条件门槛才提议；模板、编号与够格决策清单见 [references/adr-format.md](references/adr-format.md)。

## 红线

- 落笔时发现词条混入实现细节（违反驱动思想的判据红线），当场剥离，不顺水推舟。
- **当场写，不攒批**——攒到收尾凭记忆汇总就是本 skill 要防的失败模式。

---
> 2026-07-05 自 domain-modeling 拆出（行为侧，承接原调用面）；原内化自 mattpocock/skills 的 `skills/engineering/domain-modeling`（2026-07-03）。
