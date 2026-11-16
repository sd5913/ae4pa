# C-V4-04／05 与 M1 接入复核（2026-11-13）

## 当前交付范围与真实状态

本轮基线 main b4c57d0，分支 work/member-C-yinshiqi。开工干净，fetch 后无新 main，快进检查无变化。只修改 scenes/doors/ 与 scenes/tests/doors/；不改 A/B/D、主场景、项目设置，不提交／推送／合并。

C-V4-01～03 已通过 PR #12 合并。最新共享 main 已由 A 在 DoorRoot/Room201／Room202 装配真实门并接唯一 E、状态镜像、普通退回，不能再按旧交接的“正式接收方不存在”理解当前版本。旧交接是 11 月 12 日独立交付时的历史记录。

本轮完成 C 的自动复核、可选核验上下文、20 门配置与独立预览。没有完成全队 M1、真实背包联调、五任务主线或真人验收；C-V4-04／05 是组件已具备，正式接入／未决规则仍待 A/B/D。

## 本机入口

- 原 201＋普通门 F6：res://scenes/tests/doors/v4_doors_test.tscn。T／Y 是 TEST DOUBLE，不是正式接取和清理。
- 新五任务门 F6：res://scenes/tests/doors/v4_catalog_preview.tscn。201／202／303／402／503 同源实例；A/D 移动，先接近选中门，T 模拟 ACTIVE、Y 模拟 READY、E 发请求、R 重置镜像。
- 五门预览仅事件／镜像，不含五层主线、任务计时、工作点、路障或安全退回。303 交付按钮仅验证通用组件能力，不表示批准后还必须交付。
- 正式 F5 仍为 main.tscn。当前存在序章／经理／201／普通202，任务面板、污渍接线、正式重试待 A/D；B 的真实快照与清理组件已存在，不能再称 B 尚未交付。
- 本轮不替 A 自动把 202 从 M1 NORMAL 切为任务02 STORY。

## 最新 201 与左右安全点

| 对象 | 当前正式布局 | 核验 |
|---|---|---|
| 201 | x700，NOSE／STORY，TASK_01_CLEAN，story_radius120 | 未接受边界580；接受后可到192楼梯侧及980污渍位 |
| 任务锁 | x1250，玩家中心右界1226 | 清理前后、交付前均由 A 保持；不随门关闭解除 |
| 普通202 | x1550，EYE／NORMAL，radius90 | 门区[1460,1640] |
| 202左安全点 | x1400,y560 | 距门150，比半径多60；大于锁1250；不进入201固定区[580,820] |
| 202右安全点 | x1700,y560 | 距门150；下个203 Marker x2000，若未来半径90仍相隔210 |
| 201占位 | x560／1120 | 不是已验收检查点；560在剧情区左边仅20px，不替 A 声明检查点足够缓冲 |

A 的 safe_return_smoke 已在本机使用真实门验证左右及跨中心来向、无效来源、错误点、跨锁、同帧去重、卸载来源、卡／世界／任务时间保留。测试会直接准备工作结果／活动状态，不能当作完整清理或任务02路线通过。203 目前只是 Marker；未来实例化、半径变化、增加碰撞后须重验。

新增 v4_main_integration_smoke 从真实 F5 场景开始，使用 D 的继续按钮完成序章和经理对白，E 无卡上2F、实际移动到201边界，验证不自动接取／计时、不连播；随后显式 A accept_task API 检查返梯／污渍位／关门不能越锁。瞬移用于缩短路程，不代替真人行走；不假造任务 UI、清理或交付成功。

## C-V4-04：可选背包核验上下文（待 A/D 确认接线）

普通五怪改为要求 GameManager.is_world_input_allowed()，避免仅关闭 physics_process 时 identity_changed 同步回调仍在模态内触发普通退回。真实 Q／装备仍由 B 执行；无效装备、重复装备、显示刷新、collect、restore_snapshot 不新增换卡事件。

新增方法是本轮提案，不是已冻结公共接口；正式主线没有自动调用：

1. A 在打开第一个允许装备的背包前，对当前有效普通 CHECKER 调用 begin_identity_inspection() -> bool。须 OPEN、范围内、来向已知、正常游玩；重复调用不替换原证据。
2. true 时捕获玩家／门位置、进入前来向；B 实际 SWITCH_ACTIVE／EQUIP_CARD（含备用槽）只将 changed 置真，不在冻结期发退回。
3. 门自身周期／剧情触发／交付请求按 is_world_input_allowed 冻结；A/D 仍负责冻结玩家和员工等其他世界对象。组件不接管全局暂停、背包或倒计时。捕获后配置／live相位变化不会消除已记录换装。
4. 最后一个模态释放后、恢复玩家移动前，A 调 end_identity_inspection(true) -> bool。仍有其他模态则 false 并保留上下文，等待正确时序；有真实变更时仅一次 rule_violated，A 沿用自己的 request_safe_return。
5. 失败、换层、重试、背包流程取消、模式配置变更时 A 调 end_identity_inspection(false) 清除证据。换玩家 setup／门卸载也清除。玩家或门移动后不能解析旧快照，返回 false 丢弃。
6. true 仅说明上下文已处理，不代表 A 已安全退回；没有上下文返回 false。普通 pending／finish_safe_return 保护仍沿用。多个普通核验门的选择／优先级和模态关页时序由 A 统一协调。

在 A/B/D 同意这套接法并接入前，真实背包换卡验收仍待完成，不声称暂停换卡已在主线修复。没有 capture 的普通模态只屏蔽 live 报告，不提供冻结期补检。

测试 v4_identity_smoke 使用真实 CardManager（Q处理器、当前槽、备用槽、快照恢复），TEST 适配只模拟模态协调。覆盖双向来向、嵌套模态、取消、位移失效、重复setup、卸载断连、普通模态静默；原 v4_doors_smoke 保留600组五怪矩阵和30组真实身份事件。

## C-V4-05：20 门配置交付

v4_door_catalog.gd 的 get_rows(floor_number=0) 返回副本；configure(door, room, use_trial_timing=true) 显式应用，未知门false，调用方必须在 setup 前配置并连接事件，不在游戏启动时自动改变 A 的场景。

| 楼层 | 普通／剧情类型（带任务者 STORY） |
|---|---|
| 2F | 201 NOSE任务01；202 EYE任务02；203 EAR；204 CHECKER；205 HAT |
| 3F | 301 EYE；302 CHECKER；303 HAT任务03；304 NOSE；305 EAR；309由A/B/D负责救援 |
| 4F | 401 EAR；402 EYE任务04；403 NOSE；404 CHECKER；405 HAT |
| 5F | 501 HAT*；502 NOSE*；503 CHECKER任务05；504 EYE*；505 EAR* |

* 5F四个普通门型沿用仓库策划整合建议，get_rows 标记 proposed=true，尚待 A 确认。303 登记台批准是否直接完成仍是 D-05 待定：目录只提供任务门，不创建新的结算条件。

任务 ID 逐一对照 A task_definitions；任务前置和是否可 offer 必须由 A 校验。门收到 NONE 会请求介绍，不知道前一个任务是否完成，因此 A 必须只对有资格门启用触发，或回传拒绝状态；不要批量装配后把所有门镜像都设 NONE 并称任务顺序已正确。

新试玩参数5／1.5／3秒（总9.5）；use_trial_timing=false 保留5.5／1.4／2.8（总9.7），不改共享 monster_door 默认值。offset 按门序0／2／4／6／8秒；后两门可能初始 WARNING／OPEN，A 必须先摆安全出生点和足够等待区。reset_cycle 重现配置相位，不解除剧情／退回保护。未做人类节奏测量，不把新参数称为更平衡。

### 工作路线／路障要求（待 A 按实际楼层摆放验证）

- 201：接受后能返1F拿保洁、到980污渍、回201；交付才开1250后段。已检查目前边界。
- 202：接受后保安与柜子都在可达侧，取包裹后能返202；只取件不能开后段。未来202改STORY后原普通202安全测试需迁至普通门。
- 303：允许返1F偷经理及到309登记台；不能把登记台锁在救援许可后面。登记结算与救援对白／has_friend分离。
- 402：401教学区在接任务前有停步空间，巡房文件来源在接受后可达侧；拿文件后可返402，交付前后段仍锁。
- 503：前半段登记台可回访，提前装备经理后批准，返回503不需要在危险区换卡；批准与最终交付分离；EXIT另查救援和任务05。
- 所有普通门左右点要求距门中心至少 radius+60；还须检查相邻 NORMAL 半径、STORY固定区、楼梯、工作长按区、路障和整段退回路径。Marker存在／几何不重叠不能代替真实可达测试。
- 当前3F Marker仍为旧门型（301 NOSE／302 EYE／303 CHECKER／304 HAT），不要照旧元数据装配；A参考目录更新。背景3F缺305、5F缺504/505，静态门位与节点不完全一致，正式美术拆层待后续。

## 验证记录

Windows，Godot 4.7.2.stable.official.ed1daf0bf，Compatibility。实际命令：Godot控制台程序 --headless --path . --max-fps 60 --log-file <本机绝对日志路径> --script res://scenes/tests/<脚本>。

最终8项实际通过：v4_doors_smoke、door_cycle_smoke、v4_identity_smoke、v4_catalog_smoke、v4_main_integration_smoke、safe_return_smoke、world_interaction_smoke（60 FPS），foundation_smoke（单独120 FPS），均退出0；日志为 .godot/c-final-<脚本名>.log。不将未运行的旧FAILED脚本记通过。

door_cycle 首轮固定100帧检查失败；进一步记录 observed 发现首次资源加载产生长delta，跳过测试0.1秒的WARNING。现先暖机0.2秒，再最多3秒等待两个实际周期，保留完整状态顺序断言和长帧余量检查，最终连续3次通过；未修改正式周期算法。新增F5检查初轮误用了员工局部坐标，修为global_position后通过；这是测试修正，不是A主线缺陷。

foundation 在8进程并行、60 FPS复测时出现序章未在固定guard内结束及移动失败，按原120 FPS单独重跑通过；A脚本未修改，此处保留时序敏感问题。新catalog检查最初直接引用HotelPlayer类型触发命令行脚本提前编译Autoload依赖，改用Node2D持有真实玩家实例后通过。

初次沙箱编辑器导入遇用户目录／safe-save错误，随后获准执行本机导入成功；部分早期测试日志目录受限但功能断言退出0。最终使用工作区绝对 --log-file 路径，避免相对日志被解析成user://F:。未修改系统权限／编辑器设置。

MCP图形启动五任务门F6及正式F5，Compatibility/NVIDIA运行，两者调试errors=[]后停止；不冒充逐门真人试玩或视觉审阅。

## A/B/D 下一步

- A：审阅上下文两个新增方法；按模态生命周期接线，保留唯一退回协调。接 B 清理／快照恢复、D任务页后共同完成201成功／被抓／超时重试。M1通过后按目录铺后四任务。
- B：保留identity_changed主动动作语义、恢复只发cards_changed；与A确认真实清理结算接收、取消和失败恢复。
- D：真实任务面板／HUD／警告／失败页；冻结背包允许装备时与A使用上下文，关闭最后模态后先解析再放移动，E须松键。
- C：本轮自动证据已补；正式背包接线、五层真实路线／安全点、人工返程／静音预警及正式门美术继续待联调。

本轮提交／推送／提PR由用户决定；不自动发送成员消息。
