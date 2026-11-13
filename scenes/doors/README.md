# C-01 至 C-13 通用房门交接

> **2026-11-13：** 最新正式接入复核、C-V4-04可选背包核验上下文、C-V4-05全门表和五任务门F6见 [本轮交接](v4_m2_handoff.md)。新F6为 `res://scenes/tests/doors/v4_catalog_preview.tscn`（TEST DOUBLE）；五怪模态内普通检测静默，冻结期补检须A显式接新接口，未自动启用。共享默认周期保留，新目录可选5／1.5／3秒。

> **2026-11-12 V4 迁移：** 当前 NORMAL 门已经改为只报告违规事件，STORY 门提供固定剧情触发与交付请求。下方 V3 的 GameManager.fail／FAILED 说明是历史基线，不能作为当前接入方式；本轮接口、F6、实测和待联调项以 [C-V4-01～03 交接](v4_handoff.md) 为准。旧 V3 失败断言脚本不能直接作为 V4 通过证据，600 组检测和真实核验事件已迁入 v4_doors_smoke。

- 场景：`res://scenes/doors/monster_door.tscn`。Node2D 原点为门底中央，与走廊地面 y 对齐。
- 检查器中的 `room_id` 修改门号，编辑器和运行时均刷新。复制场景实例即可摆多扇门，实例参数互不影响。
- `MonsterPlaceholder` 是由 Polygon2D 组成的独眼占位图，不是正式美术。仅 OPEN 显示；关闭和预警时显示门板。
- C-02 按 CLOSED（5.5 秒）→ WARNING（1.4 秒）→ OPEN（2.8 秒）重复循环。三段时长可在检查器调整，最小按 0.01 秒处理；每门独立计时，保留帧间余量避免累计漂移。
- 只在 GameManager 为 PLAYING 时推进，非游玩状态冻结，编辑器不自动播放，树暂停时随节点暂停。`offset` 是周期已走过的秒数，正值提前、负值绕回；按总周期取模。`reset_cycle()` 回到配置相位，默认 offset=0 才是 CLOSED。修改时长或 offset 后调用 reset_cycle。
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
- 三门入口：`res://scenes/tests/doors/multi_doors_test.tscn`；201 EYE / 202 EAR / 203 CHECKER 位于 x=700/1400/2100，offset=0/2/4 秒，默认都从关闭开始。地面绿带标示 520px 门间安全区，门下带为水平检测区，OPEN 时变红。保留原有 A/D、配卡、Q、R 调试操作。F1～F5 也可将三门统一为选定类型做回归，R 保留类型并恢复配置相位。
- `door_handoff_smoke.gd` 检查七个导出参数、正负/跨周期偏移、重置、改时长、间距、五种起始时间下无卡等待通过、失败事件去重，以及 2F～5F 共 20 个现有标记的组件实例化兼容性。模拟通路使用真实 HotelPlayer 移动方法，但不代替人工试玩或主线验证。
- 五种规则、参数和相位已实现，立绘仍共用占位图并用类型文字区分，生成的美术候选未作为正式素材接入。正式主游戏装配、团队人工试玩、导出与难度调优待 A/D 协作验收。具体复核步骤见 [验收与交接](acceptance.md)。

## A 接入 2F～5F

同一门复用到每层，不能把场景标记当作实际门。下面由 A 在楼层准备阶段调用，不在组件内查找固定主场景路径：

```gdscript
var door_scene: PackedScene = preload("res://scenes/doors/monster_door.tscn")
for index: int in range(floor_instance.get_node("DoorRoot").get_child_count()):
    var slot: Marker2D = floor_instance.get_node("DoorRoot").get_child(index)
    var door = door_scene.instantiate()
    door.room_id = str(slot.get_meta("room_number"))
    door.monster_type = str(slot.get_meta("monster_type"))
    door.radius = 90.0
    door.closed_time = 5.5
    door.warning_time = 1.4
    door.open_time = 2.8
    door.offset = float(index) * 0.8
    slot.add_child(door) # 局部原点，避免重复加一次 slot 的坐标。
    door.setup(floor_instance.get_node("Player"))
```

房号可实时刷新；类型和时长配置修改后调用 reset_cycle 刷新当前状态。三段时长下限按 0.01 秒处理，radius 下限按 0；不使用非有限数值。位置仍由节点决定。

目前 A 的五层标记相邻 450px，默认半径下安全间隙为 270px；扩大半径后必须重新核对，间隙建议至少 120px。初见大耳/核验应单独放置，不与其他门重叠。offset 不是额外等待延迟；示例 0/0.8/1.6/2.4/3.2 均初始关闭。不要将玩家放在初始已开启的错误身份门检测区内。

A 在楼层重试时负责恢复卡片/故事和玩家位置，然后对保留的门调用 reset_cycle；若整层重建，新实例自动应用配置。组件不会重置卡片、换层或替 D 显示失败页。楼层销毁会自动解绑换卡通知；不要将门设为暂停时仍处理。

三个失败标识原样交给 GameManager.fail：WRONG_CARD、MOVED_NEAR_EAR、SWITCHED_NEAR_CHECKER，由 GameManager 去重，D 转成文案。组件不额外发第二套失败事件。
