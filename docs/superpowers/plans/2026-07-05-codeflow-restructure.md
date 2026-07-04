# codeflow 大一统重组实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新建 codeflow 插件（13 skill）承载 idea→ship 编码工作流，engineering 插件退役、project:grill 迁入、七个新 skill 移植自 mattpocock/skills。

**Architecture:** 纯 Markdown+JSON 配置仓库，无可运行代码；「测试」= 结构校验（frontmatter/目录名一致、相对链接可达、旧命名空间零残留、JSON 可解析）。设计的单一真相源是 `docs/superpowers/specs/2026-07-05-codeflow-restructure-design.md`（下称「设计文档」），执行每个任务前先读它的对应小节。

**Tech Stack:** Claude Code plugin marketplace（SKILL.md frontmatter 约定）、git、bash 校验一行命令。

## Global Constraints

- 全部内容**简体中文**，收窄式内化，不逐字翻译英文原版。
- 13 个 skill 一律 `disable-model-invocation: true`；description 必须写「做什么 + 何时触发」，何时触发含「仅当用户主动用 `/codeflow:<skill>` 指令调用时使用」（被其他 skill 指路的加「或 XX 显式指路时」）。
- 三处 name 一致：skill 目录名 = frontmatter `name` = 指令 `/codeflow:<name>`。
- 长方法/模板一律下沉 `references/*.md`，SKILL.md 用相对链接引用。
- 目标项目侧文档根统一为 `docs/jljskills/codeflow/`。
- 架构叙述用 design-rules 八术语，禁用词（component/service/API/boundary 等指 module/interface/seam 时）不许出现。
- 移植源仓库钉在 commit `272f99b22574f50e4266791c86b9302682970e23`，克隆到 `/tmp/mattpocock-skills-src`（下称 `$SRC`），源文件都在 `$SRC/skills/engineering/`。
- **工作区有本次无关的未提交改动（figma 系列文件）**：每次 commit 只 `git add` 本任务明确列出的路径，**严禁 `git add -A` / `git add .`**。
- 全程在 main 本地提交，**只在 Task 13 最后 push 一次**（本仓库 push 即发版）。
- 每个 skill 写完做 CLAUDE.md 家规自检：逐行 no-op 测试（与默认行为无差别的句子删掉）；对照失败模式（提前收工/重复/沉积/蔓延/空操作）。
- commit message 沿仓库风格（`feat(codeflow): ...` 等中文描述），结尾带 `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`。

---

### Task 1: 钉源 + 插件骨架

**Files:**
- Create: `plugins/codeflow/.claude-plugin/plugin.json`

**Interfaces:**
- Produces: `$SRC`（后续所有移植任务的源）；`plugins/codeflow/` 骨架（后续所有任务的落点）。

- [ ] **Step 1: 克隆并钉住源仓库**

```bash
git clone https://github.com/mattpocock/skills /tmp/mattpocock-skills-src
git -C /tmp/mattpocock-skills-src checkout 272f99b22574f50e4266791c86b9302682970e23
ls /tmp/mattpocock-skills-src/skills/engineering/
```
Expected: 列出 15 个技能目录 + README.md。

- [ ] **Step 2: 写 plugin.json**

```json
{
  "name": "codeflow",
  "description": "编码工作流 idea→ship 相关 skill（拷问 → PRD → 拆 issue → TDD 实施 → 双轴审查，含深模块方法论）",
  "author": { "name": "jiejiejlj" }
}
```

- [ ] **Step 3: 校验 JSON**

```bash
python3 -c "import json;json.load(open('plugins/codeflow/.claude-plugin/plugin.json'))" && echo OK
```
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/codeflow/.claude-plugin/plugin.json
git commit -m "feat(codeflow): 插件骨架——大一统重组开工（设计见 docs/superpowers/specs/2026-07-05）"
```

### Task 2: 平移 engineering 四件 + grilling 更名 grill-design

设计文档 §3 前四行。engineering 的四个 skill 内容基本原样，只改三类字符串。

**Files:**
- Move: `plugins/engineering/skills/{design-rules,domain-modeling,improve-arch}` → `plugins/codeflow/skills/`
- Move+Rename: `plugins/engineering/skills/grilling` → `plugins/codeflow/skills/grill-design`
- Delete: `plugins/engineering/`（README.md、.claude-plugin/plugin.json——README 内容 Task 12 重写进 codeflow README，此刻删除无损，git 历史在）
- Modify: 移过来的四个 SKILL.md 及其 references/*.md

**Interfaces:**
- Produces: `../design-rules/SKILL.md`（tdd/review/grill-design 的词汇地基）、`../domain-modeling/SKILL.md`（grill-with-docs 的落笔手册）、文档根 `docs/jljskills/codeflow/`。

- [ ] **Step 1: git mv 四个目录**

```bash
git mv plugins/engineering/skills/design-rules plugins/codeflow/skills/design-rules
git mv plugins/engineering/skills/domain-modeling plugins/codeflow/skills/domain-modeling
git mv plugins/engineering/skills/improve-arch plugins/codeflow/skills/improve-arch
git mv plugins/engineering/skills/grilling plugins/codeflow/skills/grill-design
git rm plugins/engineering/README.md plugins/engineering/.claude-plugin/plugin.json
```

- [ ] **Step 2: 逐处替换三类字符串**

先列出全部命中点，逐个用 Edit 改（散文语境多，禁用 sed 盲替）：

```bash
grep -rn "/engineering:" plugins/codeflow/skills/
grep -rn "grilling" plugins/codeflow/skills/
grep -rn "docs/jljskills/engineering" plugins/codeflow/skills/
```

替换规则：
1. `/engineering:<skill>` → `/codeflow:<skill>`（grilling 同时更名：`/engineering:grilling` → `/codeflow:grill-design`）。
2. 指 skill 名的 `grilling` → `grill-design`（含 grill-design/SKILL.md 的 frontmatter `name: grilling`、正文标题、improve-arch 第三阶段指路、各 description）；指「拷问动作」的普通词不改。
3. `docs/jljskills/engineering/` → `docs/jljskills/codeflow/`。

- [ ] **Step 3: 校验零残留 + name 一致**

```bash
grep -rn "/engineering:\|docs/jljskills/engineering" plugins/codeflow/ ; echo "exit=$?"
grep -n "^name:" plugins/codeflow/skills/grill-design/SKILL.md
```
Expected: 第一条 `exit=1`（无命中）；第二条输出 `name: grill-design`。

- [ ] **Step 4: Commit**

```bash
git add plugins/codeflow/skills
git commit -m "refine(codeflow): engineering 四件平移入驻，grilling 更名 grill-design，文档根收敛 docs/jljskills/codeflow/"
```

（`git mv`/`git rm` 的删除侧已自动暂存，无需也不可再 add 已消失的 `plugins/engineering` 路径。）

### Task 3: grill 迁入 + project 瘦身文案

**Files:**
- Move: `plugins/project/skills/grill` → `plugins/codeflow/skills/grill`
- Modify: `plugins/codeflow/skills/grill/SKILL.md`、`plugins/project/skills/loopspec/SKILL.md:17`、project 插件 README（如有 grill 登记）、`plugins/project/skills/interview2doc/SKILL.md`（如提及 grill）

**Interfaces:**
- Produces: `../grill/SKILL.md`（grill-with-docs 的拷问手法源）。

- [ ] **Step 1: git mv 并改命名空间**

```bash
git mv plugins/project/skills/grill plugins/codeflow/skills/grill
grep -rn "project:grill" plugins/
```
对每处命中用 Edit 改为 `/codeflow:grill`（含 grill 自己 description 里的调用指令、loopspec 第 17 行分工描述、interview2doc 与 project README 的提及）。

- [ ] **Step 2: 校验**

```bash
grep -rn "project:grill" plugins/ ; echo "exit=$?"
```
Expected: `exit=1`。

- [ ] **Step 3: Commit**

```bash
git add plugins/codeflow/skills/grill plugins/project
git commit -m "refine(codeflow): grill 从 project 迁入——与 domain-modeling 同居，为组合入口铺路"
```

### Task 4: 新建 grill-with-docs（组合入口）

设计文档 §2 grill 家族、§3。全文如下，直接落盘（这是完整内容，不是骨架）。

**Files:**
- Create: `plugins/codeflow/skills/grill-with-docs/SKILL.md`

**Interfaces:**
- Consumes: `../grill/SKILL.md`、`../domain-modeling/SKILL.md`（Task 2/3 产出）。

- [ ] **Step 1: 写 SKILL.md**

```markdown
---
name: grill-with-docs
description: 主流程入口：按 grill 的手法拷问方案，同时按 domain-modeling 当场沉淀术语与 ADR——拷问留下纸面痕迹。仅当用户主动用 `/codeflow:grill-with-docs` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, WebFetch, Edit, Write, AskUserQuestion
disable-model-invocation: true
---

# grill-with-docs — 拷问 + 落笔

Read `../grill/SKILL.md` 与 `../domain-modeling/SKILL.md`，然后：

- 按 grill 的流程拷问用户给的方案 / 计划 / 需求；
- 全程叠加 domain-modeling 的五个动作——术语一敲定当场写进 `docs/jljskills/codeflow/CONTEXT.md`，满足三条件门槛的决策当场记 ADR。

与两个成员 skill 的分工：只想拷问不留档 → `/codeflow:grill`；不在拷问、只想改领域模型 → `/codeflow:domain-modeling`。本 skill = 两者同时开动，是主流程（拷问 → to-prd → to-issues → implement）的一号位。
```

- [ ] **Step 2: 校验链接可达 + 自检**

```bash
test -f plugins/codeflow/skills/grill/SKILL.md && test -f plugins/codeflow/skills/domain-modeling/SKILL.md && echo OK
```
Expected: `OK`。随后做家规自检（no-op 逐行测试 + 失败模式对照）。

- [ ] **Step 3: Commit**

```bash
git add plugins/codeflow/skills/grill-with-docs
git commit -m "feat(codeflow): grill-with-docs 组合入口——拷问与落笔同步，主流程一号位"
```

### Task 5: 新建 config（追踪器配置）

设计文档 §4 config 节 + §5。源参考 `$SRC/skills/engineering/setup-matt-pocock-skills/`（只取 issue tracker 分支，砍 GitLab/自定义/triage 标签/domain docs 三节中的后两节——domain docs 布局已由 domain-modeling 自管）。

**Files:**
- Create: `plugins/codeflow/skills/config/SKILL.md`
- Create: `plugins/codeflow/skills/config/references/tracker-github.md`（源：`$SRC/.../issue-tracker-github.md` 本地化收窄）
- Create: `plugins/codeflow/skills/config/references/tracker-local.md`（源：`$SRC/.../issue-tracker-local.md`，本地路径改 `docs/jljskills/codeflow/issues/`）

**Interfaces:**
- Produces: 目标项目的 `docs/jljskills/codeflow/issue-tracker.md`（声明形态 + 操作方式），to-prd/to-issues/implement/review 开工前都读它。

- [ ] **Step 1: 写 SKILL.md**

frontmatter 逐字：

```markdown
---
name: config
description: 配置 codeflow 在目标项目的 issue 追踪器形态（GitHub 或本地 markdown），写成 docs/jljskills/codeflow/issue-tracker.md；每个项目跑一次即可。仅当用户主动用 `/codeflow:config` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, AskUserQuestion
disable-model-invocation: true
---
```

正文四节（照设计文档 §4 config 节展开）：
1. **探索**：`git remote -v` 看是否 GitHub 仓库；`docs/jljskills/codeflow/` 是否已有 issue-tracker.md（有则本次是改配置）；检测旧根 `docs/jljskills/engineering/` 存在时提示一句 `mv docs/jljskills/engineering docs/jljskills/codeflow`，不自动迁移。
2. **确认**：向用户解释两种形态后二选一（GitHub：gh CLI 操作 Issues，适合有远程/要跨设备；本地 markdown：`docs/jljskills/codeflow/issues/` 一 issue 一文件，适合纯本地）。有 GitHub remote 时默认提议 GitHub。
3. **落盘**：按所选形态，参照 references/tracker-github.md 或 tracker-local.md 写目标项目的 `docs/jljskills/codeflow/issue-tracker.md`（内容=形态声明+增删改查操作方式+agent-ready 的标记方式）。
4. **收尾**：告知哪些 skill 会读此文件；改追踪器就重跑本 skill。

- [ ] **Step 2: 写两个 references 模板**

`tracker-github.md`：gh CLI 的查/建/评论/关闭命令与 `ready-for-agent` label 用法（to-issues 发布即打此 label，视为 agent-ready）。
`tracker-local.md`：issues/ 目录一 issue 一文件 `NNN-<slug>.md`，frontmatter 含 `status: open|closed` 与 `agent_ready: true|false`、`blocked_by: []`；查=Glob/Grep，建=Write 下一个编号。

- [ ] **Step 3: 校验 + 自检 + Commit**

```bash
grep -c "references/tracker-" plugins/codeflow/skills/config/SKILL.md
git add plugins/codeflow/skills/config
git commit -m "feat(codeflow): config——issue 追踪器双形态配置（GitHub / 本地 markdown），收窄自原版 setup"
```
Expected: grep 计数 ≥2（两个模板都被引用）。

### Task 6: 新建 to-prd

设计文档 §4 to-prd 节。源：`$SRC/skills/engineering/to-prd/SKILL.md`。

**Files:**
- Create: `plugins/codeflow/skills/to-prd/SKILL.md`
- Create: `plugins/codeflow/skills/to-prd/references/prd-template.md`

**Interfaces:**
- Consumes: `docs/jljskills/codeflow/issue-tracker.md`（Task 5 契约）、CONTEXT.md 领域词汇、`../design-rules/SKILL.md` 术语。
- Produces: 发布在追踪器上的 PRD（implement/review 的 Spec 源头）。

- [ ] **Step 1: 写 SKILL.md**

frontmatter 逐字：

```markdown
---
name: to-prd
description: 把当前对话综合成 PRD 并发布到 issue 追踪器——不再采访用户，只做综合；测试 seam 先行并与用户确认。仅当用户主动用 `/codeflow:to-prd` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Bash, Write, AskUserQuestion
disable-model-invocation: true
---
```

正文要点（顺序即流程）：
1. **只综合不采访**——素材是当前对话与代码库认知；缺口标注为开放问题，不开新一轮访谈（想访谈回 `/project:interview2doc` 或 `/codeflow:grill-with-docs`）。
2. **seam 先行**：勾画测试 seam，优先复用既有 seam、放可行的最高处，全库理想数量是 1；与用户确认后才写 PRD。词汇 Read `../design-rules/SKILL.md`。
3. **写 PRD**：按 references/prd-template.md；领域名词用 `docs/jljskills/codeflow/CONTEXT.md` 的；禁写具体文件路径与代码片段（易过期），唯一例外：原型产出的决策性片段（状态机/schema/类型形状），注明来自原型、裁到决策相关部分。
4. **发布**：按 issue-tracker.md 发布，标记 agent-ready；追踪器未配置则先指路 `/codeflow:config`。

- [ ] **Step 2: 写 prd-template.md**

七节：问题陈述（用户视角）/ 方案（用户视角）/ 用户故事（长编号清单，`作为<角色>，我想要<功能>，以便<收益>`，覆盖尽量全）/ 实现决策（module 与 interface 变更、架构决策、schema、API 契约——不含文件路径）/ 测试决策（好测试标准=只测外部行为、测哪些 module、仓库内既有先例）/ 范围外 / 附注。

- [ ] **Step 3: 校验 + 自检 + Commit**

```bash
test -f plugins/codeflow/skills/to-prd/references/prd-template.md && echo OK
git add plugins/codeflow/skills/to-prd
git commit -m "feat(codeflow): to-prd——对话综合成 PRD，seam 先行、禁路径禁代码"
```

### Task 7: 新建 to-issues

设计文档 §4 to-issues 节。源：`$SRC/skills/engineering/to-issues/SKILL.md`。

**Files:**
- Create: `plugins/codeflow/skills/to-issues/SKILL.md`
- Create: `plugins/codeflow/skills/to-issues/references/issue-template.md`

**Interfaces:**
- Consumes: PRD（Task 6 产出）、issue-tracker.md 契约。
- Produces: 追踪器上可独立认领、agent-ready 的 issue 集（implement 的工作单元）。

- [ ] **Step 1: 写 SKILL.md**

frontmatter 逐字：

```markdown
---
name: to-issues
description: 把 PRD 或计划拆成曳光弹式垂直切片 issue——每片纵穿全部层、完成即可独立演示；质检粒度与依赖后按依赖序发布到 issue 追踪器。仅当用户主动用 `/codeflow:to-issues` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Bash, Write, AskUserQuestion
disable-model-invocation: true
---
```

正文要点：
1. **取材**：优先当前对话里的 PRD；用户传 issue 引用/路径则按 issue-tracker.md 取全文。
2. **垂直切片铁律**：每片纵穿全部集成层（schema、API、UI、测试），横切一律不准；完成即可独立演示或验证；prefactor（先让改动变容易）单列并排最前。
3. **质检**：编号清单呈现（标题/Blocked by/覆盖的用户故事），问用户三件事——粒度对不对、依赖对不对、该并该拆——迭代到认可。
4. **发布**：按依赖序（先被依赖者）发布，Blocked by 填真实 issue 标识；标记 agent-ready；不关闭不修改父 issue。

- [ ] **Step 2: 写 issue-template.md**

四节：Parent（源头 issue 引用，无则省）/ 要构建什么（端到端行为描述，不按层展开；禁文件路径与代码，原型决策性片段例外）/ 验收标准（checkbox 清单）/ Blocked by（真实标识或「无——可立即开工」）。

- [ ] **Step 3: 校验 + 自检 + Commit**

```bash
test -f plugins/codeflow/skills/to-issues/references/issue-template.md && echo OK
git add plugins/codeflow/skills/to-issues
git commit -m "feat(codeflow): to-issues——曳光弹垂直切片拆解，质检后按依赖序发布"
```

### Task 8: 新建 tdd

设计文档 §4 tdd 节。源：`$SRC/skills/engineering/tdd/`（SKILL.md、tests.md、mocking.md 三件都本地化）。

**Files:**
- Create: `plugins/codeflow/skills/tdd/SKILL.md`
- Create: `plugins/codeflow/skills/tdd/references/tests.md`
- Create: `plugins/codeflow/skills/tdd/references/mocking.md`

**Interfaces:**
- Consumes: `../design-rules/SKILL.md`（seam 词汇）、CONTEXT.md（测试命名贴领域语言）。
- Produces: `../tdd/SKILL.md`（implement Step「驱动 tdd」的被指路对象）。

- [ ] **Step 1: 写 SKILL.md**

frontmatter 逐字：

```markdown
---
name: tdd
description: 红绿循环的规则手册：只在预先确认的 seam 上写测试、一次一片、三反模式禁区；红在绿前，重构不属于循环。仅当用户主动用 `/codeflow:tdd` 指令调用、或 implement 显式指路时使用。
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, AskUserQuestion
disable-model-invocation: true
---
```

正文要点：
1. **前置**：Read `../design-rules/SKILL.md` 装载 seam 词汇；读 `docs/jljskills/codeflow/CONTEXT.md`（存在则）让测试名与 interface 词汇贴领域语言；尊重涉及区域的 ADR。
2. **好测试是什么**：透过 public interface 验证行为、不碰实现细节；读起来像规格说明；重构后存活。细则见 references/tests.md 与 references/mocking.md。
3. **seam 预约**：只在预先与用户确认的 seam 上写测试；开工先问「public interface 是什么、测哪些 seam」；未确认的 seam 一律不写。
4. **三反模式**：实现耦合（mock 内部协作者/测私有方法/侧信道验证——重构就红是其标志）；同义反复（断言按实现同样的方式重算期望值，期望值必须来自独立真相源）；横切（先写全部测试再写全部实现——改为垂直切片，一测试一实现一循环）。
5. **循环规则**：红在绿前，只写刚好让测试过的代码；一次一片（一 seam 一测试一最小实现）；重构不属于循环，归 `/codeflow:review` 阶段。

- [ ] **Step 2: 写 references 两件**

`tests.md`：好/坏测试对照示例（源文件本地化，示例代码保留 TypeScript）。
`mocking.md`：mock 准则（何时 mock——seam 处的外部依赖；何时不 mock——内部协作者），源文件本地化。

- [ ] **Step 3: 校验 + 自检 + Commit**

```bash
grep -c "references/" plugins/codeflow/skills/tdd/SKILL.md
git add plugins/codeflow/skills/tdd
git commit -m "feat(codeflow): tdd——红绿循环规则手册，seam 预约 + 三反模式"
```
Expected: grep 计数 ≥2。

### Task 9: 新建 review（双轴审查）

设计文档 §4 review 节。源：`$SRC/skills/engineering/code-review/SKILL.md`（更名 review）。

**Files:**
- Create: `plugins/codeflow/skills/review/SKILL.md`
- Create: `plugins/codeflow/skills/review/references/smells.md`

**Interfaces:**
- Consumes: issue-tracker.md（Spec 溯源）、PRD/issue（Task 6/7 产出）。
- Produces: `../review/SKILL.md`（implement 收尾的被指路对象）。

- [ ] **Step 1: 写 SKILL.md**

frontmatter 逐字：

```markdown
---
name: review
description: 对 HEAD 到固定点的 diff 做双轴审查——Standards（仓库成文规范 + Fowler 坏味道基线）与 Spec（忠实实现了源头 issue/PRD 吗），两轴并行子代理、报告并列不合并排序。仅当用户主动用 `/codeflow:review` 指令调用、或 implement 显式指路时使用。
allowed-tools: Read, Grep, Glob, Bash, Agent, AskUserQuestion
disable-model-invocation: true
---
```

正文五节（保留原版流程骨架）：
1. **钉固定点**：用户给什么钉什么（SHA/分支/tag），没给就问；`git rev-parse <固定点>` 验证、`git diff <固定点>...HEAD`（三点）+ `git log <固定点>..HEAD --oneline`；坏 ref 或空 diff 就地失败，不进子代理。
2. **找 Spec 源**：顺序=commit message 里的 issue 引用（按 issue-tracker.md 取）→ 用户传参路径 → docs 下匹配分支/特性的 PRD → 问用户；确认无 spec 则 Spec 轴跳过并在报告注明。
3. **找 Standards 源**：仓库内成文规范（CONTRIBUTING、CODING_STANDARDS 等）+ 恒带 references/smells.md 基线；两条约束——仓库成文规范压过基线、基线永远是判断题不是硬违规；工具已强制的一律跳过。
4. **并行双子代理**：一条消息两个 Agent 调用（general-purpose）；各带 diff 命令与 commit 清单；Standards 侧附规范文件清单 + smells.md 全文（子代理够不到本 skill 的文件）；Spec 侧附 spec 全文或路径；简报要求各 400 字内、逐条引证（规范条文/spec 原句）。
5. **汇总**：`## Standards` 与 `## Spec` 并列呈现，**不合并、不重排**（防一轴遮蔽另一轴——规范全对可能做错了事，做对了事可能破坏规范）；结尾各轴一行小结，不选跨轴赢家。

- [ ] **Step 2: 写 smells.md**

Fowler 12 坏味道基线（源文件 §3 清单本地化），每条「是什么 → 怎么修」：神秘命名、重复代码、依恋情结、数据泥团、基本类型偏执、重复的 switch、霰弹式修改、发散式变化、夸夸其谈通用性、消息链、中间人、被拒绝的遗赠。

- [ ] **Step 3: 校验 + 自检 + Commit**

```bash
grep -c "references/smells.md" plugins/codeflow/skills/review/SKILL.md
git add plugins/codeflow/skills/review
git commit -m "feat(codeflow): review——双轴审查（Standards+Spec）并行子代理，坏味道基线沉 references"
```
Expected: grep 计数 ≥1。

### Task 10: 新建 implement（薄编排）

设计文档 §4 implement 节。源：`$SRC/skills/engineering/implement/SKILL.md`（原版仅 15 行，保持短小）。

**Files:**
- Create: `plugins/codeflow/skills/implement/SKILL.md`

**Interfaces:**
- Consumes: `../tdd/SKILL.md`（Task 8）、`../review/SKILL.md`（Task 9）、PRD+issue（Task 6/7 产出）、issue-tracker.md。

- [ ] **Step 1: 写 SKILL.md（全文如下，直接落盘）**

```markdown
---
name: implement
description: 按 PRD 与单个 issue 实施一片工作：在预约 seam 上驱动 tdd 逐片红绿，完工跑 review 双轴审查后提交。仅当用户主动用 `/codeflow:implement` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Agent, AskUserQuestion
disable-model-invocation: true
---

# implement — 按 issue 实施

实施用户指定的 PRD / issue 描述的工作（按 `docs/jljskills/codeflow/issue-tracker.md` 取全文；一次只做一个 issue）。

1. 确认本片工作的预约 seam（PRD 测试决策里有则沿用，没有则先与用户确认）。
2. Read `../tdd/SKILL.md`，在预约 seam 上按它逐片红绿推进。
3. 类型检查与单测试文件常跑，全量测试套件收尾跑一次。
4. 完工 Read `../review/SKILL.md` 做双轴审查（固定点=本次开工前的 commit），处理发现的问题。
5. commit 到当前分支；issue 状态按 issue-tracker.md 更新。

多 issue 的工程每个 issue 开新会话执行（issue 已独立可认领），跨会话衔接用 `/support:handoff`——见插件 README 的流程约定。
```

- [ ] **Step 2: 校验 + 自检 + Commit**

```bash
test -f plugins/codeflow/skills/tdd/SKILL.md && test -f plugins/codeflow/skills/review/SKILL.md && echo OK
git add plugins/codeflow/skills/implement
git commit -m "feat(codeflow): implement——薄编排：seam 确认 → tdd 红绿 → review 双轴 → 提交"
```

### Task 11: 新建 prototype

设计文档 §4 prototype 节。源：`$SRC/skills/engineering/prototype/`（SKILL.md、LOGIC.md、UI.md 三件本地化）。

**Files:**
- Create: `plugins/codeflow/skills/prototype/SKILL.md`
- Create: `plugins/codeflow/skills/prototype/references/logic.md`（源 LOGIC.md）
- Create: `plugins/codeflow/skills/prototype/references/ui.md`（源 UI.md）

- [ ] **Step 1: 写 SKILL.md**

frontmatter 逐字：

```markdown
---
name: prototype
description: 用一次性代码回答一个设计问题：验证逻辑/状态机走可交互终端小程序，探索 UI 长相走一路由多变体；答案留下，代码删掉。仅当用户主动用 `/codeflow:prototype` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, AskUserQuestion
disable-model-invocation: true
---
```

正文要点：
1. **先分流**（选错分支整个原型白做）：「这套逻辑/状态模型对吗」→ references/logic.md；「这东西该长什么样」→ references/ui.md。分不清且用户不在场：按周边代码判断（后端 module→逻辑；页面/组件→UI）并在原型顶部声明假设。
2. **六铁律**：天生即弃且命名可见是原型（放在被验证的 module/页面旁边，沿项目既有路由约定）；一条命令能跑（沿项目既有任务运行器）；默认无持久化（要验证数据库时用带「PROTOTYPE——可清除」名字的草稿库）；不做打磨（无测试、无超出可运行的错误处理、无抽象）；每步呈现完整状态；答完即删或吸收进真代码。
3. **收尾**：只有答案值得留——连同它回答的问题一起落进 commit message/ADR/issue/原型旁 NOTES.md；用户不在场则留占位待验证后填。

- [ ] **Step 2: 写 references 两件**

`logic.md`：可交互终端小程序的做法（把状态机推过纸上难推的用例，逐步打印全量状态），源 LOGIC.md 本地化。
`ui.md`：一路由多个差异大的变体、URL search param 切换 + 底部浮条，源 UI.md 本地化。

- [ ] **Step 3: 校验 + 自检 + Commit**

```bash
grep -c "references/" plugins/codeflow/skills/prototype/SKILL.md
git add plugins/codeflow/skills/prototype
git commit -m "feat(codeflow): prototype——一次性代码答设计问题，逻辑/UI 双分流六铁律"
```
Expected: grep 计数 ≥2。

### Task 12: codeflow README 管线总览

参照 figma2web README 范式与原 engineering README（git 历史 `git show HEAD~N:plugins/engineering/README.md` 可取，或直接重写）。

**Files:**
- Create: `plugins/codeflow/README.md`

- [ ] **Step 1: 写 README**

必含六块：
1. 一段定位：内化自 mattpocock/skills 的 idea→ship 编码工作流；目标项目侧文档统一在 `docs/jljskills/codeflow/`（列出 CONTEXT.md/adr/designs/issue-tracker.md/issues/ 五项）。
2. 主流程图（文字版）：`grill-with-docs → [说不清就 prototype] → to-prd → to-issues → 每 issue 新会话 implement（内驱 tdd，收尾 review）`。
3. 13 个 skill 按四层各一句话：地基（design-rules、domain-modeling）/ 入口（grill、grill-with-docs）/ 交付（config、to-prd、to-issues、implement、tdd、review、prototype）/ 健康（improve-arch、grill-design）。
4. 「怎么选」清单（症状 → 指令），含 grill 三兄弟的分界：拷问方案→grill、拷问+落笔→grill-with-docs、拷问设计树→grill-design。
5. 流程约定：首次使用先 `/codeflow:config`；to-issues 之后每 issue 开新会话；跨会话用 `/support:handoff`。
6. 外部前置声明：可选上游 `/project:interview2doc`（想法还没成形时先梳理）；`/support:handoff`（跨会话）。

- [ ] **Step 2: 校验 + Commit**

```bash
grep -c "codeflow:" plugins/codeflow/README.md
git add plugins/codeflow/README.md
git commit -m "docs(codeflow): 管线总览 README——主流程/四层/怎么选/流程约定一览"
```
Expected: grep 计数 ≥13。

### Task 13: 登记面收口 + 全库校验 + push

设计文档 §6。本任务是发版 commit，做完才 push。

**Files:**
- Modify: `.claude-plugin/marketplace.json`、`README.md`、`CLAUDE.md`
- Modify（仓库外）: `~/.claude/projects/-home-king-github-jiejiejlj-jljskills/memory/` 下两个记忆文件

- [ ] **Step 1: marketplace.json 换条目**

删 engineering 条目，在原位置加：

```json
{
  "name": "codeflow",
  "source": "./plugins/codeflow",
  "description": "编码工作流 idea→ship 相关 skill"
}
```

- [ ] **Step 2: 仓库 README 重写登记**

分类表：删 engineering 行、增 codeflow 行（13 skill 一句话导览 + 前置依赖注明 project/support 可选）；project 行的 skill 清单去掉 grill；安装示例与目录树同步（目录树以 `find plugins -name SKILL.md | sort` 实际输出为准）。

- [ ] **Step 3: CLAUDE.md 改示例**

「共享内容一律做成本 plugin 内的地基 skill（如 `engineering/design-rules`、…）」中 `engineering/design-rules` → `codeflow/design-rules`。

- [ ] **Step 4: 全库结构校验**

```bash
for d in plugins/*/skills/*/; do n=$(basename "$d"); f=$(grep -m1 "^name:" "$d/SKILL.md" | sed 's/name: *//'); [ "$n" = "$f" ] || echo "MISMATCH: $d ($f)"; done; echo done
grep -rn "/engineering:\|project:grill\|docs/jljskills/engineering" plugins/ README.md CLAUDE.md ; echo "exit=$?"
python3 -c "import json;[json.load(open(p)) for p in ['.claude-plugin/marketplace.json','plugins/codeflow/.claude-plugin/plugin.json']];print('JSON OK')"
ls plugins/engineering 2>&1
```
Expected: 第一条只输出 `done`；第二条 `exit=1`；第三条 `JSON OK`；第四条 No such file or directory。

- [ ] **Step 5: 发版 commit + push**

```bash
git add .claude-plugin/marketplace.json README.md CLAUDE.md
git commit -m "feat(codeflow)!: 大一统重组收口——engineering 退役、grill 迁入、交付链上线

BREAKING CHANGE: 已装用户需 /plugin uninstall engineering@jljskills 与 project 更新，再 /plugin install codeflow@jljskills"
git push
```

- [ ] **Step 6: 更新个人 memory（仓库外，无需 commit）**

`plugin-doc-root-convention.md`：engineering 根改为 codeflow；`improve-arch-remaining-candidates.md`：skill 归属 `/engineering:improve-arch` → `/codeflow:improve-arch`；`codeflow-restructure.md`：状态改「已实施」并记收口 commit；`MEMORY.md` 索引行同步。

---

## 计划级校验（执行完 Task 13 后走一遍）

- [ ] 设计文档 §3 的 13 行处置清单逐行核对：每个 skill 在 `plugins/codeflow/skills/` 下存在且 name 三处一致。
- [ ] 设计文档 §7 范围外核对：仓库内不存在 triage/diagnosing-bugs/research 目录，interview2doc/loopspec 仍在 project。
- [ ] `/plugin marketplace update` + `/plugin install codeflow@jljskills` 在本机自测一次（用户侧动作，提示用户执行）。
