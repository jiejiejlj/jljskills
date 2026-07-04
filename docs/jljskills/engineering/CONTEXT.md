# jljskills

Claude Code skill 集合仓库（plugin marketplace）。module = skill，interface = frontmatter description，implementation = 正文 + references。

## Language

**地基 skill**：
同 plugin 内专为被兄弟 skill 以相对路径 Read 而存在的单一真相源 skill——`disable-model-invocation: true`，零上下文占用，命令面条目仅作显式装载入口。实例：`engineering/design-rules`、`figma-optimize/figma-facts`（设计中）。
_避免_：facts skill、shared reference、公共库

**装载式指针**：
消费方 flow 中的硬性「Read 地基 skill」步骤。判据正文只存地基一处，消费点不留摘要——漂移面归零，代价是运行时多一次 Read。
_避免_：摘要+链接、软引用
