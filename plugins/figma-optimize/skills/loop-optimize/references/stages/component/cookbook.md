# component 组件化 API 配方

component 专属的 `use_figma` 配方;通用坑与纪律四条见 [figma-facts](../../figma-facts/SKILL.md),此处不复述。

## 原位成立组件
`figma.createComponentFromNode(node)` 把散件原位转为 component,保留位置与层级 —— 首选它,不要新建空 component 再搬内容。

## 替换散件为实例
```js
const inst = component.createInstance();
const parent = old.parent;
parent.insertChild(parent.children.indexOf(old), inst);
inst.x = old.x; inst.y = old.y;          // 非 auto-layout 父级才需要
inst.resize(old.width, old.height);
old.remove();
```
- auto-layout 父级里 x/y 无效,**靠插入索引落位**;`layoutSizingHorizontal/Vertical` 按原节点(hug / fill / fixed)对齐。
- 先插入、后 remove:保证层级序不因删除而移位。

## 变体归并
- 每处先 `createComponentFromNode`,再 `figma.combineAsVariants(components, parent)` 并成 ComponentSet。
- 变体命名用 `属性=值`(如 `state=default` / `state=hover`),多轴逗号分隔:`state=hover, size=lg`。
- 替换某处为特定变体:创建实例后 `instance.setProperties({ state: 'hover' })`。

## 文本覆写回填
替换后原文本要保住:替换前按序收集 `old.findAll(n => n.type === 'TEXT')` 各节点的 `characters`,替换后对实例内对应文本节点先 `figma.loadFontAsync(node.fontName)` 再写回 `characters`。**只 load 该节点现用字体,缺失字体的节点跳过并记录**(load 缺失字体抛错 → 整批原子回滚,见 figma-facts)。

## 游离克隆归位
克隆节点没有指回组件的引用,判定只能靠 P2 的结构签名比对;归位 = 以已有 component 为基准走「替换散件为实例」同一配方,替换前先核对各差异均属覆写 / 变体表达范围。
