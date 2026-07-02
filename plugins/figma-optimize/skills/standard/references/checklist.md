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
| S-B1 | 规范板内存在游离裸色 / 未绑定值(本该是 token) | 高 | `fills[].boundVariables` 为空即裸值 |
| S-B2 | 库变量被 `get_variable_defs` 误显为裸 hex(勿误判为硬编码) | 中 | 用 `boundVariables` + `getVariableByIdAsync` 辨别 |

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

## 辨 token 的判据说明(S-B 核心)
- `get_variable_defs` 是**展示层快览工具**,会把**库变量(跨文件引用的共享变量)**摊平显示成「名 = 值」的裸 hex,数值上和真正的硬编码裸色**长得一模一样**。
- 判断某处是否已 token 化,唯一可靠依据是节点 / 样式属性上的 **`boundVariables`**:有 `boundVariables.color`(或对应属性)即已绑定变量,已 token 化;为空才是真正需要计入 S-B1 的裸值。
- 若需要进一步核实该变量本身的解析值(如按 mode 取浅色 / 深色下的具体色值),用 `getVariableByIdAsync(id)` 取到变量对象后读 `.valuesByMode`。
- 一律不要仅凭 `get_variable_defs` 的展示值下「硬编码」结论。
