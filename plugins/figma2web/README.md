# figma2web — Figma 转网页管线

把 Figma 设计稿变成贴合技术栈的 web 代码。八个 skill 构成一条「配置 → 标准 → 文档化 → 出码 → 校验」主链,外加增量入口。skill 之间**不自动串调**(孤岛原则),靠文件产物衔接:上游产物就是下游的前置 gate。目标项目侧的文档统一收在 `docs/jljskills/figma2web/` 下(`project.md`、`tokens.md`、`design/`、`assets/`、`verify/`)。

## 与 figma-optimize 的分工(写方向契约)

本插件**只读 Figma,绝不写回**,并遵循**读到即确认**:用户发起管线即声明「产出当前这张图」,设计稿是读取时刻的权威快照——管线不评判设计质量、不设优化 gate,设计稿后续变更由人经 re-\* 入口重新声明。Figma 侧的设计稿优化(评审 / 收编)归 `figma-optimize` 插件;两插件互不依赖、互不读写产物,**没有管线关系,只有人的编排**。

## 主链(首次接入按序走)

```
/figma2web:init ──▶ config ──▶ page2doc ──▶ coding ──▶ verify
      │                │            │           │          │
  project.md      tokens.md      spec+切图   app/ 源码   还原度报告
 (技术决策)    tailwind.config   +__ref.png  +Docker 产物
```

- **init** —— 纯交互收集 9 项技术决策写 `project.md`,管线首个必跑;重跑即预填式重配(同一意图,幂等)。不读 Figma。
- **config** —— 读 Figma 规范板抽设计标准,产 `tokens.md`(source of truth)+ `tailwind.config.*`。
- **page2doc** —— 把一个 Figma 页面忠实文档化成自包含 spec + 预下载切图 + `__ref.png` 参照图;只记设计事实,代码决策留给 coding。
- **coding** —— **全程离线**读 spec 出代码与 Docker 产物(内部复用 superpowers);缺切图 HARD STOP,绝不回头读 Figma。
- **verify** —— docker compose 起服务 + Playwright 逐断点截图,与 `__ref.png` 比对定位差异,rubric 打分出报告;最终过不过由人拍板。

## 增量入口(Figma 侧改动后)

re-\* 不是 base 的「重跑模式」,是**独立的意图入口**(设计决策:一命令一意图,语义密度在命令名上):调用它即声明「已有基线,只同步差异」。

- **re-config** —— 标准 / 变量改了 → `tokens.md` 只更新 NEW/CHANGED,UNCHANGED 原样。
- **re-page2doc** —— 页面设计改了 → 全量重抓、以 B 表比对,section 级 NEW/CHANGED/UNCHANGED 分头处理;完事对 NEW/CHANGED 跑 `coding`。

## 地基

- **spec-structure** —— spec 文件结构契约,page2doc / re-page2doc / coding 三方共用的地基,通常不单独调用。

## 怎么选

- 新项目第一次接入 → 按主链顺序:`init → config → page2doc → coding → verify`
- Figma 的标准 / 变量改了 → `/figma2web:re-config`
- Figma 的页面设计改了 → `/figma2web:re-page2doc`
- 想查 spec 段落契约 → `/figma2web:spec-structure`
- 想在 Figma 侧把重复元素沉淀成组件 → 装 `figma-optimize` 插件,用 `/figma-optimize:loop-optimize`(贴链接自动分诊,组件收编是其 component 阶段;设计阶段的事,不在本管线内)

## 前置 gate 与产物一览

| skill | 前置 gate | 产物 | 读 Figma |
|---|---|---|---|
| init | 能本地跑的工程 | `project.md` | 否 |
| config | `project.md` | `tokens.md` + `tailwind.config.*` | 是 |
| re-config | + 已有 `tokens.md` | 同 config(共同维护) | 是 |
| page2doc | `project.md` + `tokens.md` | spec + 切图 + `__ref.png` | 是 |
| re-page2doc | + 已有 spec | 同 page2doc(共同维护) | 是 |
| coding | + spec finalize + 切图在盘 | `app/` + Docker 产物 | **否(离线)** |
| verify | 代码可 build + `__ref.png` + docker/Playwright | `docs/jljskills/figma2web/verify/` 报告 | 否 |

外部前置:官方 `figma` 插件(Figma MCP,读 Figma 的 skill 都要);`coding` 需 superpowers。
