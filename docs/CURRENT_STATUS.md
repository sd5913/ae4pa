# 当前项目状态

核对日期：2026-11-24（香港时间）。当前 GitHub 基线：[`main@ac58302`](https://github.com/sd5913/ae4pa/commit/ac58302b29499a4243dd302876a8f24e84be013a)。本轮质量修复位于隔离分支 `work/member-A-release-quality-20261123`，提交 [`b313ef7`](https://github.com/sd5913/ae4pa/commit/b313ef77d756a4082864caf7a3cc6a8b7104c0d7)，并在[草稿 PR #72](https://github.com/sd5913/ae4pa/pull/72)等待团队审核。本页同时区分远端基线证据与本轮代码验证结果。阶段 A 文档、阶段 B Linux／Windows CI、阶段 C 项目 Skills 已合并，见[执行清单](../PLANS.md#开发工作流升级)。历史证据保留在 [QA](qa.md) 与[进度记录](progress.md)。

## 已实现

| 功能 | 依据 |
| --- | --- |
| 正式菜单、序章、经理谈话及五层主线。二楼完成 201–205 五怪教学，三楼 302 登记后救援 309 的 Terese，随后是 403 巡房与 501 离店许可。五楼 EXIT 已接出口资格检查和成功页。 | [正式主场景](../scenes/main.tscn) · [八项任务定义](../scripts/task_definitions.gd) · [后段接线](../scenes/late_mainline.gd) |
| 员工取证、三证双槽、Q 切换当前身份、I 或 HUD 打开背包、任务工作与返房交付。A 管理任务、计时、检查点和楼层许可，B 维护证件及工作组件，D 显示状态并发送请求。 | [CardManager](../scripts/card_manager.gd) · [GameManager](../scripts/game_manager.gd) · [主场景接线](../scenes/main.gd) |
| 普通门违规警告并退回本层左侧楼梯，保留任务成果。任务超时或员工发现触发失败，可回到接取前的检查点。救援完成后开启同行和后段路线。 | [楼层交互](../scenes/levels/floor.gd) · [GameManager](../scripts/game_manager.gd) · [后段主线交接](late_mainline_handoff_20261121.md) |

## 最新自动化验证

最近有明确链接的 GitHub Actions 证据对应 `main@cac0214d9845a2bae8c6dcb7a55000755e10e19c`，Godot `4.7.2.stable.official.ed1daf0bf`。两条工作流当时均通过：

- [Linux Godot CI](https://github.com/sd5913/ae4pa/actions/runs/45100701304)：干净导入及八项 smoke（foundation、task checkpoint、staff、work items、door rules、door lifecycle、localization、late mainline）通过。
- [Windows Godot build](https://github.com/sd5913/ae4pa/actions/runs/45100701293)：干净导入、本地化 smoke、Windows x64 导出与包内容检查、Windows runner 无界面启动均通过。非阻断的完整路线 smoke 从正常新局报告八项真实任务及 309 CG 路线 PASS。
- 完整路线日志还记录了 203／205 工作点请求被 `TASK_INACTIVE` 阻止；这没有导致本次 smoke 失败。`main@dca61f7` 上两次 EXIT 断言失败仍作为旧基线证据保留，详见 [QA 历史记录](qa.md#历史自动回归失败与诊断)。
- 2026-11-24 本机 macOS 对基于 `main@ac58302` 的代码修改运行：基础系统、任务定义／检查点、员工与工作点、门规则／生命周期、交互引导、403/501 中文与英文正式主线及完整新局到 EXIT 自动 smoke 通过。该代码已提交为 `b313ef7`；具体命令和限制见 [QA 本地复测](qa.md#2026-11-24-macos-本地发布前复测)。这些结果不是 GitHub Actions 对 `ac58302` 或 `b313ef7` 的检查。
- `localization_smoke` 和默认 `task_ui_smoke` 本轮没有通过：前者无法写入 `user://` 测试进度文件，后者依赖当前楼层不存在的旧 `CleaningSpot` 夹具。309 UI smoke 也在新增剧情断言之前就因其预置旅行失败而中止。Compatibility 图形布局 smoke 因本机执行环境没有可用显示窗口未完成；详情见 QA，均未标成通过。

这些是指定 SHA 上的自动化结果，不代表 Compatibility 画面、实际键鼠操作、真人完整通关或 Windows／macOS 同提交验收均已通过。

## 下一项与待验收

1. **A 负责本轮剧情、反馈和本地化修复的图形复核及独立 PR。** 确认 960×540／1280×720／1920×1080 中英文正式主场景关键对白、故障页与布局，补跑可写用户数据的 `localization_smoke` 和修正夹具后的 UI／309 smoke，再对提交 SHA 执行 CI。
2. **完成同提交跨平台与目标设备验收。** Windows／macOS 实机分别检查源码运行、导出包、画面、真实输入、失败恢复和完整路线；记录系统、Godot 版本和提交 SHA。Windows CI 无界面启动不能替代此项。见 [V4-08](../PLANS.md#v4-08-平台与交付)。
3. **补录已完成真人通关的环境信息。** 用户确认已完整通关，未发现问题；试玩 SHA、平台和 Godot 版本待补录。此事实不代表试玩发生在本轮提交 SHA，也不代表跨平台验收。 [真人通关记录](qa.md#已记录的真人通关)
4. **完成剩余交互专项。** 复核普通门双向退回、核验区 I／Q、309 同行与换层、八项任务计时及失败恢复；只记录实际覆盖的路径。见 [V4-04—07](../PLANS.md#v4-04-身份工作与五怪)。
