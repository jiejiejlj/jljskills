# Figma API 配方(standard 向)

`standard` 评审设计规范板本身时用到的 **skill 专属** Figma Plugin API 配方. 通用纪律见 SKILL.md 红线, 本文件不复述.

> 共享判据与通用配方 — 库变量误判坑, 三源 API, `setBoundVariableForPaint` 重赋值, 切页, 纪律四条 — **唯一权威在 [`../../figma-facts.md`](../../figma-facts.md)**(flow P1 已装载), 本文件不复述.

## 读 / 审计

- **命名遍历**: 遍历 `variable.name`(及所在集合名), 用于 S-C1(语义 / 层级)与 S-C2(风格一致性).
- **字体标准审计**: 遍历 text styles 的 `style.fontName`(family/style), 比对项目标准字体族揪非标字体; 缺失字体则把 `style.fontName.family` 与 `figma.listAvailableFontsAsync()` 结果比对判定(`hasMissingFont` 是 TextNode 属性, TextStyle 上没有, 别直接取). 用于 S-D2.

## 写回

- **变量重命名**:
  ```js
  variable.name = '新的语义化名称'; // 解决 S-C1 / S-C2
  ```
- **收敛近似 token(修复 S-E1)**:
  1. 确认要保留的「主 token」与要合并掉的「冗余 token」.
  2. 找出所有引用冗余 token 的节点 / 样式, 逐个改绑为主 token(绑定手法见 figma-facts 的写回通用坑).
  3. 确认无引用后再删除冗余变量, 避免留下悬空引用.
