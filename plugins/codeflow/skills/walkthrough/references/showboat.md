# Showboat reference

Showboat 创建可执行的 markdown 文档, 其中每个 fenced code block 都可被重新运行, 可被验证.

## Commands

- `uvx showboat init <file> <title>` — 创建一份新文档
- `uvx showboat note <file> [text]` — 追加 commentary (纯 markdown, 不执行). 多行用 heredoc: `uvx showboat note file.md <<'EOF' ... EOF`
- `uvx showboat exec <file> <lang> [code]` — 运行代码, 捕获 output. 追加一个 `lang` block (即命令) 和一个 `output` block (即结果)
- `uvx showboat pop <file>` — 移除最近一条 entry (在一次失败的 exec 之后很有用)
- `uvx showboat verify <file>` — 重新运行所有 code block, 与已捕获的 output 做 diff
- `uvx showboat verify <file> --output <file>` — 重新运行并就地更新 output block

## Gotchas

- **每个 fenced block 都是可执行的.** Showboat 把文档里**每一个** ``` 围栏都当可运行的 — 没有 "display only" 模式. 静态内容 (trees, diagrams) 必须用一个能产出该 output 的命令, 例如 `cat <<'HEREDOC' ... HEREDOC`
- **坑 A · CRLF 源文件会让 `verify` 永久失败.** 源文件是 Windows 换行 (CRLF) 时, `sed` 输出带 `\r`, 与存档的 LF output 永远对不上, verify 每次都报 diff. 解决: 把涉及的源文件行尾转成 LF; 临时兜底是读取命令接 `| tr -d '\r'`.
- **坑 B · `note` 里的裸围栏会被当命令执行.** 因为每个 ``` 围栏都可执行, 在 `note` prose 里画图 / 放静态内容时**永不用 ``` 围栏, 改用 4-空格缩进** (否则 verify 报 `exec: no command`). 需要可执行的图才用 `cat <<'EOF' ... EOF`.
- **非确定性的 output 会破坏 verify.** 计时, 日期和随机值在不同次运行之间会不同. 避免捕获像 `bun test` 这类 output 含 wall-clock time 的命令. 改用确定性的替代方案 (例如用 `grep -c` 来数 tests)
- **output 里出现 code fences.** 若捕获到的 output 含有 triple backticks, showboat 会自动使用 quadruple-backtick fences — 无需特殊处理
- **不要直接编辑或 prettier 模块文档.** Showboat 自己管理**模块文档** (`walkthrough-<scope>-<日期>.md`) 的 formatting; prettier 或手改会破坏已验证的 output block. 只经 `uvx showboat` 命令写它们, **不要用 `Edit`/`Write` 直接编辑** — (用户级 auto-format hook 只在 `Edit`/`Write`/`MultiEdit` 时触发, `uvx showboat` 走 shell 写入, hook 看不到这些文件; 别用 `Edit`/`Write` 绕过那层保护.) 地图 `walkthrough.md` 是纯 markdown, 不经 showboat, 才可以用 `Write` 直接写.
