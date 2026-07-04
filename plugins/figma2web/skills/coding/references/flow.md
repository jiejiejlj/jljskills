# coding 详细流程

`page2doc` 之后离线读 spec 出代码。**全程离线,不调 figma-mcp。**
输入:目标 section spec(段落契约见 [../../spec-structure/SKILL.md](../../spec-structure/SKILL.md),B 表 / C 段 / G 段等词汇均以它为准)+ 本地切图 + `tokens.md` + `project.md`。

## P0 — 前置校验
1. `docs/jljskills/figma2web/project.md` + `docs/jljskills/figma2web/tokens.md` 存在。
2. 目标 spec 存在且已 finalize。
3. **缺切图 HARD STOP**:spec **G 段**列的切图磁盘上必须存在;缺 → **停下**提示补跑 `page2doc`/`re-page2doc`,**不自行下载、不访问 Figma**。
4. superpowers 已装(P3 用)。

## P1 — 出实现计划(依据 `project.md` + `tokens.md`)
- **框架 / 样式**:读 `project.md`。
- **几何翻译**:B 表 `x/y/w/h` → `project.md` 布局模型(绝对定位 / flex / grid)。
- **token 翻译**:spec **C 段**忠实值 + 变量绑定 → `tokens.md` 映射 → tailwind token;**禁止魔法值**。
- **响应式**:spec **D 段** + `project.md` 断点。
- **代码落位**:`app/`,并按 `project.md` 部署方式产 Docker 产物。

## P2 — 确认计划(HARD GATE)
自检(无占位、决策与 spec 一致、验收完整)→ 用户**明确确认**;未确认不改代码。

## P3 — 执行(内部复用 superpowers)
把【spec + 已确认技术决策 + 验收标准】当 spec,内部调 `superpowers:writing-plans` → `superpowers:executing-plans` 出代码。对用户仍是「一个 coding 闭环」。

## 验收两层
- **① 结构 / 数值层(coding 离线自查)**:
  - build 通过;
  - 几何 / token / 文本码点(弯引号 / 实体 / 大小写)/ 切图引用一致;
  - 代码落位 `app/`;
  - Docker 产物齐备,条件允许 `docker build` 可成功。
- **② 视觉渲染层**:交给 `verify` + 人,**coding 不独自兜底**。

## 完成标志
目标 section 代码完成、结构 / 数值层自查通过;视觉层由 `verify` + 人裁定。
