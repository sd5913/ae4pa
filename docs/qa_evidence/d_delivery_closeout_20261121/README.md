# D 后段交付收尾证据（2026-11-21）

## 环境与基线

- Windows 11；Godot `4.7.2.stable.official.ed1daf0bf`。
- 检查到的最新 `main` 与本地 `origin/main` 均为 `49dc7d869fe2174bab393dce815acdff72092a7f`。CLI `git fetch origin` 因无法连接 `github.com:443` 失败；本分支以该提交为基线，没有在旧 D 分支上叠加历史改动。
- Godot 自动化使用独立临时用户配置；没有使用或覆盖现有玩家存档。Godot 输出根证书读取错误，但没有阻断通过的检查。

## 正式主场景截图

截图来自 `scenes/main.tscn`，由自动化通过真实 GameManager/CardManager 接口准备 403／501 状态后捕获；它们不是人工完整通关或导出包证据。

| 语言／分辨率 | 403 待交付 | 501 已批准 | 逃脱结果 |
|---|---|---|---|
| 中文 1280×720 | [patrol_ready.png](screenshots/zh1280/patrol_ready.png) | [exit_approved.png](screenshots/zh1280/exit_approved.png) | [escaped.png](screenshots/zh1280/escaped.png) |
| 英文 960×540 | [patrol_ready.png](screenshots/en960/patrol_ready.png) | [exit_approved.png](screenshots/en960/exit_approved.png) | [escaped.png](screenshots/en960/escaped.png) |

HUD 与相关界面截图：[完成态 1280×720](screenshots/hud_final/after-completed.png)、[完成态 960×540](screenshots/hud_final/after-completed-960.png)、[背包](screenshots/hud_final/after-bag.png)、[暂停](screenshots/hud_final/after-pause.png)、[对白](screenshots/hud_final/after-dialogue.png)。

## 实际测试记录

- [import_localization_final.log](logs/import_localization_final.log)：Godot 资源导入／解析检查，退出码 0。
- [localization_final_isolated.log](logs/localization_final_isolated.log)：隔离配置下的本地化回归，退出码 0，包含 403／501 HUD 与通知文本。
- [late_mainline_chinese_final.log](logs/late_mainline_chinese_final.log)：中文后段任务流程回归，退出码 0。
- [late_mainline_english_final3.log](logs/late_mainline_english_final3.log)：英文后段任务流程回归，退出码 0。
- [late_mainline_capture_zh_final.log](logs/late_mainline_capture_zh_final.log)、[late_mainline_capture_en_short_notice.log](logs/late_mainline_capture_en_short_notice.log)：正式场景截图回归，均退出码 0。
- [hud_layout_final.log](logs/hud_layout_final.log)：HUD 定向图形布局回归，退出码 0。
- [full_mainline_escape_smoke_first.log](logs/full_mainline_escape_smoke_first.log)：完整新局自动流程未通过最终“八任务／309／EXIT”断言；不能记为完整通关通过。
- [task_ui_smoke_final.log](logs/task_ui_smoke_final.log)：旧任务 UI 测试退出码 3。日志显示空 OwnedCards 列表导致卡片图标选择越界，随后当前楼层缺少 `Interactions/Stain201Slot/CleaningSpot`。没有删除或放宽断言。

## 仍待处理

403 重叠来自两个不同模块：白色“巡房记录已取得／返回403交付”提示来自 A 的 `scenes/levels/floor.gd`，绿色 `GOT PATROL RECORD` 标签来自 B 的巡逻员工场景／反馈组件。A 需缩短、移位并本地化楼层提示；B 需调整员工反馈标签位置。D 本轮没有修改 A/B 的场景或规则。

TC-11／TC-14 人工新局流程、Windows／导出验证、两位组员的八任务实测用时与暂停时间、1–3 分钟真实演示及署名均未完成；没有虚构数据或视频。工作簿保持原记录，等待团队使用同一候选提交补录。