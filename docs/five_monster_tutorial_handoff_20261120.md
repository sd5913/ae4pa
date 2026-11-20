# A／B／C接续D：二楼五怪主流程

开发分支：`work/member-A-five-monster-tutorial`；基线 `main@a802721`，已包含D `work/member-D-monster-dialogue-current@0ce69db`／PR48与B PR49。按2026-11-20本轮用户明确配置整合；只更新PR，不合入main。

## 真实合同与位置

| 房间／怪物 | 接取任务 | 工作与当前身份 | 真实成果／交付 |
|---|---|---|---|
| 201／NOSE | TASK_01_CLEAN，210秒 | 1F保洁取证 → CLEANER清理原STAIN_201 | 原stain_201_cleaned → 回201交付；保留已有链路 |
| 202／EYE | TASK_02_PARCEL，180秒 | 最新配置保安在1F → SECURITY领取原包裹柜 | 原parcel_collected → 回202交付；复用D真实成功对白 |
| 203／HAT | TASK_T03_ROOM_SERVICE，240秒 | 1F经理取证、I装备／Q当前MANAGER → 2F房务登记台x1650 | room_service_203_approved → 回203交付、passage_203_unlocked |
| 204／EAR | TASK_T04_DUAL_WORK，210秒 | 双槽CLEANER＋SECURITY；CLEANER长按清理x2120独立污渍 → SECURITY领取x2280资料柜 | stain_204_cleaned＋tutorial_patrol_collected → 回204交付、passage_204_unlocked |
| 205／CHECKER | TASK_T05_TRANSIT，210秒 | 双槽SECURITY＋MANAGER；SECURITY领取x2690待审通行单 → MANAGER批准x2820登记台 | transit_205_collected＋transit_205_approved → 回205交付、passage_205_unlocked |

后三项时限是可调试用初值，尚未做真人节奏校准。文件成果仍由GameManager保存，不新增通用物品背包。每个工作核验当前身份、指定装备槽、真实来源、楼层、顺序、活动任务、模态及剩余时间；B组件执行动作、A接收真实work_requested后结算。持卡、Q或结束对白都不会完成工作。

201／202保留原清理／包裹交付路障。203—205工作均在对应房门前侧，接受到READY仍限制玩家在门前，不能走过去；真实E交付才解除该门限制。检查点位于各门危险范围外：203 x1750、204 x2300、205 x2890，y560。重试回当前任务接受前、时间0，恢复当时证件／装备，撤销本任务所有成果，前序成果保留。

## 分工及文件边界

- A：`scripts/task_definitions.gd`／`game_manager.gd`、`scenes/main.gd`／`task_ui.gd`、`scenes/levels/floor.gd`／`floor_2.tscn`、公共接线与回归。
- B独立子任务：只新增`scenes/work/room_service_203.tscn`、`stain_204.tscn`、`patrol_cabinet_204.tscn`、`transit_pickup_205.tscn`、`transit_register_205.tscn`及独立工作点测试。复用既有CleaningSpot，未改B内部脚本、CardManager或员工配置。
- C独立子任务：只改`scenes/doors/v4_door_catalog.gd`及独立目录测试；FIRST固定201—205，后续普通门五怪会话内随机，未改检测／单门调度内部。
- D：保留现有`monster_dialogues.json`文案和`MonsterDialogue`面板；A本次授权下最小扩展两个适配脚本及HUD读取字段，不另建对白UI。不向真人队友发送消息。

## D对白接线

沿用`TaskLayer/TaskMonsterDialogue.show_task_reminder(task_id)`；201／202原路径不重做，203—205经真实offer先显示INTRO再显示原任务面板。当前活动任务／已完成任务的房门E分别显示缺证／缺指定装备槽、未工作／部分工作和完成回访；READY时E直接尝试真实交付。`phase_for_task()`另提供RETURN待交付阶段，HUD同时显示返房目标。EAR的CLEAN_ONLY、CHECKER的WRONG_IDENTITY／PICKUP_ONLY依真实成果选择。RECORD_ONLY保留作为防护读态，正常流程不允许先取记录。

`DELIVERED`只允许已有真实completed记录；面板结束信号不调用工作、交付或解除拦截。后续任务的计时、详情、HUD和重试房号均按当前任务读取。

新D怪物剧情及新增教学UI以中文接入，未完成完整英文交付／验收。既有序章／309及旧有非剧情英文UI继续回归；语言切换不重置D当前中文对白。字体沿现有OFL Noto子集补字，不加入完整字体或构建依赖。

## 后续主线与怪物规则

- 205真实交付后才允许2F→3F。302仍有独立TASK_03_AUTHORIZE／REGISTER_309；当前MANAGER批准即结算、停表，保持registration_309_approved及309视觉。公共房门元数据也返回HAT／该独立任务；不是重复初见教学，不要求再取已有经理证。
- 原403／501不再列FIRST；后续巡房／最终离店任务定义与救援前置仍保留。新203不写309登记，新204不借201污渍，新205不写exit_form_approved、has_friend或EXIT。
- 309完整救援对白与跟随仍未交付，正式入口继续门控。救援完成后1F／2F封锁策略、后续离店条件保持。
- 后续普通大耳门开时不能移动；停止后解除该次请求，等待关门再走。核验门开且范围内Q仍产生违规；退到范围外清除重试请求。完成205后的同类请求也必须可恢复，不能带往三楼卡住302。
- 仅未退离的SWITCHED_NEAR_CHECKER请求阻止换层；其他首次任务请求不妨碍为当前任务合法返回1F。背包模态内的核验换装备检查仍沿用原组件边界，本轮不宣称全部暂停换装核验已完成。205工作台与换证位置均在门半径外。

## 验证入口与限制

主场景回归：`godot --headless --path . --script res://scenes/tests/core/five_monster_main_flow_smoke.gd`。`-- --capture`使用真实Compatibility画面保存主场景证据，区别于D独立对白预览。脚本从正常菜单／序章／经理交谈开始，经真实员工偷证、真实B工作与E交付依次201—205；位置、面向／怀疑阶段及任务时钟有显式确定性夹具，不代记真人通关或实际240／210秒等待。

定向套件、先红后绿、独立评审修复、源文件指纹及截图索引见[证据目录](qa_evidence/a_five_monster_20261120/README.md)。旧309回归使用单列`tutorial_test_setup.gd`的API前置夹具，部分故意恢复旧双卡布局以保留缺经理证／偷证恢复边界；它不作为新五怪正式流程证据。

尚未完成：真人五怪验收／时限校准、Windows、完整309救援／跟随、正式04／05与最终逃脱。201原真人六项和202成功／超时结果保留，不迁移为新任务人工通过。
