# re-page2doc 详细流程

设计改动后只更新变化 section;读 Figma。对位旧 `refresh`。**不擅删、问用户。**

spec 的具体段落结构见契约 [../../spec-structure/SKILL.md](../../spec-structure/SKILL.md)(唯一权威,不在本文件复述)。

## P0 — 前置校验
`docs/figma2web/project.md` + `docs/figma2web/tokens.md` + **已有 spec** 均存在;figma-mcp 可用;用户给(更新后的)Figma 页面链接。

## P1 — 全量重抓
1. 读现有 spec,取各 section 的 `frameNodeId`。
2. 逐个 `get_metadata` / `get_design_context` / `get_screenshot` 抓**当前** Figma。
3. 同时扫页面找**新增 section**。
4. **先不下切图。**

## P2 — 比对分类
与已有 spec(以 **B 表**为基准)逐 section 比对 → **NEW / CHANGED / UNCHANGED**;全量重抓,用户无需标注范围。

## P3 — 确认分类(HARD GATE)
呈交三类清单 + **每个 CHANGED 的逐项具体改动**,确认;**未确认不写**。

## P4 — 分头处理
- **NEW**:按 [page2doc flow](../../page2doc/references/flow.md) 完整文档化,步骤以它为唯一权威(产物含 spec + 切图 + `__ref.png`)。
- **CHANGED**:自刷新 spec —— 重建 B 表、核对改动、确认交互、**只重下变化切图**、刷新 `status=CHANGED` / `updated_at`。
- **UNCHANGED**:完全不动。

## P5 — 小结
报告分类,**提示**对 NEW/CHANGED section 跑 `coding`(孤岛,不自动调)。

## 边界(改名 / 删除)
- section 改名 → 视为 **NEW**,旧 spec 标「疑似改名 / 已移除」**问用户**(删 / 留 / 手动改名保历史)。
- Figma 里已删的 section → 标「**已移除**」**问用户,不擅删**。
