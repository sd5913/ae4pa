# 二楼五怪对白接线与差异（D）

最终核对基线：main d0fec0d（含工作期间合入的 PR #47）。原 caf862d 工作目录保留，新目录 ae4pa-monster-dialogue-current／work/member-D-monster-dialogue-current。本轮未修改其他成员管理器；验证时未提交，现按用户授权整理为目标 main 的草稿 PR，实际提交与推送状态以 PR 为准。收尾 Fetch 后 origin/main 仍为 d0fec0d；代码未变，不重复运行已通过的测试。

2026-11-20 合并收尾：用户新授权将 PR #48 合入 main。Fetch 发现 main 已更新至 `147e3ec`（PR #49），本分支合入其角色／工作点美术及交互改动。进度文档保留双方记录；202 保留 D 现场对白显示，并保留 main 的一楼保安取证配置、B 交互和其他主流程。下列旧验证基线作为历史证据，不冒充新合并结果；新增定向回归日志另记。

## 当前配置与本轮方案

| 怪物 | 团队真实配置 | 本轮处理 |
|---|---|---|
| NOSE | 201，TASK_01_CLEAN，1F 保洁，STAIN_201，210 秒，DELIVER | 正式接初见和真实交付成功对白，完整保留原清理、偷证、计时和检查点 |
| EYE | 202，TASK_02_PARCEL；PR #49 将取证保安统一保留在 1F，包裹柜与交付仍在 2F | 复用 A 的 TASK_02_INTRO 入口和完成回调；D 底部逐人对白接任务面板，task_completed 后才播放交付确认；路线和时限由真实任务配置与面板读取 |
| HAT | 首见 302；TASK_03_AUTHORIZE 位于 3F，REGISTER_309，结算 AUTHORIZE | 保留已实现的 309 授权。用户提出的 203 二楼房务申请是不同任务，只有文案预览，不套用 registration_309_approved |
| EAR | 首见 403；4F 巡房记录，HAS_FRIEND 前置 | 新 204“独立污渍＋巡房记录”缺真实双工作合同，只有明确标注的预览 |
| CHECKER | 首见 501；5F 最终离店许可 | 新 205“二楼通行单领取＋批准＋交付”缺独立文件合同，只有预览；不会开放 EXIT 或写救援状态 |

v4_door_catalog 当前 FIRST 为 201=NOSE、202=EYE、302=HAT、403=EAR、501=CHECKER；203—205 仍是 NOSE/EYE 候选池。D 未擅改房号、偷证位置、时限、怪物判定或后续楼层流程。二楼五怪初见的统一迁移需要 A/C 确认并实现。

## 实际接入

- scenes/ui/monster_dialogues.json：五种怪物按用户中文分说话人保存。区分 INTRO、MISSING_CARD、WORK_PENDING、RETURN、DELIVERED、COMPLETED；EAR 另有 CLEAN_ONLY／RECORD_ONLY，CHECKER 另有 PICKUP_ONLY／WRONG_IDENTITY。大耳交付时安说“我可以过去了？”，未假设已救援同行。
- scenes/ui/monster_dialogue.gd：现场底部黄铜面板；E／鼠标一次一拍，完成 dialogue_finished("怪物ID:阶段") 一次。无跳过或自动翻页。
- 只有 NOSE／EYE 可通过运行态 show_dialogue() 调用，阶段必须符合真实任务视图；DELIVERED 必须在 get_completed_task_ids() 中已有对应真实任务。其他新方案运行态拒绝显示成功。
- scenes/ui/task_monster_dialogue.gd：TaskLayer/TaskMonsterDialogue；创建 TaskLayer/MonsterDialogue。只读管理器并显示，不调用 record_work_result、submit_task、resolve_monster_encounter、楼层切换或修改救援。
- 201 在真实 task_offered 后先读初见，再打开原任务面板；重试不重复初见。任务仍由原接受按钮接受并开始原时限。
- 202 保留 A 的 TASK_02_INTRO 入口、_active_dialogue_id 和 _on_dialogue_finished()，只替换显示层；新对白读完才经 A 原回调提供真实任务，不重复弹两套初见。
- 201／202 均监听真实 task_completed 后播放 DELIVERED，完成工作但未交付只显示 RETURN，持有卡和切 Q 不会触发成功。
- 对白结束先由消费者登记下一模态再释放自己的锁；不能清除未处理遇怪请求，不关闭其他页面的模态。
- 回访提醒公开入口：TaskLayer/TaskMonsterDialogue.show_task_reminder(task_id)，支持 TASK_01_CLEAN、TASK_02_PARCEL。只读 get_task_view／get_completed_task_ids／has_card。持卡只选择准备工作提醒，绝不决定结算。
- ACTIVE／COMPLETED 的专用 E 回访事件仍需 A 在实际目标路由接入；D 不轮询自动弹窗、不覆盖 A 的交互优先级。原 A 已有的接触与目标提示保留。

## 给 A 的文件与接口清单

| 文件／节点 | 方法或信号 | 调用范围与责任 |
|---|---|---|
| `scenes/ui/monster_dialogues.json` | `NOSE/EYE/HAT/EAR/CHECKER` 的阶段数据 | 中文文案；新二楼 203／204／205 仅预览，不是已实现任务 |
| `scenes/ui/monster_dialogue.gd`；`TaskLayer/MonsterDialogue` | `show_dialogue(dialogue_id: String) -> bool` | 正式只接 `NOSE:阶段`／`EYE:阶段`，依真实任务状态拒绝无效阶段；`DELIVERED` 要求真实完成记录 |
| 同上 | `dialogue_finished(dialogue_id: String)` | 当前展示结束只发一次；这是对白完成，不能代替任务结算 |
| 同上 | `preview_dialogue(dialogue_id: String) -> bool` | 仅独立文案演示，不触发正式接受任务或放行 |
| `scenes/ui/task_monster_dialogue.gd`；`TaskLayer/TaskMonsterDialogue` | `show_task_reminder(task_id: String = "TASK_01_CLEAN") -> bool` | 待 A 在真实怪物回访事件中调用，支持 `TASK_01_CLEAN`／`TASK_02_PARCEL`；返回 false 时不要伪造成功或清除拦截 |
| `scenes/task_ui.gd` | `_ready()` 注册 D 适配节点 | 订阅真实 `task_offered(task_id)`、`task_completed(task_id)`、`state_changed(state)`；不修改任务事实 |
| `scenes/main.gd` | 现有 `TASK_02_INTRO` 显示分支 | 原 `_active_dialogue_id` 和 `_on_dialogue_finished("TASK_02_INTRO")` 合同保留，D 只替换显示；接受任务、楼层与放行由 A 原逻辑负责 |
| `scenes/tests/ui/monster_dialogue_preview.tscn`、`monster_dialogue_smoke.gd` | F6 预览／自动检查 | 预览标明未接入，不作为正式新任务成功证据 |

只读数据沿用 `GameManager.get_task_view()`、`get_completed_task_ids()`、`can_offer_task(task_id)` 和 `CardManager.has_card(card_id)`；模态沿用 `GameManager.set_modal_open(modal_id, is_open)`。D 不调用 `submit_task()`、`record_work_result()` 或救援／逃脱状态修改。201 原任务、救援和逃脱逻辑保留。

## 未接入的新玩法合同

A/B/C 需要确认：
1. 五怪二楼新房号及顺序，同时保留后续楼层的任务和救援。
2. 新房务申请独立 target ID／批准成果／返回交付；不能借用 309 登记。
3. 204 两个独立成果：另一处清洁完成、保安领取记录。不能引用 stain_201_cleaned，也不能以持双卡或切换次数完成。
4. 205 独立二楼通行单：未领取不能批准；领取检查 active SECURITY、批准检查 active MANAGER，最后真实交付；不能引用 exit_form_approved 或 has_friend。
5. 真实交付失败／成功事件与完成后回访事件。关闭对白不解锁道路，不 resolve 未处理遇怪。保持原耳客／核验规则与模态冻结一致。
6. 新对白暂无英文翻译，本轮不编写未经确认的英文剧情。

## 测试与预览

- F6：scenes/tests/ui/monster_dialogue_preview.tscn。所有五怪各阶段均可预览，界面明确标注“独立文案预览”，不表示新任务已正式接通。
- 新回归：godot --headless --path . --script res://scenes/tests/ui/monster_dialogue_smoke.gd -- --ui-smoke
- 201／202／309 主场景回归保留原断言，增加真实 E 读完新对白；202 的可见性断言指向新显示节点，仍要求原任务 ID 和前置交谈。201 主场景回归通过真实清理组件和 E 交付，但工作证由原测试的 collect_card 夹具准备，不是人工偷证验收。计时和重试另由原任务回归覆盖。
- 新回归用真实 API 准备测试卡片、报告工作、交付，检查状态与 UI 防护；不当作人工清理／偷证记录。图形截图来自真实 main，完整人工主线尚未验收。
- 204／205 的独立标记、先领取后批准、双工作身份实际核验等新玩法尚无可运行合同，标为阻塞；预览不能代替这些测试。
