# Quality Dimensions(质量维度)

六个加权质量维度的统一参考。每个维度含评分标准(1–5)、要找的证据、常见改进套路。

## Contents

- [Score Definitions](#score-definitions)
- [Effectiveness (28%)](#effectiveness-28)
- [Clarity (22%)](#clarity-22)
- [Best Practices (17%)](#best-practices-17)
- [Documentation (15%)](#documentation-15)
- [Verification (10%)](#verification-10)
- [Trigger Coverage (8%)](#trigger-coverage-8)
- [Weighted Score Calculation](#weighted-score-calculation)
- [Scoring Tips](#scoring-tips)

## Score Definitions

| 分数 | 标签 | 含义 |
| ----- | --------- | ---------------------------------- |
| **5** | Excellent | 典范,树立标准 |
| **4** | Good      | 扎实,有小改进空间 |
| **3** | Adequate  | 能用,有明显缺口 |
| **2** | Poor      | 有重大问题 |
| **1** | Failing   | 根本性问题 |

## Effectiveness (28%)

_这个 skill 达成了它声称的用途吗?_

| 分数 | 标准 |
| ----- | --- |
| **5** | 用途清晰且完全达成。指令完整、可执行。边界情况处理得当。 |
| **4** | 用途清晰、大体达成。覆盖或边界情况有小缺口。 |
| **3** | 用途有陈述但只部分达成。部分指令不清或不完整。 |
| **2** | 用途含糊或达成得差。功能有重大缺口。 |
| **1** | 用途不清或未达成。照指令做不成它声称的目标。 |

**要找的证据**:

- description 或开篇有清晰的用途陈述
- 完整的分步指令,不跳步
- 边界情况与错误处理指引
- 从头到尾逻辑连贯——每一步都拿得到前序步骤给的东西
- 相互矛盾的指引或范围错配(危险信号)

**常见改进**:

| 问题 | 改法 |
| --- | --- |
| 用途含糊 | 换成「这个 skill 产出什么」的具体陈述 |
| 缺步骤 | 心里走一遍,补上任何用户会来问的步骤 |
| 无错误处理 | 加一节覆盖常见失败模式与恢复 |
| 前后矛盾 | 消解冲突指令,择一 |
| 范围错配 | 让用途陈述与实际指令对齐 |

## Clarity (22%)

_这个 skill 对 Claude 和人类维护者都好懂吗?_

| 分数 | 标准 |
| ----- | --- |
| **5** | 一读就懂。章节组织良好。术语一致。示例好。 |
| **4** | 清晰,有小的含糊。组织良好。多数术语有定义。 |
| **3** | 大体好懂。有些段落令人困惑。组织可改进。 |
| **2** | 频繁令人困惑。组织差。术语不一致。 |
| **1** | 极难理解。杂乱无章。解释矛盾或缺失。 |

**要找的证据**:

- 章节顺序合逻辑,标题层级一致
- 语言清晰简洁——术语有解释或避开
- 善用排版(列表、表格、带语言标记的代码块)
- 有示例阐明关键概念
- 密不透风的文字墙、被动语态、术语不一致(危险信号)

**常见改进**:

| 问题 | 改法 |
| --- | --- |
| 术语不一致 | 择一术语,通篇一致使用 |
| 被动语态 | 「Files are processed」→「The skill processes files」 |
| 长难句 | 拆成短句 |
| 术语未定义 | 加术语表或就地定义 |
| 文字墙 | 用列表、表格、代码块 |

## Best Practices (17%)

_它遵循当前的 Claude Code skill 设计范式吗?_

### Size Targets

| 指标 | 目标 | 可接受 | 危险信号 |
| --- | --- | --- | --- |
| SKILL.md 行数 | < 200 | < 400 | > 500 |
| SKILL.md 词数 | < 2,000 | < 4,000 | > 5,000 |
| SKILL.md token 数 | < 3,000 | < 5,000 | > 7,000 |

| 分数 | 标准 |
| ----- | --- |
| **5** | SKILL.md 在目标尺寸内。子目录用得当。frontmatter 只用有记录的字段。invocation 控制配置正确。 |
| **4** | SKILL.md 在可接受范围。内容值得时才用 reference。frontmatter 正确。需要时有 invocation 控制。 |
| **3** | SKILL.md 渐长(400–600 行)。抽出 reference 会更好。frontmatter 有小问题。没考虑 invocation 控制。 |
| **2** | SKILL.md 太长(> 600 行)。需要却没做渐进式披露。frontmatter 用了无记录字段。有副作用的 skill 缺安全控制。 |
| **1** | 主文件臃肿(> 800 行)。内容杂乱。frontmatter 无效。危险操作无 invocation 护栏。 |

**要找的证据**:

- frontmatter 只用有记录的字段:`name`、`description`、`argument-hint`、`disable-model-invocation`、`user-invocable`、`allowed-tools`、`model`、`effort`、`context`、`agent`、`hooks`、`paths`、`shell`
- `name` 与目录名一致,小写/数字/连字符,最多 64 字符
- 有副作用的 skill(部署、提交、发消息、删除)用 `disable-model-invocation: true`
- 不该出现在 `/` 菜单里的背景知识 skill 用 `user-invocable: false`
- 只读或受限访问的 skill 带 `allowed-tools`
- 渐进式披露:概览在 SKILL.md,细节进 `references/`、`assets/`、`scripts/`

**常见改进**:

| 问题 | 改法 |
| --- | --- |
| SKILL.md 臃肿 | 把细节抽到 `references/`;目标 < 5k token |
| 有副作用的 skill 无护栏 | 加 `disable-model-invocation: true` |
| 知识型 skill 出现在菜单 | 加 `user-invocable: false` |
| 工具不受限 | 给只读或受限 skill 加 `allowed-tools` |
| 简单 skill 过度工程 | 删掉不必要的 reference 文件;留在 SKILL.md 里 |

## Documentation (15%)

_支撑文档是否完整、组织良好?_

| 分数 | 标准 |
| ----- | --- |
| **5** | 覆盖全面。reference 文件链接良好。所有章节完整。大文件有 TOC。 |
| **4** | 覆盖良好。多数章节完整。reference 文件存在且已链接。 |
| **3** | 覆盖尚可。有些章节稀薄。reference 文件可能缺失或链接不佳。 |
| **2** | 覆盖不完整。多个章节缺失。reference 文件组织差。 |
| **1** | 文档极少。关键章节缺失。需要却无支撑文件。 |

**要找的证据**:

- 有 reference 时,SKILL.md 含「Reference Files」一节
- 所有链接都指向真实文件(无断路径)
- 大 reference 文件(> 100 行)含 TOC
- 深浅得当——复杂 skill 不过浅,简单 skill 不臃肿
- 内容分布合理:概览在 SKILL.md,细节在 reference

**常见改进**:

| 问题 | 改法 |
| --- | --- |
| 缺用途陈述 | 在第一段加清晰用途 |
| 章节顺序差 | 重排:用途 → 用法 → 细节 → reference |
| 缺 reference 链接 | 加带说明的 Reference Files 一节 |
| 链接断裂 | 修路径,核对所有链接可达 |
| 无示例 | 加 `examples.md`,含 3–5 个真实场景 |

## Verification (10%)

_你能确认这个 skill 的输出正确吗?_

按 skill 类型区别打分——不是所有 skill 都需要同等严格。

| 分数 | 标准 |
| ----- | --- |
| **5** | 有显式成功标准、验证命令/步骤、预期输出示例。读者知道「做对了」长什么样。 |
| **4** | 陈述了成功标准。提到验证方式但未完全指定。 |
| **3** | 成功标准可从指令隐含推出,但无显式验证步骤。 |
| **2** | 对成功只有含糊概念(「应该能正常工作」)。无验证机制。 |
| **1** | 无成功标准、无验证、无从确认输出质量。 |

**Skill-type modifiers**:

- **Task skills**(如 release runner、部署):严格打分——每个大阶段后须有显式验证命令
- **Analysis skills**(cc-review、code-audit):中等打分——定义好的输出格式/模板即隐式验证
- **Reference/knowledge skills**:宽松打分——用户判断就是验证闸门

**要找的证据**:

- 显式定义了成功标准或「做完长什么样」
- 含验证命令或步骤(如「跑测试」「查 git status」)
- 输出格式规范(报告模板、结构化输出)
- 「你怎么知道它成了?」的指引

**常见改进**:

| 问题 | 改法 |
| --- | --- |
| 无成功标准 | 加显式「做完长什么样」一节 |
| 任务型 skill 无验证 | 每个大阶段后加验证命令 |
| 分析型 skill 无格式 | 在报告模板或输出节定义输出结构 |
| 含糊的「应该能工作」 | 换成可度量标准 |
| 无输出示例 | 加展示正确结果的预期输出 |

## Trigger Coverage (8%)

_用户会发现并调用这个 skill 吗?_

frontmatter 的 `description` 是首要发现机制。description 争抢字符预算,在 skill 列表里超 250 字符会被截断——把关键词前置。

| 分数 | 标准 |
| ----- | --- |
| **5** | 三段式([做什么]。Use when [触发]。[能力]。),带多个自然触发短语与同义词。 |
| **4** | 有三段式。触发短语好,覆盖多数常见调用。 |
| **3** | 有触发但缺能力节,或能力糅进了「做什么」节。 |
| **2** | 触发短语少。缺三段式的一段或多段。用户多半不会自然发现它。 |
| **1** | 无有意义的触发短语或结构。skill 多半不会被调用。 |

**要找的证据**:

- 三段式:**[做什么]。Use when [触发]。[关键能力]。**
- 第三人称语态(「Analyzes...」「Generates...」,不是「Analyze...」「Generate...」)
- description 长度 200–250 字符;低于 1024 字符(硬上限)
- 触发节里措辞、动词、名词、同义词多样
- 自然语言贴合用户真实的表述方式

**危险信号**:description < 50 字符、关键词罗列式、缺「use when」、祈使语态

**常见改进**:

| 问题 | 改法 |
| --- | --- |
| 缺三段式 | 重构成:[做什么]。Use when [触发]。[关键能力]。 |
| description 太短 | 用触发短语与能力扩写(目标 200–250 字符) |
| 缺同义词 | 加变体:「commit」→「commit, committing, make commits」 |
| 无「use when」 | 加「Use when...」子句作第二句 |
| 只有技术词 | 加自然语言:「git workflow」→「git workflow, shipping code, preparing changes」 |

## Weighted Score Calculation

```text
Weighted Score =
  (Effectiveness × 0.28) +
  (Clarity × 0.22) +
  (Best Practices × 0.17) +
  (Documentation × 0.15) +
  (Verification × 0.10) +
  (Trigger Coverage × 0.08)
```

**示例**:

| 维度 | 分数 | 权重 | 贡献 |
| ---------------- | ----- | ------ | ------------ |
| Effectiveness    | 4     | 0.28   | 1.12         |
| Clarity          | 5     | 0.22   | 1.10         |
| Best Practices   | 3     | 0.17   | 0.51         |
| Documentation    | 4     | 0.15   | 0.60         |
| Verification     | 3     | 0.10   | 0.30         |
| Trigger Coverage | 4     | 0.08   | 0.32         |
| **Total**        |       |        | **3.95**     |

结果:**Good**(3.5–4.4 区间)

## Scoring Tips

- **Borderline cases(临界情形)**:问题面向用户则往低判;仅是观感则往高判
- **Evidence-based(基于证据)**:永远引用具体行或文件——「Effectiveness: 4 —— 用途在第 3 行清晰;第 45 行缺错误处理」,而非「看着不错」
- **Calibration(校准)**:各类型 skill 的分数锚点见 `scoring-examples.md`
