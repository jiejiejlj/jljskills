#!/usr/bin/env bash
# 人在环复现回路。
# 复制这个文件，编辑下面的步骤，然后运行它。
# agent 跑这个脚本；用户在自己的终端里跟着提示操作。
#
# 用法：
#   bash hitl-loop.sh
#
# 两个 helper：
#   step "<指令>"          → 显示指令，等用户按 Enter
#   capture VAR "<问题>"   → 显示问题，把回答读进 VAR
#
# 结束时，捕获到的值以 KEY=VALUE 形式打印，供 agent 解析。

set -euo pipefail

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [完成后按 Enter] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
}

# --- 以下按需编辑 ---------------------------------------------------------

step "打开 http://localhost:3000 的应用并登录。"

capture ERRORED "点击「导出」按钮，是否抛出错误？(y/n)"

capture ERROR_MSG "把错误信息粘过来（没有则填 'none'）："

# --- 以上按需编辑 ---------------------------------------------------------

printf '\n--- Captured ---\n'
printf 'ERRORED=%s\n' "$ERRORED"
printf 'ERROR_MSG=%s\n' "$ERROR_MSG"
