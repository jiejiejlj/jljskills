# figma-optimize 技能优化 需求文档

> 日期:2026-07-02 · 状态:草稿(已确认输入)
> 承接:本文档需求已由《2026-07-03 figma-optimize 拆分 standard / page》纳入并落地,原 `optimize` 技能已拆分。
> 来源:基于评审 Casally 官网「命名规范」板(node 1093:13942)+ 全量复查「设计规范」总板(node 856:12610)的实战经验。

## 1. 概述 / 背景
figma-optimize 是面向设计师的交付前评审插件(AI 作规则审计员 / 守门人)。本次用它评审 Casally 官网「命名规范」板、并全量复查「设计规范」总板,暴露出现有技能在**装载项目标准、字体维度处理、读写 API 沉淀**三处的不足。本文档汇总据实战提炼的优化需求,供后续修改技能时执行。

## 2. 要解决的问题
- **装载标准踩空**:P1 只用 `get_variable_defs`,仅抽到 3 个变量,还把**库变量**误显成裸 hex(`#333333`),漏掉 54 变量 + 12 文字样式 + 一整块专门的设计规范板。
- **字体维度被"一律受限"耽误**:缺失字体(`PingFang SC` 云端不可用)其实可检测、可修;非标字体(`SF Pro`)混入未被发现;游离字号未系统审计。
- **读写配方散落**:缺字体检测、逐段字体审计、组件化、auto-layout 重构、跨页写入等 `use_figma` 配方没沉淀,复用性差、每次现推。

## 3. 目标(Goals)
- 装载标准**三源级联**,不再空手。
- 字体维度从"降级建议"升级为"**检测 + 可行归正**"。
- 沉淀**读写 API cookbook**(单文件)。
- 报告支持**跨板(多板)结构**。

## 4. 非目标(Non-Goals)
- 本轮**不纳入**「场景分级(交付 UI vs 内部规范/文档板)+ 误报护栏扩充」(用户明确暂缓)。
- 不改核心心法 / 红线:HARD GATE 未确认不动 Figma、不做审美裁决、不生成代码、不读写 figma2web / `config.md`。
- 不做全自动无人评审。

## 5. 目标用户与使用场景
- **用户**:设计师,交付前用 `/figma-optimize:optimize` 评审设计稿。
- **场景**:单板评审 + 关联标准板复查;AI 作规则审计员,补设计师缺的开发视角。

## 6. 核心需求 / 功能清单
| 优先级 | 需求 | 说明 |
|---|---|---|
| P0 | 三源级联装载(改 flow.md P1) | ① 先问 / 找「设计规范板 / 页」当**权威标准** → ② `use_figma` 读全量 `getLocalVariableCollectionsAsync` / `getLocalVariablesAsync` / `getLocalTextStylesAsync`(拿全色板 / 字阶 / 间距)→ ③ `get_variable_defs` 仅快览 / 兜底。明确警示:`get_variable_defs` 会把**库变量**显成"名=值"裸 hex,须用 `fills[].boundVariables` 辨别是否已 token 化,别误判硬编码。 |
| P0 | 字体维度重写(改 checklist.md F) | **检测**:逐文本 `getStyledTextSegments(['fontName','fontSize'])` + `node.hasMissingFont`,揪出 缺失字体 / 非标字体混入 / 游离字号。**归正**:字体族改绑到**可用标准字体**是可行的,还能修复"缺失字体"态——关键坑:**别 `loadFontAsync` 那个缺失字体**(抛错 → 整脚本原子回滚),只 load 目标字体,中文经 Figma 自动回退渲染。**真受限**:只有"改成云端不可用字体"才降级为建议。新增检查项 **F3 缺失字体(高·可修)**、**F4 非标字体混入(中·可修)**。 |
| P1 | 新增 `references/figma-api-cookbook.md`(单文件) | 沉淀读 / 审计、跨页、写回配方 + 纪律(详见 §附录)。 |
| P1 | 报告多板结构(改 report-template.md) | 报告模板加**可选「附:关联标准板复查」章节**,容纳跨板(如本次两块板)复查结果。 |
| P1 | flow.md 衔接 | P2 审计增加逐段字体 / 缺失检测;P2 / P5 指向 cookbook。 |

## 7. 约束与依赖
- **云端字体可用性受限**:`PingFang SC` 等在 MCP 云端不可用 → cookbook 必含「别 load 缺失字体,否则抛错整脚本原子回滚」坑;字体改到**不可用**字体才是真受限。
- **保持独立插件**:不依赖 / 不读写 figma2web、`config.md`、superpowers。
- `use_figma` 前必走 `figma-use` skill;HARD GATE 不变;每次 `use_figma` 只 `setCurrentPageAsync` 一次;每处改完 `get_screenshot` / `node.screenshot()` 校验;脚本原子性(报错整体回滚,先修再重试)。

## 8. 成功标准
- 复评同类文件时能拿到**全量**色板 / 字阶(不再只 3 个),库变量不被误判为硬编码。
- 缺失 / 非标字体能被检出,并在可用字体范围内修复;**只有改成云端不可用字体才降级为建议**。
- cookbook 覆盖本次全部读写动作,新会话可直接照配方执行。
- 报告能容纳跨板复查结果。

## 9. 开放问题(待确认)
- 「场景分级 / 护栏」何时纳入(本轮暂缓)。
- cookbook 是否随经验增长再拆分为多文件。
- F3 / F4 的严重度默认值与判据措辞(建议 F3 高、F4 中)。

---

## 附录:cookbook 拟收录配方(供实现参考)
- **读 / 审计**:`getLocalVariableCollections/Variables/TextStylesAsync`(装载标准)、`getStyledTextSegments(['fontName','fontSize'])`(逐段字体 / 字号)、`hasMissingFont`、`findAllWithCriteria({types})`(大板快速遍历)、`fills[].boundVariables`(辨 token vs 裸色)、`getVariableByIdAsync` + `valuesByMode`(取变量解析值)。
- **跨页**:节点常不在首页(本次在 `homepage_AI`)→ 写前必 `await setCurrentPageAsync(page)`,每次只切一次页。
- **写回**:`setBoundVariableForPaint`(返回**新** paint 需重赋)、`setRangeFontName / setRangeFontSize`(只改指定段,先 load 目标字体)、`createComponentFromNode` + `addComponentProperty('label','TEXT',…)` + `componentPropertyReferences` + `createInstance` / `setProperties`(行组件化) 
、`createAutoLayout` 后**清默认白底 `fills`**、绝对→auto-layout(固定标签列 + hug 值列)。
- **纪律**:增量小步、每步校验;`use_figma` 原子性;写回前逐条 HARD GATE 确认。