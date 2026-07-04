# 何时 mock

只在**系统边界**处 mock：

- 外部 API（支付、邮件等）
- 数据库（有时——优先用测试库）
- 时间/随机数
- 文件系统（有时）

不要 mock：

- 自己的类/模块
- 内部协作者
- 任何自己掌控的东西

## 为可 mock 性设计

在系统边界处，设计易 mock 的 interface：

**1. 用依赖注入**

外部依赖传进来，不要在内部自建：

```typescript
// Easy to mock
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Hard to mock
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

**2. 优先 SDK 式 interface，而非通用取数函数**

给每个外部操作建专门函数，而不是一个带条件分支的通用函数：

```typescript
// GOOD: Each function is independently mockable
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: data }),
};

// BAD: Mocking requires conditional logic inside the mock
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

SDK 式写法的好处：

- 每个 mock 只返回一种确定的形状
- 测试搭建里没有条件分支
- 一眼看出某个测试触达了哪些端点
- 每个端点各自有类型安全
