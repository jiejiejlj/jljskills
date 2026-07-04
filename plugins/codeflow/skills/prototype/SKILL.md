---
name: prototype
description: 用一次性代码回答一个设计问题：验证逻辑/状态机走可交互终端小程序，探索 UI 长相走一路由多变体；答案留下，代码删掉。仅当用户主动用 `/codeflow:prototype` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, AskUserQuestion
disable-model-invocation: true
---

# prototype — 一次性代码答一个设计问题

## 定位

原型是**答一个问题就该扔的代码**，问题的形状决定原型的形状。它是主流程的旁路：拷问（grill）里说不清、争不明白的设计问题，写一次性代码验证比继续嘴仗更快。

## 先分流

选错分支，整个原型白做——动笔前先判断问题属于哪一类：

- **「这套逻辑/状态机对不对」** → Read [references/logic.md](references/logic.md)。搭一个可交互终端小程序，把状态机推过纸上想不清楚的用例。
- **「这东西该长什么样」** → Read [references/ui.md](references/ui.md)。在一个路由上并排渲染几个长相差很大的变体，靠 URL search param 切换。

问题本身分不清、用户又不在场时，按周边代码判断：原型挨着的是后端 module → 走逻辑分支；挨着的是页面/组件 → 走 UI 分支。判断结果写成一句假设，放在原型代码顶部。

## 六铁律

两个分支都要守：

1. **天生即弃，且显式标注**——放在被验证的 module/页面旁边，让上下文一看就懂；命名让随手翻到的人也能看出这是原型而非正式代码；UI 侧的路由沿项目既有约定，不建新的顶层结构。
2. **一条命令能跑**——挂到项目既有任务运行器（`package.json` scripts / Makefile / justfile 等），用户不必去记路径。
3. **默认无持久化**——状态活在内存里，持久化是原型要验证的东西，不是它该依赖的东西；确实要验证数据库时，接一个带「PROTOTYPE——可清除」字样命名的草稿库或本地文件。
4. **不做打磨**——无测试、无超出「能跑起来」所需的错误处理、无抽象。目的是尽快学到东西然后删掉它。
5. **每步呈现完整状态**——逻辑侧每次动作后、UI 侧每次切换变体后，都把当前相关状态整体打印/渲染出来，不是只给增量。
6. **答完即删或吸收**——问题有答案了，原型就该消失：删掉，或者把验证过的决策吸收进正式代码，不留着在仓库里烂掉。

## 收尾

原型本身不值得留，**答案**才值得留——连同它回答的那个问题，落进 commit message、ADR（domain-modeling 维护于 `docs/jljskills/codeflow/adr/`，格式见 [`../domain-modeling/SKILL.md`](../domain-modeling/SKILL.md)）、issue（决策性片段的收纳规则见 [`../to-prd/SKILL.md`](../to-prd/SKILL.md) 第 3 节），或原型旁的 `NOTES.md`。用户在场，当场问一句「这教会你什么」；用户不在场，先留占位，等验证结果回来再填，别把没验证过的原型直接删掉。

---
> 内化自 mattpocock/skills 的 `skills/engineering/prototype`（2026-07-05）。
