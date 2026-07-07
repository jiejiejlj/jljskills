---
name: design-skill-rules
description: skill 写作技艺的判据与词汇库——可预测原则、model/user 调用取舍、信息层级与渐进式披露、引导词、剪枝与五种失败模式。仅当用户主动用 `/skillflow:design-skill-rules` 指令调用、或其他 skill 显式指路 Read 本文件时使用。
allowed-tools: Read
disable-model-invocation: true
---

skill 的存在,是为了从随机系统里拧出确定性。**Predictability**(可预测)——agent 每次运行都走同一套*过程*、而不是产出同一份输出——是根本美德;下文每一根杠杆都服务于它。

**加粗术语**在 [`references/GLOSSARY.md`](references/GLOSSARY.md) 中定义,完整含义去那里查。

## Invocation(调用)

两种选择,各付不同的代价:

- **model-invoked** 的 skill 保留 **description**,于是 agent 能自主触发它、别的 skill 也能够到它(你自己仍可打它的名字调用)。它带来 **context load**——description 每一轮都占在上下文窗口里。做法:省去 `disable-model-invocation`,写一条面向模型、带丰富触发措辞的 description(「当用户想要……、提到……时使用」)。
- **user-invoked** 的 skill 把 description 从 agent 够到范围里剥掉:只有你打它的名字才能调用——别的 skill 都不行。零 context load,但它花的是 **cognitive load**:*你*就是那个必须记得它存在的索引。做法:设 `disable-model-invocation: true`;此时 `description` 变成面向人的一行摘要,触发列表删掉。

只有当 agent 必须自己够到它、或另一个 skill 必须够到它时,才选 model-invocation。若它只会手动触发,就做成 user-invoked,一分 context load 都不付。

当 user-invoked 的 skill 多到记不过来,这堆 cognitive load 由一个 **router skill** 治愈:一个 user-invoked 的 skill,点名其它技能、说明各自何时该够到。

## Writing the description(写 description)

一条 model-invoked 的 **description** 干两件事——说清这 skill 是什么,并列出应当触发它的那些 **branch**(分支)。每个词都在抬高 **context load**,所以 description 比正文更该狠剪:

- **把 skill 的 leading word 前置**——description 正是它施展触发之力的地方。
- **一个 branch 一条触发。** 把同一个 branch 改个说法的同义词就是 **duplication**——「用 TDD 构建功能」和「要求测试先行开发」是同一个 branch 写了两遍。合并它们,只留真正不同的 branch。
- **删掉正文里已有的身份信息。** description 只留触发,外加任何「当另一个 skill 需要……」的够到子句。

## Information hierarchy(信息层级)

一个 skill 由两类内容搭成——**step**(步骤)与 **reference**(参考)——二者自由混合:一个 skill 可以全是 step、全是 reference,或两者都有。核心决策是用哪一类、以及各自落在 **information hierarchy** 的哪一层——这是一把按「agent 多急需这份材料」排序的梯子:

1. **In-skill step**——`SKILL.md` 里的一个有序动作,第一层:agent 按顺序做什么。每个 step 终结于一个 **completion criterion**(完成标准),即告诉 agent 活干完了的条件。把它做得*可检查*(agent 分得清「完成」与「没完成」吗?),并在要紧处做得*穷尽*(「每个改动过的 model 都交代到」,而非「产出一份变更清单」)——含糊的标准会招来 **premature completion**。
2. **In-skill reference**——`SKILL.md` 里的一条定义、规则或事实,按需查阅。常常是一个正当的扁平同级集(一次评审的每条规则都在同一档上)——这是好安排,不是坏味道。*本 skill 就全是 reference。*
3. **External reference**——从 `SKILL.md` 推出去、进入单独文件的 reference,由一个 **context pointer**(上下文指针)够到,只有指针触发时才加载。(涵盖*披露式* reference——一个如 `references/GLOSSARY.md` 的近邻文件,仍属该 skill——一直到完全 **external** 的 reference:后者活在 skill 系统之外、任何 skill 都能指向它。)

一个高要求的 completion criterion 会驱动彻底的 **legwork**(实地功夫)——agent 在活计内部做的挖掘——无论这 skill 有没有 step,因为「每条规则都用上」约束扁平 reference,正如「每一步都做完」约束一段序列。

往下推得太少,顶层就臃肿;推得太多,又藏起了 agent 真正需要的材料。这份张力就是整个决策。

**Progressive disclosure**(渐进式披露)就是沿梯子往下挪的动作——挪出 `SKILL.md`、进入一个被链接的文件——好让顶层保持可读。做法:skill 目录里一个被链接的 `.md` 文件,按它所装的内容命名(本 skill 把完整定义披露到 `references/GLOSSARY.md`)。有些 skill 有不止一种用法,每种不同的用法都是一个 **branch**——不同的运行走过 skill 的不同路径。分支是最干净的披露判据:每个 branch 都需要的就内联,只有部分 branch 才够到的就推到指针后面。一个 **context pointer** 的*措辞*、而非它的目标,决定了 agent 何时、以及多可靠地够到那份材料。

梯子决定一块材料*往下坐多深*,**co-location**(就近同置)则决定它坐下后*旁边挨着什么*:把一个概念的定义、规则、注意事项归在同一个标题下、而非散落各处,这样读到其中一部分就把它的邻居一并带出。

## When to split(何时拆分)

**Granularity**(粒度)是你把 skill 切得多细,而每一刀都花掉两种 load 之一,所以只在这一刀值回票价时才拆。两种切法:

- **按 invocation 切**——当你有一个独特的 **leading word** 应当独自触发它、或另一个 skill 必须够到它时,拆出一个 **model-invoked** skill。你要为那条永远加载的新 **description** 付 **context load**,所以那份独立的够到需求必须值这个价。
- **按 sequence 切**——当仍在前头的步骤(某一步的 **post-completion steps**,即完成后才做的步骤)诱使 agent 草草了结眼前这一步(**premature completion**)时,拆开一串 **step**。把它们移出视野,会鼓励 agent 在当前任务上多下 **legwork**。

## Pruning(剪枝)

让每个含义只有一个 **single source of truth**(单一真相源):一个权威之处,这样改行为就是一处改动。

逐行检查 **relevance**(相关性):它还关乎这 skill 做的事吗?

然后逐句、而不只是逐行地猎杀 **no-op**:对每一句单独跑 no-op 测试,一旦某句没过,就删掉整句、而不是从中删词。要狠——大多数没过的 prose 该删掉,而不是重写。

## Leading words(引导词)

一个 **leading word** 是一个紧凑的概念,它已活在模型的预训练里,agent 运行这 skill 时用它来思考(如 _lesson_、_fog of war_、_tracer bullets_)。它在通篇反复出现(但未必——一个强的 leading word 可能只需出现一次),借调模型已持有的先验,以最少的 token 累积起一份分布式的定义、并锚定一整片行为区域。

它两度服务于可预测。在正文里它锚定*执行*:每次这个词出现,agent 都伸手去做同一种行为。在 description 里它锚定*触发*:当同一个词活在你的 prompt、文档与代码里,agent 就把这份共享语言与该 skill 关联起来、更可靠地触发它。

主动去找机会,把 skill 重构成使用 leading word。一个在三处铺陈开来的三元组(**duplication**)、一条花整句去指涉一个念头的 description——每一处都是一段央求着 **collapse**(塌缩)成单个 token 的文字。例如:

- 「快、确定、低开销」-> _tight_——同一种品质在一个阶段里反复申说——塌缩成一个预训练词(一个 _tight_ 的循环)。
- 「一个你信得过的循环」-> _red_——把一个模糊的闸门变成一个二元可观测状态(循环要么在 bug 上变 _red_,要么不)。

你两头都赢:更少的 token,*而且*给 agent 一个更锋利、可挂住思考的钩子。就当每个 skill 都背着 leading word 能退役掉的重复申说——去把它们找出来。

## Failure modes(失败模式)

用这些来诊断用户在这 skill 上可能遇到的问题。

- **Premature completion**(提前收工)——在一步真正做完之前就结束它,注意力滑向了*已完成*。防御,按顺序来:先磨利 completion criterion(便宜、就地);仅当它无可救药地含糊*且*你观察到了那种赶工,才靠拆分把 post-completion steps 藏起来(sequence 那一刀)。
- **Duplication**(重复)——同一含义出现在不止一处。花掉维护与 token,还把一个含义在梯子上的显要程度抬过了它的真实档次。
- **Sediment**(沉积)——因为「加」感觉安全、「删」感觉有风险而沉淀下来的陈旧层。任何没有剪枝纪律的 skill 的默认归宿。
- **Sprawl**(蔓延)——一个 skill 单纯就是太长,哪怕每一行都鲜活且不重复。它损害可读性与可维护性、浪费 token。解药是那把梯子:把 **reference** 披露到指针后面,并按 **branch** 或 sequence 拆分,让每条路径只背它需要的。
- **No-op**(空操作)——一行模型默认就会遵守的话,于是你付了 load 却什么也没说。测试:它相对默认改变了行为吗?一个弱的 leading word(agent 本就大差不差地 thorough 时还写 _be thorough_)就是 no-op;解法是换个更强的词(_relentless_),而不是换套技巧。
