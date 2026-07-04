# component 详细流程

库的生产者 / 管理者;`coding` 之后手动 / 按需跑。**离线,不读 Figma。**
输入:现有代码(`app/src`)+ `registry.json` +(可选)spec。

## 调用时机
手动 / 按需。`coding` 可在输出里**提示**「此处有重复,建议跑 component」,但**绝不自动调用**(孤岛)。

## P0 — 前置校验
`docs/jljskills/figma2web/project.md` 存在;代码目录存在;`registry.json` 存在或初始化(可空)。**不需 figma-mcp。**

## P1 — 扫描候选(判据)
扫 `app/src` 找候选:
- 结构 + 样式高度相似地**重复 ≥2 处**;或
- **单处但自成一体的可复用单元**(如本是 Figma 实例、`coding` 当时写成了局部)。

## P2 — 呈交候选清单(HARD GATE)
候选(重复出现处、建议组件名、props 摘要、涉及文件)呈交用户逐个**采纳 / 跳过 / 调整**。**绝不臆测、不擅自重构。**

## P3 — 提炼 + 替换
采纳项抽成 `app/src/components/<Name>`;把原页面内局部实现**替换为对该组件的引用**。

## P4 — 登记 registry
写 / 更新 `registry.json`,字段:
`组件名 | 路径 | 用途 | props 摘要 | 对应 Figma 节点 | 预览截图`。

「对应 Figma 节点」尽量**回溯 spec 的组件实例标识**;回溯不到则标「代码沉淀,无单一 Figma 节点」。

> **registry 由 `component` 单写、`coding` 只读**,靠单写 + 与文件系统校验避免漂移。

## P5 — 验证 + 小结
`build` 通过(替换没破坏);报告沉淀了哪些、复用率变化。

## 完成标志
采纳的组件已提炼、替换、登记;build 通过。

---

## `registry.json` 结构示例
```json
{
  "components": [
    {
      "name": "PrimaryButton",
      "path": "app/src/components/PrimaryButton",
      "purpose": "主操作按钮",
      "props": "label, onClick, disabled",
      "figmaNode": "Button/Primary",
      "preview": "docs/jljskills/figma2web/assets/_components/PrimaryButton.png"
    }
  ]
}
```
