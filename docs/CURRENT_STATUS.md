# 当前项目状态

核对日期为 2026-11-22（香港时间），基线为 GitHub [`main@dca61f7`](https://github.com/sd5913/ae4pa/commit/dca61f7b7fd5091aa1c830e83e5ad79ece4cfc91)。团队按主线、验收结果或阻塞变化更新本页。阶段目标、接口签名和历史证据分别见[执行清单](../PLANS.md)、[公共接口](interfaces.md)和[进度记录](progress.md)。

## 已实现

| 功能 | 依据 |
| --- | --- |
| 正式菜单、序章、经理谈话及五层主线。二楼完成 201–205 五怪教学，三楼 302 登记后救援 309 的 Terese，随后是 403 巡房与 501 离店许可。五楼 EXIT 已接出口资格检查和成功页。 | [正式主场景](../scenes/main.tscn) · [八项任务定义](../scripts/task_definitions.gd) · [后段接线](../scenes/late_mainline.gd) |
| 员工取证、三证双槽、Q 切换当前身份、I 或 HUD 打开背包、任务工作与返房交付。A 管理任务、计时、检查点和楼层许可，B 维护证件及工作组件，D 显示状态并发送请求。 | [CardManager](../scripts/card_manager.gd) · [GameManager](../scripts/game_manager.gd) · [主场景接线](../scenes/main.gd) |
| 普通门违规警告并退回本层左侧楼梯，保留任务成果。任务超时或员工发现触发失败，可回到接取前的检查点。救援完成后开启同行和后段路线。 | [楼层交互](../scenes/levels/floor.gd) · [GameManager](../scripts/game_manager.gd) · [后段主线交接](late_mainline_handoff_20261121.md) |

## 自动化验证

- **当前基线，macOS，Godot `4.7.2.stable.official.ed1daf0bf`。** 干净副本 headless 导入退出 0，日志有系统证书、FreeType 和编辑器设置写入诊断。基础、检查点、员工与卡片、工作点、普通门规则、任务门生命周期、本地化、英文 UI 布局断言，以及中英文后段定向用例均退出 0。后段用例准备了已救援等前置状态。具体命令与记录口径见 [QA](qa.md#现行主线验收口径)。
- **任务 UI。** `task_ui_smoke.gd -- --ui-smoke` 退出 0，覆盖任务面板、工作、失败和重试。省略参数退出 3，失败时所在楼层没有夹具预期的 `CleaningSpot`，开场和换层等待条件仍待 A/D 核对。
- **完整新局。** 当前基线的 `full_mainline_escape_smoke.gd` 两次退出 1，均在最终 EXIT／成功页断言失败，首个阻断条件待定位。保留早期 A 分支整链通过，以及 D 在较早 Windows 提交上的定向通过与整链失败记录。 [早期 A 证据](qa_evidence/a_late_mainline_20261121/README.md) · [Windows 定向与整链复测](qa_evidence/d_delivery_closeout_20261122/README.md)

## 下一项与待验收

1. **最高优先级：定位完整新局 EXIT 断言失败。** A 牵头复跑并记录 501 交付标记、E 交互目标、出口资格及 `WON`／成功页状态。C 协查门和交互条件，D 协查模态与成功页。调查结果记入 QA。
2. **真人试玩。** 用户已确认完整通关，未发现问题。该次试玩的提交和平台待补录。专项验收继续覆盖核验区 I／Q、真实超时和检查点、309 同行，以及中英文实际游玩可读性。至少两名组员按八项任务记录实际用时与暂停时间，由 D 汇总。早期 201 成功／恢复和 202 通关／超时记录保留在其原版本。 [既有真人记录](acceptance_status_20261117.md) · [游戏测试工作簿](../outputs/game-test-20261121/游戏测试.xlsx)
3. **跨平台及导出。** Windows／macOS 同一提交的源码运行和完整通关待联合验收。目标系统、导出包启动及完整流程待确认和实测。 [平台交付清单](../PLANS.md#v4-08-平台与交付)
