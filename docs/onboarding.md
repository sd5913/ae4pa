# 组员接入：当前基线与 V4 迁移

本地 A-05 主入口可进入 1F：三员工、真实偷卡和三卡上楼已接入，另有独立五层预览；这些 A-05 改动尚未提交，不保证远端 main 已有相同入口。C 五怪／offset／多门代码已在当前源码中，尚待主线接入；D 正式 UI 仍待交付。所有成员使用 Godot 4.7.2 标准版和同一仓库。

**V4 文档已于 2026-11-11 获用户确认上传；当前游戏仍是旧规则基线。** 共享 main 的 F5／core_test 是公共测试走廊，员工／门用各自 F6；下文 A-05 的 1F 主入口和 staff_floor_smoke 仅在 A 本地未提交版本中，不属于这次文档发布的源码。 新任务依 [ABCD 分工 2.0](team-plan.md)、[PLANS](../PLANS.md) 和 [接口第 13 节](interfaces.md#13-v4-目标接口提案尚未实现)推进，先做 201 闭环。下面的现有 F5／F6 和坐标说明供复用，不要求按旧“三卡上楼／整层失败”继续制作新功能。

公共底座以云端 main 为共享入口。接入前检查 main 已包含 `scenes/main.tscn`、两个管理器脚本和本文，再把最新 main 同步到自己的分支。具体发布提交与 PR 记录见 [进度文档](progress.md)。

## A 交接前核对

A 旧阶段记录见 [A 第 1 周执行与交接](a_week_1.md)；新里程碑与交接顺序以分工 2.0 为准。

1. 用 Godot 打开项目，运行 `scenes/main.tscn`：共享 main 应进入公共测试走廊；只有含 A-05 本地代码的版本才进入 1F 员工测试。Mac 运行当前场景为 Command+R；先双击 `.tscn`，不要只打开 `.gd`。
2. 左右移动、松键停止、走到两端，核对相机和边界。
3. 核对下表四个独立测试入口，并确认本轮修改文件属于公共底座。
4. 提供底座版本、准确 Godot 版本及已验证／未验证事项，再按团队授权提交、推送和合并。
5. 让 B/C/D 分别完成本机打开与最小提交，D 记录结果。

## B C D 第一次打开

先阅读 [README](../README.md)、[项目主策划](game-design.md)、[ABCD 分工 2.0](team-plan.md) 和 [公共接口](interfaces.md)，再按 [环境配置](environment.md) 导入 `project.godot`。首次导入让 Godot 完成资源和 HotelPlayer 类型扫描。

开始修改前检查自己的未提交内容和当前分支，再同步 A 发布的底座。仓库已有 `work/member-1` 至 `work/member-4`，由 A 确认人员对应关系后沿用。同步时先更新 main，再合入自己的分支；逐步操作见 [GitHub 协作指南](github-collaboration-guide.md)。

先按 F5 验证公共走廊，再打开自己的测试场景按 F6。不要新建个人 Godot 项目，不修改 `project.godot` 或 `scenes/main.tscn` 来绕过依赖。

| 成员 | F6 入口 | 开始修改的位置 | 当前骨架提供什么 |
|---|---|---|---|
| A | `scenes/tests/core/core_test.tscn`（继承 main） | `scenes/player/`、`scenes/levels/`、`scripts/game_manager.gd` | 共享 main 为公共走廊；A 本地未提交 A-05 版本有 1F 三员工与三卡上楼 |
| A 五层 | `scenes/tests/core/floors_test.tscn` | 五层场景与 GameManager | 独立换层预览、入口、相机和组件接入位置 |
| B | `scenes/tests/staff/staff_test.tscn` | `scenes/staff/`、`scripts/card_manager.gd` | `StaffSlot` 放员工；主角为 `Corridor/Player` |
| C | `scenes/tests/doors/doors_test.tscn` | `scenes/doors/` | `DoorSlot` 放门；主角为 `Corridor/Player` |
| D | `scenes/tests/ui/ui_test.tscn` | `scenes/ui/` | `UISlot` 是 CanvasLayer，放菜单／HUD／提示等 UI |

各成员也负责自己的测试场景和相邻测试脚本。测试场景中的 slot 位于走廊世界坐标；把组件放入 slot 时先用组件局部原点对齐，避免再重复加一次世界位置。

## 每位成员的下一份 V4 交付

先由 A 冻结 V4-01 的最小接口；下面是未来交付，不表示方法已存在。

| 成员 | M1 最小交付 | 必须交给 A 的信息 |
|---|---|---|
| A | 任务 01 状态／计时／快照、1F↔2F、合法目标与输入协调 | 可用方法、状态恢复顺序、201 与工作／安全点布局 |
| B | 保洁偷卡、正面／回头失败、卡快照、清理工作点 | 配置与 F6、长按取消、成功／失败事件、如何恢复已取状态 |
| C | 201 固定剧情拦截、一扇普通门违规、双向安全点配合 | 普通／剧情模式、来向与退回事件、接取后可达但未交付不开后段 |
| D | 最短经理对白、任务面板／HUD、楼梯列表、警告与任务失败页 | 接受／重试请求、模态关闭规则、真实初始读取与显示 |

B/C 原场景与 `setup(player)` 继续复用，测试准备通过已实现业务接口，不另建假 CardManager。D 的正式按钮只能在对应接口可用后接入；暂存调试数据显示必须标识，不能冒充已通关。全员选定素材后由使用者导入对应 assets/final 目录。

## 当前可用与待实现

- 可用：两个 Autoload；GameManager 新局、失败、五层装载及通知；CardManager 查询／重置／收集／双槽／Q／装备／换卡通知；HotelPlayer 移动、锁定和世界坐标边界。
- B 已交付：员工转身、长按偷取、取消、回头失败、三卡双槽，A-05 已绑定到 1F；正面偷取仅拒绝，用户同意等待 B 后续迭代，未记旧 V3-T01 通过。
- C 已交付：门计时、预警、五怪检测、offset、多门独立测试；普通违规目前仍直接失败，V4 退回／剧情拦截待实现。
- 待 D：菜单、HUD、背包、手册、对白、失败／结局界面。
- A 已实现：主入口的 1F 员工／卡片接入、实际偷卡上楼、跨层保留、五层占位与换层；房门仍待接入。待 A：本层重试、309 救援、五楼通关及 D 界面连接。开发新局清空卡片，不是 Retry。

详细签名和阶段见公共接口文档；不要调用尚未实现的方法。V4 的模态停表已定，暂停换装核验等剩余衔接见改造说明决策表。

## 测试走廊的当前约束（A 本地含 A-05 的旧基线事实）

A 使用 `work/member-A-liuling`。主入口现进入真实 1F；打开 `scenes/tests/core/floors_test.tscn` 按 F6 则额外提供开发跳层。靠近员工背后站定长按 E 0.8 秒取得 ID，三卡齐全后到右端 70 像素内按 E 上 2F，Q 切当前卡，状态显示读取真实双槽。未救援的 3F 仍会拦住上楼，5F 只有 EXIT 占位；本轮不改变 B/C 自己的 F6 入口和原 test_corridor。开发新局可在失败后重新偷三卡，尚未实现本层重试。

五层宽 3600，出生点 `(192, 560)`，行走 x 为 64—3536，相机 x 为 0—3600；均按世界原点放置。`StaffRoot/*Slot` 放员工，`DoorRoot/Room201` 等 Marker2D 放门，组件以局部原点对齐；门标记的 metadata 提供 room_number／monster_type，A 接入 C 组件时写入其公开配置，不自动当作已创建房门。2F—5F 五门 x 为 700、1150、1600、2050、2500，相邻默认检测区间留 270 像素。3F 的 `Interactions/RescuePoint` 为 309 接入位置，所有楼层 `Interactions/ExitPoint` 位于 `(3400, 560)`。

测试走廊宽 2800、高 720，默认出生点为世界坐标 `(192, 560)`，可行走 x 为 64—2736，速度 160 像素／秒。`TestCorridor` 及其父节点保持原点、无旋转、缩放为 1；当前模板的相机和边界按这个摆放方式设置，尚未支持整体偏移后的自动边界换算。

移动原型采用相反方向键抵消、`is_moving` 表示本帧实际横向位移的约定。卡在边界时按住方向键不会报告实际移动；接大耳客时 A/C 再确认是否沿用该行为。非 PLAYING 状态始终禁止移动，单独解除偷窃锁不会绕过失败状态。

## 本机回归入口

打开 `scenes/tests/core/core_test.tscn` 可按 F6 查看。自动检查脚本为 `scenes/tests/core/foundation_smoke.gd`，不需要安装测试插件。

如果 Godot 已在命令行 PATH 中，可在仓库根目录运行：

```sh
godot --headless --path . --script res://scenes/tests/core/foundation_smoke.gd
```

若没有 PATH，使用自己的 Godot 可执行文件路径；PowerShell 使用 `&` 调用带空格的程序路径。首次克隆先在编辑器完成导入，或先用 Godot `--headless --editor --path . --import` 扫描资源和全局类型。

自动检查覆盖底座，不替代 B/C/D 模块验收。上传 PR 时填写：改了哪些文件、如何 F6 运行、调用哪些公共接口、实际测试结果、需要 A 接哪里及未完成项。A 按 B→C→D 顺序接入，每次回归已有行为。

涉及五层流程时另运行 `godot --headless --path . --script res://scenes/tests/core/floor_flow_smoke.gd`。A-05 接入检查使用 `godot --headless --path . --max-fps 120 --script res://scenes/tests/core/staff_floor_smoke.gd`，通过真实 E／Q、Area 检测和长按计时获得三卡，再到出口输入 E 验证上楼；自动检查用重新摆放主角缩短走路，自然转身节奏仍需人工试玩。3F 跨层状态使用已救援夹具，不代表救援功能完成。

## 尚待人工完成

本机代码与场景检查不能替代组员验证。仍需记录 B/C/D 的系统和 Godot 版本、F5/F6 运行结果、最小提交／PR，以及 Windows 试玩和目标平台导出结果。当前尚未安装导出模板或制作导出包。
