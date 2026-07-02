# jljskills

jiejiejlj 的个人 Claude Code skill 集合，以 **plugin marketplace** 形式分发。

每个分类是一个 plugin，分类下是扁平的 skill 目录（Claude Code 只识别 `skills/<skill-name>/SKILL.md` 一层，因此用 plugin 而非嵌套目录做分类）。

## 当前分类（plugin）

| Plugin | 说明 |
| --- | --- |
| `preproject` | 项目前期准备相关 skill |
| `project` | 项目设计相关 skill |
| `figma2web` | Figma 转网页相关 skill |
| `figma-optimize` | 设计稿交付前评审优化相关 skill |

## 安装

```bash
# 添加本 marketplace
/plugin marketplace add jiejiejlj/jljskills

# 按需安装分类
/plugin install preproject@jljskills
/plugin install figma2web@jljskills
/plugin install figma-optimize@jljskills

# 获取更新（滚动更新，每次 commit 即新版本）
/plugin marketplace update
```

## 调用

安装后 skill 自带命名空间：`/<plugin>:<skill>`，例如 `/project:interview2doc`、`/figma2web:init`、`/figma-optimize:standard`、`/figma-optimize:page`。

## 目录结构

```
jljskills/
├── .claude-plugin/
│   └── marketplace.json          # marketplace 清单，登记所有 plugin
└── plugins/
    ├── preproject/
    │   ├── .claude-plugin/plugin.json
    │   └── skills/
    │       └── example/SKILL.md   # 占位示例，补齐真实 skill 后可删
    ├── project/
    │   ├── .claude-plugin/plugin.json
    │   └── skills/
    │       └── interview2doc/     # 把想法梳理成需求文档
    │           ├── SKILL.md
    │           └── references/method.md
    ├── figma2web/
    │   ├── .claude-plugin/plugin.json
    │   └── skills/                    # init/config/re-config/page2doc/re-page2doc/coding/component/verify
    │       └── <skill>/SKILL.md
    └── figma-optimize/
        ├── .claude-plugin/plugin.json
        └── skills/                    # standard(规范板评审)/ page(界面稿评审)
            ├── standard/SKILL.md + references/
            └── page/SKILL.md + references/
```

## 新增 skill

1. 在对应 plugin 的 `skills/` 下新建目录（目录名即 skill 名，**不可再嵌套子目录**）。
2. 写 `SKILL.md`，frontmatter 的 `name` 与目录名一致。
3. commit & push，用户 `/plugin marketplace update` 即可获取。
