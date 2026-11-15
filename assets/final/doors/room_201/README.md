# 201 房间门美术资产

用户提供的三张最终 PNG：`door_closed.png`、`door_warning.png`、`door_open.png`。
原始文件逐字节保留，均为 1280×1280 RGBA；透明边距也是资产的一部分。
预警图警报向外延伸，不能按各张透明内容边界分别裁剪、重设原点或缩放。

## Godot 接入

- 纯美术：拖入 `res://scenes/doors/room_201_art.tscn`，Inspector 的 `state` 或 `set_state("CLOSED" / "WARNING" / "OPEN")` 切换状态。
- 带原有门逻辑：实例化 `res://scenes/doors/room_201_door.tscn`，继承通用门的三状态计时、配置和公开接口。按用途配置 NORMAL／STORY、task_id、monster_type，再由现有 `setup(player)` 接入。图片里的怪物造型不决定玩法类型。
- 美术只有一个 Sprite2D，直接引用完整 Texture2D；不使用 AtlasTexture、region、自动裁边或按 used_rect 取景。
- 统一锚点为源画布底部中心 `(640, 1280)`：Sprite2D `centered=false`、位置 `(-640, -1280)`。原图可见底边在 y1249 附近，透明底边保留，所以可见底边略高于节点原点。
- 默认美术根节点统一等比缩放 `(0.18, 0.18)`，完整画布显示为 230.4×230.4；调整 Art 根节点一次即可，禁止为三个状态分别缩放。预览为统一 0.3 倍，方便查看。
- PNG 导入描述随资产提交；无损压缩、size_limit=0、不生成 mipmaps，保留 alpha。`.godot/` 缓存由各人引擎生成，不提交。

F6 预览入口：`res://scenes/tests/doors/room_201_art_preview.tscn`，三状态并列、同一水平基线。
自动检查：`godot --headless --path . --script res://scenes/tests/doors/room_201_art_smoke.gd`。

主线 2F 的 `DoorRoot/Room201/Door` 现由 `floor.gd` 实例化为 `room_201_door.tscn`，保留原有 STORY／TASK_01_CLEAN／NOSE 配置、位置和信号接线；202 继续使用通用门。门牌 201 和开门怪物已画入 PNG，不适合直接改作其他房号。背景图内原有静态绘制内容仍属于背景素材。
