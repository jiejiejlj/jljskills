# 体系向评审清单

本插件的**核心知识资产**:一份查「标准本身成不成体系」的评审清单,不审具体界面稿,只审设计规范板(variables / text styles)本身。每条建议呈交时含四要素:**问题 / 改法 / 依据(S 编号) / 严重度(高 / 中 / 低)**。

## 维度与检查项

### S-A 变量集合完整性
| 编号 | 检查项 | 严重度 | 判据 |
| --- | --- | --- | --- |
| S-A1 | 色 / 字阶 / 间距 / 圆角某类未成体系或整类缺档 | 高 | `getLocalVariableCollectionsAsync` 遍历 |
| S-A2 | 集合分组 / mode(如明暗)不完整 | 中 | `variable.valuesByMode` |

### S-B token 化纯净度
| 编号 | 检查项 | 严重度 | 判据 |
| --- | --- | --- | --- |
| S-B1 | 规范板内存在游离裸色 / 未绑定值(本该是 token) | 高 | 库变量判据见 figma-facts |
| S-B2 | 库变量被 `get_variable_defs` 误显为裸 hex(勿误判为硬编码) | 中 | 库变量判据见 figma-facts |

### S-C 命名规范
| 编号 | 检查项 | 严重度 | 判据 |
| --- | --- | --- | --- |
| S-C1 | 变量命名无语义 / 层级不清(如 color 1) | 中 | 遍历 `variable.name` |
| S-C2 | 同类命名风格不一致(驼峰 / 斜杠分组混用) | 低 | 遍历 `variable.name` |

### S-D 字阶 & 字体标准
| 编号 | 检查项 | 严重度 | 判据 |
| --- | --- | --- | --- |
| S-D1 | text styles 缺档 / 字号行高不成阶 | 中 | `getLocalTextStylesAsync` |
| S-D2 | 非标字体混入 / 缺失字体 | 中 | `style.fontName` 比对标准字体族;缺失字体用 `listAvailableFontsAsync` 判定(`hasMissingFont` 仅 TextNode 有) |

### S-E 收敛
| 编号 | 检查项 | 严重度 | 判据 |
| --- | --- | --- | --- |
| S-E1 | 重复 / 近似 token 应合并(如两个几乎同色变量) | 中 | 比对 `valuesByMode` 解析值 |

## 严重度默认
- **S-A1(整类缺档)= 高**、**S-B1(游离裸值)= 高**:直接影响开发能否拿到一套可信 token,优先级最高。
- 其余(S-A2 / S-C1 / S-D1 / S-D2 / S-E1)默认 **中**,S-C2 默认 **低**——风格不一致但不阻断可用性。

## 辨 token 的判据(S-B 核心)
判据正文唯一存于 [figma-facts](../../figma-facts/SKILL.md)(flow P1 已装载,本清单不复述)。本清单只定**归档映射**:按 figma-facts 判据辨出的真正游离裸值计 **S-B1**;库变量被误显为裸 hex 的误判风险计 **S-B2**。
