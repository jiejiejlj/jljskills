#!/bin/bash
# git-policy 红名单拦截脚本 —— 由 /support:git-policy 按项目策略生成/删改
# 机制:PreToolUse hook。命中红名单或已启用门禁时 exit 2 拦截,其余放行(exit 0)
# 局限(有意 fail-open):
#   - 全局选项归一化仅覆盖 -C/-c/--no-pager/--git-dir/--work-tree,其余生僻全局选项仍可能绕过;
#   - `git checkout HEAD -- <path>` 等按路径丢弃的形式不在红名单内,不拦截;
#   - heredoc / `-am` 形式的 commit message 无法提取,不校验直接放行。

INPUT=$(cat)
if command -v jq >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
elif command -v python3 >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try:
    print(json.load(sys.stdin).get("tool_input", {}).get("command", ""))
except Exception:
    pass')
else
  echo "git-policy: 未找到 jq 或 python3,无法解析命令,本次放行(安装其一后护栏生效)" >&2
  exit 0
fi
[ -z "$COMMAND" ] && exit 0

# 剔除引号内内容再匹配,避免 commit message 里出现「git push」等字样被误杀
STRIPPED=$(printf '%s' "$COMMAND" | sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g")

# 全局选项归一化:把「git + 一串全局选项」折叠为「git 」再匹配红名单,
# 否则 `git -C <path>`、`git -c k=v`、`git --no-pager` 等形式会整体绕过下方模式
STRIPPED=$(printf '%s' "$STRIPPED" | sed -E 's/git([[:space:]]+(-C[[:space:]]+[^[:space:]]+|-c[[:space:]]+[^[:space:]]+|--no-pager|--git-dir=[^[:space:]]+|--work-tree=[^[:space:]]+))+[[:space:]]+/git /g')

# ===== 红名单(安装时按用户确认结果删改) =====
PATTERNS=(
  'git[[:space:]]+push[[:space:]]+([^|;&]*[[:space:]])?(-f([[:space:]]|$)|--force)'
  'git[[:space:]]+reset[[:space:]][^|;&]*--hard'
  'git[[:space:]]+clean[[:space:]]+-[A-Za-z]*f'
  'git[[:space:]]+branch[[:space:]]+([^|;&]*[[:space:]])?-D([[:space:]]|$)'
  'git[[:space:]]+(checkout|restore)[[:space:]]+(--[[:space:]]+)?\.(\/)?([[:space:]]|$)'
  'git[[:space:]]+restore[[:space:]]+(-W|--worktree)[[:space:]]+\.(\/)?([[:space:]]|$)'
)
for p in "${PATTERNS[@]}"; do
  if printf '%s' "$STRIPPED" | grep -qE "$p"; then
    echo "BLOCKED: 命令命中 git-policy 红名单(模式:$p)。用户已通过 /support:git-policy 禁止此操作;确需执行时请由用户手动运行,或修改 .claude/hooks/block-git.sh。" >&2
    exit 2
  fi
done

# ===== 可选门禁 A:main 分支保护(未启用则删除本段) =====
PROTECTED_BRANCH="main"
if printf '%s' "$STRIPPED" | grep -qE 'git[[:space:]]+(commit|push)([[:space:]]|$)'; then
  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
  if [ "$CURRENT_BRANCH" = "$PROTECTED_BRANCH" ]; then
    echo "BLOCKED: 当前在受保护分支 $PROTECTED_BRANCH,禁止直接 commit/push(git-policy 分支策略)。请先创建功能分支。" >&2
    exit 2
  fi
fi

# ===== 可选门禁 B:commit 格式校验(未启用则删除本段;PATTERN 按项目规范改) =====
COMMIT_MSG_PATTERN='^(feat|fix|refine|chore|docs)(\([^)]+\))?: .+'
if printf '%s' "$STRIPPED" | grep -qE 'git[[:space:]]+commit([[:space:]]|$)'; then
  MSG=$(printf '%s' "$COMMAND" | grep -oE -- "-m[[:space:]]+(\"[^\"]*\"|'[^']*')" | head -1 | sed -E "s/^-m[[:space:]]+[\"']//; s/[\"']\$//")
  if [ -n "$MSG" ] && ! printf '%s' "$MSG" | grep -qE "$COMMIT_MSG_PATTERN"; then
    echo "BLOCKED: commit message 不符合项目规范($COMMIT_MSG_PATTERN)。请按项目 CLAUDE.md「Git 约定」调整。" >&2
    exit 2
  fi
fi

exit 0
