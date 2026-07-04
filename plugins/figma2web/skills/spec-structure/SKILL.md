---
name: spec-structure
description: figma2web 的 spec 文件结构契约（v2）：frontmatter 字段、A–G 段定义、「B 表为 diff 基准」的一致性约束。仅当 page2doc / re-page2doc / coding 的流程显式指路 Read 本文件、或用户主动用 `/figma2web:spec-structure` 查阅契约时使用。
allowed-tools: Read
disable-model-invocation: true
---

# spec-structure — spec 文件结构契约(v2,地基)

路径:`docs/jljskills/figma2web/design/<page>/<section>.md`。
**自包含** —— `coding` 只凭 spec + 本地切图即可离线还原,不再读 Figma。

> 本文件是 spec 结构的**唯一契约**:`page2doc`(写)、`re-page2doc`(增量刷新)、`coding`(读)三方共同遵循,契约正文只存这里,各 skill 只留指针。

## frontmatter
```yaml
page: <页面名>
section: <区块名>
fileKey: <Figma file key>
frameNodeId: <该 section 根帧 nodeId,diff 锚点>
frameW: <帧宽>
frameH: <帧高>
status: NEW | CHANGED | UNCHANGED   # re-page2doc 维护
updated_at: <YYYY-MM-DD>
```

## A. 结构树
缩进层级概览,**标注 Figma 组件实例**。

## B. 元素清单(★diff 基准)
| nodeId | 类型 | 父 | 原文文本 | 几何(x,y,w,h) | 状态 | Figma 组件实例 | 切图策略 |
|---|---|---|---|---|---|---|---|

## C. 样式细节(按 nodeId)
每项 CSS 属性记:
- **忠实值**;
- **Figma 变量绑定**(如有);
- **标准符合性**:匹配 `tokens.md` 标准 / 偏离或疑似魔法值。

> token 的**最终翻译留给 `coding`**;这里只忠实记录 + 标注符合性。

## D. 响应式
- 多尺寸稿:逐断点记几何 / 样式差异。
- 单稿:记「按 `project.md` 默认断点常规适配」+ 需特别 reflow 的元素(用户确认)。

## E. 交互行为
- 标准交互(推断)+ 业务 / 数据驱动(确认或 TODO)。
- 多态节点(hover/disabled 变体)**逐态记**。

## F. 跳过清单
装饰节点 + 跳过原因。

## G. 切图映射
`nodeId → 本地路径 + 下载策略 + 层叠说明`。

## 一致性约束
**B / C / G 段的 nodeId 必须一致。** `coding` 与 `re-page2doc` 以 **B 表**为基准。
