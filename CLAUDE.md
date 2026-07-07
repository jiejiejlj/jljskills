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
- **跨 plugin 不可用相对路径引用**：安装缓存按 `plugin/<hash>/` 隔离，`../../` 穿不出本 plugin。共享内容一律做成本 plugin 内的地基 skill（如 `codeflow/design-deep-module`、`figma-optimize/figma-facts`、`skillflow/design-skill-rules`）；依赖外部 plugin 只能按名字引用，并在 README 分类表声明前置。
- **产出落盘判据**：技能在目标项目的产出，文档（人读沉淀物）统一 `docs/jljskills/<plugin>/` 写死不问，代码/配置按项目结构，临时物进 OS 临时目录——判据与否决见 `docs/jljskills/codeflow/adr/0004`。

## 写 / 改 skill

skill 写作技艺（判据、调用取舍、渐进式披露、引导词、五种失败模式）已收进 **skillflow** 插件，不在本文平行维护——这里只留入口：

- **造新 skill**：`/skillflow:build-skill`（薄声明式入口：装 `design-skill-rules` 判据 + 落脚手架）。
- **审 / 优化 skill**：`/skillflow:review-skill`（lint→score→improve 分级处方，只读，中文报告）。
- **判据基石**：`plugins/skillflow/skills/design-skill-rules/SKILL.md`（可预测 / 调用取舍 / 信息层级与渐进式披露 / 引导词 / 五种失败模式，术语表在其 `references/GLOSSARY.md`；移植自 mattpocock `writing-great-skills`）。

## 分发模型

滚动更新——每次 commit 即新版本。用户侧：`/plugin marketplace add jiejiejlj/jljskills`、`/plugin install <plugin>@jljskills`、`/plugin marketplace update`。改完务必 commit & push，否则用户更新不到。

## 约定

- **开发语言统一用简体中文**：仓库内文档、skill、注释与对外说明一律用简体中文。
- commit message 沿用现有风格：`feat(...)`, `refine(...)`, `chore:` 等带中文描述。


