---
name: loop-optimize
description: figma-optimize 总入口. 贴一个 Figma 链接, 自动分诊页面类型, 排出优化行程单, 沿 standard→page→component 依赖链逐阶段驱动评审与写回. 仅 /figma-optimize:loop-optimize 手动触发.
allowed-tools: Read, Grep, Glob, Write, Edit, AskUserQuestion, mcp__plugin_figma_figma
disable-model-invocation: true
---

# loop-optimize

loop-optimize 只做分诊 · 行程单 · 沿链驱动, 不含评审逻辑 — 逻辑在 stages/ 各阶段 flow, 写回纪律在下方红线, 写一次.

## 分诊 (triage)

取链接 → `get_metadata` 拿 section 级子节点 → 按 `references/router.md` 逐个定类 (窄链接 = 单节点同一路).

**开局先比对台账**: 按 `references/fingerprint.md` 的「分诊比对闸门」读仓库台账 + 节点 pluginData, 命中且双账一致的 section 跳过 (已裁定 · 未变), 只对新增 / 变更项定类. 这是幂等的入口, 不是可选项.

完成标准: **每个** section 级子节点非 "高置信定类" 即 "标待定送行程单", 无一漏判.

## 行程单 (itinerary)

产行程单级蓝图 (子页 → 类型 → stage → 链位序 → 每阶段查什么 + 量级粗估).

完成标准: **每一行**经用户 "确认 / 改类型 / 改序 / 勾除", 无默认略过. (是行程单, 不是原子清单 — 原子清单到阶段才生成.)

## 沿链驱动 (chain)

按链位序 Read `references/stages/<type>/flow.md` 就地跑; 原子清单此刻才生成.

完成标准: 各阶段复审归零 (或仅剩用户有意保留, 报告标注的例外); **且各阶段已按 `references/fingerprint.md` 盖指纹, 仓库台账与 Figma pluginData 双账一致** — 未盖台账不算收尾.

## 红线 (写一次, 全阶段通用)

① HARD GATE 未确认不动 Figma; `use_figma` 前必先走 `figma-use` skill; 每步 `get_screenshot`.

② 不生成代码, 不做 design → code; 不读写 figma2web 任何产物.

③ 报告默认落 `docs/jljskills/figma-optimize/` (报告阶段可改路径 / 不落盘).

④ 分诊判据见 `references/router.md`; API 判据见 `references/figma-facts.md`; **去重 / 幂等 / 双账同步**见 `references/fingerprint.md` — 不复述. 后者是**每阶段硬性主干**, 非可选去重工具: 开局比对台账闸门 (跳过已裁定 · 未变项), 阶段末盖指纹并更新台账 (Figma pluginData + 仓库 `.loop-optimize-ledger.json` 双账). 各 flow 的 P0 与收尾步已内置此两动作.
