# C-01 / C-02 通用房门交接

- 场景：`res://scenes/doors/monster_door.tscn`。Node2D 原点为门底中央，与走廊地面 y 对齐。
- 检查器中的 `room_id` 修改门号，编辑器和运行时均刷新。复制场景实例即可摆多扇门，实例参数互不影响。
- `MonsterPlaceholder` 是由 Polygon2D 组成的独眼占位图，不是正式美术。仅 OPEN 显示；关闭和预警时显示门板。
- C-02 按 CLOSED（5.5 秒）→ WARNING（1.4 秒）→ OPEN（2.8 秒）重复循环。三段时长可在检查器调整，最小按 0.01 秒处理；每门独立计时，保留帧间余量避免累计漂移。
- 只在 GameManager 为 PLAYING 时推进，非游玩状态冻结，编辑器不自动播放。`reset_cycle()` 回到 CLOSED 并重新计时，树暂停时随节点暂停。相位 offset 留待后续任务。
- 门下状态文字用于当前占位验收，WARNING 的醒目视觉预警仍待 C-03，不能据此宣称最终预警完成。
- F6 入口：`res://scenes/tests/doors/doors_test.tscn`，显示 201、202 两个同源实例；A/D 或方向键移动。
- 不调用卡片、失败或输入业务接口，setup、检测、五怪、相位和主游戏接入均未完成。
- A 后续可实例化此场景；本次不接入 main，也不应将它当作已有危险判定的门。
