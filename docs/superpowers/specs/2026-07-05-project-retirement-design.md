# project 插件退役设计：interview2doc / loopspec 迁入 support

日期：2026-07-05
状态：已实施（单 commit d9e6087 收口并已 push）
来源：codeflow 大一统重组（一期 c4df528、二期 21e0bd0）后 project 仅剩两个通用思考 skill，用户拍板迁入 support 并移除 project 插件组。

## 1. 迁移

- `git mv plugins/project/skills/interview2doc plugins/support/skills/interview2doc`（含 references/method.md）
- `git mv plugins/project/skills/loopspec plugins/support/skills/loopspec`
- `git rm plugins/project/.claude-plugin/plugin.json`，删空壳目录。support 变 4 skill（handoff、git-policy、interview2doc、loopspec）。

## 2. 命名空间清扫（`/project:` → `/support:`，9 处）

- 迁移件自身：interview2doc SKILL.md 的 description 与「何时运行」（2 处）；loopspec SKILL.md 的 description、「何时运行」与分工描述里的 interview2doc 引用（3 处）。
- 消费方：`plugins/codeflow/README.md:82` 外部前置声明（`/project:interview2doc`→`/support:interview2doc`，`project` 插件→`support` 插件）；`plugins/codeflow/skills/to-prd/SKILL.md:12`；`plugins/codeflow/skills/grill/SKILL.md:13`。
- 完成判据：`grep -rn "project:" plugins/ README.md CLAUDE.md` 零命中（docs/superpowers 历史文档不改写）。

## 3. 登记面

- marketplace.json：删 project 条目，其余不动。
- support plugin.json：description 更新为「通用辅助 skill：需求梳理、workflow 规格、会话交接、git 策略」。
- 仓库 README：分类表删 project 行、support 行导览更新（4 skill）；codeflow 行前置列 `project` 改 `support`；示例串与目录树同步实际。
- CLAUDE.md 无引用，不动。

## 4. 收口与校验

单 commit（迁移+清扫+登记原子落地，git rename 检测保 diff 可读），message 带 BREAKING CHANGE（已装用户 `/plugin uninstall project@jljskills`，`/plugin marketplace update` 后更新 support）。校验四件：name 一致脚本零 MISMATCH、命名空间清零 grep、两个 JSON 可解析、README 目录树对照 `find plugins -name SKILL.md | sort`。校验全过单次 push。事后更新 memory（plugin-doc-root-convention 的「project/support 待办」表述、codeflow-restructure 的 project 相关描述、MEMORY.md 索引）。

## 5. 范围外

- 两 skill 内容除命名空间外一字不动（不借机改写）。
- docs/superpowers 下历史 spec/plan 里的旧命名空间保留（历史记录，家规先例：figma2web 收敛时同样不改写历史文档）。
- 不为 support 建 README（它此前就没有，体例钉死议题在 improve-arch 候选清单里另议）。
