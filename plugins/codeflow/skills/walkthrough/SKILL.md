---
name: walkthrough
allowed-tools:
  - Read
  - Bash
  - Glob
  - Write
description: 读源码, 生成 "地图文档 + 带时间戳的模块文档 + HTML 视图". 适用于讲清代码如何工作. 仅当用户主动用 `/codeflow:walkthrough` 指令调用时使用.
disable-model-invocation: true
---

读源码, 产出**地图文档** + **带时间戳的模块文档** + **HTML 视图** — 顺着 call chain 一路走读, 每块代码都真跑一遍, 连 output 一起用 showboat 钉进文档. **地图文档 + 带时间戳的模块文档**落在 `docs/jljskills/codeflow/walkthrough/` 下, **HTML 视图**落在 `docs/jljskills/codeflow/walkthrough/html/` 下.

## 语言

- **叙述一律简体中文**: note 讲解, 地图, HTML 视图的行文皆是.
- **技术术语保留英文**: 通用技术术语硬翻译会失真, 保留英文原语 (例如 call chain, entry point, boilerplate...).

## 工作流

1. **读源码** — 动笔前先理解 structure, entry points, dependencies, data flow, call chain.
2. **规划顺序** — 从 entry points 出发, 顺着 call chain 决定讲什么, 按什么次序.
3. **初始化 / 分支** — 按下面的决策树走.
4. **构建** — 交替 `showboat note` (讲解) 和 `showboat exec` (代码片段), 线性走读该模块, 写进它的模块文档. 讲解用完整句行文, 不写电报体, 先说这段在流程里干什么再讲怎么做, 一段 2-4 句封顶; 复杂逻辑 (分支 ≥2 或跳转 ≥3) 在 note 里配几行 ASCII 简图, HTML 层转成 Mermaid. 所有 `showboat` 命令从 repo root 执行, `<file>` 用相对路径, `exec` 里源码路径 (如 `src/...`) 才按 repo root 正确解析.
5. **验证** — `uvx showboat verify <模块文档>`, 确认所有 code block 产出预期 output. 报了 diff 就 `uvx showboat pop <模块文档>` 移除失败条目, 修命令, 再 `showboat exec` 重新加入.
6. **生成 HTML 视图 + 写索引** — md verify 通过后, 按 `references/html-view.md` 手写生成该模块 `.html`. **生成后自检**: md 里每个 `output` 块在 HTML 里都有对应源码卡片, 内容逐字一致 (先数数量对齐, 再抽查首尾块). 然后轻量写索引, 顺带重生成 `walkthrough.html`.

## 决策树 (启动分派)

- 三种动作: **新建模块 / 刷新模块 / 更新地图**.
- **新建模块**和**刷新模块**都走**工作流**步 4–6; **更新地图**不建模块文档.

```
├─ 地图不存在 (首次): 读项目 → 建地图 (结构快照 + 空索引) → 建首个模块文档 (问用户选哪个模块)
└─ 地图已存在 → 弹三选一菜单
        新建模块 — 建新模块文档
        刷新模块 — 重读该模块重生成
        更新地图 — 重量级, 见 "两种写地图索引"
```

`showboat init` 初始化模块文档: `uvx showboat init docs/jljskills/codeflow/walkthrough/walkthrough-<scope>-<日期>.md "<Project> — <Module>"`. 若 `uvx`/`showboat` 缺失或 `init` 失败, 运行 `uvx --from showboat showboat --version` 检查安装并重试一次; 仍失败则告知用户 showboat 不可用, 退出流程.

## 产物

**地图文档 + 带时间戳的模块文档**, 每份模块文档配一份 **HTML 视图**:

```
docs/jljskills/codeflow/walkthrough/
  walkthrough.md                        # 地图 (索引)
  walkthrough-<scope>-<YYYYMMDD>.md      # 模块文档

docs/jljskills/codeflow/walkthrough/html/
  walkthrough.html                      # 地图的 HTML 视图
  walkthrough-<scope>-<YYYYMMDD>.html    # 模块的 HTML 视图
```

- **`walkthrough.md` 是地图, 不装正文** — 纯 markdown 索引, 不经 showboat, 用 `Write` 直接写.
- **模块文档是 showboat 托管的可执行 md** — 只能经 `uvx showboat` 命令写, **绝不能用 `Edit`/`Write` 直接改** (会破坏已 verify 的 output block).
- `<scope>` = 所选模块名的 kebab-case slug (如 event-engine).
- `<YYYYMMDD>` = 内容 "截至日期". **同日重生成 → 同名覆盖; 跨天更新 → `git mv` 到新日期**并同步更新地图里的链接.

### 地图文档 `walkthrough.md`

两块内容:

**① 项目结构快照** (读项目得来): 一句话项目是什么 + tech stack · **模块地图** (顶层模块目录树, 每行一句说明) · **entry points** (`main.py`, 后台 worker 等) · 一行 `结构快照刷新于:YYYY-MM-DD`.

**② 走读索引表** (指向各模块文档):

```markdown
| Module (scope) | Doc | Updated | Covers |
|---|---|---|---|
| <模块名> · `<scope>` | walkthrough-<scope>-<YYYYMMDD>.md | YYYY-MM-DD | 一句话覆盖的关键入口/文件 |
```

slug 用于文件命名与索引表对齐.

两种**写地图索引**:
- **轻量 (自动)**: 每生成/刷新一份模块文档, 就往索引表追加/更新它那一行, 不重读项目.
- **重量 (需询问)**: "**更新地图**" = 重读整个项目 → 刷新结构快照 + 核对整张表 (新模块, 被 `git mv` 的文档, 源码已变的过时文档), 并重生成 `walkthrough.html`.

### 模块文档

#### 结构

三个顶层 section, 标题逐字照用:

1. `## Overview` — 这个模块做什么, 关键技术, 入口
2. `## Architecture` — 涉及的文件/目录, 边界, data flow
3. `## Core walkthrough` — 线性逐段走读代码, 从入口出发顺着 call chain 穿过该模块

#### Snippet selection

每个概念展示最重要的 5-20 行. 优先 function signatures, key logic, configuration, 而非 boilerplate. 通过 `showboat exec` 用 `sed -n`, `grep`, `cat` 等命令纳入 snippet. 每个 snippet 都要对得起它占的位置 — 无助于叙述就删掉.

#### Example

```bash
uvx showboat note docs/jljskills/codeflow/walkthrough/walkthrough-<scope>-<日期>.md <<'EOF'
## 配置加载

应用启动时从 `config.yaml` 读入配置. `load_config` 函数校验必填字段,
缺失时回落到默认值.
EOF

uvx showboat exec docs/jljskills/codeflow/walkthrough/walkthrough-<scope>-<日期>.md bash "sed -n '10,25p' src/config.py"
```

这会在模块文档里产出一个 `## 配置加载` section: note 的 prose + `bash` 命令块 + 捕获输出的 `output` 块.

#### Showboat reference

命令签名与坑位见 [`references/showboat.md`](references/showboat.md), 建文档前先过一遍 (尤其 CRLF, `note` 裸围栏两坑).

### HTML 视图

HTML 视图的脚手架, Terminal Cyan 配色, 卡片结构, 图型, 地图 HTML 规范见 [`references/html-view.md`](references/html-view.md).
