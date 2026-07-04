# verify 详细流程

`coding` 后校验还原度;**`docker compose` + Playwright**。离线,不需 figma-mcp。

## P0 — 前置校验
1. `docs/jljskills/figma2web/project.md` 存在;目标页代码能 build。
2. docker / docker compose + Playwright 可用。
3. **Figma 参照图已由 `page2doc` 持久化**(`assets/<page>/<section>/__ref.png`,离线读)。

## P1 — 起服务
`docker compose` 起服务(用 `coding` 产的 Docker 产物)。

## P2 — 渲染截图
Playwright 访问容器端口,**按 `project.md` 断点逐断点截图**(响应式也验)。

## P3 — 比对定位
每个 section:渲染图 vs `__ref.png` → 像素 diff **只定位差异区**(不当判据)。

## P4 — 模型 rubric 打分(逐项通过 / 不通过 + 说明)
| rubric 项 | 判据来源 |
|---|---|
| **token 用对** | 查代码:引用 tailwind 语义化 token,无魔法值 |
| **结构语义** | 查 DOM:合理语义标签,非一堆无意义 div |
| **视觉差异** | 比两图 + 差异区,落在可接受范围(非像素级) |
| **交互态齐全** | 查代码 + DOM:hover/disabled、tab/手风琴等已实现 |

## P5 — 出报告 + 建议判定
写差异报告到 `docs/jljskills/figma2web/verify/<page>-<date>.md`:逐 section、逐 rubric 项、差异区截图、**整体建议判定:过 / 待修 / 不过**。**最终过 / 不过由人拍板。**

## 完成标志
报告产出;人工终审通过。

## 工程细节(写 SKILL 时按项目定)
`docker compose` 暴露端口约定、Playwright 访问方式、是否接 CI(自动部分 headless 可跑,人工终审为手动闸门)。
