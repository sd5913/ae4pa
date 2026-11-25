# 当前项目状态

核对日期：2026-11-23（香港时间）。当前基线：GitHub [`main@cac0214`](https://github.com/sd5913/ae4pa/commit/cac0214d9845a2bae8c6dcb7a55000755e10e19c)。阶段 A 文档、阶段 B Linux／Windows CI、阶段 C 项目 Skills 已合并，见[执行清单](../PLANS.md#开发工作流升级)。此页记录当前实现、可复核的自动化结果和仍待完成的验收；历史证据保留在 [QA](qa.md) 与[进度记录](progress.md)。

## 已实现

| 功能 | 依据 |
| --- | --- |
| 正式菜单、序章、经理谈话及五层主线。二楼完成 201–205 五怪教学，三楼 302 登记后救援 309 的 Terese，随后是 403 巡房与 501 离店许可。五楼 EXIT 已接出口资格检查和成功页。 | [正式主场景](../scenes/main.tscn) · [八项任务定义](../scripts/task_definitions.gd) · [后段接线](../scenes/late_mainline.gd) |
| 员工取证、三证双槽、Q 切换当前身份、I 或 HUD 打开背包、任务工作与返房交付。A 管理任务、计时、检查点和楼层许可，B 维护证件及工作组件，D 显示状态并发送请求。 | [CardManager](../scripts/card_manager.gd) · [GameManager](../scripts/game_manager.gd) · [主场景接线](../scenes/main.gd) |
| 普通门违规警告并退回本层左侧楼梯，保留任务成果。任务超时或员工发现触发失败，可回到接取前的检查点。救援完成后开启同行和后段路线。 | [楼层交互](../scenes/levels/floor.gd) · [GameManager](../scripts/game_manager.gd) · [后段主线交接](late_mainline_handoff_20261121.md) |

## 最新自动化验证

基线为 `main@cac0214d9845a2bae8c6dcb7a55000755e10e19c`，Godot `4.7.2.stable.official.ed1daf0bf`。两条 GitHub Actions 工作流均通过：

- [Linux Godot CI](https://github.com/sd5913/ae4pa/actions/runs/45100701304)：干净导入及八项 smoke（foundation、task checkpoint、staff、work items、door rules、door lifecycle、localization、late mainline）通过。
- [Windows Godot build](https://github.com/sd5913/ae4pa/actions/runs/45100701293)：干净导入、本地化 smoke、Windows x64 导出与包内容检查、Windows runner 无界面启动均通过。非阻断的完整路线 smoke 从正常新局报告八项真实任务及 309 CG 路线 PASS。
- 完整路线日志还记录了 203／205 工作点请求被 `TASK_INACTIVE` 阻止；这没有导致本次 smoke 失败。`main@dca61f7` 上两次 EXIT 断言失败仍作为旧基线证据保留，详见 [QA 历史记录](qa.md#历史自动回归失败与诊断)。

这些是指定 SHA 上的自动化结果，不代表 Compatibility 画面、实际键鼠操作、真人完整通关或 Windows／macOS 同提交验收均已通过。

## 下一项与待验收

1. **补全既有真人通关信息。** 用户确认已完整通关且未发现问题；该次试玩的提交 SHA、平台和 Godot 版本仍待补录。至少两名组员按八项任务记录实际耗时与暂停时间，由 D 汇总。 [真人通关记录](qa.md#已记录的真人通关) · [游戏测试工作簿](../outputs/game-test-20261121/游戏测试.xlsx)
2. **完成同提交跨平台与目标设备验收。** Windows／macOS 实机分别检查源码运行、导出包、画面、真实输入、失败恢复和完整路线；记录系统、Godot 版本和提交 SHA。Windows CI 无界面启动不能替代此项。见 [V4-08](../PLANS.md#v4-08-平台与交付)。
3. **完成剩余交互专项。** 复核普通门双向退回、核验区 I／Q、309 同行与换层、八项任务计时及失败恢复；只记录实际覆盖的路径。见 [V4-04—07](../PLANS.md#v4-04-身份工作与五怪)。


## D 记忆 UI 审查增量（2026-11-24）

分支 work/member-D-memory-ui-review，代码3f29723已提供三页UI、封面/对白/暂停入口和会话已读记录；合入最新已核对main@ac58302。**完整磁盘存档与恢复尚未实现**，按钮保持禁用，不将UI通过视为跨进程成功。A需接入任务、卡片、剩余秒数、309/单个Terese、EXIT和B/C本地状态；[接口与剩余项](memory_ui_handoff_20261123.md) · [实际UI测试及截图](qa_evidence/d_memory_ui_20261123/README.md)。现有主线/CI/人工记录保持各自原SHA和口径。


PR #74 合并前增量（2026-11-24）：481cd5c仅修正后段独立夹具对新增教学/超时和任务牌去重的适配，中英文Windows headless后段均退出0；旧Linux失败及复测见[QA](qa.md#2026-11-24-pr-74-合并前检查)。不替代人工、导出或完整存档验收。
