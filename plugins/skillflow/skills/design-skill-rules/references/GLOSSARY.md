# Glossary — Building Great Skills(术语表)

关于「什么让一个 skill 出色」的领域模型。skill 的存在是为了从随机系统里拧出确定性;根本美德是 **Predictability**(可预测),下面每个术语都是作用于它的一根杠杆。本文是 [`design-skill-rules`](../SKILL.md) 的披露式 reference。

术语按轴分组:**Invocation**(一个 skill 如何被够到)、**Information Hierarchy**(它的内容如何编排)、**Steering**(agent 的运行期行为如何被塑形)、**Pruning**(它如何被保持精简)。每个 **failure mode**(失败模式)都挨着治它的那根杠杆,标以 _failure mode_。

任何定义里的**加粗术语**本身都在本术语表里有定义;按它们的标题去找。

## Predictability(可预测)

一个 skill 让 agent 每次运行都以同一*种方式*行事的程度——同一套过程,而非同一份输出(一个头脑风暴 skill 应当*可预测地*发散;它的 token 在变,它的行为不变)。是其它每个术语所服务的根本美德——成本与可维护性是它的症状,而非它的对手。

_避免_:consistency、reliability、robustness、output-determinism

## Invocation(调用)

一个 skill 如何被够到——以及这个选择要你付的两种 load。

### Model-Invoked

一个保留其 **description** 字段的 skill,于是 agent 能看见它、自主触发它——而人仍可打它的名字,所以 model-invocation 总是*包含*用户够到。不存在「仅模型」的状态:一条 description 只会*增加* agent 的发现,从不移除人的。它以每一轮永久的 **context load** 换取这份可发现性。别的 skill 也能够到它,因为让它对 agent 可发现的那条 description 同时让它可被调用。一个内容全是 **reference** 的 model-invoked skill,也是共享 reference 的一个归处:别的 skill 能调用它,于是几个 skill 都需要的 reference 就住在一处。只有当 agent 必须自己够到这个 skill 时才选 model-invocation;若它除了手动从不触发,就删掉 description、一分 context load 都不付。

_避免_:ability、tool、capability

### User-Invoked

一个 **description** 被剥掉的 skill——对 agent 不可见,只有人打它的名字才够得到(user-*only*,而 **model-invoked** 是 user-*and-agent*)。它拿 agent 可发现性换来零 **context load**。因为它没有 description,除了人谁都够不到它:别的 skill 都触发不了它。

_避免_:procedure、workflow、command

### Description

skill 的机器可读触发器,也是一个 **model-invoked** skill 被迫始终加载着的那一个 **context pointer**。它单是存在*就是*调用这根轴:留着它,skill 就是 model-invoked(且别的 skill 够得到);删掉它,skill 就是 **user-invoked**,只有人够得到。一个 model-invoked skill 的 **context load** 之源。

_避免_:frontmatter、summary

### Context Pointer

一个存在 agent 上下文里的引用,它命名某份上下文之外的材料、并编码够到它的条件。**description** 是最顶层的 context pointer(上下文窗口 → skill);指向披露文件的指针是同一个对象、往下一层。它的措辞、而非它的目标,决定 agent *何时*够到——以及*多可靠*。一份必备材料若藏在一个措辞孱弱的指针后面,就是一个方差 bug:先修措辞,只有磨利失败了才把材料内联。

_避免_:link、reference、import

### Context Load

一个 **model-invoked** skill 加在 agent 上下文窗口上的成本——它那条始终加载的 **description**,既花 token 又花注意力。这正是 **user-invoked** skill 因没有 description 而逃开的东西,也是「拆出更多 model-invoked skill」的刹车。

_避免_:token cost、context bloat

### Cognitive Load

一个 **user-invoked** skill 加在人身上的成本——他必须记在脑子里的东西:有哪些 skill、各自何时该够到(人就是那个索引)。这正是 **model-invocation** 靠对 agent 可发现而移除的东西,也是「拆出更多 user-invoked skill」的刹车。它不是一个该被最小化的成本:它是人之能动性的价钱,是某些 skill 保持 user-invoked 的理由。在人的判断要紧处花它;在不要紧处移除它。

_避免_:human index、burden、overhead

### Router Skill

一个 **user-invoked** skill,职责是指向你其它的 user-invoked skill——点名每一个、以及各自何时该够到——好让人只需记住一个 skill、而非许多个。它只能提示、从不能触发它们:user-invoked skill 没有 **description**,所以除了人谁都够不到它们。当 user-invoked skill 增多时,它是 **cognitive load** 的解药。

_避免_:dispatcher、menu、registry、index、router procedure

### Granularity

你把 skill 切得多细。切得越细,就花掉两种 load 之一:更多 **model-invoked** skill 花 **context load**(更多 description 挤占窗口、争夺注意力);更多 **user-invoked** skill 花 **cognitive load**(更多东西要人去记、去够到)。两种切法指导这个划分。按 **invocation**,在你有一个独特的 **leading word** 去触发它——一个你真的会在 prompt 里用的触发词——的地方,拆出一个 model-invoked skill。按 **sequence**,在某一步的 **post-completion steps** 需要藏起来的地方,拆开一串 **step**,因为把它孤立进自己的上下文能清掉其后的东西。当心反向操作:合并序列会把每一步的 post-completion steps 暴露给其后的步骤,招来 premature completion。

_避免_:chunking、modularity

## Information Hierarchy(信息层级)

一个 skill 的内容如何编排,以及每一块在梯子上往下坐多深。

### Information Hierarchy

一个 skill 的内容,按 agent 多急需它来排序——一把梯子,由两刀切出:在文件内还是在指针后,以及是 step 还是 reference。这些梯级:

- **Steps**——文件内,第一层
- **Reference**,文件内——第二层
- **Reference**,已披露——在一个 **context pointer** 后面

一个没有 **step** 的 skill 只用底下两级——常常是一个正当的扁平同级集(如一次评审的每条规则都在同一级),这是好安排,不是坏味道。这套层级与 invocation 无关:一个 skill 无论全是 step、全是 reference 还是两者都有,都可以是 model- 或 user-invoked。当一个 skill 有 step 时,本该披露却留在文件内的 reference 会把它们埋掉、让「留意到它们」变成掷硬币——这是一根方差杠杆,不只是可读性杠杆。让梯子顶端保持可读;凡能往下推的都往下推。

_避免_:structure、organization、layout

### Steps

agent 执行的有序动作——当一个 skill 有它们时,是其内容的第一层,也是够格待在 SKILL.md 里的那部分。并非每个 skill 都有 step:一个 skill 可以全是 step(`tdd`)、全是 **reference**(一次评审)、或两者都有,与 invocation 无关。每个 step 都终结于一个 **completion criterion**,或清晰或含糊。

_避免_:workflow、instructions、choreography

### Reference

agent 按需查阅的材料——定义、事实、参数、示例、条件性指令。当一个 skill 有 **step** 时,它次于 step;当一个 skill 没有 step 时,它就是全部内容;或者它彻底活在任何 skill 之外——见 **External Reference**。经 **context pointer** 够到,也是 **progressive disclosure** 的首选对象。

_避免_:supporting material、docs、background

### External Reference

活在 skill 系统之外的 **reference**——一个普通文件,没有 **description**、没有 **step**、不可被调用——任何 skill 都能指向它。它是那些无需自行触发的共享 reference 的归处,也是两个 **user-invoked** skill 唯一能共用的归处,因为二者都没有 description、于是谁也触发不了谁。

_避免_:doc、resource、knowledge base

### Progressive Disclosure

把 **reference** 沿梯子往下挪——挪出 SKILL.md、藏到一个 **context pointer** 后面——好让顶端保持可读。它主要不是 token 优化;它是 **information hierarchy** 被保护的方式。由 **branch** 授权:只有部分 branch 需要的就披露,每条路径都需要的就内联;若一个指针在必备材料上触发得不可靠,就磨利它的措辞,只有失败了才把它拉回内联。

_避免_:lazy loading、chunking

### Co-location

把 agent 一次需要的材料放在一处——一个概念的定义、规则、注意事项在同一个标题下,而非散落全文——这样读到其中一部分就把它的邻居一并带出。它是 **Information Hierarchy** 在文件内的搭档:层级排定一块*往下坐多深*,co-location 决定它坐下后*旁边挨着什么*。一段 **reference** 该用什么格式,没有公式;判据是,一个 skill 应当读起来像为 agent 写的文档,而归拢的材料读起来就那样、散落的材料则不然。与 **Duplication** 有别:后者把一个含义在两处重复,而散落是把单个含义碎裂到许多处。

_避免_:grouping、clustering、cohesion

### Sprawl

_failure mode。_ 一个单纯就是太长的 skill——SKILL.md 里行数太多——与它们是否陈旧或重复无关。哪怕一个全鲜活、全不重复的 skill 也能 sprawl。它花掉可读性(agent 在能动手之前要蹚过更多,注意力在多余处变薄)、可维护性(每多一行就多一行要保持 **relevant**)、以及 token。解药是 **information hierarchy**:把 **reference** 往下推到 **context pointer** 后面,并按 **branch** 或序列拆分,让每条路径只背它需要的。与 **sediment**(长自陈旧堆积)和 **duplication**(长自重复含义)有别——sprawl 是长度本身,不论其成因。

_避免_:bloat、length、size、verbosity

## Steering(引导)

把 agent 的运行期行为朝 **Predictability** 塑形的那些杠杆。

### Branch

一个 skill 能被调用的一种独特方式——skill 处理的一种情形——于是不同的运行走过它的不同路径。一个有许多 step 的 skill 可能带许多 branch;一个线性的 skill 一个都没有。

_避免_:path、case、fork

### Leading Word

一个紧凑的概念——也叫 _Leitwort_——它已活在模型的预训练里,agent 运行这 skill 时用它来思考。它借调模型已持有的先验,以尽可能少的 token 编码一条行为原则(如 _lesson_、_proximal zone of development_、_fog of war_、_tracer bullets_)。它作为一个 token 反复出现、而从不作为一个句子,在整个 skill 里累积起一份分布式的定义、并锚定一整片行为区域。自己造一个也行——只要你把它定义清楚,但一个生造的词借调不到任何先验——预训练词免费给你的,你得用定义 token 去付。先伸手去够一个已有的词。

一个 leading word 两度服务于 **predictability**。在正文里它锚定 **execution**——每次这个概念出现,agent 都伸手去做同一种行为;在扁平 reference 内部,它把注意力聚焦到一类要留意的东西上,每次运行都招来对的检查。在 **description** 里它锚定 **invocation**——而且不只在 skill 内部:当同一个词活在你的 prompt、你的文档、你的代码库里,agent 就把这份共享语言与该 skill 关联起来、更可靠地触发它。用你真正想要这个 skill 时会用的 leading word 去给 description 措辞。

_避免_:keyword、term、motif

### Completion Criterion

告诉 agent 一个工作单元干完了的条件——它据以判断的目标。两个属性让它成为一根杠杆、而不只是一种品质。它的 **clarity**(清晰度)(agent 分得清「完成」与「没完成」吗?)抵抗 **premature completion**——一个含糊的界(「达成理解」)让 agent 宣布完成、滑向下一步;这根轴需要 *step* 才咬得住,因为 premature completion 是一种步骤之间的失败。它的 **demand**(要求量)设定 **legwork**——「每个改动过的 model 都交代到」逼出彻底的工作,而「产出一份变更清单」不会——这根轴*不*受步骤约束:它也能约束一整片扁平 reference,这正是一个没有 step 的 skill 仍带着穷尽性门槛(「每条规则都用上」)的原因。最强的标准既可检查又穷尽。

_避免_:done condition、exit condition、stopping rule

### Legwork

agent 在单个 step 内幕后做的工作——读文件、探索代码库、做改动、把它需要的东西挖出来、而不是甩给用户。它活在步骤结构之下:从不作为独立的 step 写出来,潜伏在措辞里,由 agent 而非 skill 控制。它是 **post-completion steps** 那种跨步拉力在步内的对应物。由一个 **leading word**(_comprehensive_、_thorough_)、或一个要求工作穷尽的 **completion criterion** 抬升——包括作用于扁平 reference 的 demand 轴,那正是驱使一个全是扁平 reference 的 skill 覆盖它所有梯级的东西。当那份 demand 缺席、或当 **premature completion** 把 step 截短时,它就变薄。

_避免_:scope、effort、diligence、coverage

### Post-Completion Steps

跟在当前 step 之后的那些 **step**。可见时,它们把 agent 往前拉进 **premature completion**——它看见得越多,拉扯越强;防御是靠把步骤序列拆成两段来藏起它们。

_避免_:horizon、fog of war、lookahead

### Premature Completion

_failure mode。_ 在当前 step 真正做完之前就结束它,因为 agent 的注意力滑向了「已完成」而非工作本身。一种步骤之间的失败:它需要有 **step** 才会发生——一个没有 step 却早早收手的 skill,不是 premature completion,而是未满足的 demand 下变薄的 **legwork**。它是两股力量的拉锯:可见的 **post-completion steps**(往前的拉力)与 **completion criterion** 的清晰度(阻力——一道锋利、可检查的界撑得住;含糊的界让步)。含糊是必要条件:一道锋利的界无论后面可见多少步都抵得住拉力,所以一个从不赶工的 step 无需防御。两根杠杆能撑住一个会赶工的 step,但要按顺序伸手:**先磨利那道界**——它就地且便宜。只有当标准无可救药地含糊*且*你真的观察到赶工时,才去**藏起后面的步骤**——而藏只在一道真正的上下文边界上才管用(一次 user-invoked 的交接,或一次子代理派发;一次内联的 model-invoked 调用会把后面的步骤留在上下文里、什么也清不掉)。它是 legwork 变薄的一个成因,但与之有别:哪怕一个 step 跑到完全完成,legwork 也可能是薄的。

_避免_:premature closure、the rush、rushing、shortcutting

## Pruning(剪枝)

把一个 skill 保持精简——每个疗法都配上它所治的那种失败。

### Single Source of Truth

一种理想状态:每个含义恰好住在一个权威之处,于是对 skill 行为的一处改动就是一处改动。**Duplication** 是对它的违反。

_避免_:home、canonical location

### Duplication

_failure mode。_ 同一个含义被给了不止一个 **single source of truth**。它花掉维护(改一处,你必须改其余处)、花掉 token,还抬高显要程度——重复一个含义会把它在梯子上的分量抬过它的真实档次。它是 **leading word** 的无意反面:后者靠重复一个 token、而从不重复含义,来有意抬升注意力。

_避免_:repetition、redundancy

### Relevance

一行是否还关乎这 skill 做的事——决定留什么的透镜。一行失去 relevance,要么因为它从不关乎任务(纯粹的铺陈,或一个本该披露的 **branch**),要么因为它变陈旧:随它所描述的行为或世界改变而过时。更短的 skill 更容易保持 relevant,因为每一行检查起来更便宜。与 **no-op** 有别:relevance 问的是一行是否关乎任务,而非它是否改变行为。

_避免_:load-bearing、staleness、freshness

### Sediment

_failure mode。_ 沉积在一个 skill 里、从未被清走的旧内容层,因为「加」感觉安全、「删」感觉有风险——于是陈旧、不相关的行累积起来,你得往下钻透它们才能找到仍鲜活的东西。任何没有剪枝纪律的 skill 的默认归宿;是 **relevance** 的缓慢侵蚀,与 **duplication** 的重复含义相对。

_避免_:accretion、bloat、cruft、rot

### No-Op

_failure mode。_ 一条什么也不改变的指令,因为模型默认就会那么做——你付了 load,却在告诉 agent 它反正都会做的事。测试:一行相对默认改变了行为吗?一行可以完全 **relevant**、却仍是 no-op。让 **leading word** 免费的那同一批先验,也让一个 no-op 一文不值。

leading word 是一种*技巧*;No-Op 是对一行的一个*裁决*——二者相交。一个弱到打不过默认的 leading word 就是 no-op(agent 本就大差不差地 thorough 时还写 _be thorough_),解法是一个能过裁决的更强的词(_relentless_),而非换套技巧。所以 No-Op 测试——它相对默认改变了行为吗?——也是你评判一个 leading word 是否配得上它那些重复的方式。这是相对模型的、而非相对读者的:两个人争一行是不是 no-op,争的是「默认」是什么,靠运行这 skill 来了断、而非靠辩论。

_避免_:redundant instruction、restating the obvious、belaboring
