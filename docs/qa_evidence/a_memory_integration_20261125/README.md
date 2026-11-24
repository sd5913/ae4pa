# A 侧记忆存档验证 · 2026-11-25

- 实现提交 `c6b17f2`，历史去重修复 `63c4cd3`，实测脚本提交 `079cdb5`。基线包含 PR #74 的合并提交 `48c0b5c`。
- macOS Apple M5，Godot `4.7.2.stable.official.ed1daf0bf`，Compatibility。实测存档使用测试专用 `user://` 目录。
- B 卡片通过 CardManager 的快照、校验和恢复接口接入。C 怪物采用原房间候选池，门与调度器由各自组件还原。任务、登记、笔记线索和 EXIT 仍由 GameManager 的状态及原规则决定。已按源码核对 B/C 接口，未取得成员本人验收。

| 类别 | 结果 | 证据与覆盖 |
| --- | --- | --- |
| 自动，中文 1280×720 | 通过，两进程各退出 0 | [保存](zh-save.log) · [重启读取](zh-load.log) |
| 自动，英文 960×540 | 通过，两进程各退出 0 | [保存](en-save.log) · [重启读取](en-load.log) |
| 自动，磁盘错误路径 | 通过 | [存储日志](storage.log)。覆盖六手动槽与独立自动槽、损坏／不兼容档原样保留、备份读取、确定性写入失败 |
| 自动，UI 隔离 | 通过 | [中文](ui-zh.log) · [英文](ui-en.log)。真实视口鼠标事件及 Escape，记忆页不向底层对白传递推进输入 |
| 自动，底座与历史 | 通过 | [底座](foundation.log) · [历史去重](history.log) |
| 人工 | 截图目视抽查；物理键鼠端到端与跨机器验收未执行 | 下方附正式场景画面 |
| 导出，资源包 | 通过 | [导出日志](export-pack.log) · [独立加载资源包并启动](export-pack-startup.log)，两次退出 0 |
| 导出，Windows EXE | 导出失败，导出后试玩未执行 | [启动导出时报缺 Windows 模板](windows-export.log) |

六个手动槽覆盖双卡和当前生效身份、任务中途 123.25 秒无离线扣时、201 工作完成但未交付、309 救援结算前后、403 取件未交付、501 交付后到 EXIT。另验证覆盖取消、新局保留旧档、无效门数据拒绝恢复且保持现有世界、自动槽写入、309 全部 36 拍历史及单一跟随者。501 装载后，撤掉交付标志时 EXIT 拒绝，恢复标志后通过正式出口 API 获胜。

[保存并退出的录屏](01-save.avi) 和 [新 Godot 进程读取的录屏](02-restart-load.avi) 按执行顺序观看。两段是 Godot Movie Maker 对正式游戏画面的自动采集，由测试脚本驱动。脚本准备前置任务、场景和确定的计时值，保存和读取执行正式 UI 的确认路径，实际磁盘文件跨进程传递。录屏未包含应用外的桌面间隔。

| 场景 | 中文 1280×720 | 英文 960×540 |
| --- | --- | --- |
| 暂停菜单完成保存 | [截图](zh1280_saved.png) | [截图](en960_saved.png) |
| 启动后读取选择页 | [截图](zh1280_load.png) | [截图](en960_load.png) |
| 恢复后游戏世界 | [截图](zh1280_loaded.png) | [截图](en960_loaded.png) |
| 309 已读历史 | [截图](zh1280_history.png) | [截图](en960_history.png) |

[309 全屏 CG](zh1280_309.png) 沿用原始中文脚本。历史保存原始翻译源和参数，未新增 309 台词的英文译文。

## 重跑

先在项目根目录完成 Godot 导入，依次运行以下两个完整进程。可加 `--english` 与 `--resolution 960x540` 复测英文。若设置 `AE4PA_MEMORY_EVIDENCE` 为已有可写目录，图形运行会保存 PNG。

```sh
godot --path . --resolution 1280x720 --script res://scenes/tests/core/memory_cross_process_smoke.gd -- --ui-smoke
godot --path . --resolution 1280x720 --script res://scenes/tests/core/memory_cross_process_smoke.gd -- --ui-smoke --load
godot --headless --path . --script res://scenes/tests/core/memory_service_smoke.gd
```
