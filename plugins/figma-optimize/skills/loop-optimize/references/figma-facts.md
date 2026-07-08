# figma-facts — 共享 Figma API 判据 (地基)

## 用途

figma-optimize 的单一真相源: 各阶段共用的 Figma Plugin API 判据与写回纪律. 各 stage flow 在 P1 以硬性步骤 Read 本文件装载; 判据正文只存这里, 各 flow 只留指针, 不复述. 阶段专属配方 (字体归正, 收敛 token, 组件化写回等) 仍在各阶段的 `stages/<type>/cookbook.md`.

## 库变量误判坑 (token 化审计核心判据)

- `get_variable_defs` 是**展示层快览工具**, 会把**库变量 (跨文件引用的共享变量)** 摊平显示成 "名 = 值" 的裸 hex, 数值上与真正的硬编码裸色**长得一模一样** — 仅用于快速浏览与定位, **不作为审计结论依据**.
- 判断是否已 token 化, 唯一可靠依据是节点 / 样式属性上的 `boundVariables`:

  ```js
  const bound = fillsNode.fills[0]?.boundVariables;
  // 有 boundVariables.color（或对应属性）→ 已绑定变量（已 token 化）
  // 无 boundVariables → 才是真正的硬编码 / 游离裸值
  ```

- 需核实变量本身的解析值 (如按 mode 取浅色 / 深色下的具体色值): `await figma.variables.getVariableByIdAsync(id)` 取到变量对象后读 `.valuesByMode`.
- 一律不要仅凭 `get_variable_defs` 的展示值下 "硬编码" 结论. (该裸值计入哪个清单编号, 由各阶段的 checklist 规定.)

## 读全量 token 体系 (三源 API)

- `figma.variables.getLocalVariableCollectionsAsync()` — 变量集合 (色板 / 字阶 / 间距 / 圆角等分类).
- `figma.variables.getLocalVariablesAsync()` — 全量变量 (含各 mode 值).
- `figma.getLocalTextStylesAsync()` — 全量 text styles (字阶).

三者配合拿到完整 token 体系; 把它当**参照标准**还是**审计对象**, 由各阶段的 flow 定位.

## 写回通用坑

- `setBoundVariableForPaint` 返回的是**新 paint 对象**, 必须重新赋值, 不能原地修改:

  ```js
  const newPaint = figma.variables.setBoundVariableForPaint(paint, 'color', variable);
  node.fills = [newPaint];
  ```

- 写回不在当前页的节点前必须 `await figma.setCurrentPageAsync(targetPage)`; 同一批动作只在批次开头切一次页, **不在循环内反复切换**.

## 写回批次纪律 (use_figma 侧, 所有读写回合通用)

1. **增量小步**: 每次只改一小块 / 一个属性 / 一个变量, 不一次性大批量改动.
2. **`use_figma` 原子性**: 单次调用内的多个改动要么都成功要么都失败 (如字体加载失败导致整批回滚) — 据此设计脚本边界, 不把互不相关的改动塞进同一批.

> 逐步 `get_screenshot` 校验与写回前逐条 HARD GATE 属全阶段通用红线 — 见 SKILL.md 红线 ①, 此处不复述.
