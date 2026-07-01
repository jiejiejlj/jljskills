# config 详细流程

`init` 之后的地基;读 Figma,产**设计标准文档 + `tailwind.config.*`**。

## P0 — 前置校验
1. `docs/figma2web/project.md` 存在(否则停下,提示先跑 `init`)。
2. figma-mcp 可用(未认证 → 先跑认证流程)。
3. 向用户索取一个**代表设计规范的 Figma 链接**(变量面板 / 设计系统帧)。**不落盘,每次现问。**

## P1 — 抽取设计标准
1. **优先** `get_variable_defs` 读 variables。
2. **无变量 fallback** `get_design_context`,取代表帧归纳。
3. 覆盖 **7 个维度**:**色板 / 字体族 / 字号阶 / 间距网格 / 圆角 / 阴影 / 渐变**。
4. 抽不到 / 不确定即**停下问**。每一项**标注来源**:Figma 变量 / 代表帧归纳 / 人工。

## P2 — 建立映射(直译 + 异常停下问)
变量路径**直译**为 tailwind theme key:
- `color/brand/primary` → `colors.brand.primary`
- `spacing/4` → `spacing.4`
- `radius/lg` → `borderRadius.lg`

遇**不符合 tailwind 结构**的命名 → **停下问用户**,不自行归并 / 改名。

## P3 — 呈交确认(HARD GATE)
呈交设计标准表,列:`名称 | Figma 变量 | 设计值 | token | 来源`。用户可改任意值;**未确认不写**。

## P4 — 写两产物(同一运行内一起写,保一致)
1. `docs/figma2web/tokens.md` —— 设计标准文档,**source of truth**。
2. `app/tailwind.config.*` —— **每次据 `tokens.md` 重新生成**(天然不漂移)。
3. 报告,**提示下一步跑 `page2doc`**。

## 完成标志
两产物写入并经确认。

## 边界
既无 variables 也取不到代表帧 → 引导用户**手填核心标准**(至少色板 + 字体 + 网格基数),来源标=人工。

---

## `tokens.md` 模板

```markdown
---
title: 设计标准(figma2web)
source_link: <抽取时用的 Figma 链接,仅记录>
updated_at: <YYYY-MM-DD>
---

# 设计标准 · tokens

> 本文件是设计 token 的 **source of truth**;`app/tailwind.config.*` 据本文件生成。
> 由 `/figma2web:config` 与 `/figma2web:re-config` 维护。

## 色板 colors
| 名称 | Figma 变量 | 设计值 | token | 来源 |
|---|---|---|---|---|
| brand/primary | color/brand/primary | #2563EB | colors.brand.primary | Figma 变量 |

## 字体族 fontFamily
| 名称 | Figma 变量 | 设计值 | token | 来源 |
|---|---|---|---|---|

## 字号阶 fontSize
（同上表头）

## 间距网格 spacing
（同上表头）

## 圆角 borderRadius
（同上表头）

## 阴影 boxShadow
（同上表头）

## 渐变 gradient
（同上表头）
```
