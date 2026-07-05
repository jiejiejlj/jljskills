# 落盘判据（ADR-0004）与思想基石重组（ADR-0005）设计

日期：2026-07-05
状态：待实施
来源：support 文档根收敛讨论升格出两条判据级决策，与 codeflow 思想基石重组合并一轮执行。

## 0. 已拍板决策

- 产出落盘判据立 ADR：**文档**统一 `docs/jljskills/<plugin>/`（写死不再问）、**代码/配置**按项目结构、**临时物**进 OS 临时目录。
- 思想基石采用**一思想一 skill**（否决大一统思想库），`design-` 前缀 + 精确命名；行为 skill 以具名小节「**驱动思想**」声明驱动力。
- `design-rules` → **`design-deep-module`**；`domain-modeling` **拆分**为 `design-domain-model`（思想）+ **`build-context`**（行为，动词+名词命名——用户钦定）。

## 1. Commit 序（每个独立可校验，终审后单次 push）

### C1 本仓旧根迁移
`git mv docs/jljskills/engineering docs/jljskills/codeflow`（ADR-0001~0003、designs/、CONTEXT.md 等存量全迁）。这正是 config skill 旧根检测设计要提示的 mv，本仓自己先做掉。迁移后 grep 仓内活文档（plugins/、CLAUDE.md、README、memory 除外的引用）确认无断链；docs/design、docs/superpowers 历史文档不改写（家规先例）。

### C2 ADR-0004 + support 收敛（Batch A）
- 新增 `docs/jljskills/codeflow/adr/0004-技能产出按文档与代码分流落盘.md`，体例对齐 ADR-0003（正文判据 + Considered Options 记否决）。判据三分类：文档（人读沉淀物）→ `docs/jljskills/<plugin>/` 写死不问；代码/配置（工具链消费：源码、registry、settings.json、hook、CLAUDE.md 段落）→ 项目结构；临时物（一次性 HTML 报告、handoff 便签）→ OS 临时目录不入库。否决三条：逐次询问（散落无从清理，「怕污染」被统一根化解）、代码进文档根（工具链消费即失效，registry.json 先例）、不立判据逐个约定（四轮重复讨论）。
- interview2doc：删「先问落盘位置」步骤，路径写死 `docs/jljskills/support/interview2doc/<YYYY-MM-DD>-<主题>.md`（主题名自拟交用户确认保留——内容层非路径层）。
- loopspec：工作区写死 `docs/jljskills/support/loopspec/`（下辖 `workflows/*.md`、`NOTES.md`），删「先跟用户定工作区」。
- handoff / git-policy：按 ADR 分属临时物 / 配置侧，不改（豁免即设计）。
- CLAUDE.md「SKILL.md 写法」节加一行落盘判据 + 指 ADR-0004；顺修一处退役残留：「参考成熟样例 `plugins/project/skills/interview2doc/`」→ `plugins/support/skills/interview2doc/`。
- 仓库 README support 行补文档根声明（与 codeflow 行同构）。

### C3 design-rules → design-deep-module 更名 + 驱动思想具名小节
- 目录、frontmatter name、description 内指令三处同步更名；references/ 随目录走。
- 全库指针清扫：`../design-rules/` 与 `/codeflow:design-rules` 的全部引用（tdd、to-prd、improve-arch、grill-design、diagnosing-bugs、prototype 如有、CLAUDE.md 示例、README 两处）→ design-deep-module。
- 各消费方把「前置：Read `../design-deep-module/SKILL.md` 装载词汇」升格为具名小节「**驱动思想**」（一行式即可，如「驱动思想：深模块——Read `../design-deep-module/SKILL.md`」；已有前置节的就地改名，无则补）。消费方以正向指针声明驱动力，不建反向清单。

### C4 domain-modeling 拆分
- **`design-domain-model`**（思想基石，体例对齐 design-deep-module）：通用语言判据（一词一义、单一权威、词汇表与代码一致）；三病灶识别特征（冲突/超载/模糊）；四手法判断内核（何时挑战/锐化/压测/对质）；ADR 三条件门槛；理论出处（DDD 通用语言）。纯 Read 装载，无文件操作。
- **`build-context`**（行为，承接原调用面）：开头具名小节「驱动思想：Read `../design-domain-model/SKILL.md`」；文件机制（`docs/jljskills/<plugin>/` 布局、单/多 context、惰性创建）；五动作执行规程（怎么当场落笔、不攒批、完成标准遗漏数为零）；`references/context-format.md`、`adr-format.md` 随机制走。
- 分工一句话写进两边：思想侧管「什么算坏了、什么值得记」，行为侧管「手怎么动、写到哪」。
- 消费方指针清扫：grill-with-docs、improve-arch、prototype（ADR 指路）、triage（如有）等处 `domain-modeling` → `build-context`（消费方只指行为 skill，思想由 build-context 自己声明）。
- 原 domain-modeling 目录删除；codeflow 16 → 17 skill。

### C5 ADR-0005 + 登记面收口
- 新增 `docs/jljskills/codeflow/adr/0005-思想基石skill的组织判据.md`：一思想一 skill、`design-` 前缀（前缀语义：design- 开头 = 思想基石；grill-design 为 design 结尾不冲突）、消费方以「驱动思想」小节声明驱动力。否决：大一统思想库（中间人/装载粒度错位/调用面尴尬/演化不可见）；思想与机制同居（两个变更理由=发散式变化，domain-modeling 拆分即先例）。重访触发器：思想数量达十余个且每个很薄时再议归并。
- codeflow README：地基层改三件（design-deep-module、design-domain-model 两思想 + build-context 记忆层）、17 skill、「怎么选」同步。
- 仓库 README：codeflow 行导览、目录树、调用示例（`/codeflow:design-rules` → `/codeflow:design-deep-module`）。
- marketplace.json 无需改（无插件级变化）。

## 2. 校验（每 commit 后跑相关项，C5 后全量）

name 一致脚本零 MISMATCH（预期 29 个 skill）；旧名清零：`grep -rn "design-rules\|domain-modeling" plugins/ README.md CLAUDE.md` 零命中（docs/superpowers 与 docs/design 历史文档豁免）；相对链接从各文件所在目录可达；「驱动思想」小节 grep 可数（预期 ≥5 处）；JSON 可解析；README 目录树对照 find。

## 3. 终审与收尾

全轮 diff 交一次终审 subagent（最强模型）复核，修完 push（单次）。事后：本设计文档状态翻新；memory 更新（plugin-doc-root-convention 改「全部收敛」挂 ADR-0004、codeflow-restructure 补思想基石重组、MEMORY.md 索引）。

## 4. 范围外

- 不动 handoff/git-policy 内容（豁免记录在 ADR-0004 即可）。
- docs/skill写作指南.md 本轮不改（判据真相源在 ADR，CLAUDE.md 留指针；指南若要收编另议）。
- 不为记忆层将来可能的多思想复用做预设计（张力已记 ADR-0005 重访触发器侧）。
