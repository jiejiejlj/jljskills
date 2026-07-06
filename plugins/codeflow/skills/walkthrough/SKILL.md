---
name: walkthrough
argument-hint: "[范围或聚焦点]"
allowed-tools:
  - Read
  - Bash
  - Glob
description: 读源码, 产出一份线性, 可执行的走读文档. 适用于讲清代码如何工作, 编写走读, 上手一个项目, 或带人做代码巡览时. 用 showboat 生成带标注代码路径的结构化文档. 仅当用户主动用 `/codeflow:walkthrough` 指令调用时使用.
disable-model-invocation: true
---

读源码, 产出一份线性的 walkthrough —— **边走边跑**: 顺着 call chain 一路走读, 每块代码都真跑一遍, 连 output 一起钉进文档. 用 showboat 在 `docs/jljskills/codeflow/walkthrough/` 下构建这份可执行的 `walkthrough.md`.

## Workflow

1. **读源码** —— 在动笔之前, 先理解 structure, entry points, dependencies 和 data flow. 若给了 scope/focus 参数, 就把源码阅读和覆盖范围限制在那块区域.
2. **规划顺序** —— 决定要讲什么, 按什么次序讲. 从 entry points 出发, 顺着 call chain 走.
3. **初始化** —— 若 `docs/jljskills/codeflow/walkthrough/walkthrough.md` 已存在, 在做任何事之前先问用户: 是覆盖它 (从头开始) 还是续写/扩展现有的那份. 否则运行 `uvx showboat init docs/jljskills/codeflow/walkthrough/walkthrough.md "<Project> Walkthrough"`. 所有 `showboat` 命令都从 repo root 执行 —— `<file>` 用这个相对路径, `exec` 里的源码路径 (如 `src/...`) 才按 repo root 正确解析. 若 `uvx`/`showboat` 缺失或 `init` 失败, 运行 `uvx --from showboat showboat --version` 检查安装, 重试一次; 若仍失败, 告知用户 showboat 不可用, 改为提供一份纯 markdown 的 walkthrough.
4. **构建** —— 交替使用 `showboat note` (讲解) 和 `showboat exec` (代码片段), 线性地走读整个 codebase.
5. **验证** —— `uvx showboat verify docs/jljskills/codeflow/walkthrough/walkthrough.md`, 确认所有 code block 都产出预期输出. 若 verify 报告了 diff, 用 `uvx showboat pop docs/jljskills/codeflow/walkthrough/walkthrough.md` 移除失败的条目, 修正命令, 再用 `showboat exec` 重新加入.

## Walkthrough structure

1. **Overview** —— What the project does, key technologies, entry points
2. **Architecture** —— directory layout, module boundaries, data flow
3. **Core walkthrough** —— 线性地逐段走读代码, 从 entry points 出发, 顺着 call chain 穿过各 modules

## Snippet selection

每个概念展示最重要的 5-20 行. 优先选 function signatures, key logic 和 configuration, 而非 boilerplate. 通过 `showboat exec` 用 `sed -n`, `grep`, `cat` 或类似命令来纳入 snippet. 每个 snippet 都要对得起它占的位置——若它无助于阐明叙述, 就删掉它.

## Example

```bash
uvx showboat note docs/jljskills/codeflow/walkthrough/walkthrough.md <<'EOF'
## Configuration

The app reads config from `config.yaml` at startup. The `load_config`
function validates required fields and falls back to defaults.
EOF

uvx showboat exec docs/jljskills/codeflow/walkthrough/walkthrough.md bash "sed -n '10,25p' src/config.py"
```

这会在 `docs/jljskills/codeflow/walkthrough/walkthrough.md` 中产出下面这个 section:

````markdown
## Configuration

The app reads config from `config.yaml` at startup. The `load_config`
function validates required fields and falls back to defaults.

```bash
sed -n '10,25p' src/config.py
```

```output
def load_config(path: str = "config.yaml") -> Config:
    """Load and validate configuration, applying defaults for missing fields."""
    with open(path) as f:
        raw = yaml.safe_load(f)

    for field in REQUIRED_FIELDS:
        if field not in raw:
            raise ConfigError(f"missing required field: {field}")

    return Config(
        host=raw.get("host", DEFAULT_HOST),
        port=raw.get("port", DEFAULT_PORT),
        debug=raw.get("debug", False),
    )
```
````

## Showboat reference

showboat 的命令签名与坑位见 [`references/showboat.md`](references/showboat.md), 建文档前先过一遍.

## Do not use when

- 审查代码找 bugs 或 design issues — 用 `code-audit` 或 `/code-review`
- 审计 harness customizations — 用 `cc-release-review`
- 审计 CLAUDE.md — 用 `claudemd-audit`