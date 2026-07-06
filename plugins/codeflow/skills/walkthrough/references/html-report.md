# HTML 报告格式

走读渲染为单个 HTML 文件，由已 `verify` 的模块文档 md **生成**。Tailwind 与 Mermaid 都走 CDN。**md 是 source-of-truth，HTML 是视图**——`output` block 逐字照搬进源码卡片，一字不改。图形关系（call chain、依赖、生命周期状态机）用 Mermaid 稳；更编辑感的件（文件树、**逐字保真的源码卡片**、provenance chip）手搭 div——两者混用，全靠 Mermaid 会千篇一律，而 Mermaid 装不下逐字代码。本文档自举：脚手架、Terminal Cyan token、卡片结构、图型全在下面，不依赖任何样张文件。

两种产物：**模块报告** `walkthrough-<scope>-<YYYYMMDD>.html`（由对应模块文档生成）与**地图** `walkthrough.html`（由 `walkthrough.md` 生成的信息卡导航页）。

## 边界

报告 `.html` 与 `.md` 源一同**提交入库**（落盘文档，给人长期回看，不是临时物）。它用 CDN——Tailwind Play CDN、mermaid@11 都是浮动版本、无稳定哈希可钉 SRI。接受此取舍的代价：报告**联网时渲染完整**，离线或 CDN 漂移后 Mermaid 图与 Tailwind 会失效。兜底在于**逐字源码卡片是手搭静态的**，即便 CDN 全挂也读得到——走读最有价值的部分（代码 + 来源行号 + 讲解）不依赖 CDN。若日后要纯离线分发，再评估把 Tailwind 编译进内联 CSS、Mermaid 预渲染成 SVG。

## 脚手架

单文件，Tailwind CDN + Mermaid ESM + 一层 Terminal Cyan 自定义 `<style>`（Tailwind 不便表达的 token / 辉光 / 代码上色）。Mermaid 用 `themeVariables` 调成青色，跟页面一套皮：

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/>
<title><Project> — <Module> · Walkthrough</title>
<script src="https://cdn.tailwindcss.com"></script>
<script type="module">
  import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
  mermaid.initialize({ startOnLoad:true, theme:"base", securityLevel:"loose", themeVariables:{
    background:"#0b1219", primaryColor:"#0a1016", primaryBorderColor:"#2ee6d6",
    primaryTextColor:"#c6d3d8", lineColor:"#2ee6d6", fontFamily:"ui-monospace,Menlo,monospace" }});
</script>
<style>
  :root{--accent:#2ee6d6;--glow:0 0 14px rgba(46,230,214,.35)}
  body{background:#060a0f}
  /* 固定特效层：右上青色辉光 + 扫描线微网格 */
  .bg-fx{position:fixed;inset:0;z-index:0;pointer-events:none;background:
    radial-gradient(1000px 500px at 80% -10%, rgba(46,230,214,.08), transparent 70%),
    repeating-linear-gradient(0deg, rgba(46,230,214,.035) 0 1px, transparent 1px 3px);}
  .card{background:#0b1219;border:1px solid rgba(46,230,214,.18);border-radius:10px}
  .glow{box-shadow:0 0 0 1px var(--accent) inset, var(--glow)}      /* 当前 TOC 项 / 选中态 */
  .code-card{background:#05090d;border:1px solid rgba(46,230,214,.14)}
  .src::before{content:"↳ source: ";color:var(--accent)}           /* figcaption 前缀 */
  .mono{font-family:ui-monospace,"SF Mono",Menlo,Consolas,monospace}
  /* 语法高亮：手工 span，逐字代码 Mermaid 装不下，只能自己上色 */
  .k{color:#f78c6c}.s{color:#57e389}.c{color:#4a6470}.f{color:#56c8ff}
</style>
</head>
<body class="text-[#c6d3d8] font-sans">
  <div class="bg-fx"></div>
  <div class="relative z-10 grid grid-cols-[240px_minmax(0,1fr)] max-w-[1180px] mx-auto">
    <aside class="sticky top-0 h-screen overflow-auto p-6 border-r border-[rgba(46,230,214,.18)] mono text-xs space-y-1">
      ...TOC...
    </aside>
    <main class="px-8 py-9 min-w-0 space-y-4">
      ...header + cards...
    </main>
  </div>
</body></html>
```

强调色 `#2ee6d6`（青）；warn/callout 用 `#ffb454`（琥珀）；源码卡片深底 `#05090d` + 青色描边。标题、徽章、TOC、来源标注一律等宽（`mono`）。辉光克制——只上 `.glow` 在当前 TOC 项与选中态。

## 头部与 provenance chip

顶部一行 provenance chip，一眼溯源到已验证的 md：`▣ generated from verified <md 文件> · showboat verify ✓`。上方 eyebrow（`<Project> · Module Walkthrough`）+ 等宽大标题（模块名）+ 一行 meta（覆盖文件数 / 端点数等）。没有引言段——chip 之后直接进 Overview 卡。左侧 sticky TOC：Overview / Architecture / 各编号小节 / Recap，当前项 `.glow`。

## 卡片（图承担重量，代码逐字照搬）

每份模块报告一列 `.card`，按顺序：

- **Overview** —— tech-stack 徽章行 + 一句讲解 + call chain（Mermaid flowchart）。
- **Architecture** —— 文件树（手搭 `<pre>`）+ 依赖/调用关系（Mermaid）+ 生命周期（Mermaid stateDiagram）。
- **编号小节 ×N** —— 标题带编号；一句讲解；**源码卡片**（手搭 `.code-card` + `.src` 来源标注）；生产 bug / 反直觉旁白 → 琥珀 callout。
- **Recap**（青色描边）—— 状态流 + 要义列表，每条一句。

md 各元素照此转换：

| md 元素（showboat） | → HTML |
|---|---|
| `note` prose | 卡片正文 `<p>` |
| ` ```output ` 块（已 verify） | 手搭 `.code-card`，**逐字照搬、全保真** |
| ` ```bash sed -n 'A,Bp' file ` | 收成一行 `.src` → `↳ source: file:LA–LB`（人不关心跑了什么 sed） |
| Overview/Architecture 里的调用/依赖/状态 ASCII 图 | Mermaid flowchart / stateDiagram |
| Architecture 里的文件树 | 手搭 `<pre>`（Mermaid 画不好树） |
| "war story" 旁白 | 琥珀 callout |

散文克制——一句讲清「哪里疼 / 改了什么」。要一段话才看得懂的地方，重画图。

## 图型（混用别单调）

### Mermaid flowchart（call chain / 依赖的主力）

「X 调 Y 调 Z，看这条链」用 flowchart。包进 `.card`，classDef 标青 deep/入口节点，泄漏或异常边标琥珀：

```html
<div class="card p-4">
  <pre class="mermaid">
    flowchart LR
      A[verify_token] --> B[resolve_user] --> C[get_user]
      A -. 401 .-> X((abort))
      classDef hot stroke:#2ee6d6,stroke-width:2px;
      class A,B hot
  </pre>
</div>
```

### Mermaid stateDiagram（生命周期状态机）

「active → deactivated → hard-deleted」这类状态流用 stateDiagram，比手搭胶囊更稳：

```html
<div class="card p-4">
  <pre class="mermaid">
    stateDiagram-v2
      [*] --> active: provision
      active --> deactivated: POST /deactivate
      deactivated --> [*]: ≥7d + re-register (hard-delete)
  </pre>
</div>
```

时序图（`sequenceDiagram`）适合「一次请求几跳」。

### 手搭文件树（Mermaid 画不好树）

关键行 `<b>` 高亮：

```html
<pre class="code-card mono text-xs rounded-lg p-3 overflow-auto text-[#6d8791]"><b class="text-[#2ee6d6]">app/api/account.py</b>      # router + lifecycle
  provision_user()          #   shared create path
<b class="text-[#2ee6d6]">app/firebase_utils.py</b>   # auth backbone</pre>
```

### 手搭源码卡片（逐字保真，Mermaid 装不下）

走读的命根——已 verify 的 `output` 逐字进来，手工 `<span>` 上色 + 来源标注：

```html
<figure>
  <pre class="code-card mono text-xs rounded-lg p-4 overflow-auto text-[#cfe9ec]">    user = db.query(User).filter(User.firebase_uid == uid).first()
    <span class="k">if not</span> user:
        <span class="k">raise</span> HTTPException(status_code=<span class="s">404</span>, detail=<span class="s">"..."</span>)</pre>
  <figcaption class="src mono text-[11px] text-[#6d8791] mt-1.5">app/firebase_utils.py:189–203</figcaption>
</figure>
```

## 地图 HTML（`walkthrough.html`）

- **Header** —— 项目名 + `结构快照刷新于:<日期>`。
- **结构快照区** —— 模块树（手搭 `<pre>`）+ entry points。
- **索引区** —— 信息卡网格，一模块一张卡：模块名 / Covers 一句 / Updated / 覆盖的关键文件 / 打开按钮（`<a>` 链到该模块 `.html`）。

## 风格

- 编辑感、示意图感，不要仪表盘感。近黑底 + 青色辉光偏科技风。
- 用色克制：一个强调色（青 `#2ee6d6`）+ callout 琥珀。辉光只给当前 TOC 项与选中态。
- 标题、徽章、TOC、来源标注全等宽；正文系统无衬线。
- Mermaid 用 `themeVariables` 调成青色，别让它像空投进来的白底图；图高约 320px。
- **代码高亮必做**：源码卡片手工 `<span class=k/s/c/f>`（关键字/字符串/注释/函数名）上色——逐字代码不走 Mermaid，只能自己上色。覆盖这几类常见 token 即可，更多按需再加，不必一步到位。
- 脚本只有 Tailwind CDN 和 Mermaid ESM 两个，其余全静态。响应式：代码、树各自 `overflow:auto`。
