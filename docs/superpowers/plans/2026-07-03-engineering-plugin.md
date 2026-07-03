# engineering Plugin Implementation Plan

> **已执行完毕（2026-07-03）**：本计划已实施并经终审修复；文内嵌入的文件内容是执行前的快照，与最终文件存在已知差异（禁用词补全、allowed-tools 修正、两处剪重、Mermaid linkStyle）。**以仓库内实际文件为准**：`plugins/engineering/`。

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新建 `engineering` plugin，内化 mattpocock/skills 的深模块方法论为四个 skill：`design-rules`（词汇库+判据）、`improve-arch`（扫描→HTML 报告→拷问的编排入口）、`grilling`（走设计树拷问）、`domain-modeling`（CONTEXT.md 词汇表 + ADR）。

**Architecture:** design-rules 是被引用的地基（纯 reference 型），其余三个 skill 用相对路径显式指路引用它；improve-arch 是编排入口，三阶段分别指路 design-rules、grilling、domain-modeling。四个 skill 全部 user-invoked，互相够到全靠文件路径，不靠 model-invoked description。实施顺序按依赖：地基 → 被指路的两个 skill → 编排入口 → 登记。

**Tech Stack:** Markdown（SKILL.md + references）、JSON（plugin 清单）、Claude Code plugin 规范。

**Spec:** `docs/superpowers/specs/2026-07-03-engineering-plugin-design.md`

## Global Constraints

- 正文用**简体中文**；七术语（module / interface / implementation / depth / seam / adapter / leverage / locality）及 deep/shallow 保留**英文原词**；禁用词清单（component / service / unit / API / signature / boundary / layer / wrapper）保留英文。
- 三处 name 一致：skill 目录名 = frontmatter `name` = 调用名 `/engineering:<skill>`。
- 四个 skill 全部 `disable-model-invocation: true`，description 注明「仅当用户主动用 `/engineering:<skill>` 指令调用（或其他 skill 显式指路）时使用」。
- skill 间引用一律用**相对路径**（如 `../design-rules/SKILL.md`），落盘后路径必须真实存在（终验逐条检查）。
- 每个 SKILL.md 与 references 文件底部保留溯源行：「内化自 mattpocock/skills 的 `<原路径>`（2026-07-03）」。
- 每个 SKILL.md 写完过写作指南自检（`docs/skill写作指南.md`）：逐行 no-op 测试 + 五失败模式对照。
- commit 风格：`feat(engineering): ...` 中文描述，尾行 `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`。
- 最后必须 push（滚动分发）。
- 与 spec 的已知偏差：spec 提到「README 目录树补上 support 与 loopspec 的漂移」，实际 README 已包含两者、无漂移，Task 5 只做 engineering 的新增登记。

---

### Task 1: plugin 骨架 + design-rules 词汇库 skill

**Files:**
- Create: `plugins/engineering/.claude-plugin/plugin.json`
- Create: `plugins/engineering/skills/design-rules/SKILL.md`
- Create: `plugins/engineering/skills/design-rules/references/deepening.md`
- Create: `plugins/engineering/skills/design-rules/references/design-it-twice.md`

**Interfaces:**
- Produces: `../design-rules/SKILL.md`（术语表+判据，Task 2/3/4 的 SKILL.md 按此相对路径指路）；`../design-rules/references/deepening.md`（依赖四分类，Task 3/4 指路）；`../design-rules/references/design-it-twice.md`（多方案探索模式，Task 3/4 指路）。

- [ ] **Step 1: 写 plugin.json**

写入 `plugins/engineering/.claude-plugin/plugin.json`（格式对齐现有 `plugins/support/.claude-plugin/plugin.json`）：

```json
{
  "name": "engineering",
  "description": "代码库架构设计相关 skill（深模块方法论）",
  "author": { "name": "jiejiejlj" }
}
```

- [ ] **Step 2: 写 design-rules/SKILL.md**

写入 `plugins/engineering/skills/design-rules/SKILL.md`：

````markdown
---
name: design-rules
description: 深模块设计的词汇库与判据：module/interface/seam/depth/adapter/leverage/locality 七术语、deep/shallow 模型、删除测试等四原则。仅当用户主动用 `/engineering:design-rules` 指令调用、或其他 skill 显式指路 Read 本文件时使用。
allowed-tools: Read
disable-model-invocation: true
---

# design-rules — 深模块词汇与判据

## 用途

设计 **deep module**：大量行为藏在小 interface 后面，落在干净的 seam 上，可透过 interface 测试。本文是架构讨论的单一真相源——凡是设计或重构代码的场合，用这里的语言和判据。目标：给调用者 leverage，给维护者 locality，给所有人可测试性。

（理论出处：John Ousterhout《软件设计的哲学》的深模块理论、Michael Feathers 的 seam 概念。）

## 术语表（七词，精确使用）

术语一律用英文原词——一致的语言是本 skill 的全部意义，禁用词一个不许漏进来。

**Module** —— 任何「有 interface + 有 implementation」的东西。刻意不限尺度：函数、类、包、跨层切片都算。_禁用_：unit、component、service。

**Interface** —— 调用者正确使用一个 module 所需知道的**一切**：类型签名之外，还包括不变量、调用顺序约束、错误模式、必需配置、性能特征。_禁用_：API、signature（都太窄，只指类型层面）。

**Implementation** —— module 内部的代码体。与 **Adapter** 正交：一个东西可以是小 adapter + 大 implementation（Postgres 仓储），也可以是大 adapter + 小 implementation（内存 fake）。谈 seam 时用 adapter，其余场合用 implementation。

**Depth** —— interface 处的杠杆率：调用者（或测试）每学一单位 interface，能撬动多少行为。大量行为藏在小 interface 后面 = **deep**；interface 几乎和 implementation 一样复杂 = **shallow**。

**Seam**（Feathers）—— 不修改某处代码就能改变其行为的位置；一个 module 的 interface 所在之处。「seam 放哪」与「seam 后面放什么」是两个独立的设计决策。_禁用_：boundary（与 DDD 的 bounded context 撞名）。

**Adapter** —— 在 seam 处满足 interface 的具体物。描述**角色**（填什么槽），不描述实质（里面是什么）。

**Leverage** —— depth 给调用者的回报：学一份 interface，换更多能力。一份 implementation 在 N 个调用点和 M 个测试里反复回本。

**Locality** —— depth 给维护者的回报：修改、bug、知识、验证集中在一处，而不是散布在各调用方。修一次，处处生效。

## Deep vs shallow

**Deep module** = 小 interface + 厚 implementation：

```
┌─────────────────────┐
│    小 Interface     │  ← 方法少、参数简单
├─────────────────────┤
│                     │
│  厚 Implementation  │  ← 复杂度藏在里面
│                     │
└─────────────────────┘
```

**Shallow module** = 宽 interface + 薄 implementation（避免）：

```
┌─────────────────────────────────┐
│         宽 Interface            │  ← 方法多、参数复杂
├─────────────────────────────────┤
│  薄 Implementation（纯透传）    │
└─────────────────────────────────┘
```

设计 interface 时自问三句：能减少方法数吗？能简化参数吗？能把更多复杂度藏进去吗？

## 四条原则

- **Depth 是 interface 的属性，不是 implementation 的属性。** deep module 内部完全可以由小的、可 mock、可替换的部件组成——只要它们不出现在 interface 上。module 可以有 **internal seam**（implementation 私有，供自己的测试用），也有 **external seam**（interface 处）。
- **删除测试（deletion test）。** 想象删掉这个 module：复杂度凭空消失 = 它是透传；复杂度在 N 个调用方重现 = 它在挣饭钱。
- **Interface 即测试面。** 调用者和测试穿过同一条 seam。想测到 interface「后面」去，多半说明 module 形状不对。
- **一个 adapter = 假想的 seam，两个 = 真的。** 没有东西真正跨 seam 变化时，别引入 seam——单 adapter 的 seam 只是间接层。

## 可测试性三规则

1. **注入依赖，不自建依赖。**

   ```typescript
   // 可测
   function processOrder(order, paymentGateway) {}

   // 难测
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

2. **返回结果，不产副作用。**

   ```typescript
   // 可测
   function calculateDiscount(cart): Discount {}

   // 难测
   function applyDiscount(cart): void {
     cart.total -= discount;
   }
   ```

3. **小表面积。** 方法越少，要写的测试越少；参数越少，测试搭建越简单。

## 术语关系

- 一个 **Module** 有且仅有一个 **Interface**（面向调用者和测试的那个表面）。
- **Depth** 是 Module 的属性，相对其 Interface 度量。
- **Seam** 是 Module 的 Interface 所在之处。
- **Adapter** 位于 Seam 处，满足 Interface。
- **Depth** 产出 **Leverage**（给调用者）与 **Locality**（给维护者）。

## Rejected framings（否决的表述，勿滑回）

- **「depth = implementation 行数 / interface 行数」**（Ousterhout 原版）：奖励往 implementation 灌水。改用「depth 即 leverage」。
- **「interface = TypeScript 的 `interface` 关键字 / 类的 public 方法」**：太窄——这里的 interface 包括调用者必须知道的每一个事实。
- **「boundary」**：与 DDD 的 bounded context 撞名。说 **seam** 或 **interface**。

## 深入

- **给定依赖，如何深化一簇 module** —— 见 [references/deepening.md](references/deepening.md)：依赖四分类、seam 纪律、replace-don't-layer 测试策略。
- **为深化候选探索多种 interface** —— 见 [references/design-it-twice.md](references/design-it-twice.md)：并行子代理产出多个截然不同的设计再对比。

---
> 内化自 mattpocock/skills 的 `skills/engineering/codebase-design`（2026-07-03）。
````

- [ ] **Step 3: 写 references/deepening.md**

写入 `plugins/engineering/skills/design-rules/references/deepening.md`：

```markdown
# Deepening —— 给定依赖，深化一簇 shallow module

前置：先读 [SKILL.md](../SKILL.md) 的术语表——本文直接使用 module / interface / seam / adapter。

## 依赖四分类

评估深化候选时，先给它的依赖分类。类别决定深化后的 module 如何跨 seam 测试。

### 1. 进程内（in-process）

纯计算、内存状态、无 I/O。永远可深化——合并 module，直接透过新 interface 测。不需要 adapter。

### 2. 本地可替代（local-substitutable）

有本地测试替身的依赖（Postgres→PGLite、内存文件系统）。替身存在即可深化。深化后的 module 在测试套件里带着替身跑。seam 是内部的；module 的外部 interface 不开 port。

### 3. 远程但自有（ports & adapters）

跨网络边界的自家服务（微服务、内部 API）。在 seam 处定义 **port**（interface）。deep module 持有逻辑；传输作为 **adapter** 注入。测试用内存 adapter，生产用 HTTP/gRPC/队列 adapter。

建议的表述形状：「在 seam 处定义 port，生产实现 HTTP adapter、测试实现内存 adapter——逻辑集中在一个 deep module 里，哪怕部署上跨网络。」

### 4. 真外部（mock）

你控制不了的第三方服务（Stripe、Twilio 等）。深化后的 module 把外部依赖当注入的 port；测试提供 mock adapter。

## Seam 纪律

- **一个 adapter = 假想的 seam，两个 = 真的。** 至少两个 adapter 有正当性（通常是生产 + 测试）才开 port。单 adapter 的 seam 只是间接层。
- **Internal seam vs external seam。** deep module 可以有 internal seam（implementation 私有，供自己的测试用）。不要因为测试在用，就把 internal seam 暴露到 interface 上。

## 测试策略：replace, don't layer（替换，不叠加）

- 深化后的 interface 一旦有了测试，shallow module 上的旧单测就成了废物——**删掉**。
- 新测试写在深化后 module 的 interface 上。**Interface 即测试面。**
- 测试断言透过 interface 的可观察结果，不断言内部状态。
- 测试要能挺过内部重构——它们描述行为，不描述实现。实现一改测试就得跟着改的，是测过了 interface。

---
> 内化自 mattpocock/skills 的 `skills/engineering/codebase-design/DEEPENING.md`（2026-07-03）。
```

- [ ] **Step 4: 写 references/design-it-twice.md**

写入 `plugins/engineering/skills/design-rules/references/design-it-twice.md`：

```markdown
# Design It Twice —— 并行子代理探索多种 interface

用户想为选定的深化候选探索多种 interface 时，用本模式。源自 Ousterhout 的「Design It Twice」：你的第一个想法很少是最好的。

前置：先读 [SKILL.md](../SKILL.md) 的术语表与 [deepening.md](deepening.md) 的依赖四分类。

## 流程

### 1. 框定问题空间

派子代理之前，先写一份面向用户的问题空间说明：

- 任何新 interface 都必须满足的约束
- 它将依赖什么，各属于哪个依赖类别（见 deepening.md）
- 一段示意性代码草图，把约束落到具体——不是提案，只是让约束可感

呈现给用户后**立即**进入第 2 步：用户阅读思考的同时，子代理已在并行工作。

### 2. 派子代理

用 Agent 工具**并行**派 3 个以上子代理，每个必须产出**截然不同**的 interface。

给每个子代理一份独立的技术简报（文件路径、耦合细节、依赖类别、seam 后面放什么），并各带一条不同的设计约束：

- 代理 1：「最小化 interface——至多 1-3 个入口，每入口 leverage 最大化。」
- 代理 2：「最大化灵活性——支持多种用例与扩展。」
- 代理 3：「为最常见的调用者优化——默认场景做到零思考。」
- 代理 4（如适用）：「跨 seam 依赖按 ports & adapters 设计。」

简报中同时给出本 skill 的架构词汇与项目 CONTEXT.md 的领域词汇，保证各代理命名一致。

每个子代理产出：

1. Interface（类型、方法、参数——外加不变量、顺序约束、错误模式）
2. 用法示例（调用者视角）
3. implementation 在 seam 后面藏了什么
4. 依赖策略与 adapter（对照 deepening.md）
5. 权衡——leverage 厚在哪、薄在哪

### 3. 呈现与对比

设计逐个呈现（让用户逐个消化），再用散文对比：按 **depth**（interface 处的 leverage）、**locality**（修改集中在哪）、**seam 位置**三个维度。

对比后给出你自己的推荐：哪个最强、为什么。不同设计的元素能组合时，提混合方案。**要有立场——用户要的是强判断，不是菜单。**

---
> 内化自 mattpocock/skills 的 `skills/engineering/codebase-design/DESIGN-IT-TWICE.md`（2026-07-03）。
```

- [ ] **Step 5: 校验 + 自检**

```bash
python3 -m json.tool plugins/engineering/.claude-plugin/plugin.json > /dev/null && echo "plugin.json OK"
ls plugins/engineering/skills/design-rules/ plugins/engineering/skills/design-rules/references/
```
Expected: `plugin.json OK`；目录列出 `SKILL.md references`，references 列出 `deepening.md design-it-twice.md`。

写作指南自检（`docs/skill写作指南.md`）：逐行 no-op 测试；对照五失败模式；确认三处 name 一致（目录 `design-rules`、frontmatter `name: design-rules`、`/engineering:design-rules`）；确认原版判据无遗漏（对照 spec「design-rules」节的清单：七术语、深浅图、四原则、可测试性三规则、术语关系、rejected framings）。

- [ ] **Step 6: Commit**

```bash
git add plugins/engineering/
git commit -m "feat(engineering): 新增 engineering plugin 与 design-rules 词汇库 skill

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 2: domain-modeling skill

**Files:**
- Create: `plugins/engineering/skills/domain-modeling/SKILL.md`
- Create: `plugins/engineering/skills/domain-modeling/references/context-format.md`
- Create: `plugins/engineering/skills/domain-modeling/references/adr-format.md`

**Interfaces:**
- Consumes: 无（不引用其他 skill；ADR/CONTEXT 格式自含在本 skill 的 references）。
- Produces: `../domain-modeling/SKILL.md`（Task 3/4 的 SKILL.md 按此相对路径指路）。

- [ ] **Step 1: 写 domain-modeling/SKILL.md**

写入 `plugins/engineering/skills/domain-modeling/SKILL.md`：

```markdown
---
name: domain-modeling
description: 领域建模：挑战冲突术语、锐化模糊词、术语当场落笔进 CONTEXT.md，按三条件门槛记 ADR。仅当用户主动用 `/engineering:domain-modeling` 指令调用、或其他 skill 显式指路时使用。
allowed-tools: Read, Grep, Glob, Edit, Write, AskUserQuestion
disable-model-invocation: true
---

# domain-modeling — 术语当场落笔

## 用途

在设计过程中**主动**打磨项目的领域模型：挑战术语、编造边界场景、词汇和决策一敲定立刻写下来。只是*读* CONTEXT.md 查词不算本 skill——那是任何 skill 一句话就能做的习惯。本 skill 用于**改**模型，不是消费模型。

## 文件结构

多数仓库单 context：根目录一个 `CONTEXT.md`（领域词汇表）+ `docs/adr/`（决策记录）。根目录存在 `CONTEXT-MAP.md` 则是多 context 仓库，按 map 找各 context 的位置。格式细节见 [references/context-format.md](references/context-format.md)。

**文件惰性创建**——有东西要写才建：第一个术语敲定时建 CONTEXT.md，第一条 ADR 要记时建 docs/adr/。

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
```

- [ ] **Step 2: 写 references/context-format.md**

写入 `plugins/engineering/skills/domain-modeling/references/context-format.md`：

````markdown
# CONTEXT.md 格式

## 结构

```md
# {Context 名}

{一两句：这个 context 是什么、为何存在。}

## Language

**Order**：
{一两句术语定义}
_避免_：Purchase、transaction

**Invoice**：
交付后向客户发出的付款请求。
_避免_：Bill、payment request
```

## 规则

- **有立场。** 同一概念有多个词时，选定最好的那个，其余列进 `_避免_`。
- **定义收紧。** 至多一两句。定义它**是什么**，不是它做什么。
- **只收本项目特有的概念。** 通用编程概念（超时、错误类型、工具模式）再高频也不收。加词前自问：这是本 context 独有的概念，还是通用编程概念？只有前者进词汇表。
- **自然聚类才分组。** 术语自然成簇时加子标题；全部同属一块时平铺即可。

## 单 context vs 多 context

**单 context（多数仓库）**：根目录一个 `CONTEXT.md`。

**多 context**：根目录 `CONTEXT-MAP.md` 列出各 context 的位置与相互关系：

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) —— 接收与跟踪客户订单
- [Billing](./src/billing/CONTEXT.md) —— 生成发票与处理支付
- [Fulfillment](./src/fulfillment/CONTEXT.md) —— 管理仓库拣货与发运

## Relationships

- **Ordering → Fulfillment**：Ordering 发出 `OrderPlaced` 事件；Fulfillment 消费后开始拣货
- **Fulfillment → Billing**：Fulfillment 发出 `ShipmentDispatched` 事件；Billing 消费后生成发票
- **Ordering ↔ Billing**：共享 `CustomerId` 与 `Money` 类型
```

推断规则：有 `CONTEXT-MAP.md` 按 map 找；只有根 `CONTEXT.md` 即单 context；都没有则第一个术语敲定时惰性创建根 `CONTEXT.md`。多 context 时推断当前话题属于哪个 context；不明确就问。

---
> 内化自 mattpocock/skills 的 `skills/engineering/domain-modeling/CONTEXT-FORMAT.md`（2026-07-03）。
````

- [ ] **Step 3: 写 references/adr-format.md**

写入 `plugins/engineering/skills/domain-modeling/references/adr-format.md`：

````markdown
# ADR 格式

ADR 存放于 `docs/adr/`，顺序编号：`0001-slug.md`、`0002-slug.md`……目录惰性创建——第一条 ADR 要记时才建。编号规则：扫描现有最大号 +1。

## 模板

```md
# {决策短标题}

{1-3 句：背景是什么、决定了什么、为什么。}
```

就这么多。一条 ADR 可以只有一段话——价值在于记下**做过这个决定**和**为什么**，不在于填满章节。

## 可选节（多数 ADR 不需要）

- **Status** frontmatter（`proposed | accepted | deprecated | superseded by ADR-NNNN`）——决策会被重访时才有用
- **Considered Options**——被否决的备选值得记住时才写
- **Consequences**——有不显然的下游影响需要点明时才写

## 何时提议 ADR：三条件齐备

1. **难逆**——反悔成本是实打实的
2. **无上下文会困惑**——未来读者会看着代码想「当年为什么这么干？」
3. **真实取舍**——有真的备选项，为具体理由选了这个

易逆的决策直接跳过——要反悔就反悔了。不令人意外的没人会问为什么。没有真备选的，除了「我们做了显然的事」没什么可记。

## 够格的决策

- **架构形态。**「用 monorepo。」「写模型 event-sourced，读模型投影进 Postgres。」
- **Context 间的集成模式。**「Ordering 和 Billing 走领域事件，不走同步 HTTP。」
- **带锁定的技术选型。** 数据库、消息总线、认证服务商、部署目标。不是每个库都算——只算换掉要一个季度的那种。
- **边界与归属。**「客户数据归 Customer context 所有；其他 context 只按 ID 引用。」明确的「不做」和「做」一样有价值。
- **刻意偏离显然路径。**「不用 ORM 用手写 SQL，因为 X。」凡是理性读者会假设相反的地方。这能拦住下一个工程师去「修复」故意为之的设计。
- **代码里看不见的约束。**「因合规不能用 AWS。」「响应必须 200ms 内，合作方 API 合同要求。」
- **否决理由不显然的备选方案。** 考虑过 GraphQL、因微妙理由选了 REST——记下来，否则半年后有人再提。

---
> 内化自 mattpocock/skills 的 `skills/engineering/domain-modeling/ADR-FORMAT.md`（2026-07-03）。
````

- [ ] **Step 4: 自检**

写作指南自检：逐行 no-op 测试；五失败模式对照；三处 name 一致（`domain-modeling`）；SKILL.md 内不复述 references 里的格式明细（单一真相源：格式只在 references，SKILL.md 只指路）。

```bash
ls plugins/engineering/skills/domain-modeling/ plugins/engineering/skills/domain-modeling/references/
```
Expected: `SKILL.md references`；`adr-format.md context-format.md`。

- [ ] **Step 5: Commit**

```bash
git add plugins/engineering/skills/domain-modeling/
git commit -m "feat(engineering): domain-modeling skill（CONTEXT.md 词汇表 + ADR 三条件门槛）

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 3: grilling skill

**Files:**
- Create: `plugins/engineering/skills/grilling/SKILL.md`

**Interfaces:**
- Consumes: `../design-rules/SKILL.md`、`../design-rules/references/deepening.md`、`../design-rules/references/design-it-twice.md`（Task 1）；`../domain-modeling/SKILL.md`（Task 2）。
- Produces: `../grilling/SKILL.md`（Task 4 第三阶段按此路径指路）。

- [ ] **Step 1: 写 grilling/SKILL.md**

写入 `plugins/engineering/skills/grilling/SKILL.md`：

```markdown
---
name: grilling
description: 对选定的深化候选走设计树拷问：约束 → seam 位置 → interface 形状 → 藏什么 → 哪些测试存活，收敛出 interface 草图。仅当用户主动用 `/engineering:grilling` 指令调用、或 improve-arch 第三阶段显式指路时使用。
allowed-tools: Read, Grep, Glob, AskUserQuestion
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
```

- [ ] **Step 2: 自检 + 引用路径检查**

写作指南自检：逐行 no-op 测试；五失败模式对照；三处 name 一致（`grilling`）；与 `project:grill` 的分工在「用途」一句话说清（评审已成形方案 vs 收敛待设计深化）。

```bash
cd plugins/engineering/skills/grilling && ls ../design-rules/SKILL.md ../design-rules/references/deepening.md ../design-rules/references/design-it-twice.md ../domain-modeling/SKILL.md && cd -
```
Expected: 四个路径全部存在（正文里的相对引用可达）。

- [ ] **Step 3: Commit**

```bash
git add plugins/engineering/skills/grilling/
git commit -m "feat(engineering): grilling skill（走设计树，收敛 interface 草图）

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 4: improve-arch skill（编排入口）

**Files:**
- Create: `plugins/engineering/skills/improve-arch/SKILL.md`
- Create: `plugins/engineering/skills/improve-arch/references/html-report.md`

**Interfaces:**
- Consumes: `../design-rules/SKILL.md`、`../design-rules/references/design-it-twice.md`（Task 1）；`../domain-modeling/SKILL.md`（Task 2）；`../grilling/SKILL.md`（Task 3）。
- Produces: `/engineering:improve-arch` 完整三阶段流程。

- [ ] **Step 1: 写 improve-arch/SKILL.md**

写入 `plugins/engineering/skills/improve-arch/SKILL.md`：

```markdown
---
name: improve-arch
description: 扫描代码库找深化机会（shallow → deep），以可视化 HTML 报告呈现候选项，用户选定后走设计树拷问。仅当用户主动用 `/engineering:improve-arch` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Bash, Write, Agent, AskUserQuestion
disable-model-invocation: true
---

# improve-arch — 深化机会

## 用途

浮出架构摩擦，提出**深化机会**——把 shallow module 重构成 deep module 的候选项。目标是可测试性与 AI 可导航性。三阶段：探索 → HTML 报告 → 拷问。

## 前置

1. Read `../design-rules/SKILL.md` 装载词汇与判据——每条建议都用它的术语，一个词不许漂移。
2. 读项目根 `CONTEXT.md`（领域词汇表）与 `docs/adr/`（已定决策）——领域名词用 CONTEXT.md 的，ADR 记录的决策不重新争论。两者不存在则跳过，不报错、不创建。

## 阶段一：探索

用 Agent 工具（subagent_type=Explore）走查代码库。不跟僵硬的启发式——有机探索，记录你在哪里感到摩擦：

- 理解一个概念要在多个小 module 间来回跳？
- 哪里 shallow——interface 几乎和 implementation 一样复杂？
- 哪里为了可测试性抽出了纯函数，但真正的 bug 藏在调用它们的地方（没有 locality）？
- 哪里紧耦合的 module 泄漏跨过 seam？
- 哪些部分没有测试，或透过现有 interface 很难测？

对每个疑似 shallow 的地方做**删除测试**：删掉它，复杂度是集中还是搬家？「会集中」才是你要的信号。

完成标准：每个候选项（1）通过删除测试——答案是「复杂度会集中」；（2）能指出具体文件。说不出文件的候选丢弃。

## 阶段二：HTML 报告

按 [references/html-report.md](references/html-report.md) 写一份自包含 HTML 到 OS 临时目录（`$TMPDIR`，无则 `/tmp`；Windows 用 `%TEMP%`；文件名 `architecture-review-<时间戳>.html`），不落仓库。写完自动打开（Linux `xdg-open`、macOS `open`、Windows `start`）并告知用户绝对路径。

每个候选项一张卡片：Title、徽章行（推荐强度 + 依赖类别）、Files、before/after 图（居中件）、Problem 一句、Solution 一句、Wins 列表、ADR 冲突警示（如适用）。报告末尾必有 **Top recommendation**：先做哪个、为什么。

- **领域名词用 CONTEXT.md 的，架构名词用 design-rules 的。** CONTEXT.md 定义了 Order，就说「Order intake module」——不说「FooBarHandler」，也不说「Order service」。
- **ADR 冲突**：候选与现有 ADR 相抵时，只有摩擦真实到值得重开决策才列出，并在卡片上明确标注（amber 警示框：「与 ADR-0007 相抵——但值得重开，因为……」）。别把 ADR 禁止的理论重构全列一遍。

完成标准：Wins 用 locality / leverage 措辞（禁「更易维护」「更干净」）；每卡有 before/after 图；末尾有 Top recommendation。

**本阶段不许提 interface 设计。** 报告写完只问一句：「想探索哪一个？」

## 阶段三：拷问

用户选定候选后，按 `../grilling/SKILL.md` 走设计树：约束、seam 位置、interface 形状、seam 后面藏什么、哪些测试存活。

决策晶化时副作用当场发生，按 `../domain-modeling/SKILL.md` 落笔：

- 深化后的 module 要用 CONTEXT.md 里没有的概念命名？把词加进 CONTEXT.md（文件不存在则惰性创建）。
- 对话中锐化了某个模糊术语？当场更新 CONTEXT.md。
- 用户以承重理由否决候选？提议记 ADR：「要不要记成 ADR，免得未来的架构审查再提同一个建议？」——只在理由真会被未来的探索者需要时才提；短暂性理由（「现在不值得」）和不言自明的理由跳过。
- 想为深化后的 module 探索多种 interface？走 `../design-rules/references/design-it-twice.md` 的并行子代理模式。

---
> 内化自 mattpocock/skills 的 `skills/engineering/improve-codebase-architecture`（2026-07-03）。
```

- [ ] **Step 2: 写 references/html-report.md**

写入 `plugins/engineering/skills/improve-arch/references/html-report.md`：

````markdown
# HTML 报告格式

架构审查渲染为单个自包含 HTML 文件，写 OS 临时目录。Tailwind 与 Mermaid 都走 CDN。图形关系（依赖、调用流、时序）用 Mermaid 稳；更编辑感的视觉（mass diagram、cross-section）用手搭 div / 内联 SVG。两者混用——全靠 Mermaid 会千篇一律。

安全边界：本报告是写进临时目录的本地一次性文件，不部署、不分发。两个 CDN 脚本（Tailwind Play CDN、mermaid@11）都是动态/浮动版本内容，无稳定哈希可钉 SRI——接受此取舍，代价是报告须仅限本地查看，**不要**把它发布到任何线上环境。

## 脚手架

```html
<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8" />
    <title>架构审查 — {{仓库名}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* Tailwind 不好覆盖的小自定义层：seam 虚线、泄漏红、deep 深底 */
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## 头部

仓库名、日期、紧凑图例：实线框 = module、虚线 = seam、红箭头 = 泄漏、厚深框 = deep module。没有引言段——直接进候选项。

## 候选卡片

**图承担重量，散文克制**，术语直接用 design-rules 词汇表的，不加铺垫。每个候选一个 `<article>`：

- **Title** —— 短，直接命名这次深化（如「折叠 Order intake 管线」）。
- **徽章行** —— 推荐强度（`Strong` = emerald、`Worth exploring` = amber、`Speculative` = slate）+ 依赖类别 tag（`in-process`、`local-substitutable`、`ports & adapters`、`mock`）。
- **Files** —— 等宽字体清单，`font-mono text-sm`。
- **Before / After 图** —— 居中件，两栏并排。图型见下。
- **Problem** —— 一句。哪里疼。
- **Solution** —— 一句。改什么。
- **Wins** —— 列表，每条 ≤6 个词。如「测试只打一个 interface」「Pricing 不再泄漏」「删 4 个 shallow 包装」。
- **ADR 警示**（如适用）—— amber 底一行。

不写解释段。图需要一段话才能看懂，就重画图。

## 图型（五种，混用别单调）

### Mermaid graph（依赖 / 调用流的主力）

要点是「X 调 Y 调 Z，看这团乱」时用 Mermaid `flowchart`。包进 Tailwind 卡片，别让它像空投进来的。classDef 把泄漏边标红、deep module 标深。时序图适合「before：6 次往返；after：1 次」。

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
  </pre>
</div>
```

### 手搭 boxes-and-arrows（Mermaid 排版打架时）

module 用带边框的 `<div>`，箭头用绝对定位在 relative 容器上的内联 SVG `<line>`/`<path>`。想让 after 图呈现「一个厚边框 deep module、内部构件灰化」的分量感时用——Mermaid 画不出那个分量。

### Cross-section（层层皆薄时）

横向条带（`h-12 border-l-4`）堆叠，展示一次调用穿过的层。before：6 条薄层各自啥也不干。after：1 条厚带，标注合并后的职责。

### Mass diagram（interface 跟 implementation 一样宽时）

每个 module 画两个矩形：interface 表面积一个、implementation 一个。before：interface 矩形几乎和 implementation 一样高（shallow）。after：interface 矮、implementation 高（deep）。

### Call-graph collapse

before：函数调用树画成嵌套盒子。after：同一棵树折叠进一个盒子，已内化的调用在盒内淡化显示。

## 风格

- 编辑感，不要企业仪表盘感。留白慷慨。标题可用衬线（`font-serif` 配 stone/slate 好看）。
- 用色克制：一个强调色（emerald 或 indigo）+ 泄漏红 + 警示 amber。
- 图高约 320px，保证 before/after 并排不出滚动条。
- 图内 module 标签用 `text-xs uppercase tracking-wider`——读起来像示意图，不像 UI。
- 脚本只有 Tailwind CDN 和 Mermaid ESM 两个。其余全静态——没有应用代码，没有 Mermaid 渲染之外的交互。

## Top recommendation

一张更大的卡。候选名、一句为什么、锚链到对应卡片。就这些。

## 措辞

散文平实简洁——但架构名词动词一律来自 design-rules 词汇表。简洁不是漂移的借口。

**只用**：module、interface、implementation、depth、deep、shallow、seam、adapter、leverage、locality。

**永不替换**：component、service、unit（指 module 时）· API、signature（指 interface 时）· boundary（指 seam 时）· layer、wrapper（其实指 module 时）。

**合调的句式**：

- 「Order intake module 是 shallow 的——interface 几乎等于 implementation。」
- 「Pricing 泄漏跨过 seam。」
- 「深化：一个 interface，一处测试。」
- 「两个 adapter 撑起这条 seam：生产 HTTP、测试内存。」

**Wins 用词汇表词命名收益**：「locality：bug 集中到一个 module」「leverage：一个 interface，N 个调用点」「interface 收窄；implementation 吸收包装层」。不写「更易维护」「代码更干净」——这些词不在词汇表里，挣不到位置。

不套话、不清嗓、不写「值得注意的是」。能当列表项的句子就当列表项。能删的列表项就删。词汇表里找不到的词，先在表里找替代，再考虑造新词。

---
> 内化自 mattpocock/skills 的 `skills/engineering/improve-codebase-architecture/HTML-REPORT.md`（2026-07-03）。
````

- [ ] **Step 3: 自检 + 引用路径检查**

写作指南自检：逐行 no-op 测试；五失败模式对照；三处 name 一致（`improve-arch`）；单一真相源核对——报告的卡片字段/图型/措辞明细只在 html-report.md，SKILL.md 阶段二只留字段清单与完成标准，不复述图型与样式。

```bash
cd plugins/engineering/skills/improve-arch && ls ../design-rules/SKILL.md ../design-rules/references/design-it-twice.md ../grilling/SKILL.md ../domain-modeling/SKILL.md references/html-report.md && cd -
```
Expected: 五个路径全部存在。

- [ ] **Step 4: Commit**

```bash
git add plugins/engineering/skills/improve-arch/
git commit -m "feat(engineering): improve-arch skill（探索→HTML 报告→拷问三阶段编排入口）

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 5: marketplace + README 登记 + 终验 + push

**Files:**
- Modify: `.claude-plugin/marketplace.json`（plugins 数组追加 engineering）
- Modify: `README.md`（分类表、安装示例、调用示例、目录树）

**Interfaces:**
- Consumes: Task 1–4 的全部产物。

- [ ] **Step 1: marketplace.json 追加登记**

在 `.claude-plugin/marketplace.json` 的 `plugins` 数组末尾（`support` 条目之后）追加：

```json
    {
      "name": "engineering",
      "source": "./plugins/engineering",
      "description": "代码库架构设计相关 skill（深模块方法论）"
    }
```

- [ ] **Step 2: 更新 README**

四处修改：

1. 「当前分类（plugin）」表末尾加一行：

```markdown
| `engineering` | 代码库架构设计相关 skill（深模块方法论） |
```

2. 「安装」代码块 `support` 行后加：

```
/plugin install engineering@jljskills
```

3. 「调用」节示例末尾追加 `/engineering:improve-arch`、`/engineering:design-rules`。

4. 「目录结构」树的 `support` 段之后（保持缩进与现有树一致）追加：

```
    └── engineering/
        ├── .claude-plugin/plugin.json
        └── skills/
            ├── design-rules/          # 深模块词汇库与判据(供其他 skill 指路引用)
            │   ├── SKILL.md
            │   └── references/        # deepening.md + design-it-twice.md
            ├── improve-arch/          # 扫描深化机会→HTML 报告→拷问(编排入口)
            │   ├── SKILL.md
            │   └── references/html-report.md
            ├── grilling/              # 走设计树,收敛 interface 草图
            │   └── SKILL.md
            └── domain-modeling/       # 领域词汇表 CONTEXT.md + ADR
                ├── SKILL.md
                └── references/        # context-format.md + adr-format.md
```

注意：原树中 `support` 段是最后一个分支（`└──`），追加 engineering 后需把 `support` 的 `└──` 改为 `├──`（含其下竖线延续），engineering 用 `└──`。

- [ ] **Step 3: 终验**

```bash
python3 -m json.tool .claude-plugin/marketplace.json > /dev/null && echo "marketplace OK"
python3 -m json.tool plugins/engineering/.claude-plugin/plugin.json > /dev/null && echo "plugin OK"
# 三处 name 一致 + 目录扁平
grep -h '^name:' plugins/engineering/skills/*/SKILL.md
ls plugins/engineering/skills/
# 全部相对引用可达（在每个 skill 目录下核对正文里出现的 ../ 路径）
cd plugins/engineering/skills/grilling && ls ../design-rules/SKILL.md ../design-rules/references/deepening.md ../design-rules/references/design-it-twice.md ../domain-modeling/SKILL.md && cd -
cd plugins/engineering/skills/improve-arch && ls ../design-rules/SKILL.md ../design-rules/references/design-it-twice.md ../grilling/SKILL.md ../domain-modeling/SKILL.md references/html-report.md && cd -
```
Expected: 两个 `OK`；`grep` 输出四行 name 与目录名一一对应（design-rules / domain-modeling / grilling / improve-arch）；`ls` 列出恰好四个 skill 目录；所有相对路径存在。

- [ ] **Step 4: Commit & push**

```bash
git add .claude-plugin/marketplace.json README.md
git commit -m "docs: marketplace 与 README 登记 engineering plugin

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
git push
```

- [ ] **Step 5: 冒烟（用户侧手工步骤，告知即可）**

计划执行者无法调用用户级 `/plugin` 指令，向用户说明冒烟步骤：`/plugin marketplace update` 后安装 `engineering@jljskills`，在任一代码仓库跑 `/engineering:improve-arch`，验证：三阶段指路可达、HTML 报告生成并自动打开、报告术语无漂移。
