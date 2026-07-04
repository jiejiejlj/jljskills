# Issue tracker: 本地 markdown

> 落盘目标：把下面的内容（按本项目实际情况改写后）写成目标项目的 `docs/jljskills/codeflow/issue-tracker.md`。

本项目的 issue 与 PRD 都以本地 markdown 文件的形式存在，落在 `docs/jljskills/codeflow/issues/` 下，一个 issue 一个文件。

## 文件规格

- 路径：`docs/jljskills/codeflow/issues/NNN-<slug>.md`，`NNN` 从 `001` 起三位数顺序编号，`slug` 是短横线分隔的英文摘要。
- frontmatter 必含三个字段：

```yaml
---
status: open       # open | closed
agent_ready: false # true | false
blocked_by: []     # 依赖的其他 issue 编号，如 ["003"]
---
```

- 正文自由格式：标题、背景、验收标准都放这里；对话记录追加到文末的 `## Comments` 标题下。

## 增删改查

- **建**：Glob `docs/jljskills/codeflow/issues/*.md` 找当前最大编号 +1，`Write` 新文件，写好 frontmatter 三件套。
- **查（单条）**：`Read` 对应路径。
- **查（列表 / 筛选）**：Glob 拿到全部文件后，用 Grep 按 `status:`、`agent_ready:`、`blocked_by:` 过滤。
- **改**：`Edit` 对应文件——改 `status`、`agent_ready`，或在 `## Comments` 下追加一段。
- **删（关闭）**：`Edit` 把 `status` 改成 `closed`，不物理删除文件。

## agent-ready 标记

`agent_ready: true` 表示"已具备足够上下文、agent 可以直接开工"：

- to-issues 把 PRD 拆成 issue 并写文件时，同步把 `agent_ready` 设为 `true`。
- implement 挑活时，只认领 `status: open` 且 `agent_ready: true`、`blocked_by` 里列的 issue 都已 `closed` 的文件。
- 人工发现某个 issue 描述不够时，把 `agent_ready` 改回 `false` 即可让 implement 绕开它。

## 当一个 skill 说"发布到追踪器"

在 `docs/jljskills/codeflow/issues/` 下新建一个文件（目录不存在则一并创建）。

## 当一个 skill 说"取相关 ticket"

`Read` 对应路径；用户通常会直接给出文件名或编号。

---
> 内化自 mattpocock/skills 的 `skills/engineering/setup-matt-pocock-skills/issue-tracker-local.md`，路径改为 `docs/jljskills/codeflow/issues/`、文件规格补齐 frontmatter 三字段（2026-07-05）。
