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

- **每个 fenced block 都是可执行的.** Showboat 把所有 code block 都当作可运行的 — 没有 "display only" 模式. 静态内容 (trees, diagrams) 必须用一个能产出该 output 的命令, 例如 `cat <<'HEREDOC' ... HEREDOC`
- **非确定性的 output 会破坏 verify.** 计时, 日期和随机值在不同次运行之间会不同. 避免捕获像 `bun test` 这类 output 含 wall-clock time 的命令. 改用确定性的替代方案 (例如用 `grep -c` 来数 tests)
- **output 里出现 code fences.** 若捕获到的 output 含有 triple backticks, showboat 会自动使用 quadruple-backtick fences — 无需特殊处理
- **不要对 `walkthrough.md` 运行 prettier.** Showboat 自己管理它的 formatting; prettier 会破坏已验证的 output block. (用户级的 auto-format hook 只在 `Edit`/`Write`/`MultiEdit` 工具调用时触发 — 因为 `uvx showboat` 是通过 shell 写入的, 该 hook 从不会看到这个文件. 注意不要通过用 `Edit` 或 `Write` 直接编辑 `walkthrough.md` 而绕过那层保护.)
