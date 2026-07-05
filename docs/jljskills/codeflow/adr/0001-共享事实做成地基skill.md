# 共享事实做成地基 skill，而非 plugin 根 references/

figma-optimize 的共享 Figma API 判据需要单一真相源。备选是 plugin 根 `references/figma-facts.md`（零命令面噪音、缓存可达性已实证），最终选择新建地基 skill `skills/figma-facts/`：与 engineering/design-rules 完全同构，仓内只维护一种「单点被 Read」的模式，模式一致性优先于命令面精简。命令面多出一条几乎无独立调用场景的 `/figma-optimize:figma-facts` 是已知且接受的代价——未来架构审查不必再以此为由提议搬回 plugin 根。

## Considered Options

- **plugin 根 `references/`**（被否决）：零噪音，但引入第二种共享惯例，且文件无 frontmatter 声明自己的使用方式。
- **住 page、standard 穿 `../page/references/`**（被否决）：对等 skill 间强加主从关系。
