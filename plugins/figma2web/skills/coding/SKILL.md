---
name: coding
description: 全程离线读一份 section spec + 本地切图 + 设计标准 + registry,复现出贴合技术栈的 web 代码与 Docker 产物;复用已有组件、缺的写页面内局部,禁止魔法值。不调 figma-mcp。仅当用户主动用 `/figma2web:coding` 指令调用时使用 —— 不要在普通对话里自行触发。
disable-model-invocation: true
---

# coding — 离线复现代码

## 用途
`page2doc` 之后,**离线**读 spec 出代码。输入:目标 section spec + 本地切图 + `tokens.md` + `project.md` + `registry.json`。产 `app/` 源码 + Docker 产物。

核心心法:**全程离线,不调 figma-mcp。** 需要 Figma 的信息即说明 spec 不够完整,应回 `page2doc` 补,而非访问 Figma。样式一律走语义化 token,**禁止魔法值**。

> 本 skill **内部复用 superpowers**(`writing-plans` → `executing-plans`)出代码,故不设 `allowed-tools`(需完整开发工具链);对用户仍是「一个 coding 闭环」。

## 何时运行
仅当用户主动用 `/figma2web:coding` 指令调用时运行。前置:`project.md` + `tokens.md` 存在;目标 spec 存在且已 finalize;**spec G 段切图必须在磁盘上(缺切图 HARD STOP)**;`registry.json` 存在(可空);superpowers 已装。

## 产物(本 skill 是唯一写者)
- `app/` —— 应用源码(`app/src/...`)。
- `Dockerfile` / `docker-compose.yml` / `.dockerignore` 等部署产物(按 `project.md` 部署方式)。

## 流程骨架
1. **前置校验**:含**缺切图 HARD STOP**(不自行下载、不访问 Figma,回头提示补跑 `page2doc`/`re-page2doc`)。
2. **出实现计划**:复用匹配(按 Figma 组件实例标识)/ 几何翻译 / token 翻译 / 响应式 / 代码落位。
3. **确认计划(HARD GATE)**:自检后用户明确确认才动代码。
4. **执行**:内部调 `superpowers:writing-plans` → `superpowers:executing-plans`。
5. **结构 / 数值层自查**:build、几何 / token / 文本码点 / 切图引用一致、Docker 产物齐备。

> 完整分阶段流程、复用匹配与翻译规则、两层验收见 [references/flow.md](references/flow.md) —— **动笔前先读它**。

## 红线
- **全程离线**:不调 figma-mcp;缺信息回 `page2doc` 补,不访问 Figma。
- **缺切图 HARD STOP**:不自行下载,提示补跑 `page2doc`/`re-page2doc`。
- **禁止魔法值**:颜色 / 间距 / 圆角 / 字体走 `tokens.md` → tailwind token。
- **复用按 Figma 组件实例标识**(spec B 表实例名 ↔ registry「对应 Figma 节点」);非实例的重复 UI 写页面内局部,留给 `component`;歧义则问。
- HARD GATE 未确认不改代码;视觉渲染层交给 `verify` + 人,**coding 不独自兜底**。
