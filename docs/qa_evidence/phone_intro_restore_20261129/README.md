# 序章一后的原手机聊天恢复

2026-11-29，Windows / Godot `4.7.2.stable.official.ed1daf0bf`。基于 `352394fe15cdd70c70689c0bfbbc10e2c41ce958` 的未提交工作树；保留已存在的人物半身放大 8% 与 A001「维斯佩拉……」修订。本次未提交或推送。

## 改动和来源

- 从 `4d58c71^:scenes/ui/intro_script.tsv` 原样恢复开头 24 段：21 条 SMS、3 段电话／输入状态提示。恢复通知「1 条新消息」，复用原手机框、头像、聊天气泡、滚动和输入组件。
- 正式 TSV 与 JSON 内容一致；保留原 170 段及原 `complete_*` 标识，新增 `phone_001`–`phone_024`。历史源稿 `story_revision_source.txt` 仍记录此前确认的 170 段，新增手机段在 JSON 的 `source_file` / `source_line` 指向历史 TSV。
- 顺序为「序章 1 · 卧室」动效报幕 → 原摇晃／震动线 → 待玩家打开的通知 → 完整原聊天 → Carol「那家旅馆……」及后续剧情。聊天室首次打开不消费首条消息，动画期间输入被拦截。
- 逐字核对历史手机 TSV，以及 `_animate_phone_notification()` 的角度数组、每段 0.105 秒、末段归位 0.22 秒及完成回调；与历史版本一致。重新开始时隐藏旧手机，不让它露在新报幕下。

## 自动化和画面

独立验证目录最初由干净源码导出，此轮同步当前运行及测试改动后重新导入；使用独立 APPDATA，未使用玩家存档。以下命令均带 `--path <验证目录>`；日志在本目录 `logs/`。

| 命令（Godot 参数） | 退出码 | 实际覆盖 |
| --- | --- | --- |
| `--headless --editor --import --quit` | 0 | 验证目录资源导入；实际源工程也重新导入，退出 0 |
| `--headless --script res://scenes/tests/ui/complete_dialogue_smoke.gd -- --ui-smoke` | 0 | 194 段、23 种表情、英文、四场序章、经理／怪物／CG 接线和完成隔离 |
| `--headless --script res://scenes/tests/core/intro_flow_smoke.gd -- --ui-smoke` | 0 | 正式主场景的新局、E／鼠标、经理及楼层门控、重开和清理 |
| `--headless --script res://scenes/tests/core/localization_smoke.gd -- --ui-smoke` | 0 | 手机原文及现有中英资源、语言切换 |
| `--headless --script res://scenes/tests/ui/story_surface_smoke.gd -- --ui-smoke` | 0 | 直接使用恢复后的正式手机聊天，保留滚轮／拖动／触摸／鼠标模拟、单次推进、已读跳过和返回菜单覆盖 |
| `--headless res://scenes/tests/ui/intro_preview.tscn -- --ui-smoke` | 0 | 独立预览的 61 段序章、首读锁、经理完成与已读重播 |
| `--headless --script res://scenes/tests/ui/chapter_narration_review.gd` | 0 | 真实动画时间的六处报幕和旁白门控；本项为 headless，无截图 |
| `--script res://scenes/tests/ui/phone_intro_review.gd` | 0 | 正式 main.tscn，无 `--ui-smoke`；Compatibility / NVIDIA RTX 3070 Laptop GPU；中英 × 960×540、1280×720、1920×1080，共 54 张实际截图 |

图形检查包括报幕、摇晃两时刻、通知、首条消息、长消息、滚动后的警告、最后通话提示、接回 Carol；检查实际角度变化、动画输入锁、首条不丢失、21 条气泡仅各出现一次、三段提示、现有咖啡馆报幕、取消中途摇晃后重新开场、卸载后的输入恢复。已查看 [54 状态总览](matrix.png) 及原尺寸长消息、摇晃、通知和通话截图，未见新增裁切或气泡溢出。

首轮图形运行出现一组消息索引断言失败，保留 `logs/phone_graphics_initial.log`；当时未输出 case 与实际索引，原因未确定。新增 case、期望／实际索引和动画／过渡状态诊断后，未修改业务逻辑或放宽断言，完整六组合复跑通过，见 `logs/phone_graphics.log`。这两次结果均保留，不能将复跑表述为已定位首轮失败原因。

导入日志仍出现 Windows 文件 safe-save 诊断，退出 0，未出现脚本解析错误，运行检查均通过。此轮未重新做完整八任务通关、存读迁移、导出、跨平台或真人连续试玩，不将图形夹具记作这些验收。

下一步入口：重启正式工程，从新游戏查看「序章 1」后的手机；如再次出现消息索引问题，使用新增 case／实际索引诊断定位。资源和代码指纹见 `sha256.json`。
