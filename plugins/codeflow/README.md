# codeflow — idea→ship 编码工作流

内化自 mattpocock/skills 的编码工作流：从一个还没成形的想法，走到可提交的代码。13 个 skill 分四层协作，靠文件产物衔接（不自动串调）。目标项目侧的文档统一收在 `docs/jljskills/codeflow/` 下：

- `CONTEXT.md` —— 领域术语表（domain-modeling 维护）
- `adr/` —— 达到三条件门槛的重大决策记录
- `designs/` —— grill-design 收敛出的 interface 草图
- `issue-tracker.md` —— 本项目 issue 追踪器的认址与操作方式（config 产出）
- `issues/` —— 追踪器选本地 markdown 时的 issue 正文存放处

## 主流程（文字版）

```
grill-with-docs ──▶ [说不清就 prototype] ──▶ to-prd ──▶ to-issues ──▶ 每 issue 新会话 implement（内驱 tdd，收尾 review）
```

方案先经 grill-with-docs 拷问并当场沉淀术语，说不清楚的地方岔出去用 prototype 跑一次性代码探路；拷问收敛后 to-prd 综合成 PRD，to-issues 拆成可独立认领的曳光弹切片；每个 issue 另开一个会话跑 implement，内部驱动 tdd 逐片红绿，完工前跑 review 双轴审查再提交。

## 四层 13 个 skill，各一句话

**地基**（其余 skill 的共用词汇与记忆层，通常不单独调用）

- `/codeflow:design-rules` —— 深模块设计的词汇库与判据：八术语、deep/shallow 模型、删除测试等四原则。
- `/codeflow:domain-modeling` —— 挑战冲突术语、锐化模糊词、术语当场落笔进 CONTEXT.md，按三条件门槛记 ADR。

**入口**（方案还没定型时先拷问）

- `/codeflow:grill` —— 对一份已成形的方案、计划或需求文档做对抗式压力测试，逐分支拷问逼出隐藏假设与边界情况。
- `/codeflow:grill-with-docs` —— 主流程入口：按 grill 的手法拷问方案，同时按 domain-modeling 当场沉淀术语与 ADR。

**交付**（PRD → issue → 实施的主链）

- `/codeflow:config` —— 配置目标项目的 issue 追踪器形态，写成 `issue-tracker.md`；每个项目跑一次即可。
- `/codeflow:to-prd` —— 把当前对话综合成 PRD 并发布到 issue 追踪器——不再采访用户，只做综合；测试 seam 先行并与用户确认。
- `/codeflow:to-issues` —— 把 PRD 或计划拆成曳光弹式垂直切片 issue，按依赖序发布到 issue 追踪器。
- `/codeflow:implement` —— 按 PRD 与单个 issue 实施一片工作：在预约 seam 上驱动 tdd 逐片红绿，完工跑 review 双轴审查后提交。
- `/codeflow:tdd` —— 红绿循环的规则手册：只在预先确认的 seam 上写测试、一次一片、三反模式禁区。
- `/codeflow:review` —— 对 diff 做双轴审查——Standards（仓库规范 + 坏味道基线）与 Spec（是否忠实实现源头 issue/PRD），两轴并行不合并排序。
- `/codeflow:prototype` —— 用一次性代码回答一个设计问题：验证逻辑走可交互终端小程序，探索 UI 长相走一路由多变体；答案留下，代码删掉。

**健康**（存量代码库的深化闭环）

- `/codeflow:improve-arch` —— 扫描已有代码库找深化机会（shallow → deep），以 HTML 报告呈现候选项，用户选定后接入设计树拷问；终点是 interface 草图，不实施改码。
- `/codeflow:grill-design` —— 对选定的深化候选走设计树拷问：约束 → seam 位置 → interface 形状 → 藏什么 → 哪些测试存活，收敛出 interface 草图。

## 怎么选

- 有个方案/计划/需求文档，想找漏洞 → `/codeflow:grill`
- 拷问的同时要把术语和决策当场落笔存档 → `/codeflow:grill-with-docs`
- 拷问对象是**已选定的架构深化候选**（module 该怎么切 interface）→ `/codeflow:grill-design`
- 想法还没到能拷问的方案地步、要先探索 UI 长相或验证一个状态机 → `/codeflow:prototype`
- 拷问收敛了，要综合成 PRD → `/codeflow:to-prd`
- PRD 有了，要拆成可分头认领的 issue → `/codeflow:to-issues`
- 拿到一个 issue 要动手实现 → `/codeflow:implement`（内部会读 tdd、收尾读 review，不必单独调用两者）
- 说不出项目哪里不对但觉得该深化 → `/codeflow:improve-arch`
- 新项目第一次接入 codeflow → 先 `/codeflow:config`

grill 三兄弟的分界：**grill** 拷问的是方案本身；**grill-with-docs** 拷问的同时落笔存档（主流程用这个）；**grill-design** 拷问的是已选定深化候选的设计树（improve-arch 第三阶段接入这个）。

## 流程约定

- 首次在目标项目使用先跑 `/codeflow:config`，认清 issue 追踪器长什么样，后续 to-prd/to-issues/implement/review 都依赖这份认址。
- `to-issues` 拆完之后，每个 issue **开一个新会话**执行 implement（issue 已独立可认领，不必延续拆解时的上下文）；完整表述见 `skills/implement/SKILL.md` 末段。
- 跨会话衔接（比如把某个 issue 的进度交给下一个会话继续）用 `/support:handoff`。

## 外部前置声明

- 想法还没成形、需要先梳理再进 grill 系列 → 可选先用 `/project:interview2doc`（`project` 插件）。
- 跨会话衔接 issue 进度 → `/support:handoff`（`support` 插件）。
