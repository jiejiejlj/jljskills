# re-config 详细流程

设计标准 / 变量改动后差异化同步;读 Figma。对位旧 `resetup`。**不维护变更日志**(靠 git)。

## P0 — 前置校验
1. `docs/jljskills/figma2web/project.md` + `docs/jljskills/figma2web/tokens.md` 均存在(缺 `tokens.md` → 提示先跑 `config`)。
2. figma-mcp 可用。
3. 向用户索取**标准面板 Figma 链接**。

## P1 — 重抓当前标准
执行 [config flow 的 P1「抽取设计标准」](../../config/references/flow.md)全部步骤——抽取渠道、维度清单、来源标注均以它为唯一权威,不在本文件复述。

## P2 — diff 分类
与现有 `tokens.md` **逐项比对** → **NEW / CHANGED / UNCHANGED**:
- 靠**数值比对**,不靠目视。
- 记录**来源演进**(如某项 `来源:人工` → 现已成 Figma 变量)。

## P3 — 确认分类(HARD GATE)
呈交三类清单 + **每个 NEW/CHANGED 的前后具体值**,逐项确认;**未确认不写**。

## P4 — 写回(同一运行内一起写)
1. `tokens.md`:只更新 NEW/CHANGED(值 + 来源);UNCHANGED **原样**。
2. `tailwind.config.*`:据更新后的 `tokens.md` **同步重新生成**,保两者不漂移。

## P5 — 小结
报告:改了哪些 / 来源如何演进 / 哪些未变。

## 边界
- 某项在 Figma 被删(文档有、重抓没有)→ 标「**已移除**」问用户,**不擅删**。
- 字体等读不到 → **停下问**。
