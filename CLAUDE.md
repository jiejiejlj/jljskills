# CLAUDE.md

本仓库是 **jljskills** —— jiejiejlj 的个人 Claude Code skill 集合，以 **plugin marketplace** 形式分发。这里没有可运行的应用代码，全部是 Markdown + JSON 的配置与文档。

## 仓库结构

```
jljskills/
├── .claude-plugin/marketplace.json   # marketplace 清单，登记所有 plugin
└── plugins/<plugin>/
    ├── .claude-plugin/plugin.json     # 单个 plugin 清单
    └── skills/<skill>/SKILL.md         # 一个 skill = 一个目录 + 一个 SKILL.md
```

当前 plugin：`preproject`（项目前期准备）、`project`（项目设计）、`figma2web`（Figma 转网页）。

## 关键约束（容易踩坑）

- **skills 目录必须扁平**：Claude Code 只识别 `skills/<skill-name>/SKILL.md` 这一层，不能再嵌套子目录做分类。需要再分类时，新建一个 plugin，而不是加深目录。
- **三处 name 必须一致**：skill 目录名、`SKILL.md` frontmatter 的 `name`、调用命名空间 `/<plugin>:<skill>` 三者要对应得上。
- **新增 plugin 要两处登记**：建 `plugins/<plugin>/.claude-plugin/plugin.json` 的同时，必须在 `.claude-plugin/marketplace.json` 的 `plugins` 数组里补一条。漏登记则用户装不到。
- **空目录不会被 git 跟踪**：每个 plugin 至少留一个占位 `example` skill，否则 `skills/` 目录提交不上去。

## SKILL.md 写法

- frontmatter 必填 `name`、`description`；`description` 要写清「做什么 + 何时触发」，因为这是模型决定是否调用的唯一依据。
- 不希望模型在普通对话里自动触发、只允许用户显式 `/<plugin>:<skill>` 调用的 skill，加 `disable-model-invocation: true`，并在 `description` 里写明「仅当用户主动用 `/...` 指令调用时使用」。
- 用 `allowed-tools` 收窄工具权限到该 skill 实际需要的范围。
- 较长的方法 / 模板放到 `references/*.md`，在 SKILL.md 里用相对链接引用，保持主文件精炼。

参考成熟样例：`plugins/project/skills/interview2doc/`（含 `references/method.md`）。

## 分发模型

滚动更新——每次 commit 即新版本。用户侧：`/plugin marketplace add jiejiejlj/jljskills`、`/plugin install <plugin>@jljskills`、`/plugin marketplace update`。改完务必 commit & push，否则用户更新不到。

## 约定

- **开发语言统一用简体中文**：仓库内文档、skill、注释与对外说明一律用简体中文。
- commit message 沿用现有风格：`feat(...)`, `refine(...)`, `chore:` 等带中文描述。


