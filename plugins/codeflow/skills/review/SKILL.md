---
name: review
description: 对 HEAD 到固定点的 diff 做双轴审查——Standards（仓库成文规范 + Fowler 坏味道基线）与 Spec（忠实实现了源头 issue/PRD 吗），两轴并行子代理、报告并列不合并排序。仅当用户主动用 `/codeflow:review` 指令调用、或 implement 显式指路时使用。
allowed-tools: Read, Grep, Glob, Bash, Agent, AskUserQuestion
disable-model-invocation: true
---

# review — 双轴审查

对 `HEAD` 到用户指定固定点的 diff，跑两条互不相通的审查轴：

- **Standards**——代码合不合仓库的成文规范、踩没踩 Fowler 坏味道基线？
- **Spec**——代码忠不忠实实现了源头 issue/PRD 要的东西？

两轴各开一个并行子代理跑，互不看见对方的上下文，防止一轴的判断污染另一轴。

## 1. 钉固定点

固定点（commit SHA、分支名、tag、`main`、`HEAD~5`……）由用户给；没给就问，不代猜。

先确认能解析：`git rev-parse <固定点>`。再取三点 diff（对比 merge-base，避免把固定点之后主干的无关提交也算进来）：`git diff <固定点>...HEAD`；同时取提交清单：`git log <固定点>..HEAD --oneline`。

固定点解析失败或 diff 为空，当场判定失败并停止，不进子代理——两个子代理并行跑起来之后才发现 ref 是坏的，代价是两份浪费的调用。

## 2. 找 Spec 源

按顺序找，命中第一个就停：

1. commit message 里的 issue 引用（`#123`、`Closes #45` 等）——按 `docs/jljskills/codeflow/issue-tracker.md` 的操作方式取全文与既有评论；issue-tracker.md 未配置时跳过本级，直接退到第 2 级（审查是只读消费，不因追踪器未配置卡壳；想补配置可事后跑 `/codeflow:config`）。
2. 用户传参给出的路径。
3. `docs/` 下匹配当前分支名或特性名的 PRD。
4. 都没有则问用户「spec 在哪」；用户明确说没有，Spec 轴跳过，在最终报告里注明「无 spec 可比对」。

## 3. 找 Standards 源

找仓库里成文的编码规范（`CONTRIBUTING.md`、`CODING_STANDARDS.md` 等同类文件）。

除此之外，Standards 轴恒定携带 [references/smells.md](references/smells.md) 里的 Fowler 坏味道基线——仓库什么都没写时它兜底。两条约束：

- **仓库成文规范压过基线**：规范认可的写法，基线判为坏味道也不算数。
- **基线永远是判断题，不是硬违规**：每条坏味道是带标签的怀疑（如「疑似依恋情结」），不是必须整改的红线；工具已经强制的（lint、格式化等）一律跳过，不重复报。

## 4. 并行双子代理

一条消息里发两个 `Agent` 工具调用，都用 `general-purpose`。

**Standards 子代理**：喂给它 diff 命令与提交清单、步骤 3 找到的规范文件清单、[references/smells.md](references/smells.md) **全文**——子代理没有别的渠道够到本 skill 的文件，必须整篇塞进 prompt。简报要求：逐条列出 (a) 每处违反成文规范的地方，引用规范文件与具体条款；(b) 每处命中基线坏味道的地方，点名坏味道并引用改动片段；区分硬违规（成文规范）与判断题（基线坏味道，仓库规范优先于基线），工具已强制的跳过；400 字以内。

**Spec 子代理**：喂给它 diff 命令与提交清单、步骤 2 找到的 spec 全文或路径。简报要求：列出 (a) spec 要求但改动里缺失或只做了一半的部分；(b) 改动里做了但 spec 没要求的部分（范围蔓延）；(c) 看似实现了但实现错了的部分；每条引用 spec 原句；400 字以内。

Spec 轴在步骤 2 被判定跳过时，只发 Standards 子代理，最终报告里注明「Spec 轴跳过：无 spec 可比对」。

## 5. 汇总

两份子代理简报原样或轻度整理后，分别放进 `## Standards` 与 `## Spec` 两个标题下并列呈现——**不合并、不重排**。这是故意的：规范全对可能做错了事（Standards 过、Spec 不过），做对了事可能破坏规范（Spec 过、Standards 不过）；合并排序会让一轴的通过遮住另一轴的失败。

结尾给各轴单独一行小结（该轴命中数 + 该轴内最严重的一条），不跨轴选出唯一的「最严重问题」——跨轴排名正是分离设计要防的事。

---
> 内化自 mattpocock/skills 的 `skills/engineering/code-review`（2026-07-05）。
