---
name: git-policy
description: 一次配齐项目级 git 策略:红绿灰三色权限(硬拦截/免审批/默认询问)加 commit 规范与分支约定,落地到 .claude/settings.json、hook 脚本与项目 CLAUDE.md。仅当用户主动用 `/support:git-policy` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, AskUserQuestion
disable-model-invocation: true
---

# git-policy — 红绿灰三色 git 策略

## 用途
一次运行,配齐当前项目的 git 操作策略,共四层:
- **红名单**:PreToolUse hook 硬拦截,常规形式绕不过;
- **绿名单**:`permissions.allow` 免审批放行;
- **灰区**:不配置,保持默认弹窗询问;
- **Git 约定**:commit 规范与分支策略写入项目 CLAUDE.md,其中「main 分支保护」「commit 格式校验」两项可升级为硬门禁进 hook。

核心心法:**先探测,后定策;事实作推荐,用户来拍板。**

## 何时运行
仅当用户主动用 `/support:git-policy` 指令调用时运行。典型时机:新项目接入 Claude Code,或要收紧 / 放宽现有项目的 git 权限。

## 流程

1. **探测现状**。收集并向用户呈现现状清单,缺失项标「无」:
   - `git remote -v`、默认分支、CI 配置文件;
   - 已有 `.claude/settings.json` 的 hooks 与 permissions 条目;
   - 项目 CLAUDE.md 里已有的 git 约定;
   - `git log --oneline -20` 反推 commit 风格(前缀、语言、scope)。
   完成标准:四项俱全的清单已呈现给用户。

2. **生成草案**。按 [references/policy-menu.md](references/policy-menu.md) 生成四层草案,每项带推荐值与一句理由;探测到的事实(如现有 commit 风格)只作推荐值。默认分配以菜单「默认」列为准,不得私自加红。

3. **逐层确认**。红名单、绿名单、commit 规范、分支策略各一次 `AskUserQuestion`(后两问附带硬门禁开关)。完成标准:四层均有用户明确表态;未表态的层不得落地。

4. **落地**。
   - 拷贝 [scripts/block-git.sh](scripts/block-git.sh) 到项目 `.claude/hooks/block-git.sh`:按确认结果删改 `PATTERNS`;未启用的「可选门禁 A / B」整段删除;启用门禁 B 时把 `COMMIT_MSG_PATTERN` 改为确认的格式;`chmod +x`;
   - hook 注册与绿名单**合并**进 `.claude/settings.json`,已有条目一律保留;
   - 约定写入项目 CLAUDE.md「Git 约定」节,已有该节则合并更新。
   完成标准:落盘文件的 diff 中没有任何既有配置被删除。

5. **验证**。逐项实测,全过才可宣布完成:
   - 每条红名单取一条样例命令,`echo '{"tool_input":{"command":"<样例>"}}' | .claude/hooks/block-git.sh`,exit 2 且 stderr 含 `BLOCKED`;
   - 绿名单取一条样例,exit 0;
   - 误杀回归:一条格式合规、message 含红名单字样的 commit 命令,exit 0;
   - 启用的每个门禁各取一条命中样例,exit 2;
   - `.claude/settings.json` 通过 `python3 -m json.tool` 校验;
   - 向用户展示全部改动 diff。

## 红线
- **只合并不覆盖**:settings.json 与 CLAUDE.md 的既有条目一律保留。
- **红绿不重叠**:落地前逐条交叉检查,绿名单不得放行任何命中红名单模式的命令。
- **`git push` 不进默认红名单**:封 push 会打断「commit 即发版」类工作流;用户主动要求才封。
- **验证未全过,不得宣布配置完成**。
