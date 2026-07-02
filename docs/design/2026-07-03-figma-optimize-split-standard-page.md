# figma-optimize 拆分为 standard / page 设计文档

> 日期:2026-07-03 · 状态:已确认(待落地)
> 输入:[2026-07-02-figma-optimize-优化.md](./2026-07-02-figma-optimize-优化.md)(实战优化需求)+ 本轮拆分决策。

## 1. 背景 / 动机
`figma-optimize` 原本是单技能 `optimize`,交付前给 Figma 稿做「开发者思维」评审。实战中(评审 Casally 官网「命名规范」板 + 全量复查「设计规范」总板)发现:**评审「界面稿」和评审「设计规范板本身」是两类不同的工作**——前者审"界面对不对得上标准",后者审"标准本身成不成体系"。二者的 checklist、装载语义、报告形态都不同,揉在一个技能里既臃肿又互相牵制。

因此把 `optimize` 拆成两个自包含技能:
- **`standard`** —— 评审既有「设计规范板」本身(variables / text styles / 命名体系)。
- **`page`** —— 评审「界面稿」(脱胎自原 `optimize`)。

这本质上是把 [2026-07-02 优化文档] 中暂缓的「场景分级(交付 UI vs 内部规范板)」用**技能切分**实现。

## 2. 目标(Goals)
- 拆出 `standard` 与 `page` 两个技能,各自**完全独立、自包含**(各带完整 references,不跨技能引用,零 config 文件)。
- 把 2026-07-02 优化文档的四块经验**非对称分摊**进两技能。
- 删除原 `optimize` 技能,同步 `README.md`。

## 3. 非目标(Non-Goals)
- 不改核心心法 / 红线(HARD GATE 未确认不动 Figma、`use_figma` 前必走 `figma-use`、不生成代码、不做审美裁决、不读写 figma2web / `config.md`、不依赖 superpowers)。
- 两技能**不共享文件、不互相消费产物**;`page` 每次现场从规范板抽标准,不读 `standard` 的输出。
- cookbook 不做成一份共享文件;按各技能实际用到的配方**裁剪成两份**。
- 不做全自动无人评审。

## 4. 决策记录(本轮已确认)
| 决策点 | 结论 |
|---|---|
| `standard` 职责 | **评审既有规范板**(对标 `page` 审界面的做法),非从零构建标准。 |
| 两技能关系 | **完全独立**,各自现场抽取,零 config,各出各的报告。 |
| cookbook 处理 | **按技能裁剪成两份**,非整份复制,降低漂移风险。 |
| S 维度覆盖 | S-A~S-E 五维已确认覆盖足够。 |
| F 严重度默认 | 采用优化文档建议:F3 缺失字体=高,F4 非标字体混入=中。 |

## 5. 目标文件结构
删除 `plugins/figma-optimize/skills/optimize/`,新建:

```
plugins/figma-optimize/skills/
├── standard/                    # /figma-optimize:standard
│   ├── SKILL.md
│   └── references/
│       ├── flow.md
│       ├── checklist.md          # 体系向:S-A~S-E
│       ├── figma-api-cookbook.md # standard 向配方
│       └── report-template.md    # 标准体系评审报告
└── page/                        # /figma-optimize:page(脱胎自 optimize)
    ├── SKILL.md
    └── references/
        ├── flow.md
        ├── checklist.md          # 界面向:A–H(F 维度重写)
        ├── figma-api-cookbook.md # page 向配方
        └── report-template.md    # 交付就绪报告 + 可选「关联标准板复查」章节
```

两技能均 `disable-model-invocation: true`,仅显式 `/…` 调用;`allowed-tools` 同原 optimize(`Read, Grep, Glob, Write, Edit, AskUserQuestion, mcp__plugin_figma_figma`)。

## 6. 优化文档四块经验的分摊
| 经验 | page | standard |
|---|---|---|
| ① 三源级联装载标准 | ✅ P1 核心:先找规范板当权威标准 → `use_figma` 读全量 `getLocalVariableCollectionsAsync` / `getLocalVariablesAsync` / `getLocalTextStylesAsync` → `get_variable_defs` 仅快览/兜底 | ✅ 同一组 API,但规范板是**审计对象**而非参照 |
| ② 库变量误判(`get_variable_defs` 把库变量显成裸 hex) | ⚠️ 装载时用 `fills[].boundVariables` 辨别,别误判硬编码 | ✅✅ **S-B 核心检查项** |
| ③ 字体检测 + 归正(F3/F4) | ✅✅ P2 逐段 `getStyledTextSegments(['fontName','fontSize'])` + `node.hasMissingFont`;归正时**只 load 目标字体,别 load 缺失字体**(否则抛错整脚本原子回滚),中文经自动回退渲染;仅"改成云端不可用字体"才降级为建议 | ✅ S-D:text styles 字体族标准性(非标字体混入、缺失字体) |
| ④ 多板报告 | ✅ 报告加可选「附:关联标准板复查」章节 | —(standard 本就是单板体系报告) |

## 7. 各技能内容规格

### 7.1 `page`(脱胎自 `optimize`)
- **SKILL.md**:用途=交付前评审**界面稿**;心法/红线沿用原 optimize;「装载项目标准」改为**三源级联从规范板抽标准**。
- **flow.md**:
  - P0 前置校验(figma-mcp 可用;索取待审界面链接/范围,不落盘)。
  - P1 **三源级联装载标准**(改写):① 先问/找「设计规范板/页」当权威标准 → ② `use_figma` 读全量 variables/textStyles → ③ `get_variable_defs` 兜底;警示库变量误判。
  - P2 逐区块提取 + 评审,**新增逐段字体检测**(`getStyledTextSegments` + `hasMissingFont`)。
  - P3 逐条裁定(HARD GATE)。
  - P4 采纳项二次选择(我自改 / AI 改)。
  - P5 写回(含字体归正配方,别 load 缺失字体;指向 cookbook)。
  - P6 复审(数值类归零或标注例外)。
  - P7 交付就绪报告(可选落盘 `docs/figma-optimize/`)。
- **checklist.md**:A 结构 / B 切图友好 / C 色彩 / D 间距网格 / E 圆角阴影描边 / **F 字体文本(重写)** / G 命名语义 / H 组件化。
  - F 重写:F1 字号/行高游离字阶(中)、F2 字体族不一致(中)、**F3 缺失字体(高·可修)**、**F4 非标字体混入(中·可修)**。保留 snap 网格例外护栏。
- **figma-api-cookbook.md**(page 向):装载标准(读全量变量/样式)、逐段字体/字号审计、`hasMissingFont`、跨页 `setCurrentPageAsync`、写回(`setBoundVariableForPaint` / `setRangeFontName` / `setRangeFontSize` / 组件化 / auto-layout 重构)、字体归正坑、纪律(原子性、逐步校验)。
- **report-template.md**:交付就绪报告 + **可选「附:关联标准板复查」章节**。

### 7.2 `standard`(新建)
- **SKILL.md**:用途=交付/维护前评审**设计规范板本身**,AI 作**标准体系守门人**;只揪可验证的体系问题,取值/审美归设计师;红线同源。
- **flow.md**:
  - P0 前置校验(figma-mcp 可用;索取**规范板**链接/范围)。
  - P1 **读全量体系**:`use_figma` 读 `getLocalVariableCollectionsAsync` / `getLocalVariablesAsync` / `getLocalTextStylesAsync`;`get_variable_defs` 快览;**辨 token vs 裸 hex**(库变量误判坑)是核心。
  - P2 逐维度评审(S-A~S-E)。
  - P3 逐条裁定(HARD GATE)。
  - P4 采纳项二次选择。
  - P5 写回(重命名变量 / 绑定 / 收敛 token;指向 cookbook)。
  - P6 复审。
  - P7 标准体系评审报告。
- **checklist.md**(体系向):
  - **S-A 变量集合完整性**——色 / 字阶 / 间距 / 圆角是否成体系、有无缺档。
  - **S-B token 化纯净度**——规范板内游离裸色 / 未绑定值;`get_variable_defs` 库变量误判坑,须用 `boundVariables` 辨别。
  - **S-C 命名规范**——变量命名语义 / 层级 / 一致性(呼应「命名规范」板实战)。
  - **S-D 字阶 & 字体标准**——text styles 完整性 + 字体族标准性(非标字体混入、缺失字体)。
  - **S-E 收敛**——重复 / 近似 token 应合并。
- **figma-api-cookbook.md**(standard 向):读全量集合/变量/样式、`getVariableByIdAsync` + `valuesByMode` 取解析值、`boundVariables` 辨 token、变量重命名 / 收敛 / 绑定配方、纪律(原子性、逐步校验)。
- **report-template.md**:标准体系评审报告(体系快照 + 发现与处置 + 保留例外 + 给「界面评审 / 开发」的 TL;DR)。

## 8. 文档 / 登记更新
- `README.md`:
  - 「调用」示例:`/figma-optimize:optimize` → 换成 `/figma-optimize:standard`、`/figma-optimize:page`。
  - 目录树:`skills/optimize/` → `skills/standard/` + `skills/page/`。
- `marketplace.json` / `plugin.json`:**无需改**(登记的是 plugin,skill 自动发现)。
- `docs/design/2026-07-02-figma-optimize-优化.md`:顶部加一行指针「已由本拆分方案(2026-07-03)纳入」,正文不动。

## 9. 成功标准
- `/figma-optimize:standard` 与 `/figma-optimize:page` 均可独立调用,各自 references 齐全、自包含。
- 三处 name 一致(目录名 / frontmatter `name` / 命名空间),两技能均 `disable-model-invocation: true`。
- 优化文档四块经验按 §6 落到对应技能。
- 原 `optimize` 已删除,README 无残留 `optimize` 引用。
- 红线在两技能内原样保留。

## 10. 待办 / 开放问题
- 两份 cookbook 随经验增长是否再合并或拆分(暂各自维护)。
- `page` 报告的「关联标准板复查」与 `standard` 报告是否将来做成可衔接引用(本轮不做)。
