# git-policy Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 `support` 插件中实现 `/support:git-policy` skill——一次配齐项目级 git 红绿灰三色权限策略与 Git 约定(commit 规范、分支策略,含两项可选硬门禁)。

**Architecture:** skill 由三个文件组成:`SKILL.md`(五步主流程:探测→草案→确认→落地→验证)、`references/policy-menu.md`(三色菜单与约定层选项,草案阶段的单一真相源)、`scripts/block-git.sh`(hook 脚本模板,含两段可选门禁)。脚本先行(可实测),文档后行(引用脚本)。

**Tech Stack:** Bash + jq(hook 脚本)、Markdown(skill 文档)、Claude Code plugin 规范。

**Spec:** `docs/superpowers/specs/2026-07-03-git-policy-skill-design.md`

## Global Constraints

- 全部内容用**简体中文**(仓库约定)。
- 三处 name 一致:目录 `git-policy`、frontmatter `name: git-policy`、调用 `/support:git-policy`。
- skills 目录扁平:`plugins/support/skills/git-policy/` 下不再嵌套 skill。
- `disable-model-invocation: true` + description 注明「仅当用户主动用 `/support:git-policy` 指令调用时使用」。
- commit message 风格:`feat(support): ...` 中文描述,尾行 `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`。
- SKILL.md 写完须过写作指南自检:逐行 no-op 测试;引导词为「红绿灰三色策略」。
- 默认策略红线(来自 spec):`git push` 不进默认红名单;红名单只含不可逆操作;绿名单只含只读命令。
- 最后必须 push(滚动分发)。

---

### Task 1: hook 脚本模板 `block-git.sh`(TDD)

**Files:**
- Create: `plugins/support/skills/git-policy/scripts/block-git.sh`
- Test: `/tmp/claude-1000/-home-king-github-jiejiejlj-jljskills/85879ab2-2e32-487a-a816-2250ffd26d9e/scratchpad/test-block-git.sh`(测试脚本放 scratchpad,不入库)

**Interfaces:**
- Produces: `scripts/block-git.sh`——从 stdin 读 PreToolUse JSON,红名单命中/门禁命中时 stderr 输出 `BLOCKED:` 前缀信息并 exit 2,否则 exit 0。红名单数组名 `PATTERNS`,门禁 A 段标记 `可选门禁 A:main 分支保护`,门禁 B 段标记 `可选门禁 B:commit 格式校验`,格式变量 `COMMIT_MSG_PATTERN`。Task 3 的 SKILL.md 将按这些名字引用。

- [ ] **Step 1: 写失败测试**

写入 scratchpad `test-block-git.sh`:

```bash
#!/bin/bash
# git-policy hook 脚本测试。须在非 git 目录运行(scratchpad),门禁 A 才不干扰
SCRIPT="/home/king/github/jiejiejlj/jljskills/plugins/support/skills/git-policy/scripts/block-git.sh"
pass=0; fail=0
json_cmd() { python3 -c 'import json,sys; print(json.dumps({"tool_input":{"command":sys.argv[1]}}))' "$1"; }
t() { # 用法: t <期望exit码> <命令串>
  local expected="$1"; shift
  json_cmd "$1" | bash "$SCRIPT" >/dev/null 2>&1
  local got=$?
  if [ "$got" = "$expected" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL(got=$got want=$expected): $1"; fi
}
# 红名单:不可逆操作必须拦截
t 2 'git reset --hard HEAD~1'
t 2 'git push --force origin main'
t 2 'git push -f'
t 2 'git clean -fd'
t 2 'git branch -D feature-x'
t 2 'git checkout .'
t 2 'git restore .'
t 2 'cd /some/dir && git reset --hard'
# 灰区/绿区:必须放行
t 0 'git status'
t 0 'git push origin main'
t 0 'git push --follow-tags'
t 0 'git checkout .gitignore'
t 0 'git clean -n'
# 误杀回归:message 里出现红名单字样不得拦截(格式合规)
t 0 'git commit -m "feat(docs): 说明 git push --force 的风险"'
# 门禁 B:格式不合规必须拦截;无 -m(如 --amend)放行(fail-open)
t 2 'git commit -m "随便写写"'
t 0 'git commit --amend --no-edit'
echo "pass=$pass fail=$fail"
[ "$fail" = 0 ]
```

- [ ] **Step 2: 运行测试,确认失败**

```bash
cd /tmp/claude-1000/-home-king-github-jiejiejlj-jljskills/85879ab2-2e32-487a-a816-2250ffd26d9e/scratchpad && bash test-block-git.sh
```
Expected: 全部 FAIL(脚本不存在,bash 返回 127 ≠ 期望值)。

- [ ] **Step 3: 写脚本**

写入 `plugins/support/skills/git-policy/scripts/block-git.sh`:

```bash
#!/bin/bash
# git-policy 红名单拦截脚本 —— 由 /support:git-policy 按项目策略生成/删改
# 机制:PreToolUse hook。命中红名单或已启用门禁时 exit 2 拦截,其余放行(exit 0)
# 局限(有意 fail-open):heredoc / -am 形式的 commit message 无法提取,不校验直接放行

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

# ===== 红名单(安装时按用户确认结果删改) =====
PATTERNS=(
  'git[[:space:]]+push[[:space:]][^|;&]*(-f([[:space:]]|$)|--force)'
  'git[[:space:]]+reset[[:space:]][^|;&]*--hard'
  'git[[:space:]]+clean[[:space:]]+-[A-Za-z]*f'
  'git[[:space:]]+branch[[:space:]][^|;&]*-D([[:space:]]|$)'
  'git[[:space:]]+(checkout|restore)[[:space:]]+(--[[:space:]]+)?\.([[:space:]]|$)'
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
  MSG=$(printf '%s' "$COMMAND" | sed -nE 's/.*-m[[:space:]]+"([^"]*)".*/\1/p' | head -1)
  [ -z "$MSG" ] && MSG=$(printf '%s' "$COMMAND" | sed -nE "s/.*-m[[:space:]]+'([^']*)'.*/\1/p" | head -1)
  if [ -n "$MSG" ] && ! printf '%s' "$MSG" | grep -qE "$COMMIT_MSG_PATTERN"; then
    echo "BLOCKED: commit message 不符合项目规范($COMMIT_MSG_PATTERN)。请按项目 CLAUDE.md「Git 约定」调整。" >&2
    exit 2
  fi
fi

exit 0
```

然后 `chmod +x plugins/support/skills/git-policy/scripts/block-git.sh`。

- [ ] **Step 4: 运行测试,确认全过**

```bash
cd /tmp/claude-1000/-home-king-github-jiejiejlj-jljskills/85879ab2-2e32-487a-a816-2250ffd26d9e/scratchpad && bash test-block-git.sh
```
Expected: `pass=16 fail=0`,exit 0。

- [ ] **Step 5: 门禁 A 实测(临时 git 仓库)**

```bash
cd /tmp/claude-1000/-home-king-github-jiejiejlj-jljskills/85879ab2-2e32-487a-a816-2250ffd26d9e/scratchpad \
&& rm -rf gate-a-repo && git init -qb main gate-a-repo && cd gate-a-repo \
&& echo '{"tool_input":{"command":"git commit -m \"feat: x\""}}' | bash /home/king/github/jiejiejlj/jljskills/plugins/support/skills/git-policy/scripts/block-git.sh; echo "main上: exit=$?" \
&& git checkout -qb feat/t \
&& echo '{"tool_input":{"command":"git commit -m \"feat: x\""}}' | bash /home/king/github/jiejiejlj/jljskills/plugins/support/skills/git-policy/scripts/block-git.sh; echo "分支上: exit=$?"
```
Expected: `main上: exit=2`,`分支上: exit=0`。

- [ ] **Step 6: Commit**

```bash
git add plugins/support/skills/git-policy/scripts/block-git.sh
git commit -m "feat(support): git-policy hook 脚本模板(红名单+两段可选门禁)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 2: 策略菜单 `references/policy-menu.md`

**Files:**
- Create: `plugins/support/skills/git-policy/references/policy-menu.md`

**Interfaces:**
- Consumes: Task 1 的 `PATTERNS` 五条模式、`COMMIT_MSG_PATTERN`、`PROTECTED_BRANCH`(菜单描述必须与脚本实际行为一致)。
- Produces: 四层策略的全量候选菜单——SKILL.md 草案步骤的单一真相源。

- [ ] **Step 1: 写菜单文件**

写入 `plugins/support/skills/git-policy/references/policy-menu.md`:

```markdown
# git-policy 策略菜单

草案阶段的单一真相源:红绿灰分配的全量候选与分级依据,以及约定层的选项清单。

## 红名单候选(hook 硬拦截)

| 命令 | 默认 | 依据 |
| --- | --- | --- |
| `git push --force` / `-f` | 红 | 覆盖远程历史,他人已拉取则不可逆 |
| `git reset --hard` | 红 | 丢弃工作区与暂存区全部修改 |
| `git clean -f`(含 `-fd` 等) | 红 | 物理删除未跟踪文件,无处找回 |
| `git branch -D` | 红 | 强删未合并分支 |
| `git checkout .` / `git restore .` | 红 | 丢弃全部未暂存修改 |
| `git stash drop` / `clear` | 灰,可升红 | 丢弃暂存现场,但用得少 |
| `git push`(普通) | **灰,默认不红** | 可 revert,且封禁会打断「commit 即发版」类工作流;仅远程受严格管控的项目才升红 |

## 绿名单候选(permissions.allow 免审批)

| 命令 | 默认 | 依据 |
| --- | --- | --- |
| `status` / `diff` / `log` / `show` / `blame` / `remote -v` / `ls-files` / `branch`(列表) | 绿 | 纯只读 |
| `fetch` | 灰,可升绿 | 只拉不合,基本无害 |
| `add` / `restore --staged` | 灰,可升绿 | 只动暂存区,易恢复 |
| `commit` | 灰 | 写历史;团队对 commit 约定有信心后可升绿 |

写入 settings.json 的条目形如 `Bash(git status:*)`、`Bash(git diff:*)`。

## 约定层选项(写入项目 CLAUDE.md「Git 约定」节)

### commit 规范
- **格式**:探测值作推荐(从 `git log` 反推,如 `feat(scope): 中文描述`);备选 Conventional Commits、自由格式。
- **粒度**:每个可独立回退的逻辑单元一个 commit / 攒批提交。
- **确认**:每次 commit 前需用户确认 / 授权自主 commit。
- **硬门禁 B(可选)**:启用后 hook 校验 `-m` 的 message,不合规 exit 2;heredoc / `-am` 形式提取不到 message 时放行(fail-open)。

### 分支策略
- **开分支触发条件**:新功能 / 实验性改动 / 改动超过 N 个文件 / 永不(个人小项目直接主分支)。
- **命名**:`feat/xxx`、`fix/xxx` 前缀式 / 自由。
- **合并与清理**:合并回主分支后即删除功能分支 / 保留。
- **硬门禁 A(可选,main 保护)**:启用后在受保护分支上 commit/push 直接 exit 2。

## settings.json 合并样例

已有条目一律保留,只追加:

​```json
{
  "permissions": {
    "allow": ["Bash(git status:*)", "Bash(git diff:*)", "Bash(git log:*)"]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": ".claude/hooks/block-git.sh" }]
      }
    ]
  }
}
​```
```

(注:上方代码块内的 ``` 转义仅为本计划文档排版,落盘时写正常的三反引号。)

- [ ] **Step 2: 与脚本交叉核对**

逐条核对:菜单红名单五条默认项 = 脚本 `PATTERNS` 五条;门禁 A/B 描述与脚本段落行为一致(fail-open、`PROTECTED_BRANCH=main`);绿名单无任何条目命中红名单模式。
Expected: 三项全部一致,不一致则改菜单(脚本已测过,以脚本为准)。

- [ ] **Step 3: Commit**

```bash
git add plugins/support/skills/git-policy/references/policy-menu.md
git commit -m "feat(support): git-policy 策略菜单(三色候选+约定层选项)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 3: 主文件 `SKILL.md`

**Files:**
- Create: `plugins/support/skills/git-policy/SKILL.md`

**Interfaces:**
- Consumes: Task 1 脚本路径 `scripts/block-git.sh` 与两段门禁标记;Task 2 菜单路径 `references/policy-menu.md`。
- Produces: `/support:git-policy` 的完整执行流程。

- [ ] **Step 1: 写 SKILL.md**

写入 `plugins/support/skills/git-policy/SKILL.md`:

```markdown
---
name: git-policy
description: 一次配齐项目级 git 策略:红绿灰三色权限(硬拦截/免审批/默认询问)加 commit 规范与分支约定,落地到 .claude/settings.json、hook 脚本与项目 CLAUDE.md。仅当用户主动用 `/support:git-policy` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, AskUserQuestion
disable-model-invocation: true
---

# git-policy — 红绿灰三色 git 策略

## 用途
一次运行,配齐当前项目的 git 操作策略,共四层:
- **红名单**:PreToolUse hook 硬拦截,模型绕不过;
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
```

- [ ] **Step 2: 写作指南自检**

逐行 no-op 测试(与默认行为无差别的句子直接删);对照失败模式清单(提前收工/重复/沉积/蔓延/no-op);核对三处 name 一致(目录、frontmatter、`/support:git-policy`);确认 description 未复述流程细节。
Expected: 无 no-op 句;红名单默认值仅在 policy-menu.md 出现明细(SKILL.md 只指菜单,单一真相源)。

- [ ] **Step 3: Commit**

```bash
git add plugins/support/skills/git-policy/SKILL.md
git commit -m "feat(support): 新增 git-policy skill(红绿灰三色策略+Git 约定)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 4: README 登记 + 终验 + push

**Files:**
- Modify: `README.md`(「调用」示例行、目录树 support 段)

**Interfaces:**
- Consumes: Task 1–3 的全部产物。

- [ ] **Step 1: 更新 README**

「调用」节示例末尾追加 `/support:git-policy`;目录树 support 段改为:

```
    └── support/
        ├── .claude-plugin/plugin.json
        └── skills/
            ├── handoff/               # 把当前会话压缩成交接文档,供新会话接续
            │   └── SKILL.md
            └── git-policy/            # 一次配齐项目级 git 三色权限策略与 Git 约定
                ├── SKILL.md
                ├── references/policy-menu.md
                └── scripts/block-git.sh
```

- [ ] **Step 2: 终验**

```bash
bash /tmp/claude-1000/-home-king-github-jiejiejlj-jljskills/85879ab2-2e32-487a-a816-2250ffd26d9e/scratchpad/test-block-git.sh
python3 -m json.tool .claude-plugin/marketplace.json > /dev/null && echo "marketplace OK"
ls plugins/support/skills/git-policy/
```
Expected: 测试 `pass=16 fail=0`;`marketplace OK`(support 已登记,无需改动);目录列出 `SKILL.md references scripts`。

- [ ] **Step 3: Commit & push**

```bash
git add README.md
git commit -m "docs: README 登记 git-policy skill

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
git push
```
