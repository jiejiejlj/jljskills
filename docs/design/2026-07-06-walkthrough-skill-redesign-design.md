# Walkthrough Skill 优化设计（思路落盘）

**日期:** 2026-07-06
**目标 skill:** `jljskills/codeflow` plugin → `skills/walkthrough/`
**源码仓库(改这里,别改 plugin cache):** `.../plugins/codeflow/skills/walkthrough/`
**状态:** 设计已定，待在源码仓库落地

---

## 0. 背景与目标

现有 `walkthrough` skill 用 showboat 产出「边走边跑、钉输出」的可执行 markdown 走读，效果已验证 OK。本次优化四个方向：

1. **文档从"单份内容"改为"地图 + 带时间戳的模块文档"** —— `walkthrough.md` 变成纯索引地图。
2. **产出双层**：md(showboat 可验证的源）→ 生成 **HTML 报告**（人看的视图，信息卡片式，科技风）。
3. **流程微调**：地图存在时的分支从"覆盖/续写"改为"新建 / 刷新 / 更新索引"三选一。
4. **踩坑防护**：把实测撞到的 CRLF、note 裸围栏两个坑写进 `showboat.md`。

设计原则：**md 是 AI 写 + `showboat verify` 钉死的源；HTML 是由 md 生成、给人读的视图。代码片段永远来自已 verify 的 output，不失真。**

改动落在 3 个文件:
- `SKILL.md` —— 换新工作流(模型 / 命名 / 决策树 / HTML 生成步)
- `references/showboat.md` —— 加两条踩坑防护
- **新增** `references/html-report.md` —— HTML 报告规范

---

## 1. 新文档模型

```
docs/jljskills/codeflow/walkthrough/
  walkthrough.md                          # 地图(纯 markdown 索引,不带时间戳,稳定入口)
  walkthrough.html                        # 地图的 HTML 视图(信息卡导航页)
  walkthrough-app-spine-20260706.md       # 模块文档(md 源,showboat 可验证)
  walkthrough-app-spine-20260706.html     #   └ 由 md 生成的 HTML 报告
  walkthrough-app-spine-20260706.zh.md    #   └ 简体中文版(可选)
  walkthrough-event-engine-20260706.md
  walkthrough-event-engine-20260706.html
  walkthrough-account-20260706.md
  ...
```

- `walkthrough.md` 不再装正文 —— 它是**纯索引地图**。原来 no-scope 默认产出的 app-spine 正文，降级为一个和其它模块平级的模块文档 `walkthrough-app-spine-<日
期>.md`。
- 每个走读天然是一对(有时一组）：`.md`（源）+ `.html`（视图）+ 可选 `.zh.md`。

---

## 2. 命名约定

| 角色 | 文件名 | 说明 |
|---|---|---|
| 地图(源) | `walkthrough.md` | 不带时间戳,稳定入口,纯 markdown |
| 地图(视图) | `walkthrough.html` | 由地图 md 生成 |
| 模块文档(源) | `walkthrough-<scope>-<YYYYMMDD>.md` | showboat 可验证 |
| 模块文档(视图) | `walkthrough-<scope>-<YYYYMMDD>.html` | 由该 md 生成 |
| 模块中文版 | `walkthrough-<scope>-<YYYYMMDD>.zh.md` | 可选 |

- `<scope>` = kebab-case slug，如 `app-spine`、`event-engine`、`account`、`utility-sync`。
- `<YYYYMMDD>` = 内容"截至日期"。**同日重生成 → 同名覆盖，无需 rename；跨天更新 → `git mv` 到新日期**（配套更新地图索引里的链接）。
- 时间戳精确到天足够；"最近生成了啥"由地图的索引表回答，不靠文件名排序。

---

## 3. 地图 `walkthrough.md`（纯 markdown）

两块内容：

### ① 项目结构快照（读项目得来）
- 一句话：项目是什么 + tech stack
- **模块地图**：顶层模块的目录树/清单，每行一句说明
- **entry points**：`main.py`、后台 worker 等
- 一行 `结构快照刷新于:YYYY-MM-DD`（freshness 信号）

### ② 走读索引表（指向各模块文档）

| Module (scope) | Doc | Updated | Covers | zh |
|---|---|---|---|---|
| App spine · `app-spine` | `walkthrough-app-spine-20260706.md` | 2026-07-06 | main.py bootstrap · middleware · workers | ✓ |
| Event Engine · `event-engine` | `walkthrough-event-engine-20260706.md` | 2026-07-06 | evaluate() pipeline · 15 rules | ✓ |
| Account · `account` | `walkthrough-account-20260706.md` | 2026-07-06 | Firebase auth · lifecycle · deactivate | ✓ |

列义：Module=人名+slug(slug 供技能匹配/参数)；Doc=主文档链接；Updated=与文件名时间戳一致；Covers=一句话覆盖的关键入口/文件；zh=中文版链接或 ✓。

### 两种"写索引"（关键区分）
- **轻量(自动、免费)**：每次生成/刷新一份模块文档，就往索引表追加/更新它那一行。不重读项目。地图不会立刻过时。
- **重量(需询问)**：「**更新索引**」= 重读整个项目 → 刷新结构快照 + 核对整张表(发现新模块、被 `git mv` 的文档、源码已变的过时文档)。有成本，只在地图已存在 
时问用户。

---

## 4. 工作流 / 决策树

技能启动（可带 `scope` 参数）：

```
├─ 地图 walkthrough.md 不存在(首次)
│    1. 读项目 → 建地图(结构快照 + 空索引)
│    2. 生成首个模块文档(scope 给了就用;没给则询问选哪个模块)
│    3. 轻量写入该模块的索引行
│    4. 由 md 生成对应 .html;更新 walkthrough.html
│
└─ 地图已存在
     → 询问用户想做什么(三选一):
        (1) 生成新模块走读 <scope>  → 读该模块 → 新时间戳 .md → verify → 生成 .html → 轻量写索引行
        (2) 刷新已有模块文档 <scope> → 重读该模块 → 重生成 → git mv 到新日期 → 重生成 .html → 更新索引行
        (3) 更新索引(重量)         → 重读项目 → 刷新结构快照 + 核对整张表 → 重生成 walkthrough.html
```

- **原技能里"`walkthrough.md` 已存在 → 问 覆盖/续写"这一步，替换成上面的三选一。** 这是本次流程的主要变化。
- 启动带 `scope` 且该 scope **已在索引** → 默认走 (2) 并确认；**不在索引** → 默认走 (1)。没带 scope 才弹三选一菜单。
- 每次 (1)/(2) 结束都**自动**轻量写/更新索引行 + 重生成该模块 .html；地图的 HTML 也随之刷新。

---

## 5. 双层产出:md 源 → HTML 视图

**md 是 source-of-truth，HTML 由它生成。** 生成 HTML 时对 md 各元素做如下转换：

| md 元素(showboat) | → HTML 报告 |
|---|---|
| `note` prose（章节讲解） | 卡片正文 |
| ` ```output ` 代码块（已 verify） | 卡片内深色高亮代码块（**逐字照搬，全保真**） |
| ` ```bash sed -n 'A,Bp' file ` 脚手架命令 | 收成一行 `↳ source: file:LA–LB` 小标注（人不关心跑了什么 sed） |
| Overview / Architecture / Recap 里 4-空格缩进的 ASCII 图 | 手搭的 flow / state / tree HTML 图 |
| "war story" 类旁白（生产 bug 等） | 琥珀色 callout 高亮 |

- HTML **提交入库**（不像 improve-arch 写临时目录即弃 —— 那是一次性评审，我们的是落盘文档）。
- HTML **自包含、无 CDN**（离线可开、无 CDN rot）：`<style>` 内联、代码/图内联、不外链。
- 生成方式：AI 按 `references/html-report.md` 手写 HTML，内容填自已 verify 的 md。

---

## 6. HTML 报告规范（→ 新增 `references/html-report.md`）

### 脚手架
- 单文件、`<!doctype html>`、`<style>` 全内联、**无任何外部脚本/CDN/字体**。
- 响应式：`max-width` 容器 + 侧栏 TOC；宽内容(代码/树)各自 `overflow:auto`。
- 跟随系统浅/深(可选)；科技风本身偏深底。

### 配色 —— 方案「Terminal Cyan」（近黑 CRT + 青色辉光 + 等宽标题）
```css
:root{
  --bg:#060a0f; --h1:#e6fbff; --h2:#d7f6fb; --ink:#c6d3d8; --muted:#6d8791;
  --accent:#2ee6d6; --accent-soft:rgba(46,230,214,.10); --glow:0 0 14px rgba(46,230,214,.35);
  --panel:#0b1219; --panel-border:rgba(46,230,214,.18);
  --chip:#0f1a22; --node-bg:#0a1016;
  --code-bg:#05090d; --code-border:rgba(46,230,214,.14); --code-ink:#cfe9ec;
  --code-kw:#f78c6c; --code-str:#57e389; --code-com:#4a6470; --code-fn:#56c8ff;
  --warn:#ffb454; --warn-soft:rgba(255,180,84,.08);
  --mono:ui-monospace,"SF Mono",Menlo,Consolas,"Roboto Mono",monospace;
}
/* 背景特效层(fixed，pointer-events:none)：右上青色辉光 + 扫描线微网格 */
.bg-fx{background:
  radial-gradient(1000px 500px at 80% -10%, rgba(46,230,214,.08), transparent 70%),
  repeating-linear-gradient(0deg, rgba(46,230,214,.035) 0 1px, transparent 1px 3px);}
/* 标题用等宽 */
h1.title, .card h2{font-family:var(--mono);}
```
- 强调色 `#2ee6d6`(青)；warn/callout 用 `#ffb454`(琥珀)；代码块深底 `#05090d` + 青色描边。
- 徽章/来源标注/TOC 用等宽；辉光克制(仅当前 TOC 项、选中态)。

### 模块报告结构（每份 `walkthrough-<scope>-<日期>.html`）
1. **顶栏 provenance chip**：`▣ generated from verified <md 文件> · showboat verify ✓`
2. **左侧 sticky TOC**：Overview / Architecture / 各编号小节 / Recap
3. **Header**：eyebrow(项目·Module Walkthrough) + 大标题(模块名) + 一行 meta
4. **Overview 卡**：tech-stack 徽章 + 讲解 + 流程条(flow nodes)
5. **Architecture 卡**：文件树(`pre.tree`) + call-chain(flow nodes) + 状态机(state chips)
6. **编号小节卡 ×N**：标题(`<span class=num>`) + 讲解 prose + 深色代码块 + `↳ source:` 标注；旁白 → callout
7. **Recap 卡**(青色描边)：状态流 + 要义列表

### 图型（自包含、手搭，不用 Mermaid）
- **flow nodes**：`<div class=node>` 横排 + `→` 箭头（call chain / 流程）。
- **state chips**：圆角胶囊 + `—edge→` 文字（生命周期状态机）。
- **tree**：`<pre class=tree>`，关键行 `<b>` 高亮。
- （放弃 Mermaid：它要 CDN，破坏自包含。若日后要更复杂的 call-graph 再评估内联 SVG。）

### 地图 HTML（`walkthrough.html`）
- Header：项目名 + `结构快照刷新于:<日期>`
- 结构快照区：模块树(`pre.tree`) + entry points
- 索引区：**信息卡网格**，一模块一张卡 —— 卡上放 模块名 / Covers 一句 / Updated / 覆盖的关键文件 / 打开按钮(链到该模块 .html，及 zh)。

> 工作参考：本次已在 scratchpad 产出可开的样张，可作实现模板起点：
> `walkthrough-account-preview.html`（单模块报告）、`walkthrough-tech-variants.html`（配色方案，选定 V1=Terminal Cyan）。

---

## 7. 踩坑防护（→ `references/showboat.md` 增补两条）

### 坑 A · CRLF 源文件（精简版）
> **CRLF 源文件会让 `verify` 永久失败**：源文件是 Windows 换行时，`sed` 输出带 `\r`，与存档的 LF 永远对不上。解决：把涉及的源文件行尾转成 LF（临时兜底：读 
取命令接 `| tr -d '\r'`）。

### 坑 B · `note` 里的裸围栏会被当命令执行
> showboat 把文档里**每一个** ``` 围栏都当可执行。**`note` prose 里画图/放静态内容，用 4-空格缩进，永不用 ``` 围栏**（否则 verify 报 `exec: no command`）。
需要可执行的图才用 `cat <<'EOF' … EOF`。

---

## 8. 文件改动清单

1. **`SKILL.md`** —— 重写 workflow：
   - 「Walkthrough structure」保留(Overview/Architecture/Core walkthrough)，但明确它描述的是**模块文档**，不是地图。
   - 新增「文档模型」：地图 + 带时间戳模块文档 + md/html 双层（§1–§2）。
   - 新增「地图」小节（§3）。
   - 重写「初始化」步：由地图存在性驱动的**决策树**（§4），替换原"覆盖/续写"。
   - 新增「生成 HTML 视图」步：产出 md 并 verify 后，按 `references/html-report.md` 生成 `.html` 并更新地图（§5）。
2. **`references/showboat.md`** —— Gotchas 加坑 A、坑 B 两条（§7）。
3. **新增 `references/html-report.md`** —— §6 全文（脚手架 + Terminal Cyan tokens + 卡片结构 + 图型 + 地图 HTML）。

---

## 9. 迁移（不紧急）

现有 `OmbreBackend` 项目下已产出的 5 份文档（`walkthrough.md` = 旧 app-spine 正文、`walkthrough-event-engine.md`、`walkthrough-account.md` 及 zh），**可日 
后**按新约定重命名 + 建地图，非本次必须。技能改好后自然用于下一次生成。

---

## 10. 延后 / 待定（实现时再定，不阻塞）

- **zh 的 HTML**：中文版要不要也生成 `.zh.html`，还是 HTML 内做语言切换？—— 倾向"先只出英文/源语言 HTML，zh 保持 .zh.md"，实现时看效果再定。
- **代码高亮**：自包含前提下用极简手工 `<span>` 上色 vs 纯色。样张用了手工上色，够用即可，不引入高亮库。
- **地图 HTML 的自动刷新**：轻量写索引后是否每次都重生成 `walkthrough.html`，还是仅在"更新索引"时重生成 —— 倾向每次轻量写后顺带重生成(成本低)。