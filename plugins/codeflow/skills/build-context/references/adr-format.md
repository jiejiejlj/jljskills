# ADR 格式

ADR 存放于 `docs/jljskills/codeflow/adr/`，顺序编号：`0001-slug.md`、`0002-slug.md`……目录惰性创建——第一条 ADR 要记时才建。编号规则：扫描现有最大号 +1。多 context 仓库的 ADR 也集中在此目录：属特定 context 的在文件名加 context 前缀（如 `0007-ordering-事件溯源.md`）。

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

## 何时提议 ADR

三条件门槛（难逆 / 无上下文会困惑 / 真实取舍）的判据正文见 [`../../design-domain-model/SKILL.md`](../../design-domain-model/SKILL.md)——本文只管过了门槛之后怎么写。

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
