---
name: example
description: preproject 分类的占位示例 skill。复制本目录、改名、替换内容即可新增一个真实 skill。
---

# 示例 skill（preproject）

这是 `preproject` 分类下的占位示例，用途有二：
1. 让 `skills/` 目录被 git 跟踪（空目录不会被提交）。
2. 演示一个最小可用的 `SKILL.md` 格式。

安装后调用方式：`/preproject:example`

## 如何新增一个真实 skill
1. 在 `plugins/preproject/skills/` 下新建目录，例如 `my-skill/`（目录名即 skill 名）。
2. 在其中创建 `SKILL.md`，frontmatter 的 `name` 与目录名保持一致。
3. 注意：`skills/` 下必须**扁平**——不能再套子目录分类。
4. commit & push 后，用户执行 `/plugin marketplace update` 即可获取更新。

> 真实 skill 补齐后，可删除本 example 目录。
