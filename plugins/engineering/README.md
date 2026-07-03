# engineering — 深模块方法论

内化自 mattpocock/skills 的深模块方法论（Ousterhout 的深模块理论 + Feathers 的 seam），四个 skill 构成「扫描 → 设计 → 沉淀」一条链。目标项目侧的文档统一收在 `docs/jljskills/engineering/` 下。

## 四个 skill，各一句话

- **design-rules** —— 八术语词汇库与判据（deep/shallow、删除测试），另外三个 skill 的共用地基，通常不单独调用。
- **improve-arch** —— 对已有代码库扫描深化机会、出 HTML 审查报告，选定候选后接入拷问；终点是 interface 草图，不实施改码。
- **grilling** —— 对已明确的深化目标走设计树逐分支拷问，收敛出 interface 草图并落盘 `designs/`。
- **domain-modeling** —— 插件组的记忆层：领域术语当场落笔 `CONTEXT.md`，重大决策按三条件门槛记 ADR。

## 怎么选

- 觉得项目哪里不对但说不出哪疼 → `/engineering:improve-arch`
- 已明确要深化哪个 module、要设计它的 interface → `/engineering:grilling`
- 术语混乱要建词汇表 / 重大决策要记档 → `/engineering:domain-modeling`
- 只想在普通讨论里装载这套架构语言 → `/engineering:design-rules`
