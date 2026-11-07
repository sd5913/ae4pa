# C-01 至 C-05 通用房门交接

- 场景：`res://scenes/doors/monster_door.tscn`。Node2D 原点为门底中央，与走廊地面 y 对齐。
- 检查器中的 `room_id` 修改门号，编辑器和运行时均刷新。复制场景实例即可摆多扇门，实例参数互不影响。
- `MonsterPlaceholder` 是由 Polygon2D 组成的独眼占位图，不是正式美术。仅 OPEN 显示；关闭和预警时显示门板。
- C-02 按 CLOSED（5.5 秒）→ WARNING（1.4 秒）→ OPEN（2.8 秒）重复循环。三段时长可在检查器调整，最小按 0.01 秒处理；每门独立计时，保留帧间余量避免累计漂移。
- 只在 GameManager 为 PLAYING 时推进，非游玩状态冻结，编辑器不自动播放。`reset_cycle()` 回到 CLOSED 并重新计时，树暂停时随节点暂停。相位 offset 留待后续任务。
- WARNING 时门框交替变色，门上出现“! 即将开门 !”，静音也有文字和闪动提示；只有 OPEN 显示怪物。
- F6 入口：`res://scenes/tests/doors/doors_test.tscn`，显示 201、202 两个同源实例；A/D 或方向键移动。
- A 放置后调用 `setup(player: HotelPlayer)`。检测只在 PLAYING / OPEN 且主角有效时执行；比较 global_position.x，距离 <= radius（默认 90）算范围内，不限制 y，因为本游戏仅水平移动。
- 当前只实现 EYE：读取 CardManager.active_card，只有 SECURITY 安全，否则调用 GameManager.fail("WRONG_CARD")。其他 monster_type 只是预留配置，不代表规则已实现。
- F6 调试键：1 取得并佩戴保安卡，2 取得并佩戴保洁卡，R 新局并重置门；均调用真实 CardManager 接口。屏幕显示当前卡、状态和失败原因，调试键只在独立测试场景使用。
- 自动验证：`--headless --path . --script res://scenes/tests/doors/eye_door_smoke.gd`；循环回归使用相邻 `door_cycle_smoke.gd`。
- 其他四怪、offset、多门错相位和主游戏接入尚未完成。本次不修改 main，交由 A 审查接入。
