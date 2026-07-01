---
name: verify
description: coding 之后用 docker compose 起服务 + Playwright 逐断点截图,与 page2doc 持久化的 Figma 参照图做像素 diff 定位差异区,再用分级 rubric 打分,产还原度差异报告 + 建议判定(最终由人拍板)。仅当用户主动用 `/figma2web:verify` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Write, Edit, Bash, AskUserQuestion
disable-model-invocation: true
---

# verify — 还原度校验

## 用途
`coding` 之后校验还原度。用 **`docker compose` 起服务 + Playwright 截图**,与 `page2doc` 持久化的 Figma 参照图(`__ref.png`)比对,分级 rubric 打分,产差异报告。**离线,不需 figma-mcp。**

核心心法:**像素 diff 只用来定位差异区,不当判据。** rubric 逐项判过 / 不过(token/结构/交互靠查代码 + DOM,视觉靠比两图);**最终过 / 不过由人拍板。**

## 何时运行
仅当用户主动用 `/figma2web:verify` 指令调用时运行。前置:`project.md` 存在;目标页代码能 build;docker / docker compose + Playwright 可用;**Figma 参照图已由 `page2doc` 持久化**(离线读)。

## 产物(本 skill 是唯一写者)
- `docs/figma2web/verify/<page>-<date>.md` —— 还原度差异报告(供人审校)。

## 流程骨架
1. **起服务**:`docker compose` 起服务(用 `coding` 产的 Docker 产物)。
2. **渲染截图**:Playwright 访问容器端口,**按 `project.md` 断点逐断点截图**。
3. **比对定位**:渲染图 vs `__ref.png` 像素 diff,**只定位差异区**。
4. **rubric 打分**:token 用对 / 结构语义 / 视觉差异 / 交互态齐全,逐项判过 / 不过 + 说明。
5. **出报告 + 建议判定**(过 / 待修 / 不过);**最终由人拍板**。

> 完整分阶段流程与 rubric 见 [references/flow.md](references/flow.md) —— **动笔前先读它**。

## 红线
- **像素 diff 只定位差异区,不当判据**(非像素级对齐)。
- rubric 逐项判过 / 不过并写明理由;报告给**建议判定**。
- **最终过 / 不过由人拍板**,verify 不独自裁定。
- 参照图**离线读** `page2doc` 持久化的 `__ref.png`,不访问 Figma。
