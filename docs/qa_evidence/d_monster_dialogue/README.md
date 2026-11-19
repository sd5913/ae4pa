# 本轮对白验证证据

环境：Windows；Godot 4.7.2.stable.official.ed1daf0bf。工作基线 main d0fec0d。
运行时使用隔离 APPDATA／LOCALAPPDATA，未操作玩家原设置。外部日志原目录：
`C:/Users/lenovo/Documents/ChatGPT/hotel/ae4pa-monster-dialogue-validation`。

| 本次检查 | 记录文件 | 结果 |
|---|---|---|
| 图形模式真实 main，201/202 白对话与任务防护、五怪阶段预览 | [current-monster-final.log](current-monster-final.log) | 退出 0 |
| 现有 UI 回归 | [current-ui.log](current-ui.log) | 退出 0 |
| foundation（串行独立运行） | [current-foundation-serial.log](current-foundation-serial.log) | 退出 0 |
| 原序章／经理输入回归 | [current-intro_flow.log](current-intro_flow.log) | 退出 0 |
| 201 任务逻辑／计时与模态暂停 | [final-task_01.log](final-task_01.log) | 退出 0 |
| 201 正式主场景清理／交付 | [final-task_01_main_flow.log](final-task_01_main_flow.log) | 退出 0 |
| 202 正式主场景任务链 | [final-task_02_main_flow.log](final-task_02_main_flow.log) | 退出 0 |
| 原 309 正式主场景链 | [final-task_03_main_flow.log](final-task_03_main_flow.log) | 退出 0 |
| 202 任务核心 | [current-task_02_core.log](current-task_02_core.log) | 退出 0 |
| 309 任务核心 | [current-task_03_core.log](current-task_03_core.log) | 退出 0 |

标准命令：
`godot --headless --path . --script res://scenes/tests/core/<对应脚本>.gd`。
UI：`godot --headless --path . --scene res://scenes/tests/ui/ui_test.tscn -- --ui-smoke`。
新增对白：`godot --path . --script res://scenes/tests/ui/monster_dialogue_smoke.gd -- --ui-smoke`。
新增回归也支持 --headless。图形运行通过 AE4PA_MONSTER_EVIDENCE 环境变量将截图写入外部证据目录。
序章测试使用外部副本，仅把原 Mac 临时配置路径换为本机隔离目录；断言未改。

Windows 根证书读取错误仍出现，未阻断以上用例。此前 current-foundation.log 的输出实际为 UI 组，因此不作为 foundation 证据；已串行重新执行并核对 current-foundation-serial.log。

## 已查看的主场景渲染截图

- [201 初见](201-introduction.png)、[201 交付后](201-delivered.png)
- [202 初见](202-introduction.png)、[202 交付后](202-delivered.png)

画面为真实 main 节点树，底部面板、中文换行与继续按钮未裁切。新测试用公开 API 准备工作证、报告工作结果、交付，不是人工偷证录像。
201 主场景回归沿用原 collect_card 夹具，通过 B 清理组件的真实 E 长按与回门交付；不能把它写成真人完整偷证验收。
202/309 原回归包含自身明确标注的前置任务／位置／时钟夹具，保留原正式交互断言；三份主场景测试增加真实 E 读完对白，202 可见性检查改指新节点。

## 未执行与阻塞

- 未完成人工 F5 全线试玩，不把程序渲染截图当作人工操作。
- 新二楼 203 房务申请、204 独立双工作、205 领取→批准→交付合同尚无真实实现，不能由预览冒充正式接入。
- 五怪全迁至二楼的房号、工作点、员工位置、任务时限须由 A/B/C 统一；本轮保持当前真实配置。
- ACTIVE／COMPLETED 的专用怪物回访入口须由 A 连接 show_task_reminder(task_id)，D 不轮询弹窗或改 E 优先级。
- 新对白尚无经确认英文翻译。

F6 文案预览：[monster_dialogue_preview.tscn](../../../scenes/tests/ui/monster_dialogue_preview.tscn)。清楚标识预览，不改任务进度。
