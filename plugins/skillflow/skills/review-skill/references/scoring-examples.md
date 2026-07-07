# Scoring Examples(打分示例)

真实评估,示范如何套用 [dimensions.md](dimensions.md) 的评分 rubric。

## Contents

- [Example 1: Strong Skill (vc-ship) (historical — this skill has been removed)](#example-1-strong-skill-vc-ship-historical--this-skill-has-been-removed)
- [Example 2: Creative Skill (let-fate-decide)](#example-2-creative-skill-let-fate-decide)
- [Example 3: Analysis Skill (tech-debt) (historical — this skill has been removed)](#example-3-analysis-skill-tech-debt-historical--this-skill-has-been-removed)
- [Scoring Calibration Notes](#scoring-calibration-notes)

## Example 1: Strong Skill (vc-ship) (historical — this skill has been removed)

### Assessment Summary

**Skill**: vc-ship
**Overall Score**: 4.33 (Good)

### Dimension Scores

| Dimension | Score | Evidence(证据) |
| ---------------- | ----- | --- |
| Effectiveness | 5 | 完整的 8 阶段工作流,覆盖从分支管理到建 PR。处理边界情况(受保护分支、detached HEAD、冲突)。从头到尾流程清晰。 |
| Clarity | 5 | 组织良好、带 TOC。标题层级一致。Edge Case 速查表便于快速查阅。技术术语用得一致。 |
| Best Practices | 3 | SKILL.md 137 行(在目标内)。15 个 reference 文件——详尽但有些可能重叠。虽是有副作用的 skill(推代码、建 PR)却缺 `disable-model-invocation: true`。 |
| Documentation | 4 | reference 全面(workflow-phases、commit-format、rebase-guide,外加 5 个示例场景)。都从 SKILL.md 链接。若 reference 更少更聚焦会更好。 |
| Verification | 4 | 第 5 阶段含强制的推前质量评审。第 6 阶段需推送确认。无显式的「所有阶段完成」总结。 |
| Trigger Coverage | 4 | description 遵循三段式。触发短语好:「shipping code」「preparing changes for review」「committing and pushing」「creating pull requests」。 |

### Calculation

```text
(5 × 0.28) + (5 × 0.22) + (3 × 0.17) + (4 × 0.15) + (4 × 0.10) + (4 × 0.08)
= 1.40 + 1.10 + 0.51 + 0.60 + 0.40 + 0.32
= 4.33
```

### Key Takeaway

高效且文档出色,但一个执行破坏性操作(git push、建 PR)的 skill 缺 invocation 控制。加上 `disable-model-invocation: true` 会把 Best Practices 提到 4。

---

## Example 2: Creative Skill (let-fate-decide)

### Assessment Summary

**Skill**: let-fate-decide
**Overall Score**: 4.17 (Good)

### Dimension Scores

| Dimension | Score | Evidence(证据) |
| ---------------- | ----- | --- |
| Effectiveness | 4 | 工作流清晰:用脚本抽牌、读牌文件、解读牌阵。错误处理节应对脚本失败与缺牌。小缺口:无多主题会话的指引。 |
| Clarity | 5 | 组织出众:When to Use / When NOT to Use 表、牌阵位置含义、两个完整示例会话、一张「Rationalizations to Reject」表。有趣且清晰。 |
| Best Practices | 4 | SKILL.md 142 行(在目标内)。经脚本路径隐式使用 `${CLAUDE_SKILL_DIR}` 模式。78 个牌的 asset 文件、1 个解读指南 reference。正确使用 `uv run --script`。 |
| Documentation | 4 | 牌文件在 assets/,解读指南在 references/。牌阵位置在 SKILL.md 有记录。脚本用法清晰。 |
| Verification | 3 | 错误处理节覆盖脚本失败。「Never fake entropy」守则与验证相邻。对解读本身无显式成功标准(本性主观)。 |
| Trigger Coverage | 5 | 触发短语丰富:「let fate decide」「dealer's choice」「surprise me」「heart of the cards」「I'm feeling lucky」。覆盖含糊 prompt、打破平局、游戏王梗。 |

### Calculation

```text
(4 × 0.28) + (5 × 0.22) + (4 × 0.17) + (4 × 0.15) + (3 × 0.10) + (5 × 0.08)
= 1.12 + 1.10 + 0.68 + 0.60 + 0.30 + 0.40
= 4.20
```

### Key Takeaway

一个有创意、结构良好的 skill,示范了如何以恰当的验证预期处理主观输出(塔罗解读)。触发覆盖堪称典范——这就是 description 该如何捕捉多样调用模式的标准。

---

## Example 3: Analysis Skill (tech-debt) (historical — this skill has been removed)

### Assessment Summary

**Skill**: tech-debt
**Overall Score**: 4.77 (Production Ready)

### Dimension Scores

| Dimension | Score | Evidence(证据) |
| ---------------- | ----- | --- |
| Effectiveness | 5 | 四阶段工作流(scan/assess/prioritize/report),带显式的按代码库规模缩放表与边界护栏(空 Glob 结果、子目录范围)。 |
| Clarity | 5 | 通篇术语与表格一致;ROI 框架与行动档位毫不含糊。 |
| Best Practices | 5 | SKILL.md 约 120 行,配 3 个范围得当的 reference 文件,各带 Contents TOC——这个尺寸下正确的渐进式披露。 |
| Documentation | 4 | reference 覆盖债务分类、ROI 评分、一个完整实例,都从 Reference Files 节链接。报告模板的条目表没有一列对应 Assess 步骤要求记录的「周期性成本」字段——采集来的数据在输出里无处落脚。 |
| Verification | 5 | 带必填字段(category、location、risk、effort、tier)的报告模板,充当显式、可检查的输出规范——套用分析型 skill 标准。 |
| Trigger Coverage | 4 | 三段式 description,带具体触发(「auditing debt」「scoping a refactor backlog」);自然同义词「maintenance burden」只出现在正文、不在驱动发现的 description 里。 |

### Calculation

```text
(5 × 0.28) + (5 × 0.22) + (5 × 0.17) + (4 × 0.15) + (5 × 0.10) + (4 × 0.08)
= 1.40 + 1.10 + 0.85 + 0.60 + 0.50 + 0.32
= 4.77
```

### Key Takeaway

每一维都强——唯一的真缺口是报告模板采集了一个字段(周期性成本)却无处渲染,这是一种常见失败模式:工作流中途的一条指令跑赢了本该捕获其结果的输出规范。加一列「Recurring cost」、把「maintenance burden」并进 description,就能到干净的 5。

---

## Scoring Calibration Notes

这些示例展示了打分套路:

| 套路 | 分数影响 |
| -------------------------------------------- | ----------------------------------------------- |
| 有副作用的 skill 缺 invocation 控制 | Best Practices -1 到 -2 |
| 声明只读却无 `allowed-tools` | Best Practices -1 |
| 带同义词的丰富触发短语 | Trigger Coverage 5 |
| 主观输出无验证 | Verification 3(对该类型 skill 恰当) |
| SKILL.md 低于 200 行且有 ref | Best Practices 4–5(视 ref 质量而定) |
| 示例在 SKILL.md 里(不只在 ref) | Clarity +1(帮 Claude 正确执行) |
