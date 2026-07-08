# figma-optimize — 设计稿交付前优化

面向设计师的交付前守门: AI 评审 + 用户逐条裁定 + 写回 Figma. 单一 skill `loop-optimize` 共享一套范式: AI 只揪可验证问题, 审美与取值归设计师; 写回前逐条 HARD GATE; 调 `use_figma` 前必先走 `figma-use`.

## 与 figma2web 的分工 (写方向契约)

本插件是体系里**唯一有权写回 Figma** 的一侧: 优化 Figma 原生设计稿, 产物落在 Figma 文件里, **绝不落项目代码** (评审报告仅为可选旁产物). 设计稿转代码归 `figma2web` 插件; 两插件互不依赖, 互不读写产物, **没有管线关系, 只有人的编排** — 不做时序引导, 何时优化, 何时转码由用户自由组织.

## skill 一览

| skill | 评审对象 | 产物 |
| --- | --- | --- |
| `loop-optimize` | 整份 Figma 链接, 自动分诊三类场景 (standard 规范板 / page 界面稿 / component 散件收编) | 写回 Figma + 分阶段报告 + 指纹台账 |

用法: `/figma-optimize:loop-optimize` 贴链接启动; 窄链接 (单 section) = 单阶段.

报告默认落目标项目 `docs/jljskills/figma-optimize/` (可选落盘, 报告阶段可改路径 / 不落盘); 指纹台账 `.loop-optimize-ledger.json` 同落该目录.

外部前置: 官方 `figma` 插件 (Figma MCP; 写回前强制走其 `figma-use` skill).
