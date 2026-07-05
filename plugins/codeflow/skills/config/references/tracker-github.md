# Issue tracker: GitHub

> 落盘目标：把下面的内容（按本项目实际情况改写后）写成目标项目的 `docs/jljskills/codeflow/issue-tracker.md`。

本项目的 issue 与 PRD 都以 GitHub issue 的形式存在。所有操作走 `gh` CLI，在仓库目录下运行时会自动推断出对应的 GitHub 仓库。

## 增删改查

- **建**：`gh issue create --title "..." --body "..."`。正文较长用 heredoc 传。
- **查（单条）**：`gh issue view <number> --comments`。
- **查（列表）**：`gh issue list --state open --json number,title,body,labels,comments`，按需加 `--label`、`--state` 过滤。
- **改（评论）**：`gh issue comment <number> --body "..."`。
- **改（标签）**：`gh issue edit <number> --add-label "..."` / `--remove-label "..."`。
- **删（关闭）**：`gh issue close <number> --comment "..."`。

## agent-ready 标记

用标签 `ready-for-agent` 标记"已具备足够上下文、agent 可以直接开工"的 issue：

- to-issues 把 PRD 拆成 issue 并发布到 GitHub 时，同步打上 `ready-for-agent` 标签。
- implement 挑活时，只认领带这个标签的 issue——没打标签的默认还没备齐上下文，跳过。
- 人工发现某个 issue 描述不够、需要人接手时，摘掉这个标签即可让 implement 绕开它。

## triage 标签与操作

`/codeflow:triage` 用两组标签跑状态机，规范名固定，不做映射：

- **五状态**（恰好挂一个）：`needs-triage` / `needs-info` / `ready-for-agent` / `ready-for-human` / `wontfix`。`ready-for-agent` 就是上面「agent-ready 标记」那个标签——to-issues 打的和 triage 挪的是同一个。
- **两类别**（恰好挂一个）：`bug` / `enhancement`。

打/摘标签、评论、关闭用增删改查节里已列的命令（`gh issue edit --add-label/--remove-label`、`gh issue comment`、`gh issue close`）。

### PR 请求面开启时的补充

issue-tracker.md 声明「PR 请求面：开」时，外部 PR 走同一套标签与状态机：

- **查外部 PR**：`gh pr list --state open --json number,title,body,labels,author,isCrossRepository`，`isCrossRepository: true`（fork 来源）或作者不在协作者名单里即视为外部——只有外部 PR 进 triage 队列，协作者在途 PR 不动。
- **改/关**：`gh pr edit <number> --add-label "..."` / `--remove-label "..."`、`gh pr comment <number> --body "..."`、`gh pr close <number> --comment "..."`——跟 issue 版一一对应，换 `issue` 为 `pr` 即可。

## 当一个 skill 说"发布到追踪器"

创建一个 GitHub issue。

## 当一个 skill 说"取相关 ticket"

跑 `gh issue view <number> --comments`。

---
> 内化自 mattpocock/skills 的 `skills/engineering/setup-matt-pocock-skills/issue-tracker-github.md`，砍去 wayfinder 操作；PR-as-request-surface 分支随 triage 引入改造保留（2026-07-05）。
