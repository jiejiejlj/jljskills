# jljskills

jiejiejlj 的个人 Claude Code skill 集合，以 **plugin marketplace** 形式分发。

每个分类是一个 plugin，分类下是扁平的 skill 目录（Claude Code 只识别 `skills/<skill-name>/SKILL.md` 一层，因此用 plugin 而非嵌套目录做分类）。

## 当前分类（plugin）

| Plugin | 说明 |
| --- | --- |
| `project` | 项目设计相关 skill |
| `figma2web` | Figma 转网页相关 skill |
| `figma-optimize` | 设计稿交付前评审优化相关 skill |
| `support` | 工作流辅助相关 skill |
| `engineering` | 代码库架构设计相关 skill（深模块方法论） |

## 安装

```bash
# 添加本 marketplace
/plugin marketplace add jiejiejlj/jljskills

# 按需安装分类
/plugin install project@jljskills
/plugin install figma2web@jljskills
/plugin install figma-optimize@jljskills
/plugin install support@jljskills
/plugin install engineering@jljskills

# 获取更新（滚动更新，每次 commit 即新版本）
/plugin marketplace update
```

## 调用

安装后 skill 自带命名空间：`/<plugin>:<skill>`，例如 `/project:interview2doc`、`/project:grill`、`/project:loopspec`、`/figma2web:init`、`/figma-optimize:standard`、`/figma-optimize:page`、`/support:handoff`、`/support:git-policy`、`/engineering:improve-arch`、`/engineering:design-rules`。

## 目录结构

```
jljskills/
├── .claude-plugin/
│   └── marketplace.json          # marketplace 清单，登记所有 plugin
└── plugins/
    ├── project/
    │   ├── .claude-plugin/plugin.json
    │   └── skills/
    │       ├── interview2doc/     # 把想法梳理成需求文档(助产式访谈)
    │       │   ├── SKILL.md
    │       │   └── references/method.md
    │       ├── grill/             # 拷问已成形的方案(对抗式评审)
    │       │   └── SKILL.md
    │       └── loopspec/          # 拷问出自动化 workflow 规格(循环即可委派)
    │           └── SKILL.md
    ├── figma2web/
    │   ├── .claude-plugin/plugin.json
    │   └── skills/                    # init/config/re-config/page2doc/re-page2doc/coding/component/verify
    │       └── <skill>/SKILL.md
    ├── figma-optimize/
    │   ├── .claude-plugin/plugin.json
    │   └── skills/                    # standard(规范板评审)/ page(界面稿评审)/ figma-facts(共享判据地基)
    │       ├── standard/SKILL.md + references/
    │       ├── page/SKILL.md + references/
    │       └── figma-facts/SKILL.md   # 共享 Figma API 判据单一真相源,供 page/standard 的 flow P1 装载
    ├── support/
    │   ├── .claude-plugin/plugin.json
    │   └── skills/
    │       ├── handoff/               # 把当前会话压缩成交接文档,供新会话接续
    │       │   └── SKILL.md
    │       └── git-policy/            # 一次配齐项目级 git 三色权限策略与 Git 约定
    │           ├── SKILL.md
    │           ├── references/policy-menu.md
    │           └── scripts/block-git.sh
    └── engineering/
        ├── .claude-plugin/plugin.json
        ├── README.md              # 四技能一句话导览与选择指引
        └── skills/
            ├── design-rules/          # 深模块词汇库与判据(供其他 skill 指路引用)
            │   ├── SKILL.md
            │   └── references/        # deepening.md + design-it-twice.md
            ├── improve-arch/          # 扫描深化机会→HTML 报告→拷问(编排入口)
            │   ├── SKILL.md
            │   └── references/html-report.md
            ├── grilling/              # 走设计树,收敛 interface 草图
            │   └── SKILL.md
            └── domain-modeling/       # 领域词汇表 CONTEXT.md + ADR
                ├── SKILL.md
                └── references/        # context-format.md + adr-format.md
```

## 新增 skill

1. 在对应 plugin 的 `skills/` 下新建目录（目录名即 skill 名，**不可再嵌套子目录**）。
2. 写 `SKILL.md`，frontmatter 的 `name` 与目录名一致。
3. commit & push，用户 `/plugin marketplace update` 即可获取。
