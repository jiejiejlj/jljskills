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

**单 context（多数仓库）**：`docs/jljskills/codeflow/CONTEXT.md`。

**多 context**：`docs/jljskills/codeflow/CONTEXT-MAP.md` 列出各 context 的位置与相互关系；各 context 词汇表集中放同目录 `contexts/<名>.md`，不随代码目录分散：

```md
# Context Map

## Contexts

- [Ordering](./contexts/ordering.md) —— 接收与跟踪客户订单
- [Billing](./contexts/billing.md) —— 生成发票与处理支付
- [Fulfillment](./contexts/fulfillment.md) —— 管理仓库拣货与发运

## Relationships

- **Ordering → Fulfillment**：Ordering 发出 `OrderPlaced` 事件；Fulfillment 消费后开始拣货
- **Fulfillment → Billing**：Fulfillment 发出 `ShipmentDispatched` 事件；Billing 消费后生成发票
- **Ordering ↔ Billing**：共享 `CustomerId` 与 `Money` 类型
```

推断规则：有 `CONTEXT-MAP.md` 按 map 找；只有 `CONTEXT.md` 即单 context；都没有则第一个术语敲定时惰性创建 `docs/jljskills/codeflow/CONTEXT.md`。多 context 时推断当前话题属于哪个 context；不明确就问。

---
> 内化自 mattpocock/skills 的 `skills/engineering/domain-modeling/CONTEXT-FORMAT.md`（2026-07-03）。
