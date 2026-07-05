# figma-facts —— figma-optimize 共享判据单点化（interface 草图）

> 产自 `/engineering:improve-arch` 三阶段（2026-07-04）。本草图是交给实施会话的 seam，实施不在本次范围。

## 候选锚定

- **摩擦**：「库变量误判坑」判据沉积 6 处（`standard/SKILL.md`、双 `figma-api-cookbook.md`、`standard/references/checklist.md`、双 `references/flow.md`），措辞已漂移（page 版「以 `boundVariables` 为准」 vs standard 版「`boundVariables` + `getVariableByIdAsync`」）；双 cookbook 另有约 44 行逐字相同的 API 事实与纪律。
- **删除测试**：删任一副本规则不消失（其余兜底）——典型沉积；收敛后复杂度集中到单点。
- **依赖类别**：in-process（纯文档，同 plugin 内 Read，无 adapter、不开 port）。

## 各分支结论

| 分支 | 结论 |
|------|------|
| 约束 | 真相源必须住 figma-optimize 内（安装缓存按 `plugin/<hash>/` 隔离，跨 plugin 路径运行时不可解析；独立性红线）；`skills/` 必须扁平；两 skill `allowed-tools` 已含 Read；plugin 根文件会进缓存（engineering README 实证） |
| Seam 位置 | **新建 `skills/figma-facts/`**，与 design-rules 完全同构（用户选定：模式一致性优先于命令面精简；否决了 plugin 根 `references/` 与「住 page、standard 穿过去」两案） |
| Interface 形状 | **装载式**：判据正文只存 figma-facts；双 flow P1 加硬性 Read 步骤；SKILL 红线 / cookbook / checklist 全指针化，不留摘要 |
| 藏什么 | 吸收 7 项共享事实（见下）；skill 专属配方留在瘦身后的各自 cookbook |
| 测试存活 | 6 处冗余是旧的「漏读保险」——replace, don't layer：删保险，换硬性 Read 步骤 + grep 不变量 |

## Interface 草图

**Module**：`plugins/figma-optimize/skills/figma-facts/SKILL.md`

**Frontmatter（interface 声明）**：

```yaml
name: figma-facts
description: figma-optimize 的共享 Figma API 判据与写回纪律：库变量误判坑、
  setBoundVariableForPaint 重赋值、解析值读取、批次纪律四条。仅当 page /
  standard 的流程显式指路 Read 本文件、或用户主动用
  `/figma-optimize:figma-facts` 把判据装进当前会话时使用。
allowed-tools: Read
disable-model-invocation: true
```

**入口**：单入口——整文件 Read。消费方不得只引某一节（节名不成为第二 interface，内部结构可自由重排）。

**内容结构（implementation，7 项共享事实）**：

1. 库变量误判坑（权威合并版：`boundVariables` 辨绑定；需解析值时 `getVariableByIdAsync`。「计入 C1 / S-B1」的归档映射**不在此**——归各 skill checklist）
2. `get_variable_defs` 仅快览、不作审计结论依据
3. `getVariableByIdAsync` → `valuesByMode` 取解析值
4. `setBoundVariableForPaint` 返回新 paint、必须重赋 `node.fills`
5. 读全量 token 体系三源 API（`getLocalVariableCollectionsAsync` / `getLocalVariablesAsync` / `getLocalTextStylesAsync`；「当参照标准 vs 当审计对象」的语义定位留在各自 flow）
6. 跨页/批次只切一次 `setCurrentPageAsync`
7. 纪律四条：增量小步 / 每步 `get_screenshot` / `use_figma` 原子性 / 写回前 HARD GATE

**不变量**：

- 上述判据**正文**唯一存于本文件；6 个消费点只许指针或装载步骤。
- 可 grep 验证：`boundVariables` 的判据性论述在 `plugins/figma-optimize/` 下只命中 figma-facts。

**错误模式**：模型漏 Read → 双 flow P1 的硬性装载步骤兜底（与 improve-arch 前置 Read design-rules 同机制，已证可靠）。

**消费端改动清单（6 处）**：

| 文件 | 改动 |
|------|------|
| `page/references/flow.md` | P1 首条加「Read `../figma-facts/SKILL.md` 装载判据」；删 P1 内判据复述 |
| `standard/references/flow.md` | 同上 |
| `page/references/figma-api-cookbook.md` | 删「辨 token vs 裸色」「取变量解析值」「纪律」全节、跨页只切一次、`setBoundVariableForPaint` 条目；保留字体审计 / `loadFontAsync` 坑 / 组件化 / auto-layout 白底坑 |
| `standard/references/figma-api-cookbook.md` | 删对应重叠节；保留变量重命名 / 收敛近似 token / TextStyle 无 `hasMissingFont` 差异 |
| `standard/SKILL.md` | 红线中判据复述改一行指针 |
| `standard/references/checklist.md` | 判据行改指针 |

**保持不动**：「先走 figma-use」的一句话行为约束留在各 SKILL 红线（无正文可漂移，本身已是最小形式）。

## 实施会话核对项

- [ ] 建 `skills/figma-facts/SKILL.md`（上述 frontmatter + 7 项）
- [ ] 6 处消费端按清单收敛
- [ ] grep 不变量验证通过
- [ ] README.md 目录树 & 分类表同步（CLAUDE.md 三处登记规则）
- [ ] commit & push（滚动分发）
