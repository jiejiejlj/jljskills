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

当前 plugin 清单以 `.claude-plugin/marketplace.json` 为准（单一真相源），一句话导览与前置依赖见 `README.md` 分类表——不在本文件平行罗列，免得漂移。

## 关键约束（容易踩坑）

- **skills 目录必须扁平**：Claude Code 只识别 `skills/<skill-name>/SKILL.md` 这一层，不能再嵌套子目录做分类。需要再分类时，新建一个 plugin，而不是加深目录。
- **三处 name 必须一致**：skill 目录名、`SKILL.md` frontmatter 的 `name`、调用命名空间 `/<plugin>:<skill>` 三者要对应得上。
- **新增 plugin 要三处登记**：建 `plugins/<plugin>/.claude-plugin/plugin.json` 的同时，必须（1）在 `.claude-plugin/marketplace.json` 的 `plugins` 数组里补一条（漏登记则用户装不到），（2）同步更新 `README.md` 的分类表、安装示例与目录树（漏了不影响安装，但文档会漂移）。改了 plugin 的 skill 构成时，也要回头看 README 的目录树是否过时。
- **空目录不会被 git 跟踪**：每个 plugin 的 `skills/` 下至少要有一个真 skill，否则目录提交不上去——不要建空壳 plugin。
- **跨 plugin 不可用相对路径引用**：安装缓存按 `plugin/<hash>/` 隔离，`../../` 穿不出本 plugin。共享内容一律做成本 plugin 内的地基 skill（如 `codeflow/design-deep-module`、`figma-optimize/figma-facts`）；依赖外部 plugin 只能按名字引用，并在 README 分类表声明前置。

## SKILL.md 写法

- frontmatter 必填 `name`、`description`；`description` 要写清「做什么 + 何时触发」，因为这是模型决定是否调用的唯一依据。
- 不希望模型在普通对话里自动触发、只允许用户显式 `/<plugin>:<skill>` 调用的 skill，加 `disable-model-invocation: true`，并在 `description` 里写明「仅当用户主动用 `/...` 指令调用时使用」。
- 用 `allowed-tools` 收窄工具权限到该 skill 实际需要的范围。
- 较长的方法 / 模板放到 `references/*.md`，在 SKILL.md 里用相对链接引用，保持主文件精炼。
- **产出落盘判据**：技能在目标项目的产出，文档（人读沉淀物）统一 `docs/jljskills/<plugin>/` 写死不问，代码/配置按项目结构，临时物进 OS 临时目录——判据与否决见 `docs/jljskills/codeflow/adr/0004`。
- **调用决策规则**：只有「模型必须自主触发」或「另一个 skill 要够到它」时才用 model-invoked（description 每轮占上下文）；否则一律 `disable-model-invocation: true`，白赚零上下文。
- **引导词优先**：给 skill 一个紧凑、有画面感的核心词（如 `grill` 的「对抗式拷问」、`interview2doc` 的「矛盾即缺口」）——它同时稳定执行行为、提升触发命中。审视时问：核心词够不够一击命中？
- **写完自检**：逐行做 no-op 测试（跟默认行为相比没改变的句子直接删，别精简）；对照失败模式——提前收工 / 重复 / 沉积 / 蔓延 / 空操作。

参考成熟样例：`plugins/support/skills/interview2doc/`（含 `references/method.md`）。
完整写作判据与词汇见 [`docs/skill写作指南.md`](docs/skill写作指南.md)。

## 分发模型

滚动更新——每次 commit 即新版本。用户侧：`/plugin marketplace add jiejiejlj/jljskills`、`/plugin install <plugin>@jljskills`、`/plugin marketplace update`。改完务必 commit & push，否则用户更新不到。

## 约定

- **开发语言统一用简体中文**：仓库内文档、skill、注释与对外说明一律用简体中文。
- commit message 沿用现有风格：`feat(...)`, `refine(...)`, `chore:` 等带中文描述。


