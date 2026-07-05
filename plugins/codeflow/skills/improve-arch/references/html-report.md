# HTML 报告格式

架构审查渲染为单个自包含 HTML 文件，写 OS 临时目录。Tailwind 与 Mermaid 都走 CDN。图形关系（依赖、调用流、时序）用 Mermaid 稳；更编辑感的视觉（mass diagram、cross-section）用手搭 div / 内联 SVG。两者混用——全靠 Mermaid 会千篇一律。

安全边界：本报告是写进临时目录的本地一次性文件，不部署、不分发。两个 CDN 脚本（Tailwind Play CDN、mermaid@11）都是动态/浮动版本内容，无稳定哈希可钉 SRI——接受此取舍，代价是报告须仅限本地查看，**不要**把它发布到任何线上环境。

## 脚手架

```html
<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8" />
    <title>架构审查 — {{仓库名}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* Tailwind 不好覆盖的小自定义层：seam 虚线、泄漏红、deep 深底 */
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## 头部

仓库名、日期、紧凑图例：实线框 = module、虚线 = seam、红箭头 = 泄漏、厚深框 = deep module。没有引言段——直接进候选项。

## 候选卡片

**图承担重量，散文克制**，术语直接用 design-deep-module 词汇表的，不加铺垫。每个候选一个 `<article>`：

- **Title** —— 短，直接命名这次深化（如「折叠 Order intake 管线」）。
- **徽章行** —— 推荐强度（`Strong` = emerald、`Worth exploring` = amber、`Speculative` = slate）+ 依赖类别 tag（`in-process`、`local-substitutable`、`ports & adapters`、`mock`）。
- **Files** —— 等宽字体清单，`font-mono text-sm`。
- **Before / After 图** —— 居中件，两栏并排。图型见下。
- **Problem** —— 一句。哪里疼。
- **Solution** —— 一句。改什么。
- **Wins** —— 列表，每条 ≤6 个词。如「测试只打一个 interface」「Pricing 不再泄漏」「删 4 个 shallow 包装」。
- **ADR 警示**（如适用）—— amber 底一行。

不写解释段。图需要一段话才能看懂，就重画图。

## 图型（五种，混用别单调）

### Mermaid graph（依赖 / 调用流的主力）

要点是「X 调 Y 调 Z，看这团乱」时用 Mermaid `flowchart`。包进 Tailwind 卡片，别让它像空投进来的。classDef 标红泄漏节点、linkStyle 标红泄漏边、deep module 标深。时序图适合「before：6 次往返；after：1 次」。

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
      linkStyle 2 stroke:#dc2626,stroke-width:2px;
  </pre>
</div>
```

### 手搭 boxes-and-arrows（Mermaid 排版打架时）

module 用带边框的 `<div>`，箭头用绝对定位在 relative 容器上的内联 SVG `<line>`/`<path>`。想让 after 图呈现「一个厚边框 deep module、内部构件灰化」的分量感时用——Mermaid 画不出那个分量。

### Cross-section（层层皆薄时）

横向条带（`h-12 border-l-4`）堆叠，展示一次调用穿过的层。before：6 条薄层各自啥也不干。after：1 条厚带，标注合并后的职责。

### Mass diagram（interface 跟 implementation 一样宽时）

每个 module 画两个矩形：interface 表面积一个、implementation 一个。before：interface 矩形几乎和 implementation 一样高（shallow）。after：interface 矮、implementation 高（deep）。

### Call-graph collapse

before：函数调用树画成嵌套盒子。after：同一棵树折叠进一个盒子，已内化的调用在盒内淡化显示。

## 风格

- 编辑感，不要企业仪表盘感。留白慷慨。标题可用衬线（`font-serif` 配 stone/slate 好看）。
- 用色克制：一个强调色（emerald 或 indigo）+ 泄漏红 + 警示 amber。
- 图高约 320px，保证 before/after 并排不出滚动条。
- 图内 module 标签用 `text-xs uppercase tracking-wider`——读起来像示意图，不像 UI。
- 脚本只有 Tailwind CDN 和 Mermaid ESM 两个。其余全静态——没有应用代码，没有 Mermaid 渲染之外的交互。

## Top recommendation

一张更大的卡。候选名、一句为什么、锚链到对应卡片。就这些。

## 措辞

散文平实简洁——但架构名词动词一律来自 design-deep-module 词汇表。简洁不是漂移的借口。

**只用**：module、interface、implementation、depth、deep、shallow、seam、adapter、leverage、locality。

**永不替换**：component、service、unit（指 module 时）· API、signature（指 interface 时）· boundary（指 seam 时）· layer、wrapper（其实指 module 时）。

**合调的句式**：

- 「Order intake module 是 shallow 的——interface 几乎等于 implementation。」
- 「Pricing 泄漏跨过 seam。」
- 「深化：一个 interface，一处测试。」
- 「两个 adapter 撑起这条 seam：生产 HTTP、测试内存。」

**Wins 用词汇表词命名收益**：「locality：bug 集中到一个 module」「leverage：一个 interface，N 个调用点」「interface 收窄；implementation 吸收包装层」。不写「更易维护」「代码更干净」——这些词不在词汇表里，挣不到位置。

不套话、不清嗓、不写「值得注意的是」。能当列表项的句子就当列表项。能删的列表项就删。词汇表里找不到的词，先在表里找替代，再考虑造新词。

---
> 内化自 mattpocock/skills 的 `skills/engineering/improve-codebase-architecture/HTML-REPORT.md`（2026-07-03）。
