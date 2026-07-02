# figma-optimize 拆分 standard / page 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把单技能 `optimize` 拆成两个自包含技能 `standard`(评审设计规范板)和 `page`(评审界面稿),并纳入 2026-07-02 优化文档的四块经验。

**Architecture:** 两技能完全独立、各带完整 `references/`(flow / checklist / figma-api-cookbook / report-template),零 config、不跨技能引用。`page` 脱胎自原 `optimize`(装载改三源级联 + F 维度重写 + cookbook + 多板报告);`standard` 全新(体系向 S-A~S-E checklist)。删除 `optimize`,同步 README。

**Tech Stack:** Markdown + JSON(Claude Code plugin marketplace,无可运行代码)。验证靠结构检查(`grep` / 目录树 / 三处 name 一致),非单元测试。

**权威来源:** 内容规格见 spec [2026-07-03-figma-optimize-split-standard-page.md](./2026-07-03-figma-optimize-split-standard-page.md) §7;`page` 的改写基线是现有 `plugins/figma-optimize/skills/optimize/` 四个文件(仍在 git 中,作为 `page` 的蓝本逐一改写)。

## Global Constraints
- **三处 name 必须一致**:skill 目录名 = `SKILL.md` frontmatter `name` = 命名空间 `/figma-optimize:<name>`。取值 `standard`、`page`。
- **skills 目录扁平**:只 `skills/<name>/SKILL.md` + `skills/<name>/references/*.md`,不得再嵌套。
- 两技能 frontmatter 均含 `disable-model-invocation: true`;`allowed-tools: Read, Grep, Glob, Write, Edit, AskUserQuestion, mcp__plugin_figma_figma`。
- **红线原样保留(两技能各写一份,措辞一致)**:HARD GATE 未确认不动 Figma;调 `use_figma` 前必先走 `figma-use` skill;每处改完 `get_screenshot`/`node.screenshot()` 校验;每次 `use_figma` 只 `setCurrentPageAsync` 一次;脚本原子性(报错整体回滚);不生成代码、不做 design→code;不读写 figma2web / `config.md`;不依赖 superpowers;不做审美裁决、不无中生有设计新界面。
- **字体归正关键坑(page)**:归正只 `loadFontAsync` 目标字体,**绝不 load 缺失字体**(抛错 → 整脚本原子回滚),中文经 Figma 自动回退渲染;仅"改成云端不可用字体"才降级为建议。
- **F 维度严重度默认**:F1 中、F2 中、F3 高、F4 中。
- **开发语言统一简体中文**;commit message 沿用 `feat(...)` / `refine(...)` / `chore:` 带中文描述风格,并追加 `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`。

---

### Task 1: 新建 `page` 技能(脱胎自 optimize)

**Files:**
- Create: `plugins/figma-optimize/skills/page/SKILL.md`
- Create: `plugins/figma-optimize/skills/page/references/flow.md`
- Create: `plugins/figma-optimize/skills/page/references/checklist.md`
- Create: `plugins/figma-optimize/skills/page/references/figma-api-cookbook.md`
- Create: `plugins/figma-optimize/skills/page/references/report-template.md`
- Base(只读蓝本,勿改):`plugins/figma-optimize/skills/optimize/{SKILL,references/flow,references/checklist,references/report-template}.md`

**Interfaces:**
- Produces: 命名空间 `/figma-optimize:page`;references 相对链接 `references/flow.md` 等四个文件,均存在且被 SKILL.md 引用。
- Consumes: 无(独立技能)。

- [ ] **Step 1: 写 `page/SKILL.md`**

以 optimize/SKILL.md 为蓝本改写。frontmatter:

```markdown
---
name: page
description: 交付前给 Figma **界面稿**做「开发者思维」评审:依内置评审清单 + 现场从「设计规范板」三源级联抽取的项目标准,逐区块揪出结构 / 切图 / 色彩 / 间距 / 字体等可验证问题,逐条经用户裁定后由 AI 写回 Figma 或给自改说明,复审并产一份交付就绪报告。仅当用户主动用 `/figma-optimize:page` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Write, Edit, AskUserQuestion, mcp__plugin_figma_figma
disable-model-invocation: true
---
```

正文沿用 optimize 的「用途 / 核心心法 / 何时运行 / 产物 / 流程骨架 / 红线」六段,做三处改动:① 用途/心法中「装载项目标准」改为**三源级联从设计规范板抽标准**;② 流程骨架第 2 步(装载)与第 3 步(逐区块)引用改写后的 flow.md;③ 引用链接指向本技能 `references/`(见 Global Constraints 红线,原样保留)。产物路径仍 `docs/figma-optimize/<页面>-<日期>.md`。

- [ ] **Step 2: 写 `page/references/flow.md`**

以 optimize/references/flow.md 为蓝本,按 spec §7.1 改写:
- **P1 三源级联装载标准**(替换原 P1):① 先问/找「设计规范板 / 页」当权威标准 → ② `use_figma` 读全量 `getLocalVariableCollectionsAsync` / `getLocalVariablesAsync` / `getLocalTextStylesAsync`(拿全色板 / 字阶 / 间距)→ ③ `get_variable_defs` 仅快览 / 兜底。警示:`get_variable_defs` 把**库变量**显成"名=值"裸 hex,须用 `fills[].boundVariables` 辨别是否已 token 化,别误判硬编码。抽不到 → 退回 checklist 通用默认,关键缺口对话补。
- **P2** 增加:逐文本 `getStyledTextSegments(['fontName','fontSize'])` + `node.hasMissingFont` 检测缺失/非标字体与游离字号;P2/P5 指向 figma-api-cookbook.md。
- **P5** 增加:字体归正配方(见 Global Constraints 字体坑)。
- 其余 P0/P3/P4/P6/P7 沿用。

- [ ] **Step 3: 写 `page/references/checklist.md`**

以 optimize/references/checklist.md 为蓝本,**只重写 F 维度**,其余 A/B/C/D/E/G/H 维度、snap 网格例外护栏、判据方式、通用默认阈值原样保留。F 维度替换为:

```markdown
### F 字体 / 文本(检测 + 可行归正)
| 编号 | 检查项 | 严重度 | 判据 |
| --- | --- | --- | --- |
| F1 | 字号 / 行高游离于字阶 | 中 | `use_figma` 逐段 `getStyledTextSegments(['fontName','fontSize'])` |
| F2 | 字体族不一致 | 中 | 同上 |
| F3 | 缺失字体(云端不可用,已致渲染回退) | 高·可修 | `node.hasMissingFont`;归正:只 load 目标字体,别 load 缺失字体 |
| F4 | 非标字体混入(不在项目字体族标准内) | 中·可修 | `getStyledTextSegments(['fontName'])` 比对标准字体族 |

> 字体维度不再"一律受限":缺失/非标字体**可检测、可在可用字体范围内归正**;仅"改成云端不可用字体"才降级为建议(报告标注「受限」)。
```

- [ ] **Step 4: 写 `page/references/figma-api-cookbook.md`(page 向,新建)**

按 spec §7.1 收录 page 用到的配方,分「读 / 审计」「跨页」「写回」「纪律」四组:
- 读/审计:`getLocalVariableCollections/Variables/TextStylesAsync`(装载标准)、`getStyledTextSegments(['fontName','fontSize'])`、`hasMissingFont`、`findAllWithCriteria({types})`、`fills[].boundVariables`(辨 token vs 裸色)、`getVariableByIdAsync` + `valuesByMode`。
- 跨页:节点常不在首页 → 写前必 `await setCurrentPageAsync(page)`,每次只切一次。
- 写回:`setBoundVariableForPaint`(返回**新** paint 需重赋)、`setRangeFontName` / `setRangeFontSize`(先 load **目标**字体)、字体归正坑(别 load 缺失字体,否则抛错整脚本原子回滚)、`createComponentFromNode` + `addComponentProperty` + `createInstance` / `setProperties`、`createAutoLayout` 后清默认白底 `fills`、绝对→auto-layout。
- 纪律:增量小步、每步 `get_screenshot` 校验、`use_figma` 原子性、写回前逐条 HARD GATE 确认。

- [ ] **Step 5: 写 `page/references/report-template.md`**

以 optimize/references/report-template.md 为蓝本,末尾增加**可选章节**:

```markdown
## 附:关联标准板复查(可选)
当本次评审跨到关联的「设计规范板」时,在此容纳跨板复查结果:
| 标准板 / 范围 | 发现 | 处置 |
|---|---|---|
| <板名 / node> | <问题> | 已改 / 跳过 / 建议 |
```

- [ ] **Step 6: 验证 page 结构完整**

Run:
```bash
ls plugins/figma-optimize/skills/page/references/ && \
grep -c '^name: page$' plugins/figma-optimize/skills/page/SKILL.md && \
grep -c 'disable-model-invocation: true' plugins/figma-optimize/skills/page/SKILL.md && \
grep -oE 'references/[a-z-]+\.md' plugins/figma-optimize/skills/page/SKILL.md | sort -u
```
Expected: references 目录列出 4 个 `.md`;两个 `grep -c` 均输出 `1`;SKILL.md 引用的每个 `references/*.md` 都能在目录里找到(无死链)。

- [ ] **Step 7: 提交**

```bash
git add plugins/figma-optimize/skills/page/
git commit -m "$(cat <<'EOF'
feat(figma-optimize): 新增 page 技能(界面稿评审,脱胎自 optimize)

三源级联装载标准 + F 维度重写(F3 缺失字体高·可修 / F4 非标字体混入中·可修)
+ page 向 figma-api-cookbook + 报告多板结构。

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: 新建 `standard` 技能(评审设计规范板)

**Files:**
- Create: `plugins/figma-optimize/skills/standard/SKILL.md`
- Create: `plugins/figma-optimize/skills/standard/references/flow.md`
- Create: `plugins/figma-optimize/skills/standard/references/checklist.md`
- Create: `plugins/figma-optimize/skills/standard/references/figma-api-cookbook.md`
- Create: `plugins/figma-optimize/skills/standard/references/report-template.md`

**Interfaces:**
- Produces: 命名空间 `/figma-optimize:standard`;references 四文件存在且被 SKILL.md 引用。
- Consumes: 无(独立技能,不读 page 产物)。

- [ ] **Step 1: 写 `standard/SKILL.md`**

frontmatter:

```markdown
---
name: standard
description: 交付 / 维护前评审 Figma **设计规范板本身**:AI 作标准体系守门人,读全量 variables / text styles,逐维度(变量完整性 / token 化纯净度 / 命名规范 / 字阶字体 / 收敛)揪出体系问题,辨别库变量 vs 裸 hex 避免误判,逐条经用户裁定后写回或给自改说明,产一份标准体系评审报告。仅当用户主动用 `/figma-optimize:standard` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Write, Edit, AskUserQuestion, mcp__plugin_figma_figma
disable-model-invocation: true
---
```

正文六段(对齐 page 的骨架,内容换成体系向):
- **用途**:交付/维护前评审设计规范板本身,弥合"标准散乱"与"开发要一套可信 token"的鸿沟;AI 作标准体系守门人。
- **核心心法**:只揪可验证的体系问题(缺档 / 未 token 化 / 命名不规范 / 近似重复),**取值与审美归设计师**;写回前 HARD GATE。
- **何时运行**:仅 `/figma-optimize:standard`;前置 figma-mcp 可用 + 拿到**规范板**链接/范围。独立插件(不依赖/不读写 figma2web、config.md、superpowers)。
- **产物**:`docs/figma-optimize/standard-<板名>-<日期>.md`(可选落盘)。
- **流程骨架**:引用 references/flow.md 的 P0~P7。
- **红线**:见 Global Constraints,原样写入。

- [ ] **Step 2: 写 `standard/references/flow.md`**

按 spec §7.2:
- P0 前置校验(figma-mcp 可用;索取**规范板**链接/范围,不落盘)。
- P1 **读全量体系**:`use_figma` 读 `getLocalVariableCollectionsAsync` / `getLocalVariablesAsync` / `getLocalTextStylesAsync`;`get_variable_defs` 快览;**辨 token vs 裸 hex**(`get_variable_defs` 把库变量显成裸 hex,须用 `boundVariables` / `getVariableByIdAsync` 辨别)是核心。
- P2 逐维度评审(S-A~S-E,见 checklist.md)。
- P3 逐条裁定(HARD GATE)。
- P4 采纳项二次选择(我自改 / AI 改)。
- P5 写回:重命名变量 / 绑定 / 收敛 token,先走 `figma-use` skill,每处 `get_screenshot` 校验;指向 figma-api-cookbook.md。
- P6 复审(体系问题归零或标注例外)。
- P7 标准体系评审报告。
- 完成标志 + 边界(只审既有规范板,不无中生有设计新体系;不做取值裁决)。

- [ ] **Step 3: 写 `standard/references/checklist.md`(体系向,新建)**

开篇说明:本清单查"标准本身成不成体系",每条含 问题 / 改法 / 依据(S 编号)/ 严重度。五维:

```markdown
### S-A 变量集合完整性
| 编号 | 检查项 | 严重度 | 判据 |
| --- | --- | --- | --- |
| S-A1 | 色 / 字阶 / 间距 / 圆角某类未成体系或整类缺档 | 高 | `getLocalVariableCollectionsAsync` 遍历 |
| S-A2 | 集合分组 / mode(如明暗)不完整 | 中 | `variable.valuesByMode` |

### S-B token 化纯净度
| S-B1 | 规范板内存在游离裸色 / 未绑定值(本该是 token) | 高 | `fills[].boundVariables` 为空即裸值 |
| S-B2 | 库变量被 `get_variable_defs` 误显为裸 hex(勿误判为硬编码) | 中 | 用 `boundVariables` + `getVariableByIdAsync` 辨别 |

### S-C 命名规范
| S-C1 | 变量命名无语义 / 层级不清(如 color 1) | 中 | 遍历 `variable.name` |
| S-C2 | 同类命名风格不一致(驼峰 / 斜杠分组混用) | 低 | 遍历 `variable.name` |

### S-D 字阶 & 字体标准
| S-D1 | text styles 缺档 / 字号行高不成阶 | 中 | `getLocalTextStylesAsync` |
| S-D2 | 非标字体混入 / 缺失字体 | 中 | `style.fontName` + `hasMissingFont` |

### S-E 收敛
| S-E1 | 重复 / 近似 token 应合并(如两个几乎同色变量) | 中 | 比对 `valuesByMode` 解析值 |
```

文末附:严重度默认(S-A1 高、S-B1 高,余中/低)、辨 token 的判据说明。

- [ ] **Step 4: 写 `standard/references/figma-api-cookbook.md`(standard 向,新建)**

按 spec §7.2:
- 读/审计:`getLocalVariableCollectionsAsync` / `getLocalVariablesAsync` / `getLocalTextStylesAsync`、`getVariableByIdAsync` + `valuesByMode`(取解析值)、`fills[].boundVariables`(辨 token vs 裸色)、`get_variable_defs`(快览,注意库变量误判)。
- 写回:变量重命名(`variable.name = …`)、绑定(`setBoundVariableForPaint` 返回新 paint 需重赋)、收敛(合并近似 token 后改引用)。
- 纪律:增量小步、每步校验、`use_figma` 原子性(报错整体回滚)、写回前逐条 HARD GATE 确认。

- [ ] **Step 5: 写 `standard/references/report-template.md`(新建)**

标准体系评审报告模板,frontmatter(title/board/figma_link/date/collections_count),章节:
- 体系快照(集合 / 变量数 / text styles 数 / mode)。
- 发现与处置表(编号 / 维度 / 问题 / 依据 S 编号 / 严重度 / 处置)。
- 保留的例外。
- 复审结论。
- 给「界面评审 / 开发」的 TL;DR(一句话:标准是否可作权威依据)。

- [ ] **Step 6: 验证 standard 结构完整**

Run:
```bash
ls plugins/figma-optimize/skills/standard/references/ && \
grep -c '^name: standard$' plugins/figma-optimize/skills/standard/SKILL.md && \
grep -c 'disable-model-invocation: true' plugins/figma-optimize/skills/standard/SKILL.md && \
grep -oE 'references/[a-z-]+\.md' plugins/figma-optimize/skills/standard/SKILL.md | sort -u
```
Expected: references 目录 4 个 `.md`;两个 `grep -c` 均 `1`;引用的每个 `references/*.md` 都存在(无死链)。

- [ ] **Step 7: 提交**

```bash
git add plugins/figma-optimize/skills/standard/
git commit -m "$(cat <<'EOF'
feat(figma-optimize): 新增 standard 技能(设计规范板体系评审)

体系向 checklist S-A~S-E(完整性 / token 化纯净度 / 命名 / 字阶字体 / 收敛)
+ 辨库变量 vs 裸 hex + standard 向 cookbook + 标准体系评审报告。

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 3: 删除 optimize + 同步 README 与旧设计文档

**Files:**
- Delete: `plugins/figma-optimize/skills/optimize/`(整目录)
- Modify: `README.md`(调用示例 + 目录树)
- Modify: `docs/design/2026-07-02-figma-optimize-优化.md`(顶部加指针)

**Interfaces:**
- Consumes: Task 1、Task 2 产出的 `page/`、`standard/` 目录(README 目录树须与之一致)。

- [ ] **Step 1: 删除 optimize 目录**

```bash
git rm -r plugins/figma-optimize/skills/optimize/
```

- [ ] **Step 2: 改 README 调用示例**

`README.md:33` 的调用示例把 `/figma-optimize:optimize` 换成 `/figma-optimize:standard`、`/figma-optimize:page`(举其一或都列)。修改后该行不再出现 `optimize`。

- [ ] **Step 3: 改 README 目录树**

`README.md` 目录树中 figma-optimize 段(约 56–61 行)由:
```
    └── figma-optimize/
        ├── .claude-plugin/plugin.json
        └── skills/
            └── optimize/              # 交付前设计稿评审优化
                ├── SKILL.md
                └── references/         # checklist / flow / report-template
```
改为:
```
    └── figma-optimize/
        ├── .claude-plugin/plugin.json
        └── skills/                    # standard(规范板评审)/ page(界面稿评审)
            ├── standard/SKILL.md + references/
            └── page/SKILL.md + references/
```

- [ ] **Step 4: 给旧设计文档加指针**

在 `docs/design/2026-07-02-figma-optimize-优化.md` 第 3 行(状态行)下方插入一行:
```markdown
> 承接:本文档需求已由《2026-07-03 figma-optimize 拆分 standard / page》纳入并落地,原 `optimize` 技能已拆分。
```
正文其余不动。

- [ ] **Step 5: 全仓一致性扫描(无 optimize 残留、目录树对得上)**

Run:
```bash
grep -rn 'figma-optimize:optimize\|skills/optimize' README.md; echo "---exit $?---"; \
ls plugins/figma-optimize/skills/
```
Expected: 第一条 `grep` **无输出**(exit 1,即 README 无 `optimize` 残留);`ls` 只列出 `page` 和 `standard` 两个目录。

- [ ] **Step 6: 提交**

```bash
git add -A
git commit -m "$(cat <<'EOF'
refine(figma-optimize): 删除 optimize 技能,拆分为 standard/page 并同步 README

原 optimize 已拆成 standard(规范板评审)+ page(界面稿评审);
README 调用示例与目录树同步,旧优化文档加承接指针。

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Self-Review

**1. Spec coverage(逐节对照 spec):**
- §5 文件结构 → Task 1/2 建目录、Task 3 删 optimize。✅
- §6 四块经验分摊:三源级联(page P1 = T1S2 / standard P1 = T2S2)、库变量误判(page 装载 = T1S2 / standard S-B = T2S3)、字体 F3/F4(T1S2+T1S3)、多板报告(T1S5)。✅
- §7.1 page 五文件 → Task 1 Step1-5。✅
- §7.2 standard 五文件 → Task 2 Step1-5。✅
- §8 文档登记:README = T3S2/S3、旧文档指针 = T3S4;marketplace/plugin.json 无需改(spec §8 明确)→ 计划未列,正确。✅
- §9 成功标准:三处 name 一致(T1S6/T2S6 grep 验)、无 optimize 残留(T3S5 grep 验)、红线保留(Global Constraints)。✅

**2. Placeholder scan:** 无 TBD/TODO;红线与 F/S 表格给了 verbatim 内容;"以 X 为蓝本"均附具体改动点,非"similar to"空引用。✅

**3. Type consistency:** name 全程 `page` / `standard`;命名空间 `/figma-optimize:page`、`/figma-optimize:standard` 一致;references 文件名(flow/checklist/figma-api-cookbook/report-template)四技能文件间一致;F1-F4、S-A~S-E 编号与 spec §7 一致。✅
