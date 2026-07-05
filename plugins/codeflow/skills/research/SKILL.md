---
name: research
description: 把阅读性调研外包给后台代理：只查一手来源、逐条带引用，落成 docs/jljskills/codeflow/research/ 下一份 Markdown；主会话继续干活。仅当用户主动用 `/codeflow:research` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Agent, Read, Glob
disable-model-invocation: true
---

# research — 调研外包

用 Agent 工具派一个**后台代理**（`run_in_background: true`）做调研，主会话继续干活。

给代理的任务：

1. 对着**一手来源**调查问题——官方文档、源码、规范、第一方 API，不要二手转述；每条结论追溯到拥有它的那个源头。
2. 把发现写成单个 Markdown 文件，逐条带来源引用。
3. 存到目标项目 `docs/jljskills/codeflow/research/<slug>.md`（目录不存在则连同建出，slug 用问题的短横线概括），并在完成时报告路径。

产物可直接作 `/codeflow:grill-with-docs` 的输入——research 喂养思考，不替代思考。

> 内化自 mattpocock/skills 的 `skills/engineering/research`（2026-07-05）。
