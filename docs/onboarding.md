# 组员接入公共底座

公共底座目前可以运行：有主场景、GameManager、CardManager 空数据骨架、主角和测试走廊。B/C/D 的独立测试场景可以加载，但没有员工、房门或正式 UI 功能。所有成员使用 Godot 4.7.2 标准版和同一仓库。

公共底座以云端 main 为共享入口。接入前检查 main 已包含 `scenes/main.tscn`、两个管理器脚本和本文，再把最新 main 同步到自己的分支。具体发布提交与 PR 记录见 [进度文档](progress.md)。

## A 交接前核对

1. 用 Godot 打开项目并按 F5，确认进入公共测试走廊。
2. 左右移动、松键停止、走到两端，核对相机和边界。
3. 核对下表四个独立测试入口，并确认本轮修改文件属于公共底座。
4. 提供底座版本、准确 Godot 版本及已验证／未验证事项，再按团队授权提交、推送和合并。
5. 让 B/C/D 分别完成本机打开与最小提交，D 记录结果。

## B C D 第一次打开

先阅读 [README](../README.md)、[项目主策划](game-design.md)、[开发分工文档 1.0](team-plan.md) 和 [公共接口](interfaces.md)，再按 [环境配置](environment.md) 导入 `project.godot`。首次导入让 Godot 完成资源和 HotelPlayer 类型扫描。

开始修改前检查自己的未提交内容和当前分支，再同步 A 发布的底座。仓库已有 `work/member-1` 至 `work/member-4`，由 A 确认人员对应关系后沿用。同步时先更新 main，再合入自己的分支；逐步操作见 [GitHub 协作指南](github-collaboration-guide.md)。

先按 F5 验证公共走廊，再打开自己的测试场景按 F6。不要新建个人 Godot 项目，不修改 `project.godot` 或 `scenes/main.tscn` 来绕过依赖。

| 成员 | F6 入口 | 开始修改的位置 | 当前骨架提供什么 |
|---|---|---|---|
| A | `scenes/tests/core/core_test.tscn` | `scenes/player/`、`scenes/levels/`、`scripts/game_manager.gd` | 主角、相机、走廊、开发状态显示 |
| B | `scenes/tests/staff/staff_test.tscn` | `scenes/staff/`、`scripts/card_manager.gd` | `StaffSlot` 放员工；主角为 `Corridor/Player` |
| C | `scenes/tests/doors/doors_test.tscn` | `scenes/doors/` | `DoorSlot` 放门；主角为 `Corridor/Player` |
| D | `scenes/tests/ui/ui_test.tscn` | `scenes/ui/` | `UISlot` 是 CanvasLayer，放菜单／HUD／提示等 UI |

各成员也负责自己的测试场景和相邻测试脚本。测试场景中的 slot 位于走廊世界坐标；把组件放入 slot 时先用组件局部原点对齐，避免再重复加一次世界位置。

## 每位成员的第一份交付

B 先交一个会转身、可从背后偷保安卡的 `staff.tscn`，并在现有 CardManager 中实现 `collect_card(card_id)`。只有收集入口完成后，才能验证有卡安全、三卡和装备等行为。现有查询返回副本，当前卡为只读属性；不能通过修改查询结果或给只读属性赋值来准备测试数据。

C 先交一个 `monster_door.tscn`，完成关闭→预警→开启和无卡时独眼客失败。员工和门统一使用 `setup(player: HotelPlayer)` 接收主角；在自己的测试脚本中传入 `Corridor/Player`。有保安卡安全的用例等 B 的收集接口完成后验证，不另造卡片管理器。

D 先交开始菜单、失败界面和操作说明。HUD 可以先显示真实空槽；背包按钮等 B 的接口实现后再启用。主场景中的 DeveloperOverlay 是 A 的临时测试显示，不是 D 的最终 HUD 或菜单。

美术由全员共同选择，分别放入 `assets/final/player/`、`staff/`、`doors/`、`ui/`、`backgrounds/`，由对应使用者接入自己的场景。

## 当前可用与待实现

- 可用：两个 Autoload；GameManager 的新局、失败及状态通知；CardManager 的空数据读取／查询／重置；HotelPlayer 的移动、锁定和世界坐标边界。
- 待 B：收集卡片、Q 切换、装备替换和实际换卡通知。
- 待 C：门计时、五怪规则、预警与检测。
- 待 D：菜单、HUD、背包、手册、对白、失败／结局界面。
- 待 A 接入：楼层切换、重试、309 救援和五楼通关。暂时没有 Retry 按钮或出口交互。

详细签名和阶段见公共接口文档；不要调用尚未实现的方法。背包、暂停和其他详细交互继续在对应功能开发时确认。

## 测试走廊的当前约束

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

## 尚待人工完成

本机代码与场景检查不能替代组员验证。仍需记录 B/C/D 的系统和 Godot 版本、F5/F6 运行结果、最小提交／PR，以及 Windows 试玩和目标平台导出结果。当前尚未安装导出模板或制作导出包。
