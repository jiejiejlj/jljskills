---
name: tdd
description: 红绿循环的规则手册：只在预先确认的 seam 上写测试、一次一片、三反模式禁区；红在绿前，重构不属于循环。仅当用户主动用 `/codeflow:tdd` 指令调用、或 implement 显式指路时使用。
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, AskUserQuestion
disable-model-invocation: true
---

# tdd — 红绿循环规则手册

## 用途

TDD 就是红 → 绿循环。本 skill 是让这个循环产出「值得留下的测试」的规则手册：好测试的标准、seam 怎么定、三条反模式、循环本身的纪律。每一节在每一轮循环里都要用——开工前和开工中都要对照，不是事后补课。

## 前置

- Read [`../design-rules/SKILL.md`](../design-rules/SKILL.md) 装载 seam / interface 词汇——本文全程用它的定义，不重新定义。
- 读目标项目 `docs/jljskills/codeflow/CONTEXT.md`（存在则读），让测试名和 interface 用词贴领域语言。
- 尊重涉及区域已记录的 ADR——已否决的方案不要在测试设计里悄悄复活。

## 好测试是什么

测试透过 public interface 验证行为，不碰实现细节。代码可以整体重写，测试不应该跟着变。好测试读起来像规格说明——「用户能用有效购物车结账」一句话就说清有什么能力——因为不关心内部结构，所以能在重构后存活。

正反例见 [references/tests.md](references/tests.md)。
mock 取舍见 [references/mocking.md](references/mocking.md)。

## Seam 预约

**只在预先与用户确认的 seam 上写测试。** 动笔前先列出待测的 seam，跟用户对齐；未经确认的 seam，一律不写测试。测不完所有东西——把测试精力提前圈定在关键路径和复杂逻辑上，而不是撒到每个边角，靠的就是这一步。

开工先问：「public interface 是什么，该测哪些 seam？」

## 三反模式

- **实现耦合**——mock 内部协作者、测私有方法、或走侧信道验证（绕过 interface 直接查数据库）。标志：行为没变，重构就红。
- **同义反复**——断言按实现同样的方式重算期望值（`expect(add(a, b)).toBe(a + b)`、手算的快照、常量断言等于自己），于是天然通过，永远不会跟代码意见相左。期望值必须来自独立真相源——已知正确的字面量、算好的例子、规格文档。
- **横切**——先写完全部测试再写全部实现。批量测试验证的是*想象中*的行为：测的是形状而非用户可见的行为，测试对真实改动变得不敏感，还没搞懂实现就先钉死了测试结构。改用**垂直切片**：一测试 → 一实现 → 循环，每个测试是一发**曳光弹**，根据上一轮循环学到的东西调整方向。

## 循环规则

- **红在绿前。** 先写失败的测试，再写刚好让它过的代码。不预支未来的测试，不加投机性功能。
- **一次一片。** 一个 seam、一个测试、一次最小实现，一轮循环只做这些。
- **重构不属于循环。** 归 `/codeflow:review` 阶段，不混进红 → 绿的实现循环。

---
> 内化自 mattpocock/skills 的 `skills/engineering/tdd`（2026-07-05）。
