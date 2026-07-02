---
name: page
description: 交付前给 Figma **界面稿**做「开发者思维」评审:依内置评审清单 + 现场从「设计规范板」三源级联抽取的项目标准,逐区块揪出结构 / 切图 / 色彩 / 间距 / 字体等可验证问题,逐条经用户裁定后由 AI 写回 Figma 或给自改说明,复审并产一份交付就绪报告。仅当用户主动用 `/figma-optimize:page` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Write, Edit, AskUserQuestion, mcp__plugin_figma_figma
disable-model-invocation: true
---

# page — 交付前界面稿评审优化

## 用途
面向**设计师**,在把设计稿交付给开发之前,以「开发能不能顺畅实现」为尺度审查 Figma **界面稿**并帮改到位,弥合设计师 ↔ 开发者的交付鸿沟。AI 在这里充当**规则审计员 / 守门人**:补上设计师缺的那套开发视角,揪出可验证的规则、一致性、可实现性问题。

核心心法:**AI 只揪可验证的问题,审美决策权归设计师。** 评审既依据插件**内置评审清单**,也现场从「设计规范板」**三源级联抽取**项目标准;每条建议都得经用户裁定,**写回 Figma 前 HARD GATE 未确认不动手**。

## 何时运行
仅当用户主动用 `/figma-optimize:page` 指令调用时运行。前置:figma-mcp 可用(需读取,采纳项经 `use_figma` 写回;未认证先跑认证);拿到待审的 Figma 链接 / 范围。

**独立插件**:不依赖、不读写 figma2web 的任何产物(尤其 `config.md`),不作为其流程一环;不依赖 superpowers。

## 产物(本 skill 是唯一写者)
- `docs/figma-optimize/<页面>-<日期>.md` —— 交付就绪报告(可选落盘,报告阶段可改路径 / 不落盘)。作为递给开发的自查单与交接凭证。

## 流程骨架
1. **前置校验**:figma-mcp 可用(未认证先认证);向用户索取待审 Figma 链接 / 范围(不落盘,每次现问)。
2. **三源级联装载标准**:先问/找「设计规范板 / 页」当权威标准 → `use_figma` 读全量 variables/text styles → `get_variable_defs` 仅快览 / 兜底;抽不到退回内置通用清单,缺口对话补(零 config 文件)。
3. **逐区块提取 + 评审**:每区块 `get_metadata` + `get_screenshot` + `get_design_context`;数值类靠 `use_figma` 读 x/y/w/h/fills 审计,视觉 / 结构类靠截图;新增逐段字体检测。产带严重度的建议列表。
4. **逐条裁定(HARD GATE)**:逐区块、逐条呈交,用户选 采纳 / 跳过 / 再调;**写入 Figma 前必须确认,未确认不得改动**。
5. **采纳项二次选择**:每条采纳的问题,用户再选「我自改」还是「让 AI 改」。
6. **写回 / 自改说明**:「让 AI 改」→ **先走 `figma-use` skill** → `use_figma` 写入 → 每处 `get_screenshot` 校验;「我自改」→ 给可照做的明确改法说明。
7. **复审**:复审数值类项是否达标(理想归零,或仅剩有意保留、报告标注的例外)。
8. **交付就绪报告**:默认落 `docs/figma-optimize/`,报告阶段允许改路径 / 不落盘。

> 完整分阶段流程见 [references/flow.md](references/flow.md);内置评审清单见 [references/checklist.md](references/checklist.md);Figma API 配方见 [references/figma-api-cookbook.md](references/figma-api-cookbook.md);报告模板见 [references/report-template.md](references/report-template.md) —— **动笔前先读它们**。

## 红线
- **HARD GATE 未确认不动 Figma**;调用 `use_figma` 之前**必先走 `figma-use` skill**,每处改完 `get_screenshot` 校验。
- **不生成代码**、不做 design→code;**不读写 figma2web / `config.md`**,不复用其文件。
- **不替设计师做审美裁决**,不无中生有设计新界面 —— 只审既有稿并按用户裁定优化。
- 云端 Figma 字体类改动常受限 → **降级为「建议」**,报告标注「受限」,不强制;字体归正只 load **目标**字体,绝不 load 缺失字体(否则抛错整脚本原子回滚)。
- 数值类靠 `use_figma` 精确审计;对 hug 宽度、1px 描边、组件实例、矢量锚点等合理非网格值**不误报**。
