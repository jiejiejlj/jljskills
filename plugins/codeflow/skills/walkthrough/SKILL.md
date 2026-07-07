---
name: walkthrough
argument-hint: "[scope 或聚焦点]"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Write
description: 读源码, 产出可执行的走读文档 —— 地图 + 带时间戳的模块文档 + HTML 报告. 适用于讲清代码如何工作, 编写走读, 上手一个项目, 或带人做代码巡览时. 用 showboat 钉死代码路径与 output. 仅当用户主动用 `/codeflow:walkthrough` 指令调用时使用.
disable-model-invocation: true
---

读源码, 产出**边走边跑**的走读 —— 顺着 call chain 一路走读, 每块代码都真跑一遍, 连 output 一起用 showboat 钉进文档. 全部落在 `docs/jljskills/codeflow/walkthrough/` 下.

## Language

**叙述一律简体中文**——note 讲解、地图、HTML 报告的行文皆是, 被读项目是英文项目也不改变这条. **准确压倒统一**: 硬译会失真的通用技术术语保留英文原语(call chain、entry point、boilerplate……).

## 文档模型

**地图 + 带时间戳的模块文档**, 每份模块文档配一份 HTML 视图:

```
docs/jljskills/codeflow/walkthrough/
  walkthrough.md                        # 地图(索引)
  walkthrough.html                      # 地图的 HTML 视图
  walkthrough-<scope>-<YYYYMMDD>.md      # 模块文档
  walkthrough-<scope>-<YYYYMMDD>.html    #   └ 该 md 的 HTML 报告
```

- **`walkthrough.md` 是地图, 不装正文** —— 纯 markdown 索引, 不经 showboat, 用 `Write` 直接写.
- **模块文档是 showboat 托管的可执行 md** —— 只能经 `uvx showboat` 命令写, **绝不能用 `Edit`/`Write` 直接改**(会破坏已 verify 的 output block).
- `<scope>` = kebab-case slug(`app-spine`、`event-engine`、`account`……); `<YYYYMMDD>` = 内容"截至日期". **同日重生成 → 同名覆盖; 跨天更新 → `git mv` 到新日期**并同步更新地图里的链接.

## 地图 `walkthrough.md`

两块内容:

**① 项目结构快照**(读项目得来): 一句话项目是什么 + tech stack · **模块地图**(顶层模块目录树, 每行一句说明) · **entry points**(`main.py`、后台 worker 等) · 一行 `结构快照刷新于:YYYY-MM-DD`.

**② 走读索引表**(指向各模块文档):

```markdown
| Module (scope) | Doc | Updated | Covers |
|---|---|---|---|
| <模块名> · `<scope>` | walkthrough-<scope>-<YYYYMMDD>.md | YYYY-MM-DD | 一句话覆盖的关键入口/文件 |
```

slug 供技能匹配/参数.

**两种"写索引"**:
- **轻量(自动)**: 每生成/刷新一份模块文档, 就往索引表追加/更新它那一行, 不重读项目.
- **重量(需询问)**:「**更新索引**」= 重读整个项目 → 刷新结构快照 + 核对整张表(新模块、被 `git mv` 的文档、源码已变的过时文档), 并重生成 `walkthrough.html`.

## Workflow

1. **读源码** —— 动笔前先理解 structure、entry points、dependencies、data flow. 给了 scope 就把阅读和覆盖范围限制在那块.
2. **规划顺序** —— 从 entry points 出发, 顺着 call chain 决定讲什么、按什么次序.
3. **初始化 / 分支** —— 按下面的决策树走.
4. **构建** —— 交替 `showboat note`(讲解) 和 `showboat exec`(代码片段), 线性走读该模块, 写进它的模块文档. 所有 `showboat` 命令从 repo root 执行, `<file>` 用相对路径, `exec` 里源码路径(如 `src/...`)才按 repo root 正确解析.
5. **验证** —— `uvx showboat verify <模块文档>`, 确认所有 code block 产出预期 output. 报了 diff 就 `uvx showboat pop <模块文档>` 移除失败条目, 修命令, 再 `showboat exec` 重新加入.
6. **生成 HTML 视图 + 写索引** —— md verify 通过后, 按 `references/html-report.md` 手写生成该模块 `.html`; 轻量写索引; 顺带重生成 `walkthrough.html`.

## 决策树(启动分派)

三种动作: **新建 / 刷新 / 更新索引**. 新建、刷新都走 Workflow 步 4–6; 更新索引不建模块文档.

```
├─ 地图不存在(首次): 读项目 → 建地图(结构快照 + 空索引) → 建首个模块文档(scope 没给则问选哪个)
└─ 地图已存在, 按 scope 分派:
     · 带 scope 且在索引 → 默认「刷新」并确认
     · 带 scope 不在索引 → 默认「新建」
     · 没带 scope      → 弹三选一菜单
        新建 <scope>   —— 建新模块文档
        刷新 <scope>   —— 重读该模块重生成
        更新索引       —— 重量级, 见「两种写索引」
```

`showboat init` 初始化模块文档: `uvx showboat init docs/jljskills/codeflow/walkthrough/walkthrough-<scope>-<日期>.md "<Project> — <Module>"`. 若 `uvx`/`showboat` 缺失或 `init` 失败, 运行 `uvx --from showboat showboat --version` 检查安装并重试一次; 仍失败则告知用户 showboat 不可用, 改提供纯 markdown 走读(仍可出 HTML).

## 模块文档结构

三个顶层 section, 标题逐字照用:

1. `## Overview` —— 这个模块做什么、关键技术、入口
2. `## Architecture` —— 涉及的文件/目录、边界、data flow
3. `## Core walkthrough` —— 线性逐段走读代码, 从入口出发顺着 call chain 穿过该模块

## Snippet selection

每个概念展示最重要的 5-20 行. 优先 function signatures、key logic、configuration, 而非 boilerplate. 通过 `showboat exec` 用 `sed -n`、`grep`、`cat` 等命令纳入 snippet. 每个 snippet 都要对得起它占的位置——无助于叙述就删掉.

## Example

```bash
uvx showboat note docs/jljskills/codeflow/walkthrough/walkthrough-<scope>-<日期>.md <<'EOF'
## 配置加载

应用启动时从 `config.yaml` 读入配置. `load_config` 函数校验必填字段,
缺失时回落到默认值.
EOF

uvx showboat exec docs/jljskills/codeflow/walkthrough/walkthrough-<scope>-<日期>.md bash "sed -n '10,25p' src/config.py"
```

这会在模块文档里产出一个 `## 配置加载` section: note 的 prose + `bash` 命令块 + 捕获输出的 `output` 块.

## Showboat reference

命令签名与坑位见 [`references/showboat.md`](references/showboat.md), 建文档前先过一遍(尤其 CRLF、`note` 裸围栏两坑).

## HTML report reference

HTML 视图的脚手架、Terminal Cyan 配色、卡片结构、图型、地图 HTML 规范见 [`references/html-report.md`](references/html-report.md).

## Do not use when

- 审查代码找 bugs 或 design issues — 用 `code-audit` 或 `/code-review`
- 审计 harness customizations — 用 `cc-release-review`
- 审计 CLAUDE.md — 用 `claudemd-audit`
