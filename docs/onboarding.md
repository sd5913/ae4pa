# 组员接入

[项目首页](../README.md) · [文档目录](README.md) · [A/B/C/D 分工](team-plan.md)

## 开始开发

1. 检查当前分支和本地修改，保存手头工作。更新 `main`，再把 `main` 合到自己的功能分支。遇到冲突时按[协作指南](github-collaboration-guide.md)处理。
2. 使用 Godot 4.7.2 标准版导入根目录的 `project.godot`，等待资源和脚本类型扫描。见[环境配置](environment.md)。
3. 按 **F5** 进入正式菜单，使用 `scenes/main.tscn` 验证主流程。打开下表中的场景按 **F6**，可独立检查模块。

| 模块 | 开发测试入口 | 主要范围 |
| --- | --- | --- |
| A · 主线与公共底座 | [201 任务](../scenes/tests/core/task_01_core_test.tscn) · [五层预览](../scenes/tests/core/floors_test.tscn) | `scenes/player/`、`scenes/levels/`、主场景与 GameManager |
| B · 员工与工作证 | [员工测试](../scenes/tests/staff/staff_test.tscn) | `scenes/staff/`、`scenes/work/`、CardManager |
| C · 房门与怪物 | [门组件测试](../scenes/tests/doors/doors_test.tscn) | `scenes/doors/` |
| D · UI 与对白 | [界面测试](../scenes/tests/ui/ui_test.tscn) | `scenes/ui/`、验收和玩家说明 |

测试场景中的组件使用对应 slot，在 slot 的局部原点对齐。开发预览、测试夹具和 F5 真人验收分别写入记录。

## 接线与交接

- 用 [公共接口](interfaces.md) 对齐功能与信号。A 管主线、楼层和检查点，B 管员工、工作点和卡片，C 管房门判定，D 用现有状态更新界面。
- PR 写清修改范围、F5／F6 验证路径、实际结果、依赖模块和剩余事项。真人测试写提交、系统和 Godot 版本，反馈可对照[测试表](../outputs/game-test-20261121/游戏测试.xlsx)。
- 完成首次导入后，可在仓库根目录使用以下底座检查命令。若 Godot 不在 PATH 中，使用本机可执行文件路径。

```sh
godot --headless --path . --script res://scenes/tests/core/foundation_smoke.gd
```

旧公共走廊坐标、早期 A-05 接线和首轮交付约定见[历史接入说明](https://github.com/sd5913/ae4pa/blob/d189e028da4461912b8ebeb6f76b8348f54d6073/docs/onboarding.md)。
