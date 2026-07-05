---
name: config
description: 配置 codeflow 在目标项目的 issue 追踪器形态（GitHub 或本地 markdown），写成 docs/jljskills/codeflow/issue-tracker.md；每个项目跑一次即可。仅当用户主动用 `/codeflow:config` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, AskUserQuestion
disable-model-invocation: true
---

# config — 追踪器认址

## 用途

config 是 codeflow 交付链的地基配置：确定这个项目的 issue 追踪器长什么样，写成一份 `docs/jljskills/codeflow/issue-tracker.md`。to-prd、to-issues、implement、review 四个 skill 开工前都先读这份文件，取增删改查的具体操作方式——本 skill 只需每个项目跑一次，换追踪器才重跑。

## 1. 探索

- `git remote -v`：有没有指向 GitHub 的 remote，决定第 2 步的默认建议。
- `docs/jljskills/codeflow/issue-tracker.md` 是否已存在——存在则这次是改配置，先读出旧形态给用户看，不要当空白项目从头问一遍。
- 旧根 `docs/jljskills/engineering/` 是否存在——存在就提示一句 `mv docs/jljskills/engineering docs/jljskills/codeflow`，不自动迁移，交给用户自己动手。

## 2. 确认

用户未必懂"issue tracker"指什么，先解释再问。用 AskUserQuestion 二选一：

- **GitHub**：issues 挂在仓库自带的 GitHub Issues 上，用 `gh` CLI 操作；适合已有远程仓库、要跨设备协作的项目。
- **本地 markdown**：issues 落在 `docs/jljskills/codeflow/issues/` 下，一个 issue 一个文件；适合纯本地、没有远程仓库的项目。

探索阶段发现有 GitHub remote 时，默认提议 GitHub；否则默认提议本地 markdown。

选了 GitHub 时再追问一次「外部 PR 是否请求面？」——先解释：开源仓库常以 PR 形式收功能请求，PR 本质是带代码的 issue；一旦开启，`/codeflow:triage` 会把**外部** PR 拉进同一队列同一状态机，协作者在途的 PR 不受影响。用 AskUserQuestion 二选一，默认否。选本地 markdown 则跳过此问——本地形态没有 PR 这个概念。

## 3. 落盘

按用户选定的形态，参照对应模板写 `docs/jljskills/codeflow/issue-tracker.md`：

- 选 GitHub → 照 [references/tracker-github.md](references/tracker-github.md)
- 选本地 markdown → 照 [references/tracker-local.md](references/tracker-local.md)

写入内容三件套：形态声明（选了哪种、为什么；GitHub 形态附带上一步追问的答案——PR 请求面开/关）、增删改查的具体操作方式、agent-ready 状态的标记方式——to-issues 发布 issue 时打上这个标记，implement 靠它判断能不能自主开工。

## 4. 收尾

告知用户：to-prd、to-issues、implement、review、triage 开工前都会读这份文件，按形态走不同的操作方式。以后想换追踪器，重跑 `/codeflow:config` 即可，不用手动改四处。

---
> 内化自 mattpocock/skills 的 `skills/engineering/setup-matt-pocock-skills`（仅取 issue tracker 分支，2026-07-05）。
