# D 交付收尾复测证据（2026-11-22）

## 基线与环境

- 工作区：`ae4pa-d-delivery-closeout`；分支：`work/member-D-delivery-closeout`。
- 用户提供的 main SHA 为 `ea717f562b110b74bab4b54fdfad32f8e867dccb`，本机缓存 `origin/main` 与之完全一致。`git fetch origin` 及 `git ls-remote origin refs/heads/main` 均因无法连接 `github.com:443` 失败，故远端状态未能独立刷新。
- 本地已把缓存的 `origin/main` 合入 D 分支，合并提交 `6fde88e940b9eb61920c6ff4457c90f50db37f10`，无冲突；合并树保留 main 的 A/B 规则和员工反馈更新。所有合并前 314 个未跟踪条目保留。
- 实测代码提交：`6fde88e940b9eb61920c6ff4457c90f50db37f10`。Godot：`C:\Users\lenovo\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`，版本 `4.7.2.stable.official.ed1daf0bf`。测试使用隔离临时用户配置。根证书读取错误未阻断通过的项目。

## 测试结果

| 检查 | 结果 | 证据 |
|---|---|---|
| Godot headless editor import | PASS，退出码 0 | [import.log](logs/import.log) |
| 本地化回归 | PASS，退出码 0 | [localization.log](logs/localization.log) |
| 后段流程中文 | PASS，退出码 0 | [late_mainline_zh.log](logs/late_mainline_zh.log) |
| 后段流程英文 | PASS，退出码 0 | [late_mainline_en.log](logs/late_mainline_en.log) |
| HUD 图形布局 | PASS，退出码 0 | [hud_layout.log](logs/hud_layout.log) |
| 任务 UI smoke | FAIL，退出码 3 | [task_ui_smoke.log](logs/task_ui_smoke.log)：空 OwnedCards 列表造成取图标／选择索引越界；随后当前楼层缺少 `Interactions/Stain201Slot/CleaningSpot`。未删除或放宽断言。 |
| 完整新局自动通关 | FAIL，退出码 1 | [full_mainline_escape.log](logs/full_mainline_escape.log)：最终“八任务／309／EXIT”断言失败；日志另输出 `ROOM_SERVICE_203`、`TRANSIT_REGISTER_205` 为 `TASK_INACTIVE`。不计为通关通过。 |
| 中文正式主场景截图 | PASS，图形流程退出码 0 | [截图](screenshots/zh1280/) |
| 英文正式主场景截图 | PASS，图形流程退出码 0 | [截图](screenshots/en960/) |
| HUD 多分辨率／界面截图 | PASS，来自 HUD 图形回归 | [截图](screenshots/hud/) |

Godot 有一次用 `--quit-after 5` 的试运行中止了扫描线程，该次没有作为通过结果；最终资源导入采用 `--headless --editor --path . --import` 并完整退出 0。

## 403 巡房提示重叠

正式场景截图仍显示提示靠近巡逻员工和房门区域。提示来源为 A 的 `scenes/levels/floor.gd`（包括约第 674 行的世界标签）；员工领取反馈来自 B 的 `scenes/staff/staff.gd` 和 `scenes/staff/patrol_staff_4f.tscn`。本分支未改这两个模块：请 A 调整／本地化楼层提示，B 调整员工反馈位置。

## 未执行项

- TC-11、TC-14 的人工新局路线未执行；自动化准备状态不能代替人工验收。
- 多人同提交 TC-01—11／TC-20、两位组员八个任务的真实用时及暂停时间未采集。
- Windows／macOS／导出构建验证未执行。
- 1–3 分钟真实演示视频及署名材料未制作。截图来自自动化在正式主场景中的运行，不是人工完整试玩或导出包。

A 可从 `scenes/main.tscn` 启动正式流程；后段自动验证入口为 `scenes/tests/core/late_mainline_main_flow_smoke.gd`。建议审查 A 的任务／楼层提示来源、B 的员工反馈位置，并调查 `task_ui_smoke` 的夹具路径和完整通关断言。D 的 403 HUD 继续只读 `GameManager.get_task_view()`。