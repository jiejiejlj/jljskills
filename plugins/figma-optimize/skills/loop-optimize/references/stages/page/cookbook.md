# Figma API 配方(page 向)

`page` 评审界面稿时用到的 **skill 专属** Figma Plugin API 配方. 通用纪律见 SKILL.md 红线, 本文件不复述.

> 共享判据与通用配方 — 库变量误判坑, 三源 API, `setBoundVariableForPaint` 重赋值, 切页, 纪律四条 — **唯一权威在 [`../../figma-facts.md`](../../figma-facts.md)**(flow P1 已装载), 本文件不复述.

## 读 / 审计

- **逐段字体 / 字号审计**:
  ```js
  const segments = textNode.getStyledTextSegments(['fontName', 'fontSize']);
  // 每段含 { fontName: {family, style}, fontSize, characters, start, end }
  ```
  用于揪出 F1(字号游离字阶), F2(字体族不一致), F4(非标字体混入).
- **缺失字体检测**:
  ```js
  if (textNode.hasMissingFont) { /* 云端不可用,已致渲染回退,命中 F3 */ }
  ```
- **批量取节点**: `figma.currentPage.findAllWithCriteria({ types: ['TEXT', 'FRAME', ...] })` — 按类型批量抓取待审节点, 避免逐个手动遍历.

## 写回

- **字体归正**(先 load 目标字体, 严禁 load 缺失字体):
  ```js
  await figma.loadFontAsync(targetFontName); // 只 load 目标字体
  textNode.setRangeFontName(start, end, targetFontName);
  textNode.setRangeFontSize(start, end, targetSize);
  ```
  > **坑**: 绝不能对缺失字体调用 `loadFontAsync` — 尝试 load 一个云端不可用的字体会直接抛错, 导致整个写回脚本**原子回滚**(本次批次内所有改动一并失败). 归正逻辑必须先确定「目标字体在云端可用」, 再 load, 再赋值.
  > 中文文本经目标字体自动回退渲染(如目标字体不含中文字形, 系统会用回退字体渲染中文), 这是预期行为, 不算问题; 只有「归正方案本身就是改成云端不可用的字体」时, 才降级为「建议」不写回.
- **组件化**:
  ```js
  const component = figma.createComponentFromNode(node);
  component.addComponentProperty('状态', 'VARIANT', 'Default');
  const instance = component.createInstance();
  instance.setProperties({ '状态': 'Hover' });
  ```
- **绝对定位 → auto-layout 重构**: `frame.layoutMode = 'VERTICAL' | 'HORIZONTAL'` 后用 `createAutoLayout`(或对既有 frame 直接赋值 layoutMode)重排子节点; 新建的 auto-layout frame 常带**默认白底 `fills`**, 写回后要显式清空或改为预期值, 避免多余的可见背景.
