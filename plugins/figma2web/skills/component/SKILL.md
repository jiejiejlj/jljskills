---
name: component
description: 离线扫现有代码(app/src)找可沉淀的重复 / 可复用单元,呈交用户逐个采纳后提炼成共享组件并登记 registry.json;不读 Figma。coding 之后手动 / 按需跑。仅当用户主动用 `/figma2web:component` 指令调用时使用 —— 不要在普通对话里自行触发。
allowed-tools: Read, Grep, Glob, Write, Edit, Bash, AskUserQuestion
disable-model-invocation: true
---

# component — 沉淀共享组件

## 用途
组件库的**生产者 / 管理者**。扫现有代码找可复用的,提炼成共享组件 + 登记 registry,让组件库越用越大。**离线,不读 Figma。**
输入:现有代码(`app/src`)+ `registry.json` +(可选)spec。

核心心法:**绝不臆测、不擅自重构。** 候选逐个呈交用户采纳 / 跳过 / 调整;registry 由本 skill 单写,靠单写 + 与文件系统校验避免漂移。

## 何时运行
仅当用户主动用 `/figma2web:component` 指令调用时运行。`coding` 之后**手动 / 按需**跑(`coding` 只能在输出里提示「建议跑 component」,绝不自动调)。前置:`project.md` 存在;代码目录存在;`registry.json` 存在或初始化(可空)。**不需 figma-mcp。**

## 产物(本 skill 是唯一写者)
- `app/src/components/<Name>` —— 共享组件。
- `app/src/components/registry.json` —— 组件清单(`coding` 只读)。

## 流程骨架
1. **扫描候选**:重复 ≥2 处,或单处但自成一体的可复用单元。
2. **呈交候选清单(HARD GATE)**:逐个采纳 / 跳过 / 调整。
3. **提炼 + 替换**:抽成组件,原页面内局部实现替换为引用。
4. **登记 registry**。
5. **验证 + 小结**:build 通过,报告沉淀了哪些 / 复用率变化。

> 完整分阶段流程、扫描判据与 registry 字段见 [references/flow.md](references/flow.md) —— **动笔前先读它**。

## 红线
- **绝不臆测、不擅自重构**;候选逐个由用户拍板。
- **registry 由本 skill 单写**,`coding` 只读;靠单写 + 文件系统校验避免漂移。
- 提炼后必须把原局部实现**替换为组件引用**,并 **build 通过**(替换没破坏)。
