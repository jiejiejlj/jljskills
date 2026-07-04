# jljskills

Claude Code skill 集合仓库（plugin marketplace）。module = skill，interface = frontmatter description，implementation = 正文 + references。

## Language

**地基 skill**：
同 plugin 内专为被兄弟 skill 以相对路径 Read 而存在的单一真相源 skill——`disable-model-invocation: true`，零上下文占用，命令面条目仅作显式装载入口。实例：`engineering/design-rules`、`figma-optimize/figma-facts`、`figma2web/spec-structure`。
_避免_：facts skill、shared reference、公共库

**装载式指针**：
消费方 flow 中的硬性「Read 地基 skill」步骤。判据正文只存地基一处，消费点不留摘要——漂移面归零，代价是运行时多一次 Read。
_避免_：摘要+链接、软引用

**写方向契约**：
figma2web 与 figma-optimize 的分工判据——figma-optimize 唯一有权写回 Figma、绝不落项目代码；figma2web 只读 Figma、只写项目文件。正文在两 plugin README 各自半边（按名互指），判据与否决记 ADR-0003；两插件间只有人的编排，文档不得写时序建议。
_避免_：优化 vs 产出、设计阶段 vs 编码阶段（裁不动骑墙技能）

**读到即确认**：
figma2web 的输入契约——用户发起管线即声明「产出当前这张图」，设计稿是读取时刻的权威快照；管线不设设计质量 gate、不提示先去优化，变更由人经 re-\* 重新声明。
_避免_：设计稿校验、先优化再转码
