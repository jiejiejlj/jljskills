# router.md — 识别引擎 + 链注册表

被 SKILL.md 分诊段指针够到, 逐 section 级子节点定类. 本文件是分诊判据与扩展注册的**单一真相源** — API 判据见 `figma-facts.md`, 去重机制见 `fingerprint.md`, 这里不复述.

## 三路信号

三路信号叠加判定, 优先级从上到下:

- **命名约定 (主)**: `*_page` / 含 `*_section` → 内容页; `design spec*` / 子节点为 token 品类 → 标准板; `components` · `icon` → 组件库; `img` / 素材 → 跳过.
- **宽高形态 (辅, 抓错标)**: 子帧 ≈ 1920×1080 → 内容页; 2000×4500 长条 → 标准板; 小杂帧 → 组件 / 图标.
- **子节点构成 (决胜)**: 子节点叫 `*_section` → 内容页; 叫 token 品类 (Color · Text · Spacing · Radius · Shadow · Grid) → 标准板.

## 置信度 + 兜底

- 三信号一致 → 高置信, 自动定类.
- 冲突, 或名字是垃圾 (`Page 1` / `草稿` / `Frame 2121…`) → 截图补看 → 仍不定 → 标"待定", 送进行程单问用户.
- 绝不静默错路由: 行程单每行标"判成什么, 凭哪条信号", 用户可覆盖任一行.

## 链注册表

加新类型的唯一注册点. 新增类型时, 在此表补一行 + 建对应 `stages/<新类型>/` 目录.

| 类型 | 识别信号 | stage 目录 | 链位序 | 吃谁产物 |
|---|---|---|---|---|
| standard | `design spec*` / 子叫 Color · Text · Spacing · Radius · Shadow · Grid | `stages/standard/` | 10 | — |
| page | `*_page` / 含 `*_section` / 子帧 ≈ 1920×1080 | `stages/page/` | 20 | standard |
| component | `components` · `icon` / 一堆小杂帧 | `stages/component/` | 30 | — (独立收尾) |
| (素材) | `img` · 素材 | — | 跳过 (无可优化) | — |

**扩展规则**: 加新类型 = 加 `stages/<新类型>/` + 在此表补一行; 吃标准的排序号 > 20, 收尾类挂尾.
