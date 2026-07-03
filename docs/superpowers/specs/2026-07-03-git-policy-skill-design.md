# git-policy skill 设计文档

日期:2026-07-03
状态:已与用户对齐(方案 A + 约定层扩展 + 软约定可选硬门禁)

## 背景与目标

调研 mattpocock/skills 的 `git-guardrails-claude-code` 后发现:它只覆盖「拦截危险 git 命令」一层,且默认封禁 `git push` 会与"改完必须 push"类工作流冲突。本 skill 将其扩展为**项目级 git 策略的一站式配置器**:一次运行,配齐一个项目的 git 权限三色策略与 git 工作约定。

## 定位

- 调用方式:`/support:git-policy`,放入 `support` 插件(工作流辅助)。
- `disable-model-invocation: true`:一次性配置动作,无模型自主触发需求,零上下文占用。
- 引导词:**红绿灰三色策略**。红 = PreToolUse hook 硬拦截(模型绕不过);绿 = `permissions.allow` 免审批放行;灰 = 默认弹窗询问。约定层(commit 规范、分支策略)为第四层,与三色并列为一等公民。

## 配置的四层内容

| 层 | 载体 | 性质 |
| --- | --- | --- |
| 红名单(拦截) | `.claude/hooks/block-git.sh` + settings.json 的 PreToolUse | 硬,模型绕不过 |
| 绿名单(放行) | settings.json 的 `permissions.allow` | 硬,免审批 |
| 灰区(询问) | 不配置,即默认行为 | — |
| Git 约定 | 项目 CLAUDE.md「Git 约定」节;两项可选硬门禁进 hook | 软为主,硬可选 |

约定层内容:

- **commit 规范**:格式(前缀 / 语言 / scope,从 `git log` 反推现有风格作推荐值)、粒度(何时该 commit)、是否需用户确认后才 commit。
- **分支策略**:何时必须开分支(新功能 / 实验性改动等触发条件)、命名规范、何时合并回与清理、是否禁止直接在 main 提交。
- **可选硬门禁**(访谈中逐项询问,选了才写进 hook):
  1. commit 格式门禁:hook 校验 `git commit -m` 的 message,不合规 exit 2 拦截;
  2. main 分支保护:hook 检查当前分支,在 main 上 commit/push 直接拦截。

## 流程(五步,每步带完成标准)

1. **探测**:git remote、默认分支、CI 配置、已有 `.claude/settings.json`(hooks/permissions)、CLAUDE.md 已有 git 约定、`git log` 反推 commit 风格。完成标准:产出现状清单。
2. **草案**:据探测生成四层策略草案。默认红名单只含真正不可逆操作(`push --force`、`reset --hard`、`clean -f`、`branch -D`、`checkout .`、`restore .`);默认绿名单只含只读命令(`status`、`diff`、`log`、`show`、`branch` 列表类);**`git push`、`commit`、`merge`、`rebase` 默认灰区**(避免封 push 打断发版类工作流)。完成标准:草案覆盖四层,每项带推荐值与理由。
3. **逐层确认**:红名单、绿名单、commit 规范、分支策略(含两项硬门禁开关)各一次 AskUserQuestion,每题带推荐值。完成标准:四层均获用户表态。
4. **落地**:hook 脚本写入 `.claude/hooks/block-git.sh`;hook 与 permissions **合并**进 `.claude/settings.json`(绝不覆盖已有条目);约定追加到项目 CLAUDE.md「Git 约定」节(已有则合并更新)。完成标准:三个文件落盘,已有内容无丢失。
5. **验证**:管道喂样例 JSON 给 hook 脚本——红名单命令 exit 2、绿名单与灰区命令 exit 0、(若启用)不合规 commit message exit 2;settings.json 过 JSON 语法校验;向用户展示全部 diff。完成标准:三项全过才算配置完成。

## 文件结构

```
plugins/support/skills/git-policy/
├── SKILL.md                    # 主流程(精炼)
├── references/policy-menu.md   # 三色全量菜单、分级依据、约定层选项清单
└── scripts/block-git.sh        # hook 脚本模板
```

## hook 脚本设计要点

- 修正原版误杀 bug:正则锚定命令开头(词边界),`git commit -m "含 git push 字样"` 不再被误拦。
- 拦截提示用简体中文,说明「用户通过 git-policy 禁止了此操作」及放行途径。
- commit 格式门禁与 main 保护为脚本内可选段,未启用则不生成对应代码。
- JSON 解析优先用 `jq`,缺失时退回 `python3`;两者都没有才提示并放行(fail-open,避免环境问题卡死全部 git 操作)。

## 红线

- 只合并不覆盖:settings.json 与 CLAUDE.md 的已有内容必须保留。
- 绿名单条目绝不与红名单模式重叠;落地前做交叉检查。
- 探测到的事实(如 commit 风格)只作推荐值,不替用户拍板。
- 未经验证步骤全过,不得宣布配置完成。

## 非目标

- 不做全局(`~/.claude`)配置——本 skill 聚焦项目级;用户明确要求时才写全局。
- 不配置 git 自身的 hooks(`.git/hooks`)、不动 CI。
- 不移植原版「封禁 git push」默认值。
