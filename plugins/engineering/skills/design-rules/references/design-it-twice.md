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
