# Figma API 配方(page 向)

`page` 评审界面稿时用到的 Figma Plugin API 配方,按「读 / 审计」「跨页」「写回」「纪律」分组。所有 `use_figma` 调用**前必先走 `figma-use` skill**。

## 读 / 审计

- **装载标准(P1 三源级联)**:
  - `figma.variables.getLocalVariableCollectionsAsync()` —— 取变量集合(色板 / 字阶 / 间距等分类)。
  - `figma.variables.getLocalVariablesAsync()` —— 取全量变量(含解析值)。
  - `figma.getLocalTextStylesAsync()` —— 取全量 text styles(字阶)。
  - 三者配合可拿到规范板的完整 token 体系,作为本次评审的权威标准。
- **逐段字体 / 字号审计**:
  ```js
  const segments = textNode.getStyledTextSegments(['fontName', 'fontSize']);
  // 每段含 { fontName: {family, style}, fontSize, characters, start, end }
  ```
  用于揪出 F1(字号游离字阶)、F2(字体族不一致)、F4(非标字体混入)。
- **缺失字体检测**:
  ```js
  if (textNode.hasMissingFont) { /* 云端不可用,已致渲染回退,命中 F3 */ }
  ```
- **批量取节点**:`figma.currentPage.findAllWithCriteria({ types: ['TEXT', 'FRAME', ...] })` —— 按类型批量抓取待审节点,避免逐个手动遍历。
- **辨 token vs 裸色(库变量误判坑)**:
  ```js
  const bound = fillsNode.fills[0]?.boundVariables;
  // 有 boundVariables.color → 已绑定变量(已 token 化)
  // 无 boundVariables → 才是真正的硬编码裸色,才计入 C1
  ```
  `get_variable_defs` 会把**库变量(跨文件引用)**显示成「名 = 值」的裸 hex,极易被误判为硬编码——凡是审计颜色/间距等 token 化程度,一律以 `boundVariables` 为准,不要只看数值。
- **取变量解析值**:`await figma.variables.getVariableByIdAsync(id)` 拿到变量对象后读 `.valuesByMode`,按 mode 取实际解析值(如浅色 / 深色模式下的具体色值)。

## 跨页

- 待审节点常常不在当前页(界面稿可能横跨多个 Figma page)。**写入前必须**:
  ```js
  await figma.setCurrentPageAsync(targetPage);
  ```
- **每次操作只切一次页**:同一批写回动作若都在同一页,只在批次开头 `setCurrentPageAsync` 一次,不要在循环内反复切换。

## 写回

- **绑定颜色变量**:
  ```js
  const newPaint = figma.variables.setBoundVariableForPaint(paint, 'color', variable);
  node.fills = [newPaint]; // 该 API 返回的是新 paint 对象,必须重新赋值给 node.fills,不能原地修改
  ```
- **字体归正**(先 load 目标字体,严禁 load 缺失字体):
  ```js
  await figma.loadFontAsync(targetFontName); // 只 load 目标字体
  textNode.setRangeFontName(start, end, targetFontName);
  textNode.setRangeFontSize(start, end, targetSize);
  ```
  > **坑**:绝不能对缺失字体调用 `loadFontAsync` ——尝试 load 一个云端不可用的字体会直接抛错,导致整个写回脚本**原子回滚**(本次批次内所有改动一并失败)。归正逻辑必须先确定「目标字体在云端可用」,再 load、再赋值。
  > 中文文本经目标字体自动回退渲染(如目标字体不含中文字形,系统会用回退字体渲染中文),这是预期行为,不算问题;只有「归正方案本身就是改成云端不可用的字体」时,才降级为「建议」不写回。
- **组件化**:
  ```js
  const component = figma.createComponentFromNode(node);
  component.addComponentProperty('状态', 'VARIANT', 'Default');
  const instance = component.createInstance();
  instance.setProperties({ '状态': 'Hover' });
  ```
- **绝对定位 → auto-layout 重构**:`frame.layoutMode = 'VERTICAL' | 'HORIZONTAL'` 后用 `createAutoLayout`(或对既有 frame 直接赋值 layoutMode)重排子节点;新建的 auto-layout frame 常带**默认白底 `fills`**,写回后要显式清空或改为预期值,避免多余的可见背景。

## 纪律

- **增量小步**:每次只改一小块 / 一个属性,不要一次性大批量改动。
- **每步 `get_screenshot` 校验**:每处改完立即截图确认符合预期,再进行下一处。
- **`use_figma` 原子性**:单次调用内的多个改动要么都成功要么都失败(如字体加载失败会导致整批回滚)——据此设计脚本边界,避免把互不相关的改动塞进同一批。
- **写回前逐条 HARD GATE 确认**:任何写入 Figma 的动作,必须是用户已在 P3/P4 明确裁定「让 AI 改」之后才能执行,未确认不得动手。
