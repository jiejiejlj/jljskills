---
name: page2doc
description: 给一个带 node-id 的 Figma 页面链接,忠实文档化成一份自包含的纯设计 spec + 预下载切图,让同事拿 spec 就能离线复现代码、不必再读 Figma。产 `docs/jljskills/figma2web/design/<page>/<section>.md` 与切图。仅当用户主动用 `/figma2web:page2doc` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Write, Edit, Bash, AskUserQuestion, mcp__plugin_figma_figma
disable-model-invocation: true
---

# page2doc — Figma 页面转自包含 spec

## 用途
把一个 Figma 页面**忠实文档化**成一份人可读、可交接、**可离线复现**的设计 spec,并预下载切图。目标:**同事拿这份 spec 就能复现 web 代码,写代码时不必再读 Figma。**

核心心法:**spec 只记设计事实,不做代码决策。** 忠实记录设计(含「这块是 Figma 组件实例 X」这类客观事实);token 最终翻译、组件拆分等**代码决策留给 `coding`**。信息不足 / 交互含糊就**停下问用户**,绝不臆测。

## 何时运行
仅当用户主动用 `/figma2web:page2doc` 指令调用时运行。前置:`project.md` 存在;**`tokens.md` 存在(强制先跑 `config`——转换时要用其标准值做参照与魔法值把关)**;figma-mcp 可用;用户给一个带 `node-id` 的 Figma 页面链接。

## 产物(本 skill 与 `re-page2doc` 共同维护)
- `docs/jljskills/figma2web/design/<page>/<section>.md` —— 自包含设计 spec,`coding` 只读。
- `docs/jljskills/figma2web/assets/<page>/<section>/...` —— 本地切图。
- `docs/jljskills/figma2web/assets/<page>/<section>/__ref.png` —— section 整体参照截图,供 `verify` 离线比对。

## 流程骨架(每一步多为 HARD GATE)
1. **读取 + 提议分块**:`get_metadata` + `get_design_context` + `get_screenshot`;主动提出 section 分块方案请用户确认。
2. **元素清单 + 完整性 gate**:每个可见叶子节点要么进清单、要么进跳过清单写明原因。
3. **逐区块确认**:元素清单 / 关键样式 / 切图清单 / 交互理解;疑似魔法值在此提示。
4. **交互行为**:标准交互自推断;模糊 / 业务 / 数据驱动 → 停下问或留 TODO。
5. **切图预下载**:按保真规则定策略,先呈交「节点 → 本地路径」映射确认再下载;存 `__ref.png`。
6. **写 spec + 复核**:自检后请用户复核。

> 完整分阶段流程见 [references/flow.md](references/flow.md);spec 文件结构契约见 [../spec-structure/SKILL.md](../spec-structure/SKILL.md)(page2doc / re-page2doc / coding 三方共用的地基)—— **动笔前先读它俩**。

## 红线
- **spec 保持纯设计描述**:记设计事实,代码决策(token 翻译 / 组件拆分)留给 `coding`。
- **绝不臆测**:交互 / 数据含糊 → 停下问或留 TODO,不脑补。
- 完整性 gate:每个可见叶子节点**要么进清单、要么进跳过清单写明原因**,不留遗漏。
- 切图先呈交「节点 → 本地路径」映射**确认再下载**;每个 section 存 `__ref.png` 供 `verify`。
- **B/C/G 三段的 nodeId 必须一致**,`coding` 与 `re-page2doc` 以 B 表为基准。
