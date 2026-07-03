# engineering plugin 设计：内化 mattpocock 深模块方法论

日期：2026-07-03
状态：已获用户批准（brainstorming 分节确认通过）

## 目标

新建 `engineering` plugin，把 mattpocock/skills 的深模块方法论内化为自己的工程 skill 集合。共四个 skill：

| skill | 内化自（mattpocock/skills） | 角色 |
|---|---|---|
| `design-rules` | `engineering/codebase-design`（含 DEEPENING.md、DESIGN-IT-TWICE.md） | 词汇库 + 判据，被其他三个引用 |
| `improve-arch` | `engineering/improve-codebase-architecture`（含 HTML-REPORT.md） | 编排入口：扫描 → HTML 报告 → 拷问 |
| `grilling` | `productivity/grilling`（骨架参考自家 `project:grill` 补强） | 架构设计拷问 |
| `domain-modeling` | `engineering/domain-modeling`（含 CONTEXT-FORMAT.md、ADR-FORMAT.md） | 领域词汇表 + ADR 维护 |

**内化笔法（方案 C）**：骨架与判据忠实原版（一条不丢、可回溯出处），写法按 `docs/skill写作指南.md` 执行——每个 skill 提炼引导词、步骤带可检查的完成标准、逐行 no-op 测试、对照五失败模式。

## 已定决策

1. **载体**：design-rules 做成 user-invoked skill（`disable-model-invocation: true`），上层 skill 用文件相对路径显式指路（"先 Read `../design-rules/SKILL.md`"），不靠 model-invoked description 互相够到。理由：确定性强、零 description 上下文税；代价是普通对话中不自动触发，符合本仓库既有习惯。
2. **四个 skill 全部 user-invoked**，调用形如 `/engineering:improve-arch`。
3. **术语语言**：七术语保留英文原词（module / interface / implementation / depth / seam / adapter / leverage / locality，以及 deep/shallow），定义与正文用简体中文。禁用词清单保留英文（component / service / unit / API / signature / boundary / layer / wrapper）。理由：英文原词是预训练好的引导词，禁用词翻译后防漂移机制失效。
4. **HTML 报告保留**：照原版 Tailwind + Mermaid CDN、写 OS 临时目录、自动打开；脚手架与图型规范内化为 `improve-arch/references/html-report.md`。
5. **domain-modeling 完整内化**为第四个 skill，CONTEXT.md / ADR 机制齐备。
6. **不依赖 project plugin**：engineering 单独安装完整可用。grilling 与 `project:grill` 暂时重名共存，命名修正由用户后续自行处理。

## 目录结构

```
plugins/engineering/
├── .claude-plugin/plugin.json        # name: engineering
└── skills/
    ├── design-rules/
    │   ├── SKILL.md                  # 术语表、深浅模型、四原则、可测试性三规则、rejected framings
    │   └── references/
    │       ├── deepening.md          # 依赖四分类、seam 纪律、replace-don't-layer 测试策略
    │       └── design-it-twice.md    # 并行子代理多接口探索模式
    ├── improve-arch/
    │   ├── SKILL.md                  # 三阶段：探索 → HTML 报告 → 拷问
    │   └── references/
    │       └── html-report.md        # HTML 脚手架、五种图型、风格与措辞规范
    ├── grilling/
    │   └── SKILL.md
    └── domain-modeling/
        ├── SKILL.md
        └── references/
            ├── context-format.md     # CONTEXT.md / CONTEXT-MAP.md 格式与规则
            └── adr-format.md         # ADR 模板、编号、三条件门槛、够格决策清单
```

## 各 skill 设计

### design-rules —— 引导词：deep/shallow + 删除测试

纯 reference 型 skill，无步骤流程。SKILL.md 内容（重组为「术语表在前、判据在后」）：

- **七术语表**：每条 = 英文原词 + 中文定义 + `_禁用_` 行。含 Implementation vs Adapter 的正交区分（小 adapter 大实现 vs 大 adapter 小实现）。
- **深浅模块图示**：深 = 小接口 + 厚实现；浅 = 宽接口 + 薄实现（ASCII 图照原版）。
- **四条原则**：深度是接口的属性（内部 seam vs 外部 seam）；删除测试（复杂度集中 = 挣饭钱，搬位置 = 透传）；接口即测试面；一个 adapter = 假想 seam、两个 = 真 seam。
- **可测试性三规则**：注入依赖不自建、返回结果不产副作用、小表面积。
- **术语关系**：Module 有且仅有一个 Interface；Depth 相对 Interface 度量；Seam 是 Interface 所在之处；Adapter 在 Seam 处满足 Interface；Depth 产出 Leverage（调用者）与 Locality（维护者）。
- **Rejected framings**：否决"实现行数/接口行数"的深度定义（奖励灌水，改用深度即杠杆）；否决把 interface 理解为 TS `interface` 关键字或 public 方法（太窄）；否决 boundary（与 DDD 撞名）。
- 正文标注理论出处：Ousterhout《软件设计的哲学》、Feathers 的 seam。

`references/deepening.md`：依赖四分类（进程内 / 本地可替代 / 远程自有走 ports & adapters / 真外部用 mock）及各自测试策略；seam 纪律（两 adapter 才开 port；内部 seam 不因测试暴露到接口）；replace-don't-layer（深化后旧浅模块单测删除，新测试打接口、断言可观察结果、能挺过内部重构）。

`references/design-it-twice.md`：先写问题空间说明（约束、依赖分类、示意草图）给用户 → 并行派 3+ 子代理，各带一条截然不同的设计约束（极小接口 / 最大灵活 / 为最常见调用者优化 / ports & adapters）→ 每个产出接口、用法示例、seam 后藏什么、依赖策略、权衡 → 按 depth / locality / seam 位置对比，给出有立场的推荐（可提混合方案）。

### improve-arch —— 引导词：深化机会（deepening opportunity）

三阶段，每阶段带完成标准（对原版的主要补强）：

1. **探索**：先 Read `../design-rules/SKILL.md` 装载词汇与判据 → 读 `CONTEXT.md` 与 `docs/adr/`（不存在则跳过，不报错）→ 派 Explore 子代理有机走查（不跟僵硬启发式），关注：理解一个概念要跳多个小模块、模块浅、纯函数抽出但 bug 藏在调用处（无 locality）、耦合泄漏跨 seam、难以通过现有接口测试。**完成标准**：每个候选项必须通过删除测试（答案是"复杂度会集中"）且能指出具体文件；说不出文件的候选丢弃。
2. **HTML 报告**：按 `references/html-report.md` 写自包含 HTML 到 OS 临时目录（`$TMPDIR` → `/tmp` → `%TEMP%`，文件名带时间戳），自动打开（xdg-open / open / start）并告知绝对路径。卡片字段：Title / 徽章行（推荐强度 Strong=emerald、Worth exploring=amber、Speculative=slate + 依赖分类 tag）/ Files（等宽）/ before-after 图（居中件）/ Problem 一句 / Solution 一句 / Wins（≤6 词/条）/ ADR 冲突警示（amber 框，仅当摩擦真实到值得重开决策才列）。**完成标准**：Wins 必须用 locality / leverage 措辞，禁"更易维护""更干净"；报告末尾必有 Top recommendation；本阶段不准提接口设计；写完只问「想探索哪一个？」。
3. **拷问**：用户选定后指路 `../grilling/SKILL.md` 走设计树；过程中术语落笔 / ADR 提议指路 `../domain-modeling/SKILL.md`；用户想探索多接口方案时指路 `../design-rules/references/design-it-twice.md`。

`references/html-report.md` 内化原版 HTML-REPORT.md：脚手架（Tailwind CDN + Mermaid ESM + 少量自定义 CSS：seam 虚线、leak 红、deep 深底）；头部图例（实框=module、虚线=seam、红箭头=泄漏、厚深框=deep module）；五种图型（Mermaid flowchart 画依赖/调用流并用 classDef 标红泄漏边、手搭 boxes-and-arrows、cross-section 分层带、mass diagram 接口/实现面积对比、call-graph collapse）；风格（editorial 不 corporate、留白、一个强调色 + 红泄漏 + amber 警示、图高约 320px、模块标签 text-xs uppercase）；措辞规范（术语精确使用、Wins 用词汇表词、无套话）。

### grilling —— 引导词：走设计树（walk the design tree）

与 `project:grill` 的差异化定位：grill 拷问**已成形的方案**（目标：压出问题）；grilling 拷问**待设计的深化**（目标：收敛出接口形状）。

流程（原版三句话骨架 + grill 已验证模式补强）：

1. 若尚未装载，先 Read `../design-rules/SKILL.md`。
2. 从最上游决策开始逐分支走设计树：约束 → seam 位置 → 接口形状 → seam 后面藏什么 → 哪些测试存活。
3. 一次只问一题，等回应再继续；每题附推荐答案 + 理由；**能查代码回答的自己查，不拿去问用户**（原版保留）。
4. 每分支结论当场登记，不攒到最后凭记忆。

**完成标准**：拷问结束时必须能写出深化后模块的接口草图——方法、参数、不变量、错误模式；写不出说明分支没走完。

### domain-modeling —— 引导词：术语当场落笔

会话中的五个动作（照原版）：

1. **对照词汇表挑战**：用户用词与 CONTEXT.md 冲突时立即指出（"词汇表定义 X 是……你说的像 Y——是哪个？"）。
2. **锐化模糊词**：模糊/超载的词，提议精确的规范词。
3. **编造边界场景**：压测概念关系，逼出概念间的精确边界。
4. **对照代码查证**：用户的陈述与代码矛盾时当面摆出。
5. **当场更新 CONTEXT.md**：术语一敲定立刻写，不攒批；文件惰性创建（第一个术语敲定时才建）。

ADR 三条件门槛：难逆 + 无上下文会困惑 + 真实取舍，三者齐备才提议；缺一即跳过。

红线：CONTEXT.md 只是词汇表——不装实现细节、不当 spec、不当草稿本。

`references/context-format.md`：术语条目格式（词 + 一两句定义 + `_避免_` 行）；规则（有立场地选词、定义"是什么"不是"做什么"、只收本项目特有概念不收通用编程概念、自然聚类才分组）；单/多 context（有 CONTEXT-MAP.md 则多 context，列出各 context 位置与关系；推断当前话题属于哪个 context，不明确则问）。

`references/adr-format.md`：存放 `docs/adr/`、顺序编号 `NNNN-slug.md`、目录惰性创建；模板极简（标题 + 1-3 句：背景/决定/理由），可选节（Status frontmatter / Considered Options / Consequences）仅在真有价值时加；扫描现有最大编号 +1；够格决策清单（架构形态、context 间集成模式、带锁定的技术选型、边界与归属、刻意偏离显然路径、代码里看不见的约束、否决理由不显然的备选方案）。

## frontmatter 约定

四个 skill 统一：

- `disable-model-invocation: true`
- `description` 写清「做什么 + 仅当用户主动用 `/engineering:<skill>` 调用时使用」
- `allowed-tools` 按需收窄：design-rules 只需 Read；improve-arch 需 Read / Grep / Glob / Bash / Agent / AskUserQuestion / Write（写临时报告）；grilling 需 Read / Grep / Glob / AskUserQuestion；domain-modeling 需 Read / Grep / Glob / Edit / Write / AskUserQuestion。

## 溯源标注

每个 SKILL.md 底部一行：「内化自 mattpocock/skills 的 `<原路径>`，内化日期 2026-07-03」。

## 登记与文档更新

1. `plugins/engineering/.claude-plugin/plugin.json`：name `engineering`，description「代码库架构设计相关 skill（深模块方法论）」。
2. `.claude-plugin/marketplace.json` `plugins` 数组补一条。
3. `README.md`：分类表加 engineering 行、安装示例、目录树补全；**顺手修正既有文档漂移**——目录树补上已存在但缺失的 `support` plugin 与 `project:loopspec` skill（只补树，不动内容）。

## 验收

- 四个 SKILL.md 逐行过写作指南自检：no-op 测试 + 五失败模式（提前收工/重复/沉积/蔓延/空操作）对照。
- `marketplace.json` 与 `plugin.json` 过 `jq` 校验。
- 冒烟：在本仓库跑 `/engineering:improve-arch`（纯 Markdown 仓库，预期产出零或少量候选的报告），验证流程不报错、HTML 报告能生成并打开、阶段间指路可达。

## 遗留事项（不在本次实施）

- `grilling` 与 `project:grill` 的重名/分工修正——用户后续自行定名。
- CONTEXT.md 机制与 `interview2doc` 产出文档的关系（是否互通）——暂不处理。
