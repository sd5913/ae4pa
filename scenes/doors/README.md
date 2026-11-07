# C-01 通用房门交接

- 场景：`res://scenes/doors/monster_door.tscn`。Node2D 原点为门底中央，与走廊地面 y 对齐。
- 检查器中的 `room_id` 修改门号，编辑器和运行时均刷新。复制场景实例即可摆多扇门，实例参数互不影响。
- `MonsterPlaceholder` 是由 Polygon2D 组成的独眼占位图，不是正式美术。C-01 为静态展示，怪物暂时可见；关闭隐藏、预警和开启将由 C-02/C-03 接入。
- F6 入口：`res://scenes/tests/doors/doors_test.tscn`，显示 201、202 两个同源实例；A/D 或方向键移动。
- C-01 不调用卡片、失败或输入业务接口，不提供尚未实现的 setup/reset_cycle。计时、检测、五怪、相位和主游戏接入均未完成。
- A 后续可实例化此场景；本次不接入 main，也不应将它当作已有危险判定的门。
