# 人工试玩bug与Carol／Terese改名验证

2026-11-21；[范围与交接](../../playtest_bugfix_handoff_20261121.md)。用户仅批准修bug及改名，玩法机制提案未实施。未提交／推送。

## 最终结果

- [最新54项矩阵](matrix.json)：原有主线／UI／组件检查，加本轮bug和姓名检查；53项初跑52通过，旧world_interaction前置迁移后实际复查通过，另补姓名专项，最新54项均通过。
- [原始53项结果](matrix_initial.json)及`regression/`保留，未把初跑写成全绿。
- [真实世界交互复查](world_interaction_recheck.log)：保留偷窃取消、模态、清理、交付、通路及回访断言，增加“真实首卡已生效”；移除的是依赖旧bug的额外切空槽操作。
- [正常新局整链](regression/full_mainline_escape_smoke.log)：PASS，真实201—205、302、完整309 CG、403、501和EXIT，未用API代记前序任务。
- [本轮bug检查](regression/playtest_bugfix_smoke.log)：PASS，首卡、剧情核验门Q／装备按钮、安全区操作、403反馈、真实普通门退回、同帧同行、楼梯提示／图层／方向。
- [最终姓名检查](names_final.log)：PASS，实际英文翻译、309数据和带“心想”后缀的怪物对白姓名均一致。
- [原生Compatibility](native_bugfix.log)：PASS；已查看[Carol开场](screenshots/carol_intro.png)、[Terese退回楼梯](screenshots/terese_stairs.png)、[楼梯方向菜单](screenshots/stairs_4f_choices.png)。
- [源码指纹](source_sha256.json)、[画面指纹](screenshots_sha256.json)。测试专用用户目录`ae4pa-playtest-bugfix-20261121`已撤销，用户原project.godot按字节恢复，包含原有aspect差异。

## 先失败后修复

- [初次测试入口错误](initial_test_error.log)：误调普通对白方法导致测试报错；修正为真实开场方法后才使用后续失败结果，不算产品问题。
- [有效bug RED](bugs_red.log)：首卡未生效、角色旧名、剧情核验Q绕过、同行拖尾、楼梯提示和方向。
- [403反馈RED](feedback_403_red.log)、[提示层级RED](stair_feedback_red.log)：任务未满足原因不清、提示被布景遮挡；最终bug检查通过。
- [英文姓名RED](names_red.log)：独立只读复核发现的四处An／An's；修复后实际翻译输出通过。
- [心想姓名RED](name_prefix_red.log)：安（心想）两处遗漏；修复后最终姓名检查通过。

实际Godot为`/Users/xiaxiabao/Downloads/Godot.app/Contents/MacOS/Godot`，4.7.2；回归原命令保留在矩阵中。`--ui-smoke`用于独立组件／界面检查跳过无关开场转场；原正常五怪流程保留其真实新局入口。

## 验证边界

bug专项使用明确的任务前置、位置、门相位与救援回调夹具，验证真实组件和输入，不代记完整真人流程。整链另用真实八任务与309 CG；仍有位置、朝向和任务时钟控制。Windows、真人重测、长时限节奏未由自动化代签。

一次拿三证、双槽减负、204自由顺序、403改交谈领取、身份饰品、解谜和新剧情均未实施。内部`an`／`friend`资源角色ID、Persica节点ID保留，历史记录不改写；玩家实际看到的名字为Carol／Terese。
