# C-01 至 C-08 通用房门交接

- 场景：`res://scenes/doors/monster_door.tscn`。Node2D 原点为门底中央，与走廊地面 y 对齐。
- 检查器中的 `room_id` 修改门号，编辑器和运行时均刷新。复制场景实例即可摆多扇门，实例参数互不影响。
- `MonsterPlaceholder` 是由 Polygon2D 组成的独眼占位图，不是正式美术。仅 OPEN 显示；关闭和预警时显示门板。
- C-02 按 CLOSED（5.5 秒）→ WARNING（1.4 秒）→ OPEN（2.8 秒）重复循环。三段时长可在检查器调整，最小按 0.01 秒处理；每门独立计时，保留帧间余量避免累计漂移。
- 只在 GameManager 为 PLAYING 时推进，非游玩状态冻结，编辑器不自动播放。`reset_cycle()` 回到 CLOSED 并重新计时，树暂停时随节点暂停。相位 offset 留待后续任务。
- WARNING 时门框交替变色，门上出现“! 即将开门 !”，静音也有文字和闪动提示；只有 OPEN 显示怪物。
- F6 入口：`res://scenes/tests/doors/doors_test.tscn`，显示 201、202 两个同源实例；A/D 或方向键移动。
- A 放置后调用 `setup(player: HotelPlayer)`。检测只在 PLAYING / OPEN 且主角有效时执行；比较 global_position.x，距离 <= radius（默认 90）算范围内，不限制 y，因为本游戏仅水平移动。
- EYE / NOSE / HAT 共用身份表，分别要求当前 SECURITY / CLEANER / MANAGER，否则上报 WRONG_CARD。仅拥有卡但未佩戴为当前卡仍不安全。
- EAR 读取 HotelPlayer.is_moving，移动上报 MOVED_NEAR_EAR，停步安全，任何卡均不能保护；门的 process_physics_priority 为 1，晚于默认优先级的 Player 更新，沿用 A 的实际位移约定（反向键抵消、边界无位移安全）。
- CHECKER 仅同步监听 CardManager.identity_changed 的 SWITCH_ACTIVE / EQUIP_CARD，符合检测条件时报 SWITCHED_NEAR_CHECKER，包括备用槽装备。走路、收集、cards_changed、无效/重复装备不作为换卡；空槽切换按 B 当前真实信号处理，不额外修改其规则。
- setup 重复调用不重复订阅，退出场景树即断开通知；没有有效主角、非 PLAYING、树暂停时不检测。reset_cycle 不清除绑定。
- F6 调试键：F1～F5 将两扇门切为独眼/长鼻/礼帽/大耳/核验并重置周期；1/2/3 取得并佩戴保安/保洁/经理卡，4 装备经理卡到备用槽，Q 沿用 B 的切卡入口，R 新局并重置门。均调用真实 CardManager 接口。屏幕显示当前卡、状态和失败原因，调试键只在独立测试场景使用。
- 自动验证：`--headless --path . --script res://scenes/tests/doors/eye_door_smoke.gd`；循环回归使用相邻 `door_cycle_smoke.gd`。
- 新规则检查：`--headless --path . --script res://scenes/tests/doors/monster_rules_smoke.gd`，包含五怪状态/范围/卡片/移动矩阵和真实换卡通知检查。
- 五种规则已实现，立绘仍共用占位图并用类型文字区分，生成的美术候选未作为正式素材接入。offset、多门错相位与安全区、主游戏接入和 C-12 完整人工回归尚未完成；由 A 审查接入。
