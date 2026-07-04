# codeflow 大一统重组设计

日期：2026-07-05
状态：待实施
来源：将 mattpocock/skills `skills/engineering` 主流程（idea→ship 交付链）融合进本仓库，并借机重组既有同族技能。

## 1. 背景与问题

本仓库此前已从 mattpocock/skills 收窄式内化了一批技能：`engineering`（design-rules、domain-modeling、improve-arch、grilling）、`support:handoff`、以及呼应其 grilling 原语的 `project:grill`。这次要补的是主流程缺口——交付链（prototype、to-prd、to-issues、implement、tdd、code-review）与追踪器配置层。

若交付链另起新插件，会产生三处结构性摩擦：

1. **词汇跨插件**：tdd/review/to-prd 全程使用 design-rules 的 seam/interface 词汇，而跨插件不可用相对路径，只能按名引用 + README 声明前置。
2. **文档根分裂**：交付链要读写 CONTEXT.md/ADR，但它们收在 `docs/jljskills/engineering/` 下，新插件按约定得另开根目录。
3. **重复未消**：原版 grill-with-docs ≈ 本仓库 grill + domain-modeling，重复只被绕开，没被消解。

根因：既有布局是「按来源分插件」（先复刻的放 engineering、自创的放 project），而这族技能的引用密度要求「按引用密度分插件」。

## 2. 目标结构

新建 `codeflow` 插件（编码工作流 idea→ship，13 个 skill），`engineering` 插件退役删除，`project:grill` 迁入 codeflow。

```
plugins/
├─ project/          通用思考（瘦身）
│   ├─ interview2doc  （不动）
│   └─ loopspec       （只改文案：grill 指向 /codeflow:grill）
├─ codeflow/ ★新建   编码工作流 idea→ship
│   【地基层】design-rules · domain-modeling
│   【入口层】grill（迁入）· grill-with-docs ★
│   【交付链】config★ · to-prd★ · to-issues★ · implement★ · tdd★ · review★ · prototype★
│   【健康层】improve-arch · grill-design（grilling 更名）
├─ figma2web / figma-optimize / support   （均不动）
└─ engineering/      ✂ 退役删除
```

- 目录扁平，分层结构靠插件 README 管线总览表达（同 figma2web 范式）。
- 族内引用全部为插件内相对路径；跨插件仅剩一条弱依赖：`/project:interview2doc` 作为可选前置（README 声明）。
- 已拍板命名：插件名 `codeflow`；`grilling` 更名 `grill-design`；双轴审查叫 `review`。
- grill 家族谱系：`grill`（拷问方案）→ `grill-with-docs`（拷问 + 落笔）→ `grill-design`（拷问设计树）。

## 3. 十三个 skill 处置清单

| skill | 处置 | 要点 |
|---|---|---|
| design-rules | 平移 | 内容原样；其余 skill 以 `../design-rules/` 引用 |
| domain-modeling | 平移 + 改文档根 | 文档根 `docs/jljskills/engineering/` → `docs/jljskills/codeflow/` |
| improve-arch | 平移 + 改文档根 + 改指路 | 第三阶段指路 grilling → grill-design |
| grilling → grill-design | 平移 + 更名 | 目录名、frontmatter name、description 中的调用指令三处同步改 |
| grill | 从 project 迁入 | 本体不动；description 中 `/project:grill` → `/codeflow:grill` |
| grill-with-docs ★ | 新建（约十行组合子） | 跑 grill，同时按 domain-modeling 当场落笔术语/ADR；主流程一号位 |
| config ★ | 新建（收窄自原版 setup） | 见 §4 |
| to-prd ★ | 新建（移植） | 见 §4 |
| to-issues ★ | 新建（移植） | 见 §4 |
| implement ★ | 新建（移植） | 见 §4 |
| tdd ★ | 新建（移植） | 见 §4 |
| review ★ | 新建（移植自 code-review） | 见 §4 |
| prototype ★ | 新建（移植） | 见 §4 |

全部 13 个遵守家规：`disable-model-invocation: true`；description 写清「做什么 + 何时触发（仅当用户主动用 `/codeflow:<skill>` 调用、或另一 skill 显式指路时）」；`allowed-tools` 收窄；简体中文收窄式内化，不逐字翻译；长方法/模板下沉 `references/*.md`。

## 4. 新建七件的移植要点

**config**（收窄自 setup-matt-pocock-skills）
- 只管一件事：issue 追踪器形态。二选一：**GitHub**（gh CLI 操作 Issues）或**本地 markdown**（`docs/jljskills/codeflow/issues/` 下一 issue 一文件）。GitLab/自定义分支不搬。
- 探索仓库现状（git remote、既有 `docs/jljskills/codeflow/`）→ 向用户确认 → 写 `docs/jljskills/codeflow/issue-tracker.md`。
- triage 标签体系不搬（triage 不在本次范围）；to-issues 发布的 issue 直接视为 agent-ready。
- 检测到旧根 `docs/jljskills/engineering/` 存在时，提示一句 `mv` 迁移；不做自动迁移、不建兼容层。

**to-prd**
- 把当前对话综合成 PRD——明确禁止再采访用户。
- 保留原版两个关键设计：①「接缝先行」——先勾画测试 seam 并与用户确认，优先复用既有 seam、放最高处，全库理想数量为 1；②禁写具体文件路径与代码片段（易过期），唯一例外是原型产出的决策性片段（状态机/schema/类型形状），注明出处并裁到决策相关部分。
- PRD 模板（下沉 references/）：问题陈述 / 方案 / 用户故事（长编号清单，As-a/I-want/So-that）/ 实现决策 / 测试决策 / 范围外 / 附注。
- 发布到 issue 追踪器（按 issue-tracker.md）。词汇用 CONTEXT.md 的领域名词与 design-rules 术语。

**to-issues**
- 把 PRD/计划拆成可独立认领的 issue，强制曳光弹垂直切片：每片纵穿全部层（schema、API、UI、测试），完成即可独立演示；横切一律不准。
- 先向用户质检：粒度（过粗/过细）、依赖关系、该并该拆；迭代到用户认可。
- 按依赖序发布，Blocked by 引用真实 issue 标识。issue 模板（下沉 references/）：Parent / What to build / 验收标准 / Blocked by。
- 不关闭、不修改父 issue。

**implement**
- 薄编排（保持原版短小）：读 PRD + 单个 issue → 确认预约 seam → 驱动 `../tdd/` 逐片红绿 → 常跑类型检查与单文件测试、结尾跑一次全量 → `../review/` 审查 → commit 到当前分支。
- 「每 issue 开新会话执行」写进插件 README 的流程约定，跨会话衔接交给 `/support:handoff`。

**tdd**
- 红绿循环规则：red before green；一次一片（一 seam 一测试一最小实现）；重构不属于循环（归 review 阶段）。
- 只在预先与用户确认的 seam 上写测试；开工先问「public interface 是什么、测哪些 seam」。
- 三反模式写全：实现耦合（mock 内部协作者/测私有方法/侧信道验证）、同义反复（断言按实现同样的方式重算期望值）、横切先写全部测试。
- `references/tests.md`（好测试示例）、`references/mocking.md`（mock 准则），取材原版并本地化。
- 前置：Read `../design-rules/SKILL.md` 装载 seam 词汇；读 CONTEXT.md 使测试命名贴领域语言。

**review**（移植 code-review）
- 双轴：Standards（仓库成文规范 + Fowler 12 坏味道基线）与 Spec（忠实实现了源头 issue/PRD 吗——缺漏/蔓延/做错）。
- 先钉固定点：`git rev-parse` 验证、三点 diff、空 diff 或坏 ref 就地失败，不进子代理。
- Spec 溯源顺序：commit message 里的 issue 引用 → 用户传参 → docs 下匹配的 PRD → 问用户；无 spec 则该轴跳过并注明。
- 两轴并行子代理（general-purpose），提示词各带 diff 命令、来源材料、400 字内简报要求；坏味道基线全文塞给 Standards 子代理。
- 汇总时两轴并列呈现，**故意不合并排序**（防互相遮蔽）；结尾各轴一行小结。
- 12 坏味道基线（是什么→怎么修）下沉 `references/smells.md`；两条约束保留：仓库成文规范压过基线；基线永远是判断题不是硬违规，工具已强制的跳过。

**prototype**
- 「一次性代码回答一个设计问题」，先分流：逻辑/状态机 → `references/logic.md`（可交互终端小程序）；UI 长相 → `references/ui.md`（一路由多变体、URL 参数切换）。分不清且用户不在场时按周边代码判断并声明假设。
- 六铁律保留：天生即弃且显式标注、一条命令能跑、默认无持久化、不做打磨、每步呈现完整状态、答完即删或吸收。
- 收尾：只有「答案」值得留——落到 commit message/ADR/issue/NOTES.md，并记录它回答的问题。

## 5. 目标项目侧文档根

```
docs/jljskills/codeflow/
├─ CONTEXT.md            领域词汇表（domain-modeling 维护）
├─ adr/                  决策记录
├─ designs/              grill-design 落盘的 interface 草图
├─ issue-tracker.md      config 产出：追踪器形态声明
└─ issues/               本地 markdown 追踪器（选 GitHub 则无此目录）
```

交付链与健康层共用同一根。老项目的 `docs/jljskills/engineering/` 由用户手动 `mv` 迁移（config 会提示）。

## 6. 登记面与迁移动作（一次 commit 收口）

1. `.claude-plugin/marketplace.json`：删 engineering 条目，增 codeflow 条目。
2. 仓库 `README.md`：分类表、安装示例、目录树重写。
3. `CLAUDE.md`：地基 skill 示例 `engineering/design-rules` → `codeflow/design-rules`。
4. project 插件：loopspec 分工文案 `/project:grill` → `/codeflow:grill`；project README（如有登记）同步。
5. `git mv plugins/project/skills/grill plugins/codeflow/skills/grill`（迁入）；`git rm -r plugins/engineering`（退役，历史保留）——engineering 四个 skill 的内容以 `git mv` 方式进入 codeflow 后再删除空壳，保证 diff 可读。
6. codeflow 插件 README：管线总览（主流程图、每 skill 一句话、怎么选、与 project/support 的衔接、每 issue 新会话约定）。
7. commit message 注明破坏性变更：已装用户需 `/plugin uninstall engineering@jljskills` 后 `install codeflow@jljskills`。
8. 更新个人 memory：插件文档根约定、improve-arch 相关记忆中 engineering 的指向。

## 7. 范围外（明确不做）

- 不搬 triage / diagnosing-bugs / research / resolving-merge-conflicts / ask-matt（后续另议）。
- interview2doc、loopspec 留在 project，不迁。
- 不写向后兼容 shim；不自动迁移目标项目文档根。
- GitLab / Jira 等追踪器分支不搬。

## 8. 风险与对策

- **命名空间破坏**（/engineering:*、/project:grill 作废）：唯一使用者是作者本人，commit message + README 说明即可。
- **新旧文档根并存**：config 检测旧根并提示迁移，一次性成本。
- **13 skill 单插件的登记漂移**：README 目录树与 marketplace 登记在同一 commit 内改齐，遵守「三处登记」家规。
