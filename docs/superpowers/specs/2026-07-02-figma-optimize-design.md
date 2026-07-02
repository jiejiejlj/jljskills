# figma-optimize 设计方案（spec）

> 日期:2026-07-02 · 状态:待用户评审
> 需求来源:[docs/design/2026-07-02-figma-optimize.md](../../design/2026-07-02-figma-optimize.md)

## 0. 本 spec 敲定的决策

在需求文档基础上,brainstorming 阶段敲定:

- **单 skill 插件**(非技能组):遵循需求文档非目标#31「首版不引入额外 skill」。入口 `figma-optimize:optimize`。
- **内置评审清单是净新资产**:figma2web 里并不存在 `optimize` skill 或现成清单,需求文档#77「相对 figma2web 版增删」因此作废——从零撰写。
- **报告落盘**:默认 `docs/figma-optimize/<页面>-<日期>.md`(与 `docs/figma2web/` 命名风格一致,但不读写 figma2web 任何产物,不构成耦合);报告阶段允许用户改路径或选择不落盘。
- **插件物理位置**:本仓库 `plugins/figma-optimize/`,并在 `.claude-plugin/marketplace.json` 登记。

## 1. 骨架结构(单 skill 插件)

```
plugins/figma-optimize/
├── .claude-plugin/plugin.json          # {name, description, author}
└── skills/optimize/
    ├── SKILL.md                        # 主流程骨架 + 红线
    └── references/
        ├── checklist.md                # 内置评审清单(核心资产,净新)
        ├── flow.md                     # 分阶段详细流程
        └── report-template.md          # 交付就绪报告模板
```

外加改动:`.claude-plugin/marketplace.json` 的 `plugins` 数组补一条 `figma-optimize`。

SKILL.md frontmatter:

- `name: optimize`
- `description`:做什么 + 何时触发,写明「仅当用户主动用 `/figma-optimize:optimize` 指令调用时使用」。
- `disable-model-invocation: true`
- `allowed-tools: Read, Grep, Glob, Write, Edit, AskUserQuestion, mcp__plugin_figma_figma`

SKILL.md 正文沿用仓库既有风格(参考 figma2web `config`/`verify`):`## 用途`(含核心心法)→ `## 何时运行` → `## 产物` → `## 流程骨架` → 引用 references → `## 红线`。较长内容(清单、分阶段流程、报告模板)放 references,主文件精炼。

## 2. 内置评审清单 `references/checklist.md`(核心资产)

以「利于开发落地成代码」为尺度,分维度、带优先级(P0/P1)与严重度(高/中/低)。**结构类 / 切图友好类 = P0**。

| 维度 | 代表项(严重度) | 判据方式 |
| --- | --- | --- |
| A 结构/布局 (P0) | 该用 auto-layout 处用绝对定位堆叠(高);冗余嵌套/空 group/无意义 wrapper(中);constraints/resizing 未设、响应式意图不明(中) | 截图 + `get_design_context` |
| B 切图友好 (P0) | 需导出资源未标 export settings / 未独立成节点(高);图标是位图或散乱矢量而非合并矢量/组件(高);图片资源命名无语义(中) | 截图 + `get_metadata` |
| C 色彩 (P0·数值) | 游离色:填充/描边颜色不在 variables/styles 色板内(高);硬编码透明度、重复色值未收敛为 token(中) | `use_figma` 读 fills |
| D 间距/网格 (P1·数值) | off-grid 间距/内边距,非网格基数且排除合理例外(中);同类间距近似值不统一,如 15/16/17 混用(中) | `use_figma` 读 x/y/w/h |
| E 圆角/阴影/描边 (P1·数值) | 游离于 token 的圆角/阴影(中);近似值不统一(低) | `use_figma` |
| F 字体/文本 (P1·受限降级) | 字号/行高游离于字阶(中);字体族不一致(中) | `use_figma`;云端受限 → 降级为建议 |
| G 命名/语义 (P1) | 图层命名无语义,如 Frame 5 / Rectangle 3(中);文本/形状语义角色不清(低) | `get_metadata` |
| H 组件化 (P1) | 重复元素应抽为 component 而非复制(中);应用 variant 表达状态而非并列多份(低) | `get_metadata` + 截图 |

**snap 网格例外(不误报)**:hug 宽度、1px 描边、组件实例内部、矢量锚点、图标细节等合理非网格值。

**数值类 vs 视觉/结构类**:数值类(色/间距/圆角/字号)靠 `use_figma` 读 x/y/w/h/fills 精确审计;视觉与结构类靠 `get_screenshot` + `get_design_context` 判断。

## 3. 运行时装载项目标准(零 config)

现场从待审 Figma 的 variables/styles 抽取色板 / 字体族 / 字号阶 / 间距网格基数等,作为**本次评审的项目标准**。抽不到则退回内置通用清单,缺口通过对话向用户补齐(至少色板 + 网格基数)。**不生成、不读写任何 config 文件**,不触碰 figma2web 的 `config.md`。

## 4. 主流程(SKILL.md 流程骨架 + `references/flow.md` 展开)

1. **前置校验**:figma-mcp 可用(未认证先跑认证);向用户索取待审 Figma 链接/范围(不落盘,每次现问)。
2. **装载项目标准**:抽 variables/styles → 色板/字阶/网格基数;无则退内置清单 + 对话补缺口。
3. **逐区块提取 + 评审**:对每区块 `get_metadata` + `get_screenshot` + `get_design_context`;数值类靠 `use_figma` 读 x/y/w/h/fills 审计,视觉/结构类靠截图。产出带严重度的建议列表:每条含 问题 / 改法 / 依据(清单编号) / 严重度。
4. **逐条裁定(HARD GATE)**:逐区块、逐条呈交,用户选 采纳 / 跳过 / 再调;**写入 Figma 前必须确认,未确认不得改动**。
5. **采纳项二次选择**:每条采纳的问题,用户再选「我自改」or「让 AI 改」。
6. **写回 / 自改说明**:
   - 「让 AI 改」→ **先走 `figma-use` skill(强制前置)** → `use_figma` 写入 → 每处改完 `get_screenshot` 校验。
   - 「我自改」→ AI 给出明确、可照做的改法说明,交设计师在 Figma 自行修改。
7. **复审**:复审数值类项是否达标(理想为审计列表归零,或仅剩有意保留、并在报告标注的例外)。
8. **交付就绪报告(可选落盘)**:默认落 `docs/figma-optimize/<页面>-<日期>.md`;报告阶段允许用户改路径或选择不落盘。

## 5. 报告模板 `references/report-template.md`(需求文档#76)

字段结构:

- **元信息**:页面/范围、Figma 链接、日期、项目标准来源(variables/styles / 人工补)。
- **项目标准快照**:本次抽到的色板 / 字阶 / 网格基数。
- **发现与处置表**:编号 ｜ 区块 ｜ 问题 ｜ 依据(清单编号) ｜ 严重度 ｜ 处置(已改-AI / 已改-自改 / 跳过 / 待改 / 受限建议)。
- **保留的例外**:有意保留的非标准值 + 理由。
- **复审结论**:数值类是否归零、剩余例外。
- **给开发的交接 TL;DR**:一句话可交付状态 + 需注意点。

## 6. 红线 & 降级

- 写回前 HARD GATE 未确认不动 Figma;`use_figma` 之前必先走 `figma-use` skill。
- 不生成代码;不读写 figma2web/`config.md`,不复用其文件,不作为其流程一环。
- 不替设计师做审美裁决;不无中生有设计新界面,只审既有稿并按用户裁定优化。
- 云端 Figma 字体类改动常受限 → 降级为「建议」,报告标注「受限」,不强制。

## 7. 成功标准(承接需求文档#8)

- 数值类审计项(off-grid、游离色、近似值不统一等)复审后归零,或仅剩用户有意保留且报告标注的例外。
- 结构类、切图友好类高严重度问题均已处置(改到位或明确跳过并记录)。
- 设计师拿报告后可直接交付开发,对接与实现摩擦显著降低。

## 8. 未决 / 需用户确认

- 报告落盘策略(默认 `docs/figma-optimize/` + 报告阶段可改/可不落盘)为 brainstorming 中的判断默认值,用户 AFK 未最终拍板,可评审时调整。
- 清单各维度阈值(如网格基数默认 8pt?近似值容差?)在 `checklist.md` 撰写时给默认,运行时以抽到的项目标准为准。
