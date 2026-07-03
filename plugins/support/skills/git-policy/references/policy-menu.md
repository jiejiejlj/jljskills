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
- **硬门禁 B(可选)**:启用后 hook 仅校验首个 `-m` 参数的 message,不合规 exit 2;heredoc / `-am` 形式提取不到 message 时放行(fail-open)。

### 分支策略
- **开分支触发条件**:新功能 / 实验性改动 / 改动超过 N 个文件 / 永不(个人小项目直接主分支)。
- **命名**:`feat/xxx`、`fix/xxx` 前缀式 / 自由。
- **合并与清理**:合并回主分支后即删除功能分支 / 保留。
- **硬门禁 A(可选,main 保护)**:启用后在受保护分支上 commit/push 直接 exit 2。

## settings.json 合并样例

已有条目一律保留,只追加:

```json
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
```
