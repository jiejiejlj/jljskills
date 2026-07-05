# out-of-scope 知识库

`docs/jljskills/codeflow/out-of-scope/` 目录（惰性创建——第一次要写才建这个目录）存放被否决的 feature 请求的持久记录，用途两个：

1. **机构记忆**——为什么否决，issue 关闭之后这份理由不会跟着丢
2. **去重**——新 issue 撞上之前被否决过的同一个概念时，能直接把旧决定亮出来，不用重新吵一遍

## 目录结构

```
docs/jljskills/codeflow/out-of-scope/
├── dark-mode.md
├── plugin-system.md
└── graphql-api.md
```

一个**概念**一个文件，不是一个 issue 一个文件——多条 issue 请求同一件事，都归并到一个文件下。

## 文件格式

写得松一点、可读一点——更像一份短设计文档，不是数据库条目。用段落、代码样例、例子把理由讲清楚，让第一次看到这份文件的人也能明白。

````markdown
# Dark Mode

This project does not support dark mode or user-facing theming.

## Why this is out of scope

The rendering pipeline assumes a single color palette defined in
`ThemeConfig`. Supporting multiple themes would require:

- A theme context provider wrapping the entire component tree
- Per-component theme-aware style resolution
- A persistence layer for user theme preferences

This is a significant architectural change that doesn't align with the
project's focus on content authoring. Theming is a concern for downstream
consumers who embed or redistribute the output.

```ts
// The current ThemeConfig interface is not designed for runtime switching:
interface ThemeConfig {
  colors: ColorPalette; // single palette, resolved at build time
  fonts: FontStack;
}
```

## Prior requests

- #42 — "Add dark mode support"
- #87 — "Night theme for accessibility"
- #134 — "Dark theme option"
````

### 文件命名

概念用简短的 kebab-case 命名：`dark-mode.md`、`plugin-system.md`、`graphql-api.md`。名字要让人光看目录列表就知道否决的是什么，不用打开文件。

### 写理由

理由要实打实——不是「我们不想要这个」，是**为什么**。好理由会引用：

- 项目范围或理念（「本项目聚焦 X；主题是下游关心的事」）
- 技术约束（「支持这个需要 Y，跟我们的 Z 架构冲突」）
- 战略决策（「我们选了 A 而不是 B，因为……」）

理由要 durable（经得起时间）。别引用临时性的处境（「我们现在太忙」）——那不是真的否决，是推迟。

## 什么时候查

triage 第 1 步（gather context）时，读 `out-of-scope/` 下全部文件。评估一条新 issue 时：

- 检查它是不是撞上了已有的某个否决概念
- 匹配按概念相似，不是关键词——"night theme" 能匹配上 `dark-mode.md`
- 撞上了就亮给维护者："这跟 `out-of-scope/dark-mode.md` 很像——我们之前因为[理由]否决过。你还是这个态度吗？"

维护者可能三种反应：

- **确认**——新 issue 追加进现有文件的「Prior requests」列表，然后关闭
- **重新考虑**——删掉或改掉这份 out-of-scope 文件，这条 issue 走正常 triage 流程
- **不同意**——两者相关但不是一回事，这条 issue 走正常 triage 流程

## 什么时候写

只有一种情况：**enhancement**（不是 bug）被否决为 `wontfix`。这条规则对 enhancement 类型的 PR 同样适用——被否决的 PR 也要记进来，免得同一个请求又以新代码的形式杀回来。

因为**已实现**而关成 `wontfix` 的，**不要**写进来。那是已经做好的功能，不是被否决的请求；记进去会拿假的否决污染去重检查。这种情况下，关闭评论直接指向功能已经在哪就够了。

流程：

1. 维护者判定这条 feature 请求范围外
2. 检查有没有已存在的匹配文件
3. 有——把这条 issue 追加进「Prior requests」列表
4. 没有——新建一个文件，写好概念名、决定、理由，加上第一条 prior request
5. 在 issue 上贴评论解释决定，提到这份 out-of-scope 文件
6. 用 `wontfix` 关闭 issue

## 改或删

维护者改主意了：

- 删掉那份 out-of-scope 文件
- 不需要去翻旧 issue 重新打开——它们是历史记录
- 触发这次重新考虑的新 issue，走正常 triage 流程

---
> 内化自 mattpocock/skills 的 `skills/engineering/triage/OUT-OF-SCOPE.md`，目录约定 `.out-of-scope/` 改为 `docs/jljskills/codeflow/out-of-scope/`（2026-07-05）。
