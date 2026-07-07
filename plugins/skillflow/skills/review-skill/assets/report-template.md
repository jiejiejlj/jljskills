# Report Template(报告模板)

review-skill 报告的统一输出格式。三节对应三个阶段。

## Full Report(完整报告)

```markdown
# review-skill: {Name}

**位置:** `{path/to/target}`
**类型:** Skill
**日期:** {YYYY-MM-DD}

---

## Lint

| 检查 | 状态 |
|-------|--------|
| {check name} | {PASS / WARN / FAIL} |
| ... | ... |

**发现:**
- {带 file:line 引用的具体发现}

---

## Score

| 维度 | 权重 | 分数 | 加权 |
|-----------|--------|-------|----------|
| Effectiveness | 28% | {1-5} | {score × 0.28} |
| Clarity | 22% | {1-5} | {score × 0.22} |
| Best Practices | 17% | {1-5} | {score × 0.17} |
| Documentation | 15% | {1-5} | {score × 0.15} |
| Verification | 10% | {1-5} | {score × 0.10} |
| Trigger Coverage | 8% | {1-5} | {score × 0.08} |
| **Total** | | | **{sum}** |

**档位:** {tier name} ({range})

**逐维备注:**
- *{Dimension} ({score}):* {证据与理由}

---

## Improve

| # | 发现 | 维度 | 优先级 | 成本 |
|---|---------|-----------|----------|--------|
| {N} | {finding} | {dimension} | {P1-P5} | {Low/Med/High} |

**{P1} — {发现标题}**
*{Dimension} · {Impact} 影响 · {Effort} 成本*
现状:{现在是什么}
建议:{具体改法}
为什么:{理由}

{...其余建议按优先级...}

---
*报告由 review-skill 生成*
```

## Report Guidelines(报告准则)

1. **Evidence-based(基于证据)**:每个分数都引用行号、文件路径或原文引文
2. **Actionable(可执行)**:改进具体到无需再调研即可实施
3. **Proportional(成比例)**:得 5 分的维度只给证据;1–2 分的给详细分析
4. **P1 first(P1 优先)**:永远把 P1 建议列在 P2、P3 等之前

## Abbreviated Format(精简格式)

跨多个 skill 的批量对比:

```text
{name} — {X.XX} {Tier} — {N} P1s, {N} P3s
```

## Comparison Format(对比格式)

同时评审多个 skill 时:

```markdown
| 名称 | 分数 | 档位 | 最强 | 最弱 |
|------|-------|------|-----------|---------|
| {name} | {X.XX} | {tier} | {dimension} | {dimension} |
```
