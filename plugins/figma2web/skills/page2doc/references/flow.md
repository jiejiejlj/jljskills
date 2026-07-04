# page2doc 详细流程

给一个 Figma 页面链接,文档化成 spec + 切图;读 Figma。
产 `docs/jljskills/figma2web/design/<page>/<section>.md` + `docs/jljskills/figma2web/assets/<page>/<section>/...`。

spec 的具体段落结构见契约 [../../spec-structure/SKILL.md](../../spec-structure/SKILL.md)(唯一权威,不在本文件复述)。

## P0 — 前置校验
1. `docs/jljskills/figma2web/project.md` 存在。
2. **`docs/jljskills/figma2web/tokens.md` 存在(强制先跑 `config`)** —— 转换时要用其标准值做参照与魔法值把关。
3. figma-mcp 可用;用户给一个带 `node-id` 的 Figma 页面链接。

## P1 — 读取 + 提议分块
1. `get_metadata`(结构 / 层级 / 几何)+ `get_design_context`(样式 / 文本)+ `get_screenshot`(视觉参照)。
2. **主动提出 section 分块方案请用户确认**。

## P2 — 元素清单 + 完整性 gate(HARD GATE)
建 spec 的 **B 表**;每个**可见叶子节点**要么进清单、要么进**跳过清单写明原因**,不留遗漏。

## P3 — 逐区块确认(HARD GATE)
呈交:元素清单、关键样式、切图清单、交互理解。**C 段发现的疑似魔法值在此提示用户**(对照 `tokens.md`)。

## P4 — 交互行为(HARD GATE)
标准交互(hover/disabled、tab/手风琴等)自推断;**模糊 / 业务 / 数据驱动 → 停下问 或 留 TODO**。

## P5 — 切图预下载(HARD GATE)
1. 按**保真规则**定策略:
   - `rawImages` 保留透明;
   - `export` SVG 剥离背景;
   - 能纯 CSS 还原的**不切图**。
2. 先呈交「**节点 → 本地路径**」映射请用户确认,**再下载**到 `assets/<page>/<section>/`。
3. **把每个 section 的 Figma 整体参照截图存入 `assets/<page>/<section>/__ref.png`**(供 `verify` 离线比对)。

## P6 — 写 spec + 复核(HARD GATE)
自检:无占位、B/C/G 段 nodeId 一致、交互完整;请用户复核。

## 完成标志
所有 section 写入 spec + 切图并复核。**提示下一步跑 `coding`**。

## 边界
- 交互 / 数据来源不明 → 停下问,或在 E 段留明确 TODO,不脑补。
- 某节点既不该切图也无法纯 CSS 还原且信息不足 → 停下问用户。
