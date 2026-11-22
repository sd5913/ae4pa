# C 侧房门交付复核 · 2026-11-22

状态：**交 A 验证，暂不合并**。本轮只添加 C 的复核脚本、日志、截图和交接记录；没有改随机池、统一禁换证、楼层、移动、UI 或游戏机制。

## 实际版本与环境

- 已同步 main：`569b5d0941aaef73a327eaa19def1b0b95bcb798`，个人分支 `work/member-C-yinshiqi`。开始时无已跟踪本地修改；旧未跟踪候选文件保留。
- C 诊断脚本已提交并实际运行：`5bbbe6536eb358618325cf5a3d419b24a7097470`。游戏运行源码保持上述main；图形主线先运行同一基线加当时C检查脚本，提交后的精确版本又做无窗口诊断，分别保留日志，不混记为同一次运行。
- Windows NT 10.0.26300.0；Godot `4.7.2.stable.official.ed1daf0bf`；Compatibility / OpenGL3.3 / NVIDIA546.30 / RTX3070 Laptop GPU；1280×720。
- 顺序：先独立组件自动检查（F6等价），后加载真实 `scenes/main.tscn` 的图形主线（F5等价）。不是人工按F6/F5全程试玩或导出包验收。测试披露位置直设、员工朝向和任务时钟控制，实际取证/工作/交付通过真实输入与组件完成；普通门矩阵使用已解锁/已认识怪物前置，不冒充正常主线解锁。
- 证据目录：[日志与清单](../tests/doors/evidence/c_closeout_20261122/)。`environment.json`含运行源码SHA256。

## TC 状态（原步骤尚缺）

仓库文档及当前《游戏测试.xlsx》没有TC-02/06/16/18原文，已向用户请求原步骤。本轮先按A消息中逐项要求执行替代自动核对，不能将其代记完整原TC或人工通过。

| TC | 本轮替代核对 | 完整原TC状态 |
|---|---|---|
| TC-02 | 二楼201—205固定NOSE/EYE/HAT/EAR/CHECKER、完整预警、OPEN/关闭/重访/交付顺序自动通过；对白中的真实怪物显示有下述失败项 | 未执行完整原步骤；显示缺陷待A/D处理 |
| TC-06 | 关介绍不等于接受，持卡不等于完成，工作未交付仍挡路，真实交付才放行；完成回访不重复首次教学，自动通过 | 未执行完整原步骤/真人复测 |
| TC-16 | 3—5F实际普通房间，三组随机会话；身份、方向、闭门/预警安全、左右退回与重访稳定性自动通过 | 未执行完整原步骤/真人复测 |
| TC-18 | 大耳停步/移动、普通核验切卡退回；剧情205/501仅开门范围拒绝Q/I、安全工作台可换证，自动通过 | 未执行完整原步骤/真人复测 |

## 房门复核表

| 房门 | 核对结果与限制 |
|---|---|
|201—205|首次预警/住客类型/工作/返房交付、提醒与检查点重试通过；完整主线日志检查了201—205实际房门和动画节点。0个被采样快照出现同时WARNING/OPEN多门。对白显示透明问题不能仅凭is_visible_in_tree判通过。|
|302|真实接管理授权，当前经理批准登记即完成；303等普通门违规没有串成302任务。接受后关闭，批准后不重复任务。|
|309|真实36段重逢流程后才has_friend、实际生成Persica并上4F；未做真人连续行走跟随距离/遮挡评估。|
|403|实际接取、背后长按取得巡房文件、READY_TO_SUBMIT后回房交付，才开放5F；文件不是卡。|
|501|实际接取、经理批准、READY_TO_SUBMIT回门打开、交付完成；执行工作时门关闭，不能把“关闭时允许换证”误记为缺陷。|
|205/501核验|在真实开门状态、门中心左35px，Q不改变快照，I拒绝；安全工作台205取物点/501(x760,y560)允许Q切槽及I打开，随后恢复身份。|

### 普通门实际随机记录

不改池、不强制怪物。三组seed仅用于复现会话，换层重建同一房间类型一致。每一行每个seed都检查两侧：NOSE/CLEANER、EYE/SECURITY、HAT/MANAGER，EAR静止/移动，CHECKER不换/切卡。房门检测与实际动画kind一致；关闭/预警没有动画怪物。全部门/动画等比且无负缩放，五种实际渲染截图已查看；头像/帽子/耳朵没有被拉窄。

| 房号 | 20261122 | 20261123 | 20261124 | 双侧违规落点 |
|---|---|---|---|---|
|301|NOSE|NOSE|NOSE|(192,560)|
|303|HAT|CHECKER|HAT|(192,560)|
|304|HAT|HAT|EAR|(192,560)|
|401|CHECKER|EAR|EYE|(192,560)|
|402|EYE|EAR|CHECKER|(192,560)|
|404|EAR|EAR|EAR|(192,560)|
|405|NOSE|CHECKER|CHECKER|(192,560)|
|502|NOSE|EYE|EYE|(192,560)|
|503|HAT|EAR|EAR|(192,560)|

54次实际普通门违规：来向-1/1，起点为门中心x±40、y560；退回均为(192,560)。来源链为 `monster_door.rule_violated → floor._on_door_violation → GameManager.safe_return_started`。退回后PLAYING、pending为空，没有改任务真值。坐标逐条见`ordinary_trace.json`。3层×3会话×400调度tick=3600tick没有同时WARNING/OPEN多门。

## 失败项与交 A 的接线

### C-OBS-01 对白期间实际场景怪物被隐藏（显示失败，D/A确认）

- 复现：正常新局到2F201介绍或201—205交付对白；门OPEN，实际MonsterIdle节点可见标志为true，但`modulate.a=0`，画面只能看到OPEN素材里烘焙的小剪影。205仍能看到礼帽形状剪影，不能用它判断实时核验客。
- 证据：`screenshots_serial/201_intro.png`、`205_delivered.png`；`graphical_trace.json`记录alpha=0，65个采样到的OPEN住客被设透明。普通门无对白截图显示正确动态住客，说明动画绑定正常。
- 实际来源：`scenes/ui/dialogue.gd`中`mute_world_prompts`处理名单包含MonsterIdle并设`modulate.a=0`。该文件属D，C本轮不改。请A/D确认对话时保留场景住客还是接入已发布半身立绘；若采用后者，需D完成头像绑定后再验收。原OPEN静态剪影是已确认素材，C不擅自重绘整套门。

### C-OBS-02 EXIT第一次E未通关（A侧输入/自动夹具兼容，未认定真人卡死）

- 正常主线完成全部八项任务、真实309救援和501交付后，到5F(3400,560)。`can_escape=true`，`interaction_target=EXIT_5F`，任务COMPLETED，门均CLOSED，pending与open_modals均空，Persica节点存在。
- `EXIT_before_real_E`的`needs_e_release=true`；发真实interact按下/松开后，`needs_e_release=false`但game_state仍PLAYING，未见WON。完整状态与世界flags见`main_flow_trace.json`；截图`full_escape.png`。
- 三条正式运行记录在同一最终断言失败：C图形复核、未修改的原`full_mainline_escape_smoke`无窗口对照、提交5bbbe65的C诊断。没有脚本解析错误，不把它们记PASS。
- 需要A检查最后交付对白结束的`_needs_e_release`与E输入交接；原主线测试用`_advance()`直接推进对白，可能缺真实松键，不能据此推断真人必然卡死。请A先修正/确认主线测试输入适配，再决定是否改floor输入。未发现本轮普通门退回或302/403/501许可误串线。

## 实际检查结果

通过：tutorial_catalog、tutorial_lifecycle、v4_doors（600规则矩阵）、v4_identity、known_monster_rules；C ordinary真实门矩阵及3600调度tick；205/501开门区Q/I拒绝与安全区换证；实际302/309/403/501任务段。

失败：图形主线终点WON断言、未改原主线终点WON断言、提交后诊断同一断言；对白中场景住客alpha=0显示项。

未执行：四条原TC完整步骤、真人新局连续操作全通关、另一台电脑/macOS/导出包；所有截图/日志来自本机自动运行。

初轮C夹具曾把205行走右界(x3024.75、距门24px)当安全区、把501执行时CLOSED当OPEN，导致无效断言；已改为真实工作台和501批准后的回门OPEN再测，原失败日志保留为`initial_fixture_*`、`initial_501_closed_fixture_*`，不算产品缺陷。一次并发图形捕获中断保留`interrupted_concurrent_render_*`，随后串行图形跑完；中断不算PASS。

## A 拉取与复测

在个人分支拉取本PR；先运行C组件，再运行两个C脚本。普通门可用`--headless --path . --script res://scenes/tests/doors/c_closeout_ordinary_smoke.gd`，需图形截图时移除headless并追加`-- --capture`。正式诊断入口为`res://scenes/tests/doors/c_closeout_main_flow.gd`，同样支持capture。诊断在现行基线上保留终点失败以便A复现，不能为绿灯改掉真实断言。

本轮没有C运行时逻辑修复：已测C组件未发现需在C范围内改动的行为缺陷；跨模块显示/输入问题明确交A处理。没有擅自统一禁换证、调整随机池、改移动/安全点或重绘确认资源。待A复核和原TC补齐后再决定合并。
