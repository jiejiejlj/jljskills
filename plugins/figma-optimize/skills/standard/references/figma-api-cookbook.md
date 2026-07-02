# Figma API 配方(standard 向)

`standard` 评审设计规范板本身时用到的 Figma Plugin API 配方,按「读 / 审计」「写回」「纪律」分组。所有 `use_figma` 调用**前必先走 `figma-use` skill**。

## 读 / 审计

- **读全量体系(P1)**:
  - `figma.variables.getLocalVariableCollectionsAsync()` —— 取全部变量集合(色板 / 字阶 / 间距 / 圆角等分类),用于 S-A 完整性审计。
  - `figma.variables.getLocalVariablesAsync()` —— 取全量变量。
  - `figma.getLocalTextStylesAsync()` —— 取全量 text styles,用于 S-D 字阶 & 字体标准审计。
  - 三者配合拿到规范板的完整 token 体系,是本次评审的**审计对象**(不是像 page 那样当参照标准)。
- **取变量解析值**:
  ```js
  const variable = await figma.variables.getVariableByIdAsync(id);
  const resolved = variable.valuesByMode; // 按 mode(如 light/dark)取实际解析值
  ```
  用于 S-A2(集合分组 / mode 是否完整)与 S-E(比对解析值找近似重复)。
- **辨 token vs 裸色(S-B 核心,库变量误判坑)**:
  ```js
  const bound = fillsNode.fills[0]?.boundVariables;
  // 有 boundVariables.color → 已绑定变量(已 token 化)
  // 无 boundVariables → 才是真正的游离裸值,计入 S-B1
  ```
  `get_variable_defs` 会把**库变量(跨文件引用)**显示成「名 = 值」的裸 hex,极易被误判为硬编码——凡是审计 token 化程度,一律以 `boundVariables` + `getVariableByIdAsync` 为准,不要只看 `get_variable_defs` 的展示数值。
- **快览**:`get_variable_defs` 仅用于对规范板做一次性快速浏览,定位可能有问题的区域,**不作为审计结论依据**。
- **命名遍历**:遍历 `variable.name`(及所在集合名),用于 S-C1(语义 / 层级)与 S-C2(风格一致性)。
- **字体标准审计**:遍历 text styles 的 `style.fontName`(family/style)与 `hasMissingFont`,用于 S-D2(非标字体混入 / 缺失字体)。

## 写回

- **变量重命名**:
  ```js
  variable.name = '新的语义化名称'; // 解决 S-C1 / S-C2
  ```
- **绑定变量(修复 S-B1 游离裸值)**:
  ```js
  const newPaint = figma.variables.setBoundVariableForPaint(paint, 'color', variable);
  node.fills = [newPaint]; // 该 API 返回新 paint 对象,必须重新赋值给 node.fills,不能原地修改
  ```
- **收敛近似 token(修复 S-E1)**:
  1. 确认要保留的「主 token」与要合并掉的「冗余 token」。
  2. 找出所有引用冗余 token 的节点 / 样式,逐个改绑为主 token(见上「绑定变量」)。
  3. 确认无引用后再删除冗余变量,避免留下悬空引用。
- **跨集合 / 跨页操作只切一次页**:若写回涉及多个页面,批次开头 `await figma.setCurrentPageAsync(targetPage)` 一次,不在循环内反复切换。

## 纪律

- **增量小步**:每次只改一个变量 / 一小类,不要一次性大批量改动。
- **每步 `get_screenshot` 校验**:每处改完立即截图确认符合预期,再进行下一处。
- **`use_figma` 原子性**:单次调用内的多个改动要么都成功要么都失败——据此设计脚本边界,避免把互不相关的改动塞进同一批。
- **写回前逐条 HARD GATE 确认**:任何写入 Figma 的动作,必须是用户已在 P3/P4 明确裁定「让 AI 改」之后才能执行,未确认不得动手。
