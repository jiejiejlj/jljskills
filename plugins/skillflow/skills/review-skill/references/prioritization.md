# Prioritization Guide(分级指南)

如何用影响与成本给改进建议指定优先级。

## Impact/Effort Matrix

```text
                    IMPACT
            Low         Medium        High
         ┌──────────┬──────────┬──────────┐
    Low  │   P5     │   P3     │   P1     │
         │ Nice to  │  Quick   │ Do First │
         │  Have    │   Wins   │          │
         ├──────────┼──────────┼──────────┤
E  Med   │   P5     │   P4     │   P2     │
F        │ Nice to  │ Consider │  Plan    │
F        │  Have    │          │ Carefully│
O        ├──────────┼──────────┼──────────┤
R   High │   P5     │   P4     │   P2     │
T        │ Nice to  │ Consider │  Plan    │
         │  Have    │          │ Carefully│
         └──────────┴──────────┴──────────┘
```

## Priority Levels(优先级)

**P1: Do First(先做)**(高影响,低成本)  
影响显著的快赢。<15 分钟完成。例:给 description 加触发短语、修断链、加「何时用」指引。

**P2: Plan Carefully(谋定后动)**(高影响,高成本)  
值得投入但需规划。1 小时以上。例:重构臃肿的 SKILL.md、建完整示例、重写不清的核心指令。

**P3: Quick Wins(快赢)**(中影响,低成本)  
容易且有可见收益。每项 5–15 分钟。可批量做。例:加触发短语变体、修术语不一致、补边界情况示例。

**P4: Consider(斟酌)**(中影响,高成本)  
仔细掂量成本收益。1–4 小时。仅当 P1/P2 已了结才做。例:整篇文档重写、详尽排障指南、可视化图。

**P5: Nice to Have(可有可无)**(低影响,任意成本)  
可无限期搁置的润色。例:完美标题层级、冷僻边界示例、边际收益的优化。

## Assessing Impact(判影响)

- **High**:动到核心功能、防住常见失败、提升可发现性
- **Medium**:改善体验但不根本改变、影响边界情况、提供润色
- **Low**:观感或风格、影响极少用到的特性、个人偏好

## Assessing Effort(判成本)

- **Low**:<15 分钟、只改文本、单文件
- **Medium**:15–60 分钟、多文件、需些调研
- **High**:1 小时以上、大幅重构、多依赖

## Special Cases(特例)

**Dependencies(依赖)**:若某 P3 依赖某 P2,标出来,考虑一起做。

**Quick wins batching(快赢批量)**:许多 P3 合起来可能抵一个 P2 的影响——按势头 vs 单一效果来取舍。

**Diminishing returns(收益递减)**:做完 P1/P2 后重估剩余项。质量可能已经够了。
