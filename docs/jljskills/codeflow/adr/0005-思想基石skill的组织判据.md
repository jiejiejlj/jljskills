# 思想基石 skill 的组织判据

行为 skill 的方法论来源（设计思想）按以下方式组织，保证任何时候都能回答「这个 skill 的驱动力是谁」：

- **一思想一 skill**：每套设计思想（深模块、领域建模，及未来引入者）独立成一个地基 skill，内容为纯判据与词汇，只供 Read 装载、不操作文件。
- **`design-` 前缀 + 精确命名**：思想基石 skill 一律 `design-<思想名>`（design-deep-module、design-domain-model）。前缀语义：**design- 开头 = 思想基石**；`skills/design-*/` 一扫即得全部思想。（grill-design 为 design 结尾，不在此列，无冲突。）
- **驱动力以正向指针声明**：行为 skill 在正文用具名槽位「**驱动思想：<思想名>**——Read `../design-<思想>/SKILL.md` …」声明驱动它的思想。`grep -rn "驱动思想" skills/*/SKILL.md` 即全库思想-链路映射，不建任何会漂移的反向消费方清单。辅助性查阅（如 diagnosing-bugs 仅在 Phase 5 借 seam 判断）保持行内 Read，不佩戴驱动思想槽位——槽位专属「方法本身是该思想的应用」的 skill，滥贴会稀释语义。
- **思想与机制分离**：一个 skill 若同时承载判据（思想）与文件操作规程（机制），就有两个变更理由——发散式变化。拆开：思想入 `design-*`，机制/行为独立成 skill 并声明驱动思想。先例：domain-modeling → design-domain-model + build-context（2026-07-05）。

## Considered Options

- **大一统思想库**（单 skill + references/<思想>.md，被否决）：SKILL.md 层退化为目录索引（中间人）；消费方要么精确指 ref（skill 层成空壳）要么整包装载（无关思想污染上下文，思想间还可能互相矛盾——深模块的少接缝与插件化哲学的处处留钩就打架）；`/codeflow:design-thoughts` 还得带参数选思想，违背引导词一击命中；换驱动思想时 diff 藏在 mega-skill 内部，演化不可见。
- **思想与机制同居一个 skill**（被否决）：两个变更理由 = 发散式变化；domain-modeling 拆分即先例。
- **维护反向消费方清单**（被否决）：triage 依赖登记失联的教训——反向清单必漂移；正向指针（驱动思想槽位）本身就是真相源，可 grep 汇总。

## 重访触发器

思想数量膨胀到十余个且每个都很薄（判据不足一屏）时，单 skill 的登记成本才会反超装载精度收益，届时再议归并——在那之前，本判据不因「skill 变多了」而重开。
