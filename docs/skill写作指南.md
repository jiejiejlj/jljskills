# Skill 写作指南

本文是本仓库写 / 改 skill 的判据集,供在 `jljskills` 内编写 skill 时查阅。CLAUDE.md 的「SKILL.md 写法」节放了高频自检项,完整推理与词汇在这里。

> 提炼自 mattpocock/skills 的 `writing-great-skills`。

## 根本原则:可预测

skill 的根本美德是**可预测**——不是输出一致,而是**过程一致**:同一个 skill 每次都走同一套方法论,从随机的模型行为里拧出确定性。下面所有技巧都服务于这一点。

## 调用策略:model-invoked vs user-invoked

两种调用各付一种「税」:

- **model-invoked**(模型自动触发):`description` 每一轮都占上下文(context load);换来「模型能自主够到、别的 skill 能引用」。
- **user-invoked**(`disable-model-invocation: true`):零上下文占用;代价是你得记得它存在(cognitive load)。

**决策规则**:只有当「模型必须自主触发它」或「另一个 skill 需要够到它」时,才选 model-invoked;否则一律 user-invoked,白赚零上下文。

管理多个 user-invoked skill:建一个 **router skill**——单个 user-invoked skill,里面列出其它技能各自「何时用」,用它做入口。

## description 写法(补充)

`description` 有双重职责:说清「这是什么」+ 列出「哪些分支触发它」。

- **前置引导词**:把最关键的词放句首,提升触发命中率。
- **一个真分支一条触发**:同义改写同一个触发点 = duplication,是浪费。
- **别重复正文已有的身份信息**:description 专注「触发 + 够到」,不复述 skill 正文里已经说过的「我是什么」。

## 信息层级:三层,按即时性排

skill 内容分两类(steps / reference),沿三层摆放:

1. **In-skill steps**:有序动作,每步带**可检查的完成标准**,尽量穷尽。
2. **In-skill reference**:扁平的定义 / 规则 / 事实,按需查。
3. **External reference**:推到 `references/*.md`,正文用相对链接当指针。

关键机制:**苛刻的完成标准会逼出 legwork**(真正的调查性工作量)。步骤写不写得清,取决于完成标准硬不硬。

## 渐进式披露

内容沿层级往下沉(正文 → 链接文件),让顶层保持可读。**用分支做披露测试**:

> 每个分支都需要的 → 内联;只有部分分支才够到的 → 藏到指针后面。

## 何时拆分 skill

- **按调用拆**:某段内容有独立的引导词、值得被单独触发时,拆成一个 model-invoked skill。但这要付 context load,必须有独立的「够到」需求来 justify。
- **按顺序拆**:当后面的步骤会诱使你在当前步骤「提前收工」时,把「完成后才做的步骤」藏起来,逼出更深的 legwork。

## 剪枝纪律

- 每个含义只保留**单一真相源**(single source of truth)。
- 逐行做 **no-op 测试**:这句跟默认行为相比,改变了什么?没改变 = no-op。
- no-op 句**直接删掉**,而不是精简它。

## Leading words(引导词)——最锋利的一招

引导词 = 一个预训练好的、紧凑的概念词,agent 执行时「用它来思考」。它同时锚定两件事:

- **执行**:这个词出现时,行为一致。
- **触发**:prompt / 文档 / 代码里出现同一个词时,可靠地唤起 skill。

**塌缩重构**——把一串描述压成一个 token,更省 token 且认知钩子更锋利:

- 「fast, deterministic, low-overhead」→ **tight**
- 「a loop you believe in」→ **red**(TDD 的 red 阶段)

本仓库已有的好例子:`grill` 的「对抗式拷问」、`interview2doc` 的「矛盾即缺口」——它们就是引导词。审视自己的 skill 时,问:核心词够不够一击命中?

## 失败模式清单(review 时逐条对照)

| 失败模式 | 症状 | 解法 |
|---|---|---|
| **Premature completion**(提前收工)| 步骤没做透就结束 | 更锐利的完成标准,或按顺序拆分 |
| **Duplication**(重复)| 同一含义出现在多处 | 合并到单一真相源 |
| **Sediment**(沉积)| 陈旧内容堆积没清 | 删过时内容 |
| **Sprawl**(蔓延)| 内容都有效但太长 | 用披露 + 分支瘦身 |
| **No-op**(空操作)| 句子其实是默认行为 | 换更强的引导词,而非换技巧 |
