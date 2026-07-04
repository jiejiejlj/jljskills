---
name: design-rules
description: 深模块设计的词汇库与判据：module/interface/implementation/depth/seam/adapter/leverage/locality 八术语、deep/shallow 模型、删除测试等四原则。仅当用户主动用 `/codeflow:design-rules` 指令调用、或其他 skill 显式指路 Read 本文件时使用。
allowed-tools: Read
disable-model-invocation: true
---

# design-rules — 深模块词汇与判据

## 用途

设计 **deep module**：大量行为藏在小 interface 后面，落在干净的 seam 上，可透过 interface 测试。本文是架构讨论的单一真相源——凡是设计或重构代码的场合，用这里的语言和判据。目标：给调用者 leverage，给维护者 locality，给所有人可测试性。

本 skill 是另外三个 skill 的共用地基，运行时被它们自动 Read 装载，通常不需要单独调用；单独 `/codeflow:design-rules` 只有一个场景——想在普通设计讨论里把这套语言装进当前会话。

（理论出处：John Ousterhout《软件设计的哲学》的深模块理论、Michael Feathers 的 seam 概念。）

## 术语表（八词，精确使用）

术语一律用英文原词——一致的语言是本 skill 的全部意义，禁用词一个不许漏进来。

**Module** —— 任何「有 interface + 有 implementation」的东西。刻意不限尺度：函数、类、包、跨层切片都算。_禁用_：unit、component、service；layer、wrapper（其实指 module 时）。

**Interface** —— 调用者正确使用一个 module 所需知道的**一切**：类型签名之外，还包括不变量、调用顺序约束、错误模式、必需配置、性能特征。_禁用_：API、signature（指 interface 时——都太窄，只指类型层面）。

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
