# 完整对话清单与确认立绘接入 · 2026-11-26

本地分支 `work/member-C-story-revision-20261126`，基于 `4ae5577b2e6455372366b21e21a12b08fb0d96a7`，工作区尚未提交、推送或合并。本次结果对应 [code_sha256.json](code_sha256.json) 的文件内容，不能用基线 SHA 代替本次修改的证据。

## 最终行为

以用户 `对话清单.txt` 为唯一剧情顺序，170 段对白／旁白全部按原顺序接入。序章恢复卧室 → 咖啡馆回忆 → 卧室 → 旅馆外，之后进入一楼经理谈话及五层主线。原文件的重复 D/C 编号作为来源标签保留，运行使用唯一 beat_id，不覆盖重复编号的台词。

Carol 13 张、Terese 7 张、经理 3 张确认原图全部归档并接入共用半身立绘组件；五种怪物继续使用提供的固定半身图和既有裁切。28 张 PNG 经 SHA-256 验证，与用户提供的原文件逐字节一致，只在显示时通过 AtlasTexture 去除透明边距。来源见 [素材清单](../../../assets/final/confirmed_characters_20261126/source_manifest.json)。

表情别名：`思考 → 沉思`，`坚定 → 猎杀时刻`。`狐疑`与`怀疑`分别解析为不同原图。括号内的“英文版：HOTEL VESPERA”为英文说明，仅用于英文台词，中文显示“维斯佩拉旅馆！”。未标表情的怪物使用唯一固定立绘；广播与楼下员工没有擅自添加人物图。

309 保留原有三幅整幅 CG、淡入、输入归属与救援完成回调，12 段新文字不叠加半身立绘。旁白及 CG 文字框收回左侧空位，人物对白恢复对应表情。逐句对应见 [dialogue_mapping.tsv](dialogue_mapping.tsv)，原稿归档见 [story_revision_source.txt](../../../scenes/ui/story_revision_source.txt)。

## 环境与命令

Windows，Godot `4.7.2.stable.official.ed1daf0bf`，Compatibility / OpenGL 3.3 / NVIDIA GeForce RTX 3070 Laptop GPU。所有测试使用 `work/story_profiles/complete_*` 下独立 APPDATA，避免修改玩家档案。运行均从项目根目录执行，`--log-file` 传本目录内的绝对路径。

通用 headless 命令为 `godot --headless --path . --script res://scenes/tests/<类别>/<脚本>.gd --log-file <绝对日志路径> -- --ui-smoke`。

| 检查 | 结果与证据 |
| --- | --- |
| `--headless --editor --import --quit` | 退出 0，[导入日志](import.log)。仍有既有 Windows editor safe-save 诊断，未造成资源缺失或脚本解析失败。 |
| `ui/complete_dialogue_smoke.gd` | 退出 0，[逐句检查](complete_dialogue.log)：170 段、23 表情、场景顺序、经理结尾、英文、怪物及 CG 数据一致、完成仅触发一次。 |
| `core/foundation_smoke.gd` | 退出 0，[日志](foundation_smoke.log)。 |
| `core/intro_flow_smoke.gd` | 退出 0，[正式序章及经理输入／模态／楼层解锁](intro_flow_smoke.log)。 |
| `core/localization_smoke.gd` | 退出 0，[语言切换、目录及任务状态隔离](localization_smoke.log)。 |
| `core/full_mainline_escape_smoke.gd` | 退出 0，[从正常新局完成八项实际任务、309 CG、警报、真实 EXIT 和雨夜结尾](full_mainline_escape_smoke.log)。 |
| `core/late_mainline_main_flow_smoke.gd` | 退出 0，[后段成功、超时、重试和身份边界](late_mainline_main_flow_smoke.log)。 |
| `ui/reunion_309_smoke.gd` | 退出 0，[保洁开门、救援结算与跟随](reunion_309_smoke.log)。 |
| `core/memory_cross_process_smoke.gd -- --ui-smoke --save` / `--load` | 两个独立进程均退出 0，[保存](memory_save.log) / [读取](memory_load.log)，含救援前后、单个跟随者与完整阅读记录。 |
| `ui/story_surface_smoke.gd`（真实窗口，无 `--headless`） | 退出 0，[日志](story_surface_smoke.log)。实际序章点击、E、跳过、关闭恢复；另保留显式手机组件夹具验证通知、拖动、滚轮、触摸与模拟鼠标，手机夹具不是正式新稿内容。 |
| `res://scenes/tests/ui/intro_preview.tscn -- --ui-smoke` | 退出 0，[独立序章预览](intro_preview.log)。 |
| `ui/complete_dialogue_review.gd`（真实窗口） | 退出 0，[106 个 Compatibility 截图及边界检查](visual_review.log)。13 个代表状态 × 中英 × 三尺寸 = 78，加 23 人物表情及 5 怪物固定图。世界对白的画面夹具使用一楼作为统一背景，只用于评价对白 UI；真实任务路由另由完整主线检查验证。 |
| `ui/reunion_dialogue_layout_smoke.gd -- --ui-smoke` / `--english`（真实窗口） | 中英均退出 0，[中文](reunion_layout_zh.log) / [英文](reunion_layout_en.log)。三尺寸 CG、12 段正文边界、点击／E、淡入输入锁、取消与单次完成。 |

独立 Python 原稿抽取核对了 170 段的文字与顺序，源稿归档字节与用户文件相同；28 张素材的归档哈希均等于来源哈希。`git diff --check` 通过。

## 画面证据

中英均检查 960×540、1280×720、1920×1080 的布局与长段落，未见文字裁切或半身立绘遮挡正文：

- [中文 960](contact_zh_CN_960x540.jpg) · [1280](contact_zh_CN_1280x720.jpg) · [1920](contact_zh_CN_1920x1080.jpg)
- [英文 960](contact_en_960x540.jpg) · [1280](contact_en_1280x720.jpg) · [1920](contact_en_1920x1080.jpg)
- [全部 23 种人物表情与 5 种怪物](contact_all_portraits.jpg)
- [卧室原尺寸](zh_CN_1280x720_00.png) · [气鼓鼓原尺寸](zh_CN_1280x720_02.png) · [旅馆外原尺寸](zh_CN_1280x720_04.png) · [展开旁白框](zh_CN_1280x720_05.png)
- CG：[中文 960](309_dialogue_zh_960x540.png) · [1280](309_dialogue_zh_1280x720.png) · [1920](309_dialogue_zh_1920x1080.png)；[英文 960](309_dialogue_en_960x540.png) · [1280](309_dialogue_en_1280x720.png) · [1920](309_dialogue_en_1920x1080.png)

## 诊断与限制

最初的图形夹具为手动构造的检查行漏填 `mode`，出现阅读记录报错；修复夹具后重跑无脚本报错。最初手机组件夹具沿用了 `--ui-smoke` 跳过过渡状态，通知断言失败；夹具显式恢复手机状态后真实窗口复测通过。两份初始日志分别保留为 `visual_review_fixture_missing_mode_initial.log`、`story_surface_fixture_skip_initial*.log`，不能当作最终通过日志。

完整主线日志中仍有已知 203／205 `TASK_INACTIVE` 工作点诊断，未阻断实际任务或最终 EXIT 断言。以上是自动化和渲染夹具结果；本次未进行真人连续试玩、macOS 或导出包验收。旧版本的“149 段／仅四句保留立绘／Carol 组员版”是历史要求，已由本次完整清单和三张确认表替代，历史日志仍保留。
