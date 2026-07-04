# init 详细流程

纯交互式收集,不读 Figma、不写代码。产出 `docs/jljskills/figma2web/project.md`。

## P0 — 前置校验 + 首建 / 重配判定
1. 检测 `docs/jljskills/figma2web/project.md`:
   - **不存在 → 首建**:走全量收集。
   - **已存在 → 预填式重配**:载入现有值,P1 逐项**预填当前值**,用户只改要改的项、其余回车保留;**只写变更**,不动未改项。
2. 向用户确认前提:**「已有一个能本地跑的工程」**(init 不建脚手架,只往里加配置 / token / 组件 / 页面 / 部署产物)。

## P1 — 逐项收集技术决策(10 项)
每项**给默认值 + 理由**,请用户确认或改。**逐项必答**:每项取得确定值,不接受留空 / 擅自默认;用户「无所谓」时也把默认值念出来请其确认。

| # | 字段 | 默认值 | 说明 |
|---|---|---|---|
| 1 | 技术框架 + 语言 | React + TypeScript | v1 标准栈 |
| 2 | 样式方案 | Tailwind CSS | 语义化 token,禁魔法值 |
| 3 | 布局模型 | 绝对定位 / flex / grid(问用户主选哪种) | 供 `coding` 翻译几何 |
| 4 | 代码目录约定 | `app/` 根;源码在 `app/src/...` | 应用源码落位 |
| 5 | 组件库位置 + registry 位置 | `app/src/components/` + `app/src/components/registry.json` | `component` 写、`coding` 读 |
| 6 | 切图引用约定 | 如 `/assets/...` | 代码里怎么引用本地切图 |
| 7 | 设计 token 落地位置 | `app/tailwind.config.*` | `config` 生成 theme |
| 8 | 响应式断点 | Tailwind `sm/md/lg/xl` | `coding`/`verify` 逐断点用 |
| 9 | 部署方式 | Docker 容器化(注明运行形态,如「多阶段构建 → nginx 托管 dist」) | `coding` 产 Docker 产物,`verify` 走 `docker compose` |
| 10 | Figma file key | 每次给链接 / 或固定一个 key | 便于校验 nodeId 归属 |

## P2 — 呈交确认(HARD GATE)
把完整配置(10 项)列成一张表请用户确认。**任一项待定 → 回 P1 补齐,绝不带缺口写。**

## P3 — 写 `project.md` + 报告
1. 首建:写入全部 10 项。重配:只写变更项,其余原样保留。
2. 报告写了什么,**提示下一步跑 `config`**(打通设计 token)。

## 完成标志
`project.md` 写入并经用户确认。

---

## `project.md` 模板

```markdown
---
title: figma2web 项目技术配置
updated_at: <YYYY-MM-DD>
---

# 项目技术配置(figma2web)

> 本文件由 `/figma2web:init` 维护,是 figma2web 全部下游 skill 的技术决策唯一依据。
> 下游 skill 直接信任本文件,不再做齐备性校验。

| # | 项 | 值 | 备注 |
|---|---|---|---|
| 1 | 技术框架 + 语言 | React + TypeScript | |
| 2 | 样式方案 | Tailwind CSS | 语义化 token,禁魔法值 |
| 3 | 布局模型 | <绝对定位 / flex / grid> | |
| 4 | 代码目录约定 | 根 `app/`;源码 `app/src/...` | |
| 5 | 组件库 + registry | `app/src/components/` + `app/src/components/registry.json` | |
| 6 | 切图引用约定 | `/assets/...` | |
| 7 | token 落地位置 | `app/tailwind.config.*` | |
| 8 | 响应式断点 | `sm/md/lg/xl` | |
| 9 | 部署方式 | Docker(<运行形态>) | |
| 10 | Figma file key | <key 或「每次给链接」> | |
```
