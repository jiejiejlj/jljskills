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
