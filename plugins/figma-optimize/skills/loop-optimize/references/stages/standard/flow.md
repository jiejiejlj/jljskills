# standard 详细流程

交付 / 维护前评审 Figma **设计规范板本身**是否成体系并帮改到位, 产一份标准体系评审报告.

## 核心心法

面向**设计师**, 在设计规范板交付或长期维护之前, 审查规范板**本身**是否成体系, 弥合"标准散乱"与"开发要一套可信 token"之间的鸿沟. AI 在这里充当**标准体系守门人**: 检查变量 / 文本样式是否成体系, 是否已 token 化, 命名是否规范, 而不是审查某个具体界面稿.

**AI 只揪可验证的体系问题(缺档 / 未 token 化 / 命名不规范 / 近似重复), 取值与审美归设计师.**

> 通用纪律见 SKILL.md 红线, 本文件不复述.

## P0 — 前置校验

1. figma-mcp 可用(未认证 → 先跑认证流程; 开局用 `whoami` 亮认证身份给用户确认改的是对的账号 / 文件).
2. 向用户索取**待审的设计规范板链接 / 范围**(整板 / 若干集合). **不落盘, 每次现问.**
3. 说明本次评审依据: 体系向评审清单(见 [checklist.md](checklist.md)).
4. **Read [`../../fingerprint.md`](../../fingerprint.md)(硬性步骤)装载指纹机制**; 按其「分诊比对闸门」读仓库台账 + 变量 / text style 的 pluginData, 命中且双账一致的对象跳过(已裁定 · 未变), 只审新增 / 变更项. **此步绝不因"看起来是新文件"跳过.**

## P1 — 读全量体系

1. **Read [`../../figma-facts.md`](../../figma-facts.md) 装载共享判据**(硬性步骤): 库变量误判坑, 三源 API, 写回通用坑, 纪律四条, P1–P5 全程适用, 判据正文以它为唯一权威, 不在本文件复述.
2. **`use_figma` 读全量**: 对规范板执行三源 API(见 figma-facts), 拿到全量**变量集合 / 变量 / text styles**, 这是本次审计的完整数据源(当**审计对象**, 不当参照标准).
3. **`get_variable_defs` 仅快览**: 仅用它做快速浏览, **不作为审计主渠道**; 是否已 token 化以 figma-facts 的库变量判据为准 — 这是 S-B 维度的核心判据.
4. 读全量后按集合 / mode 归类, 为 P2 逐维度评审做数据准备.

## P2 — 逐维度评审

对照 [checklist.md](checklist.md) 的 S-A~S-E 五维逐条审查:

1. **S-A 变量集合完整性**: 遍历 `getLocalVariableCollectionsAsync` 结果, 检查色 / 字阶 / 间距 / 圆角是否成体系, 有无整类缺档; 检查 `variable.valuesByMode` 下集合分组 / mode(如明暗)是否完整.
2. **S-B token 化纯净度**: 检查游离裸值; 辨别库变量 vs 真正裸 hex(判据见 figma-facts, P1 已装载).
3. **S-C 命名规范**: 遍历 `variable.name`, 检查命名是否有语义, 层级是否清晰, 同类命名风格是否一致.
4. **S-D 字阶 & 字体标准**: `getLocalTextStylesAsync` 检查字号 / 行高是否成阶, 是否缺档; `style.fontName` 比对标准字体族揪非标字体, 缺失字体用 `listAvailableFontsAsync` 判定(`hasMissingFont` 仅 TextNode 有, TextStyle 上取不到).
5. **S-E 收敛**: 比对 `valuesByMode` 解析值, 找出重复 / 近似应合并的 token.

产带严重度的建议列表, 每条含: 问题 / 改法 / 依据(S 编号) / 严重度.

## P3 — 逐条裁定

逐维度, 逐条呈交建议, 用户对每条选:

- **采纳** — 进入 P4 二次选择.
- **跳过** — 记入报告(跳过).
- **再调** — 用户给反馈, AI 修正该条后重新呈交.

## P4 — 采纳项二次选择

每条采纳的问题, 用户再选处置方式:

- **让 AI 改** — 进入 P5 写回.
- **我自改** — AI 给出明确, 可照做的改法说明(改哪个变量 / 集合, 从什么值改到什么值, 为什么), 交设计师在 Figma 自行修改.

## P5 — 写回 Figma(仅「让 AI 改」项)

1. `use_figma` 写入改动: 重命名变量(`variable.name = …`), 绑定变量(`setBoundVariableForPaint` 等返回新对象需重赋), 收敛 token(合并近似变量后改引用). 配方细节见 [cookbook.md](cookbook.md).
2. 增量小步: 每次只改一个变量 / 一小类, 不要一次性大批量改动.

## P6 — 复审

复审体系问题是否达标:

- 理想为体系问题**归零**;
- 或仅剩用户**有意保留**, 并在报告标注的例外.

未达标项回 P3 与用户确认是保留还是继续改.

## P7 — 标准体系评审报告

按 [report-template.md](report-template.md) 出报告: 体系快照, 发现与处置结果, 保留的例外, 复审结论, 给「界面评审 / 开发」的 TL;DR.

## P8 — 盖指纹 + 更新台账(硬性收尾, 双账互证)

按 [fingerprint.md](../../fingerprint.md) 的「何时盖 / HARD GATE」执行, 用本阶段「审计面(rev 1)」算 `fp`:

1. **Figma 侧**: 给本阶段所审**变量与 text style** `setSharedPluginData('loop_optimize','audit', {fp,stage:'standard',decision,rev,ts})`(变量与 TextStyle 均支持 setSharedPluginData; 命名空间用 `loop_optimize`; `ts` 由用户给或取当前, 脚本内 `Date.now()` 被禁).
2. **仓库侧**: 写 / 更新 `docs/jljskills/figma-optimize/.loop-optimize-ledger.json`.
3. 盖搭已批准裁决的顺风车, 阶段末统一盖一次(只切一次页), 一句话披露.

> 未盖台账 = 本阶段**未收尾**.

## 完成标志

- 体系问题复审后归零, 或仅剩报告标注的有意例外.
- S-A / S-B 高严重度问题均已处置(改到位或明确跳过并记录).
- 报告产出, 可作为界面评审 / 开发的权威依据凭证.
- **P8 已执行: 本阶段变量 / text style 双账俱盖且一致.**

## 边界

- **只审既有规范板**并按用户裁定优化, **不无中生有设计新体系**.
- **不做取值裁决**, 审美与具体取值归设计师; AI 只揪可验证的体系问题.
- 越出「评审 + 经确认写回 Figma + 出报告」范围即停.

## 审计面(rev 1)

本阶段喂进 [fingerprint.md](../../fingerprint.md) 的 `surface()` prop 清单(机制正文见该文件, 这里只定义本阶段取哪些 prop):

- **变量集合名**(所属 collection 名, 用于按集合分组去重).
- **变量 name**(命名本身即审计对象, S-C 维度).
- **变量 type**(色 / 数值 / 字符串等, 判别集合内类型是否一致).
- **valuesByMode**(各 mode 下的解析值, S-A2 完整性与 S-E 收敛均据此比对).
- **text style 属性**(`fontName.family` / `.style`, 字号, 行高, 用于 S-D 字阶字体审计).

canon / fnv1a 复用 fingerprint.md, 本阶段只定义 surface 取哪些 prop.
