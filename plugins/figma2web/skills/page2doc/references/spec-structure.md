# spec 文件结构(v2)

路径:`docs/figma2web/design/<page>/<section>.md`。
**自包含** —— `coding` 只凭 spec + 本地切图即可离线还原,不再读 Figma。

> 本文件被 `page2doc`(写)与 `re-page2doc`(增量刷新)共同遵循;`coding` 据此读取。

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
