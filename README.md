# jljskills

jiejiejlj 的个人 Claude Code skill 集合，以 **plugin marketplace** 形式分发。

每个分类是一个 plugin，分类下是扁平的 skill 目录（Claude Code 只识别 `skills/<skill-name>/SKILL.md` 一层，因此用 plugin 而非嵌套目录做分类）。

## 当前分类（plugin）

| Plugin | 说明 | 前置依赖（不装则相关功能静默失效） |
| --- | --- | --- |
| `figma2web` | Figma 转网页相关 skill | 官方 `figma` 插件（Figma MCP）；`coding` 内部编排调用 `superpowers` |
| `figma-optimize` | 设计稿交付前评审优化相关 skill | 官方 `figma` 插件（Figma MCP + `figma-use` skill，写回前强制） |
| `support` | 通用辅助 skill：需求梳理（interview2doc）、workflow 规格（loopspec）、会话交接（handoff）、git 策略（git-policy）；文档类产物统一落目标项目 `docs/jljskills/support/` | — |
| `codeflow` | 编码工作流 idea→ship：拷问→PRD→拆 issue→TDD 实施→双轴审查，含深模块方法论、架构健康层，以及外来 issue/PR 分诊与硬 bug 诊断两条汇入支线 | 可选：`support`（`/support:interview2doc` 前置梳理想法、`/support:handoff` 跨会话衔接）；`walkthrough` 需 `uvx showboat`（本机装 `uv`），未装则退回纯 markdown |
| `skillflow` | skill 相关技能组合：写作判据基石（design-skill-rules）+ 造（build-skill）+ 审（review-skill，lint→score→improve 分级处方，中文报告）；判据基石移植自 mattpocock `writing-great-skills`，审移植自 philoserf `cc-review`（skill-only） | — |

## 安装

```bash
# 添加本 marketplace
/plugin marketplace add jiejiejlj/jljskills

# 按需安装分类
/plugin install figma2web@jljskills
/plugin install figma-optimize@jljskills
/plugin install support@jljskills
/plugin install codeflow@jljskills
/plugin install skillflow@jljskills

# 获取更新（滚动更新，每次 commit 即新版本）
/plugin marketplace update
```

## 调用

安装后 skill 自带命名空间：`/<plugin>:<skill>`，例如 `/figma2web:init`、`/figma-optimize:standard`、`/figma-optimize:page`、`/support:interview2doc`、`/support:loopspec`、`/support:handoff`、`/support:git-policy`、`/codeflow:grill-with-docs`、`/codeflow:to-prd`、`/codeflow:implement`、`/codeflow:improve-arch`、`/codeflow:design-deep-module`、`/codeflow:walkthrough`、`/skillflow:build-skill`、`/skillflow:review-skill`。

## 目录结构

```
jljskills/
├── .claude-plugin/
│   └── marketplace.json          # marketplace 清单，登记所有 plugin
└── plugins/
    ├── figma2web/
    │   ├── .claude-plugin/plugin.json
    │   ├── README.md              # 管线总览:主链/增量入口/地基,前置 gate 与产物一览;写方向契约(只读侧)
    │   └── skills/                    # init/config/re-config/page2doc/re-page2doc/coding/verify
    │       ├── <skill>/SKILL.md
    │       └── spec-structure/SKILL.md   # spec 文件结构契约地基,page2doc/re-page2doc/coding 三方共用
    ├── figma-optimize/
    │   ├── .claude-plugin/plugin.json
    │   ├── README.md              # 导览与写方向契约(写回侧)
    │   └── skills/                    # standard(规范板评审)/ page(界面稿评审)/ component(散件收编)/ figma-facts(共享判据地基)
    │       ├── standard/SKILL.md + references/
    │       ├── page/SKILL.md + references/
    │       ├── component/SKILL.md + references/
    │       └── figma-facts/SKILL.md   # 共享 Figma API 判据单一真相源,供 page/standard/component 的 flow P1 装载
    ├── support/
    │   ├── .claude-plugin/plugin.json
    │   └── skills/
    │       ├── interview2doc/         # 把想法梳理成需求文档(助产式访谈)
    │       │   ├── SKILL.md
    │       │   └── references/method.md
    │       ├── loopspec/              # 拷问出自动化 workflow 规格(循环即可委派)
    │       │   └── SKILL.md
    │       ├── handoff/               # 把当前会话压缩成交接文档,供新会话接续
    │       │   └── SKILL.md
    │       └── git-policy/            # 一次配齐项目级 git 三色权限策略与 Git 约定
    │           ├── SKILL.md
    │           ├── references/policy-menu.md
    │           └── scripts/block-git.sh
    ├── codeflow/
        ├── .claude-plugin/plugin.json
        ├── README.md              # 19 skill 五层管线总览:地基/入口(旁挂 research)/交付/汇入/健康,主流程图与外部前置声明
        └── skills/                    # 地基:design-deep-module/design-domain-model/build-context；入口:grill/grill-with-docs(旁挂 research)；交付:config/to-prd/to-issues/tdd/review/implement/prototype；汇入:triage/diagnosing-bugs；健康:audit-repo/improve-arch/grill-design/walkthrough
            ├── design-deep-module/SKILL.md + references/  # 思想基石:深模块词汇库与判据(design- 前缀=思想基石)
            ├── design-domain-model/SKILL.md               # 思想基石:领域建模判据(通用语言/病灶/ADR 门槛)
            ├── build-context/SKILL.md + references/       # 记忆层行为:术语落笔 CONTEXT.md + 记 ADR(驱动思想:领域建模)
            ├── grill/SKILL.md                             # 对已成形方案做对抗式压力测试
            ├── grill-with-docs/SKILL.md                   # grill 手法+当场沉淀术语/ADR(主流程入口)
            ├── research/SKILL.md                          # 调研外包给后台代理,产物入文档根 research/
            ├── config/SKILL.md + references/              # 认址目标项目 issue 追踪器
            ├── to-prd/SKILL.md + references/              # 综合当前对话成 PRD
            ├── to-issues/SKILL.md + references/           # PRD 拆成曳光弹式垂直切片 issue
            ├── tdd/SKILL.md + references/                 # 红绿循环规则手册
            ├── review/SKILL.md + references/              # 双轴审查(Standards + Spec)
            ├── implement/SKILL.md                         # 单 issue 实施,内驱 tdd 收尾 review
            ├── prototype/SKILL.md + references/           # 一次性代码探路(逻辑走终端小程序/UI 走多变体路由)
            ├── triage/SKILL.md + references/               # 外来 issue/PR 分诊状态机,被拒 enhancement 沉 out-of-scope/
            ├── diagnosing-bugs/SKILL.md + references/ + scripts/  # 硬 bug/性能回归诊断纪律,反馈回路硬门
            ├── audit-repo/SKILL.md + references/          # 九类全科体检→自包含交接计划(移植自 shadcn/improve)
            ├── improve-arch/SKILL.md + references/        # 扫描深化机会→HTML 报告(编排入口)
            ├── grill-design/SKILL.md                      # 走设计树,收敛 interface 草图
            └── walkthrough/SKILL.md + references/         # 读源码产出可执行 walkthrough(边走边跑:每块真跑+verify 复跑),需 uvx showboat/纯 md 兜底(移植自 philoserf)
    └── skillflow/
        ├── .claude-plugin/plugin.json
        └── skills/                    # 基石:design-skill-rules；造:build-skill；审:review-skill
            ├── design-skill-rules/SKILL.md + references/GLOSSARY.md  # 判据基石(移植 mattpocock writing-great-skills)
            ├── build-skill/SKILL.md                                 # 薄声明式入口:装判据 + 落脚手架
            └── review-skill/SKILL.md + references/ + assets/         # lint→score→improve 分级处方(移植 philoserf cc-review,skill-only,中文报告)
```

## 新增 skill

1. 在对应 plugin 的 `skills/` 下新建目录（目录名即 skill 名，**不可再嵌套子目录**）。
2. 写 `SKILL.md`，frontmatter 的 `name` 与目录名一致。
3. commit & push，用户 `/plugin marketplace update` 即可获取。
