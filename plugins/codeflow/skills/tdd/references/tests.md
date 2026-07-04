# 好测试与坏测试

## 好测试

**集成式**：透过真实 interface 测试，不 mock 内部部件。

```typescript
// 好：测可观察行为
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

特征：

- 测的是调用者/用户在意的行为
- 只用 public interface
- 内部重构后依然存活
- 描述「做什么」而非「怎么做」
- 一个测试一条逻辑断言

## 坏测试

**实现细节测试**：与内部结构耦合。

```typescript
// 坏：测实现细节
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

红旗信号：

- mock 内部协作者
- 测私有方法
- 断言调用次数/调用顺序
- 行为没变，重构就红
- 测试名描述「怎么做」而非「做什么」
- 绕开 interface、走外部手段验证

```typescript
// 坏：绕过 interface 去验证
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// 好：透过 interface 验证
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

**同义反复测试**：期望值复述了实现本身，测试因此天然通过。

```typescript
// 坏：期望值按代码同样的方式重算出来
test("calculateTotal sums line items", () => {
  const items = [{ price: 10 }, { price: 5 }];
  const expected = items.reduce((sum, i) => sum + i.price, 0);
  expect(calculateTotal(items)).toBe(expected);
});

// 好：期望值是独立的已知字面量
test("calculateTotal sums line items", () => {
  expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);
});
```
