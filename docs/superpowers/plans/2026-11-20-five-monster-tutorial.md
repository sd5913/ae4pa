# 二楼五怪主流程整合计划

> **For agentic workers:** 使用 superpowers:executing-plans 连续执行；B/C独立文件按 dispatching-parallel-agents 并行，主场景与管理器仅A修改。

**Goal:** 正常新局依次完成201—205的真实工作与回房交付，五怪初见均在2F。
**Architecture:** 保留01／02及后续03／04／05故事任务；新增三个独立二楼教学任务。GameManager统一维护步骤成果／资格／倒计时／恢复；B的CleaningSpot执行真实工作，C目录确定首次房门，复用D怪物对白面板。持卡、切卡、对白结束不结算任务。
**Tech Stack:** Godot4.7.2、GDScript、Compatibility。
**Spec:** 本轮用户明确的201—205流程及docs/monster_task_dialogue_handoff.md（最新main a802721已包含D 0ce69db和B PR49）。本计划直接执行已授权接线，不重新要求审批。

## Global Constraints
- 保安取证位于最新1F；经理证首次在203任务取得。01／02已验证链路保留。
- 203 TASK_T03_ROOM_SERVICE／ROOM_SERVICE_203／room_service_203_approved，回203交付；不得写registration_309_approved。
- 204 TASK_T04_DUAL_WORK：STAIN_204／stain_204_cleaned，PATROL_CABINET_204／tutorial_patrol_collected；前者CLEANER、后者SECURITY且先清理。不得复用STAIN_201。
- 205 TASK_T05_TRANSIT：TRANSIT_PICKUP_205／transit_205_collected，TRANSIT_REGISTER_205／transit_205_approved；SECURITY领取后MANAGER批准，最后回205。不得写exit_form_approved／has_friend。
- 三个教学任务暂沿240／210／210秒可调初值；并非节奏或真人验收。两身份任务工作时当前卡必须正确且双槽装备指定卡组，成果分别核验。
- 205工作点与换证安全位均在核验门radius外。任务门仅交付后开放；普通后续怪物检测规则保留。
- 完成205才上3F；302保留独立309登记任务，403／501保留后续用途但不再first。309与EXIT条件不变。
- 不合并main。完成验证后提交个人分支并更新PR；原工作区未提交配置与资源保留。

## Review Focus
- 任一阶段结束对白或Q切换不会移除任务路障；READY仍要真实E交付。
- 204完成201或仅一个新工作不能交付，205未领取不能批准。
- 备用／仅收藏正确卡不能工作；工作事件拒绝旧楼层／错误来源。
- 超时／被抓恢复当前任务全部新增成果，保留前序任务与卡／通路。
- 完成回访和后来随机重遇不能重复教学、结算或干扰309／EXIT。

## Tasks
### 1 数据与工作合同（A，B独立场景，C独立目录）
- [x] 新core测试：203独立批准但不放行、204／205错误身份／双成果／顺序／交付／前序保留；先运行记录RED。
- [x] A修改scripts/task_definitions.gd、game_manager.gd，新增work_steps只在这些任务使用，既有01—03合同兼容；开放定义化步骤视图与独立成果读取。
- [x] B只新增五个scenes/work场景与staff/tutorial_workpoints_smoke.gd；C只改v4_door_catalog.gd及doors/tutorial_catalog_smoke.gd。A不编辑这些文件。
- [x] 运行新core、B独立工作、C目录和foundation，用真实输出记GREEN。
### 2 正式主场景、路障与D对白（A）
- [x] 新main测试从菜单开始，通过实际经理谈话／楼梯／工作组件／E交付依次201—205，先记录RED。位置／面向／门相位可固定，不能用伪工作结果替代后三项。
- [x] A修改floor.gd／floor_2.tscn：独立工作点／安全点、单一E优先级、逐门路线、动态检查点、提醒；D适配扩支持HAT/EAR/CHECKER并只读真实成果选阶段。
- [x] main/task_ui/HUD读取当前任务目标／卡组／重试房号，不再默认201。新剧情中文沿用D，暂无英文剧情不虚构译审。
- [x] 验证缺证、错身份、单步骤、未交付、超时／被抓重试、完成回访；03原309批准链更新前置但保留其结算断言。
### 3 回归、记录与PR
- [x] 定向底座、01／02／03、检查点、门、D面板、英文旧页面回归；真实主场景原生截图，不以预览冒充。
- [x] 更新接口、教学配置、交接、进度和QA，区分自动／夹具／真人／平台限制。
- [x] 一次独立全分支评审，重要问题已修复并复测。

交付结果：个人分支已推送并创建[PR #50](https://github.com/sd5913/ae4pa/pull/50)，保持未合并。

执行记录：冻结版本38/38＋原生新局链路通过；独立评审发现的问题已补RED→GREEN。时限及独立教学ID属于本计划明示实施选择；原先双卡／五层规则按本轮用户明确配置，不另推断人工验收。PR结果另以GitHub为准，未合main。
