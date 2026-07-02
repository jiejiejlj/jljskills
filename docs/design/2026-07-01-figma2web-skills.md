# figma2web skill 组 重设计 需求文档

> 日期:2026-07-01 · 状态:草稿(经访谈重定义,取代根目录 `2026-07-01-figma2web-skills.md` 预案)

> 说明:本文由 `interview2doc` 逐点访谈产出。**「已确认」= 访谈中拍板的决策;「建议」= 我给的推荐,待你在本文上 review;定不下来的进第 9 节「开放问题」。** 全文只放确认过或明确标注为建议的内容,不替你臆断。

---

## 1. 概述 / 背景

`figma2web` 是一个 Claude Code 插件,提供**一组孤岛(island)skill**,把设计师的 Figma 设计稿转成 web 页面,做到**有据可循、可复现、可差异更新**。

本文是对根目录预案(4 skill:tokens/page/component/verify)的一次重设计。核心是**吸取原 6-skill 项目(setup/optimize/document/coding/refresh/resetup)的经验**,把其中被验证过、值得留的骨干继承进新设计,同时补上预案缺失的能力。

重设计后的骨干:**先写自包含 spec、再离线复现代码**(继承旧 `document → coding`),辅以固定技术栈的地基(`init` + `config`)、组件库的持续沉淀(`component`)、以及自动化的还原度把关(`verify`)。

## 2. 要解决的问题

- 官方「设计转代码」产出太通用,不贴合团队技术栈与目录 / 命名 / 组件规范,拿来即用会带来大量返工。
- 每个人凭感觉转,结果质量不一致,缺少一条可复用的标准流程。
- 转换后缺少还原度把关,难以保证产物忠实于设计稿。
- 现状两个缺口:**组件库还没有**(需要边转边沉淀)、**Figma 有变量但代码侧还没建对应 token**(需要先打通)。
- 预案的额外缺口:丢掉了原设计「自包含 spec + 离线复现 + 差异更新」这条骨干,导致不可离线复现、改稿只能整页重跑。

## 3. 目标(Goals)

- 产出**贴合技术栈 / 规范**的代码(v1 标准栈:React + TypeScript + Tailwind CSS)。
- 把 Figma → web 的转换**固化成标准化、可复用的流程**,任何人经 Claude 执行都能得到质量一致的结果。
- **保留自包含 spec**:把 Figma 信息文档化成一份人可读、可交接、可离线复现的设计文档 —— **同事拿这份文档就能复现 web 代码,写代码时不必再读 Figma**。(访谈 Q1 已确认,是本次重设计的核心要点。)
- 建立**还原度校验**环节,用可执行的分级 rubric 把关产物质量。
- 支持**从无到有攒组件库**:转页面的过程中沉淀可复用组件,让组件库越用越大。
- 打通 **Figma 变量 → 代码 token** 链路,让样式有据可依、避免魔法值。
- 保留**差异更新**能力:设计 / 变量改动后只更新变化部分,不整体重跑。

## 4. 非目标(Non-Goals)

- **不连真实数据 / 后端接口**:产出交互,但数据用 mock / 占位。
- **不负责脚手架初始化**:以「已有一个能本地跑的工程」为前提,skill 只往里加 token / 组件 / 页面 / 部署产物。
- **不追求逐像素一致**:验收用分级 rubric,非像素级对齐。
- **不发明设计规则**:响应式断点、交互行为等以设计稿为准;设计稿没给的不自行脑补(标准视觉交互除外,见 §6)。
- **v1 不做多技术栈**:标准栈一套做透(见 §6「栈策略」),换栈是后话。
- **v1 不含 `optimize`**(AI 设计顾问优化 Figma):与核心管线正交、可跳过;想加随时以孤岛形式加回。

## 5. 目标用户与使用场景

- **用户**:团队内的前端开发人员。
- **执行模式**:**Claude 执行、开发人员审校** —— skill 是写给 agent 照着跑的操作流程,开发人员在每步之间 review 并拍板。**正因如此,skill 之间不自动串成黑箱链(见 §6 纯孤岛)。**
- **交接方式**:开发人员提供一个**带 `node-id` 的 Figma 节点链接**。
- **典型流程**:`init` 建项目配置 → `config` 打通设计 token → `page2doc` 把页面文档化成 spec → `coding` 离线复现代码 → 需要时 `component` 沉淀共享组件 → `verify` 校验还原度 → 设计改动时用 `re-config` / `re-page2doc` 差异同步。

## 6. 核心需求 / 功能清单

### 6.1 架构不变量(贯穿所有 skill)

- **纯孤岛**(已确认 Q4):skill **绝不互相调用**,只通过 `docs/figma2web/` 下的产物 + 代码侧产物(`tailwind.config.*`、`registry.json`)串联;哪怕因此在 skill 间复制少量逻辑,也不引入自动编排。每个 skill 都能单独跑、单独 review。
- **`coding` 全程离线**(已确认 Q1/Q2):`coding` 不调用任何 figma-mcp 工具,只凭 spec + 本地切图 + `config` 产物 + registry 复现。需要 Figma 的信息即说明 spec 不够完整,应回 `page2doc` 补,而非访问 Figma。
- **spec 保持纯设计描述**(已确认 Q3):`page2doc` 只忠实记录设计(含「这块是 Figma 组件实例 X」这类**客观设计事实**);组件复用 / 新建等**代码决策留给 `coding`**,不写进 spec。
- **绝不臆测**:任何 skill,信息不足 / 含糊时**停下问用户**,不猜。
- **单写者**(产物写入权唯一):见 §6.4 产物映射表。

### 6.2 栈策略(已确认 Q5/Q6)

- 技术栈**不写死在 skill 里**,而由 `init` 逐项目配置、记录进 `project.md`;下游 skill 读 `project.md` 适配,不硬编码。
- 但 **v1 只把一套标准栈做深做透**:默认且首推 **React + TypeScript + Tailwind CSS**,`coding` / `config` / `component` / `verify` 的细节都围绕它;支持其它栈是后续演进。
- **项目初始化闸门**:任何 skill 开工前先检查 `project.md` 是否存在 —— 不存在则停下,提示先跑 `init`;存在才继续。

### 6.3 八个命令(已确认 Q7)

纯孤岛,只经产物串联。「在线」= 是否调用 figma-mcp。

| # | 命令 | 职责 | 在线 | 主要产物 |
|---|---|---|---|---|
| 1 | `init` | 配置项目级技术决策 → `project.md`;首个必跑,其它 gate 于它;**可重跑**(交互式覆盖,无 Figma diff,故不设独立 update) | 否 | `project.md` |
| 2 | `config` | 经 Figma 链接抽取设计标准 → **文档化 + 落实为可用 token** | 是 | 设计标准文档 + `tailwind.config.*` |
| 3 | `re-config` | 设计标准 / 变量改动 → 差异更新(对位旧 `resetup`) | 是 | 更新上述(只改变化项) |
| 4 | `page2doc` | Figma 页面 → **纯设计 spec**;预下载切图;交互式确认分块、追问不明交互 | 是 | spec(按 section)+ 本地切图 |
| 5 | `re-page2doc` | 设计改动 → section 级差异更新(对位旧 `refresh`) | 是 | 更新 spec(标记 NEW/CHANGED/UNCHANGED) |
| 6 | `coding` | **离线**读 spec + 设计标准 + registry → 出代码;复用已有组件、缺的写页面内局部;产 Docker 产物 | **否** | `app/` 源码 + `Dockerfile` 等 |
| 7 | `component` | 扫现有代码找可沉淀的 → 提炼共享组件 + 登记 registry;`coding` 之后按需跑 | 否 | 共享组件 + `registry.json` |
| 8 | `verify` | `docker compose` 起服务 + Playwright 截图 → 混合判定 + 人工终审 | — | 差异报告 |

### 6.4 产物映射与写入权(建议,待 review)

| 产物 | 谁写(单写者) | 谁读 | 位置(建议) |
|---|---|---|---|
| 项目技术配置 | `init` | 所有 skill | `docs/figma2web/project.md` |
| 设计标准文档 `tokens.md`(值 + 映射 + 来源) | `config` / `re-config` | `page2doc` / `coding` | `docs/figma2web/tokens.md` |
| 设计 spec(自包含) | `page2doc` / `re-page2doc` | `coding` | `docs/figma2web/design/<page>/<section>.md` |
| 本地切图 + section 参照截图 | `page2doc` / `re-page2doc` | `coding`(切图)/ `verify`(参照图 `__ref.png`) | `docs/figma2web/assets/<page>/<section>/...` |
| 可用 token(theme) | `config` / `re-config` | `app` 构建 | `app/tailwind.config.*` |
| 应用源码 + 部署产物 | `coding` | 部署 | `app/`（`app/src/...`;`Dockerfile`/`docker-compose.yml`/`.dockerignore`) |
| 共享组件 + 组件清单 | `component` | `coding` 复用 | `app/src/components/` + `app/src/components/registry.json` |
| 还原度差异报告 | `verify` | 人审校 | `docs/figma2web/verify/<page>-<date>.md` |

### 6.5 各 skill 细节

**`init`(已确认 Q5/Q6 + 详细流程)** —— 不读 Figma、不写代码,纯交互式收集,产 `docs/figma2web/project.md`。
- **P0 前置校验**:检测 `project.md` —— 不存在 → 「首建」;已存在 → **「预填式重配」**(载入现有值逐项预填,用户只改要改的项,其余回车保留,只写变更)。并提示用户确认前提「已有一个能本地跑的工程」(init 不建脚手架)。
- **P1 逐项收集技术决策**(每项给默认值 + 理由,请用户确认或改;字段清单已定为这 10 项):
  - 技术框架 + 语言(默认 React + TypeScript)
  - 样式方案(默认 Tailwind CSS)
  - 布局模型(绝对定位 / flex / grid)
  - 代码目录约定(默认 `app/` 根;源码在 `app/src/...`)
  - 组件库位置 + registry 位置(默认 `app/src/components/` + `registry.json`)
  - 切图引用约定(如 `/assets/...`)
  - 设计 token 落地位置(默认 `app/tailwind.config.*`)
  - 响应式断点(默认 Tailwind `sm/md/lg/xl`)
  - 部署方式(默认 Docker 容器化,注明运行形态,如「多阶段构建 → nginx 托管 dist」)
  - Figma file key(或声明每次给链接)
  - > **逐项必答**(沿用旧 setup 的完整性保证):每项取得确定值,不接受留空 / 擅自默认;用户「无所谓」时也把默认值念出来请其确认。下游因此可直接信任 `project.md`,不再做齐备性校验。
- **P2 呈交确认(HARD GATE)**:完整配置列出请用户确认;任一项待定 → 回 P1 补齐,绝不带缺口写。
- **P3 写 `project.md` + 报告**:写入,提示下一步 `config`。
- **完成标志**:`project.md` 写入并经确认。

**`config`(已确认 Q10 + 详细流程)** —— `init` 之后、建页面前的地基;读 Figma,产**设计标准文档 + `tailwind.config.*`**。
- **P0 前置校验**:`project.md` 存在(否则提示先 `init`);figma-mcp 可用;向用户索取一个**代表设计规范的 Figma 链接**(不落盘,每次现问)。
- **P1 抽取设计标准**:优先 `get_variable_defs` 读 variables;无变量 fallback `get_design_context` 取代表帧归纳。维度(已定 7 个):**色板 / 字体族 / 字号阶 / 间距网格 / 圆角 / 阴影 / 渐变**。抽不到 / 不确定即停下问,标注来源(Figma 变量 / 代表帧归纳 / 人工)。
- **P2 建立映射(已定:直译 + 异常停下问)**:变量路径直译为 tailwind theme key —— `color/brand/primary → colors.brand.primary`、`spacing/4 → spacing.4`、`radius/lg → borderRadius.lg`;遇不符合 tailwind 结构的命名 → **停下问用户**,不自行归并。
- **P3 呈交确认(HARD GATE)**:设计标准表(`名称 | Figma 变量 | 设计值 | token | 来源`)请用户确认;可改任意值;未确认不写。
- **P4 写两产物(同一运行内一起写,保一致)**:① 设计标准文档 `tokens.md`(**source of truth**);② `tailwind.config.*`(**每次据 `tokens.md` 重新生成**,天然不漂移)。报告,提示下一步 `page2doc`。
- **完成标志**:两产物写入并确认。**边界**:既无 variables 也取不到代表帧 → 引导用户手填核心标准(至少色板 + 字体 + 网格基数),标来源=人工。

**`re-config`(对位旧 resetup + 详细流程)** —— 设计标准 / 变量改动后差异化同步;读 Figma。**不维护变更日志**(改动历史靠 git)。
- **P0 前置校验**:`project.md` + 设计标准文档均存在(缺后者 → 提示先 `config`);figma-mcp 可用;向用户索取**标准面板 Figma 链接**。
- **P1 重抓当前标准**:同 `config` P1(优先 variables,fallback 代表帧)。
- **P2 diff 分类**:与现有设计标准文档逐项比对 → **NEW / CHANGED / UNCHANGED**,含**来源演进**(如某项 `来源:人工` → 现已成 Figma 变量);靠数值比对,不靠目视。
- **P3 确认分类(HARD GATE)**:三类清单 + 每个 NEW/CHANGED 的**前后具体值**,逐项确认;未确认不写。
- **P4 写回(同一运行内一起写)**:`tokens.md` 只更新 NEW/CHANGED(值 + 来源),UNCHANGED 原样;`tailwind.config.*` 据更新后的 `tokens.md` 同步重新生成,保两者不漂移。
- **P5 小结**:报告改了哪些 / 来源如何演进 / 哪些未变。
- **边界**:某项在 Figma 被删(文档有、重抓没有)→ 标「已移除」问用户,不擅删;字体等读不到 → 停下问。

**`page2doc`(已确认 Q3/Q11 + 详细流程)** —— 给一个 Figma 页面链接,文档化成 spec + 切图;读 Figma。产 `design/<page>/<section>.md` + `assets/<page>/<section>/...`。
- **P0 前置校验**:`project.md` 存在;**设计标准文档存在(强制要求先跑 `config`——转换时要用其标准值做参照与魔法值把关)**;figma-mcp 可用;用户给 Figma 页面链接。
- **P1 读取 + 提议分块**:`get_metadata`(结构/层级/几何)+ `get_design_context`(样式/文本)+ `get_screenshot`(视觉参照);**主动提出 section 分块方案请用户确认**。
- **P2 元素清单 + 完整性 gate(HARD GATE)**:建 B 表;每个可见叶子节点**要么进清单、要么进跳过清单写明原因**,不留遗漏。
- **P3 逐区块确认(HARD GATE)**:元素清单、关键样式、切图清单、交互理解 呈交确认;**C 段发现的疑似魔法值在此提示用户**。
- **P4 交互行为(HARD GATE)**:标准交互自推断;模糊 / 业务 / 数据驱动 → 停下问 或 留 TODO。
- **P5 切图预下载(HARD GATE)**:按保真规则(`rawImages` 保透明 / `export` SVG 剥背景 / 纯 CSS 还原)定策略;先呈交「节点 → 本地路径」映射确认,再下载到 `assets/`。**并把每个 section 的 Figma 整体参照截图存入 `assets/<page>/<section>/__ref.png`(供 `verify` 离线比对)。**
- **P6 写 spec + 复核(HARD GATE)**:自检(无占位、B/C/G nodeId 一致、交互完整),请用户复核。
- **完成标志**:所有 section 写入 spec + 切图并复核。提示下一步 `coding`。

**spec 结构(已确认 v2)** —— 路径 `docs/figma2web/design/<page>/<section>.md`;自包含(coding 只凭 spec + 本地切图即可离线还原)。
- **frontmatter**:`page / section / fileKey / frameNodeId(diff 锚点)/ frameW / frameH / status(NEW|CHANGED|UNCHANGED,re-page2doc 维护)/ updated_at`。
- **A. 结构树**:缩进层级概览,**标注 Figma 组件实例**。
- **B. 元素清单(★diff 基准)**:`nodeId | 类型 | 父 | 原文文本 | 几何(x,y,w,h) | 状态 | Figma 组件实例 | 切图策略`。
- **C. 样式细节**(按 nodeId):每项 CSS 属性记 `忠实值 + Figma 变量绑定(如有) + 标准符合性`(匹配 config 标准 / 偏离或疑似魔法值);**token 的最终翻译留给 coding**。
- **D. 响应式**:多尺寸稿逐断点记几何/样式差异;单稿则记「按 `project.md` 默认断点常规适配」+ 需特别 reflow 的元素(用户确认)。
- **E. 交互行为**:标准交互(推断)+ 业务/数据驱动(确认或 TODO);多态节点(hover/disabled 变体)逐态记。
- **F. 跳过清单**:装饰节点 + 跳过原因。
- **G. 切图映射**:`nodeId → 本地路径 + 下载策略 + 层叠说明`。
- **一致性**:B/C/G 的 nodeId 必须一致,coding 与 re-page2doc 以 B 表为基准。

**`re-page2doc`(对位旧 refresh + 详细流程)** —— 设计改动后只更新变化 section;读 Figma。**不擅删、问用户**。
- **P0 前置校验**:`project.md` + 设计标准文档 + 已有 spec 均存在;figma-mcp 可用;用户给(更新后的)Figma 页面链接。
- **P1 全量重抓**:读现有 spec 取各 section `frameNodeId` → 逐个 `get_metadata`/`get_design_context`/`get_screenshot` 抓**当前** Figma;同时扫页面找**新增 section**;先不下切图。
- **P2 比对分类**:与已有 spec(以 B 表为基准)逐 section 比对 → **NEW / CHANGED / UNCHANGED**;全量重抓,用户无需标注范围。
- **P3 确认分类(HARD GATE)**:三类清单 + 每个 CHANGED 的**逐项具体改动**,确认。
- **P4 分头处理**:NEW → 完整文档化(建 spec + 下切图);CHANGED → 自刷新 spec(重建 B 表、核对改动、确认交互、**只重下变化切图**、刷新 `status=CHANGED`/`updated_at`);UNCHANGED → 完全不动。
- **P5 小结**:报告分类,**提示**对 NEW/CHANGED section 跑 `coding`(孤岛,不自动调)。
- **边界(改名/删除)**:section 改名 → 视为 NEW,旧 spec 标「疑似改名/已移除」问用户(删 / 留 / 手动改名保历史);Figma 里已删的 section → 标「已移除」问用户,**不擅删**。

**`coding`(已确认 Q1/Q2/Q3/Q8/Q13 + 详细流程)** —— `page2doc` 之后离线读 spec 出代码。**全程离线,不调 figma-mcp**。输入:目标 section spec + 本地切图 + 设计标准文档 + `project.md` + `registry.json`。
- **P0 前置校验**:`project.md` + 设计标准文档存在;目标 spec 存在且 finalize;**缺切图 HARD STOP**(spec G 段切图磁盘必须存在,缺 → 停下提示补跑 `page2doc`/`re-page2doc`,不自行下载、不访问 Figma);`registry.json` 存在(可空);superpowers 已装(P3 用)。
- **P1 出实现计划**(依据 `project.md` + 设计标准 + registry):框架/样式(`project.md`);**复用匹配 = 按 Figma 组件实例标识**(spec B 表实例名 ↔ registry「对应 Figma 节点」,命中则复用、歧义则问;非实例的重复 UI 写页面内局部,留给 `component`);**几何翻译**(B 表 x/y/w/h → `project.md` 布局模型);**token 翻译**(spec C 段忠实值 + 变量绑定 → 设计标准文档映射 → tailwind token,**禁止魔法值**);**响应式**(spec D 段 + `project.md` 断点);代码落位 `app/` + 按部署方式产 Docker 产物。
- **P2 确认计划(HARD GATE)**:自检(无占位、决策与 spec 一致、验收完整)→ 用户明确确认;未确认不改代码。
- **P3 执行(内部复用 superpowers)**:把【spec + 已确认技术决策 + 验收标准】当 spec,内部调 `superpowers:writing-plans` → `superpowers:executing-plans` 出代码。对用户仍是「一个 coding 闭环」。
- **验收两层**:① **结构/数值层**由 coding 离线自查(build 通过;几何 / token / 文本码点(弯引号/实体/大小写) / 切图引用一致;代码落位 `app/`;Docker 产物齐备,条件允许 `docker build` 可成功);② **视觉渲染层**交给 `verify` + 人,coding 不独自兜底。
- **完成标志**:目标 section 代码完成、结构/数值层自查通过;视觉层由 `verify` + 人裁定。

**`component`(已确认 Q8/Q9 + 详细流程)** —— 库的生产者/管理者;`coding` 之后手动/按需跑;**离线,不读 Figma**。输入:现有代码(`app/src`)+ `registry.json` +(可选)spec。
- **调用时机**:手动 / 按需;`coding` 可在输出里**提示**「此处有重复,建议跑 component」,但绝不自动调用(孤岛)。
- **P0 前置校验**:`project.md` 存在;代码目录存在;`registry.json` 存在或初始化(可空)。不需要 figma-mcp。
- **P1 扫描候选(判据已定)**:扫 `app/src` 找候选 —— 结构+样式高度相似地**重复 ≥2 处**,或**单处但自成一体的可复用单元**(如本是 Figma 实例、coding 当时写成了局部)。
- **P2 呈交候选清单(HARD GATE)**:候选(重复出现处、建议组件名、props 摘要、涉及文件)呈交用户逐个**采纳 / 跳过 / 调整**;**绝不臆测、不擅自重构**。
- **P3 提炼 + 替换**:采纳项抽成 `app/src/components/<Name>`;把原页面内局部实现替换为对该组件的引用。
- **P4 登记 registry**:写 / 更新 `registry.json`(`组件名 | 路径 | 用途 | props 摘要 | 对应 Figma 节点 | 预览截图`);「对应 Figma 节点」尽量回溯 spec 的组件实例标识,回溯不到则标「代码沉淀,无单一 Figma 节点」。**registry 由 `component` 单写、`coding` 只读**,靠单写 + 与文件系统校验避免漂移。
- **P5 验证 + 小结**:`build` 通过(替换没破坏);报告沉淀了哪些、复用率变化。
- **完成标志**:采纳的组件已提炼、替换、登记;build 通过。

**`verify`(已确认 Q12/Q13 + 详细流程)** —— `coding` 后校验还原度;**`docker compose` + Playwright**。
- **P0 前置校验**:`project.md` 存在;目标页代码能 build;docker / docker compose + Playwright 可用;**Figma 参照图已由 `page2doc` 持久化**(离线读,verify 不需 figma-mcp)。
- **P1 起服务**:`docker compose` 起服务(用 `coding` 产的 Docker 产物)。
- **P2 渲染截图**:Playwright 访问容器端口,**按 `project.md` 断点逐断点截图**(响应式也验)。
- **P3 比对定位**:每个 section,渲染图 vs Figma 参照图 → 像素 diff **只定位差异区**(不当判据)。
- **P4 模型 rubric 打分(逐项通过 / 不通过 + 说明)**:**token 用对 / 结构语义 / 视觉差异 / 交互态齐全** —— token/结构/交互靠查代码 + DOM,视觉靠比两图 + 差异区。
- **P5 出报告 + 建议判定**:写差异报告(逐 section、逐 rubric 项、差异区截图、**整体建议判定:过 / 待修 / 不过**)到 `docs/figma2web/verify/<page>-<date>.md`;**最终过 / 不过由人拍板**。
- **完成标志**:报告产出;人工终审通过。

## 7. 约束与依赖

- **技术栈**:v1 标准栈 React + TypeScript + Tailwind CSS(由 `init` 记录进 `project.md`,不硬编码)。
- **外部依赖**:官方 Figma MCP(`config`/`re-config`/`page2doc`/`re-page2doc` 读取);Playwright + Docker(`verify` 渲染截图);superpowers(`coding` 内部复用 `writing-plans` / `executing-plans`,**运行时必需**)。
- **运行 / 部署**:项目使用 Docker 部署,可本地运行;`coding` 产出 Docker 产物,`verify` 走 `docker compose`。
- **前提**:已有一个能本地跑的工程(脚手架不由 skill 负责)。
- **平台约束**:`figma2web` 插件的 `skills/` 目录必须扁平;调用形式 `/figma2web:<skill名>`。
- **样式约束**:颜色 / 间距 / 圆角 / 字体等走 Tailwind theme 的语义化 token,**禁止魔法值**。

## 8. 成功标准

**单页「过」的 rubric(`verify` + 人)**:
- **token 用对**:引用 Tailwind theme 的语义化 token,无魔法值。
- **结构语义正确**:DOM 结构与语义化标签合理,非一堆无意义 div。
- **视觉差异在阈值内**:渲染截图与 Figma 截图差异落在可接受范围(非像素级),经人工终审。
- **交互态齐全**:设计体现的交互态(hover / disabled、tab / 手风琴切换等)已实现。

**流程层面**:
- 转换标准化、可复用,不同页面 / 不同人经 Claude 执行得到质量一致的产物。
- **spec 可交接**:他人拿 spec 能离线复现代码,无需再读 Figma。
- 组件库随使用持续沉淀、复用率提升。
- 改稿走差异更新,不整体重跑。
- 产物符合团队技术栈与目录 / 命名规范,减少人工返工。

## 9. 开放问题(待确认)

设计层面已全部收口。仅剩**实现时定**的工程细节,不阻塞设计定稿:

- **`verify` 的 Docker 集成**:`docker compose` 暴露端口约定、Playwright 访问方式、是否接 CI(自动部分 headless 可跑,人工终审为手动闸门)。写 `verify` 的 SKILL.md 时定。
