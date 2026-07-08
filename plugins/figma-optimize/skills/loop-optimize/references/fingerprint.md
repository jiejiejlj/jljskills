# fingerprint.md — 审计指纹去重 + 双账互证

被 SKILL.md 红线④与各 `stages/<type>/flow.md` 指针够到. 本文件是**指纹机制的单一真相源** — 分诊判据见 `router.md`, API 判据见 `figma-facts.md`, 这里不复述. 各 stage flow 只定义**本阶段的 `surface()` prop 清单 + rev**, 机制本身不重写.

## 两种重复

- **一次运行内**: 共享节点被多个父页各审一遍. 真实文件里 `global_footer_section` 跨 7 个 page section (克隆非实例), nav/workflow 跨 4~5 页 → 审 7 遍改 7 遍, 且可能自己改自己.
- **跨次调用**: 重跑把已裁定项 (跳过 / 有意保留) 又翻出来重裁, 甚至"修好"本想留的.

## 一个基元治两头: 审计指纹

把"这个阶段会审的那几个属性"(= 审计面) 哈希成一枚指纹.

- **去重 (运行内)**: 按 fp 分组, footer 只审 1 遍, 克隆套用同裁决.
- **变更检测 (跨次)**: 按节点 id 存 / 取比 fp, **指纹未变 = 已裁定且没动过 → 跳过**. → 整个 skill **幂等**.

## 计算 (use_figma 的 JS 里, 确定性无随机)

两条规范化命门: **抹掉绝对坐标**(哈希父相对子树, 7 克隆撞同一指纹)、**浮点归整**(round(x*100)/100 砍 168.003 噪声).

审计面递归子树; `bv`(绑定变量 id) 优先于裸色 (token 化正是所审). canon 键排序确定性序列化 → fnv1a → 8 位十六进制.

```js
const r = n => Math.round(n*100)/100;               // 浮点归整,砍 168.003 噪声
function surface(node){                              // ← 这份 prop 清单是「page 阶段」的审计面(各 stage 自定义)
  const s = {
    ty: node.type,
    g: [r(node.x), r(node.y), r(node.width), r(node.height)],   // 父相对几何(Figma child.x 本就相对父帧)
    fills:(node.fills||[]).map(f=>({ t:f.type, o:r(f.opacity??1),
      c: f.color?[r(f.color.r),r(f.color.g),r(f.color.b)]:null,
      bv: f.boundVariables?.color?.id ?? null })),             // 绑定变量 id 优先于裸色(token 化正是所审)
    lay: node.layoutMode?{m:node.layoutMode, gap:r(node.itemSpacing),
      pad:[r(node.paddingTop),r(node.paddingRight),r(node.paddingBottom),r(node.paddingLeft)]}:null,
  };
  if(node.type==='TEXT') s.font={ fam:node.fontName.family, st:node.fontName.style,
    sz:node.fontSize, lh:node.lineHeight, bv:node.boundVariables?.fontSize?.id ?? null };
  if(node.children) s.kids = node.children.map(surface);       // 递归 → 子树结构指纹(footer 整体入指纹)
  return s;
}
const canon = o =>                                  // 确定性序列化:键排序,否则哈希不稳
  Array.isArray(o) ? '['+o.map(canon).join(',')+']' :
  (o&&typeof o==='object') ? '{'+Object.keys(o).sort().map(k=>JSON.stringify(k)+':'+canon(o[k])).join(',')+'}' :
  JSON.stringify(o);
const fnv1a = s=>{let h=0x811c9dc5>>>0;for(let i=0;i<s.length;i++){h^=s.charCodeAt(i);h=Math.imul(h,0x01000193)>>>0;}return h.toString(16).padStart(8,'0');};
const fp = fnv1a(canon(surface(node)));             // → 8 位十六进制,如 "a3f19b02"
```

> 抹绝对坐标靠"哈希父相对子树"实现 (surface 只取 node.x/y 的父相对值并递归) — 7 份 footer 克隆算出同一指纹、自然撞在一起去重. 各 stage 用**同一 canon/fnv1a**, 只换 `surface()` 的 prop 清单 (见"落位"一节).

## 双账互证 (用户要求)

- **仓库侧** `docs/jljskills/figma-optimize/.loop-optimize-ledger.json`: `{fileKey, rev, entries:[{nodeId,path,stage,fp,decision,ts}]}`.
- **Figma 侧** `node.setPluginData('loop-optimize', {fp,stage,decision,rev,ts})`.
- **价值** = 韧性 (一侧丢另一侧兜: 换机 / 换仓靠 pluginData, 导出抹了靠仓库台账) + 失同步侦测 (`doc≠fig` → 报"手改/复刻件", 取保守重审).

## `rev` 语义

`rev` = 审计面版本号: 改了 surface prop → rev 变 → 旧指纹不参与比对, 重算重审.

## 分诊比对闸门

| 现 fp vs 存档 | 两侧一致 | 动作 |
|---|---|---|
| 相等且 doc==fig | 是 | 跳过 (已裁定 · 未变) |
| 不相等 | — | 重审 (内容变了) |
| 只存一侧 | — | 用在的一侧, 补写缺失侧 |
| 两侧都在但 doc≠fig | 否 | 标"台账失同步", 取保守重审, 提示手改/复刻 |
| 两侧皆无 | — | 新目标, 正常审 |

## 何时盖 / HARD GATE

指纹是记账写, 搭已批准裁决的顺风车: 批了改动 → 同批次末尾盖; 纯跳过 / 保留 → 阶段末统一盖一次 (只切一次页), 一句话披露"给这批已裁定项盖指纹水印", 不单设重 gate.

## 落位

机制单一真相源在本文件; 每个 `stages/<type>/flow.md` 各自定义**本阶段 `surface()` prop 清单 + rev**(page 审几何字体、standard 审变量集合与 valuesByMode、component 拿它当同构键).
