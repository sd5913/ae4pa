# 场景报幕与旁白位置复测 · 2026-11-27

基线 `main@67c27fd8ae16c690e63e91d5c672f0ac892c6cb0`（完整清单已由 [PR #86](https://github.com/sd5913/ae4pa/pull/86) 合入）；本轮为 `work/story-chapter-cues-20261127` 未提交增量，没有推送或合并。运行文件 SHA-256 见 [candidate_manifest.json](candidate_manifest.json)。

## 最终行为

- 原实现有背景上的 StageCue 旁白，没有这五处独立报幕。新增「序章1／卧室」「序章2／咖啡馆回忆」「序章3／卧室」「序章4／旅馆外」「309／重逢」。采用现有字体、墨绿遮罩与暖金文字；背景不带人物。报幕淡入0.65秒、停留1秒、提示淡入0.25秒，之后等待点击或E，淡出0.35秒。序章切场背景黑场渐变由0.22/0.32秒延长为0.55/0.65秒。
- 指定的咖啡馆、回到雨夜、登记簿、向前一步、楼上关门、消防门、走进雨里共七段旁白，直接显示在当前背景上，隐藏半身和对白框。
- 用户随后明确修改309开头一段：`Carol 在安全处切回保洁，刷开 309。Terese 扑过来时……` 保留底部整宽文字框、没有姓名牌；没有在人物脸上叠字。其他CG对白及旁白保持原框。
- 309原CG已画入两名人物，因此由内置图像生成工具根据原房间补出 `cg309_reunion/assets/room309_empty.png`，仅用于报幕；原三幅CG保留。报幕结束后从无人房间交叉淡入原CG。
- 报幕期间刷新不显示首句人物，也不提前写入历史；关闭报幕只显示首句，不吞掉首句。救援结算仍由原12拍和完成回调负责。

## 环境与功能检查

Windows，Godot `4.7.2.stable.official.ed1daf0bf`。先将Git基线归档展开到独立 `work/chapter_clean_verify_20261127`，覆盖本轮候选文件，不复制 `.godot` 缓存；干净导入结束后才运行功能测试。最终源码与测试快照按字节核对。每项使用独立APPDATA，`--log-file` 使用绝对路径。

下表命令前缀均为 `godot --headless --path .`，路径均从独立候选快照运行。

| 参数 | 退出码／证据 |
| --- | --- |
| `--editor --import --quit` | 0：[干净导入](clean_import.log)、[最终增量导入](clean_import_final.log) |
| `--script res://scenes/tests/ui/complete_dialogue_smoke.gd -- --ui-smoke` | 0：[170段／23表情／场景顺序](complete_dialogue.log) |
| `--script res://scenes/tests/core/intro_flow_smoke.gd -- --ui-smoke` | 0：[正式序章与模态输入](intro_flow.log) |
| `--script res://scenes/tests/core/full_mainline_escape_smoke.gd -- --ui-smoke` | 0：[新局八任务到实际EXIT](full_mainline_escape.log) |
| `--script res://scenes/tests/ui/reunion_dialogue_layout_smoke.gd -- --ui-smoke` | 0：[309中文12拍／取消／单次结算](reunion_zh.log) |
| 同上加 `--english` | 0：[309英文](reunion_en.log) |
| `--script res://scenes/tests/ui/story_surface_smoke.gd` | 0：[正式菜单开场／输入／SMS夹具／背景旁白／返回菜单](story_surface.log) |
| `--script res://scenes/tests/core/localization_smoke.gd -- --ui-smoke` | 0：[本地化](localization.log) |

[机器可读结果](functional_results.json)。完整路线保留原最终EXIT断言；测试内位置、员工朝向、任务时钟仍为确定性控制。`--ui-smoke` 跳过报幕等待，所以报幕实际淡入与门控另用下述不带该参数的图形检查覆盖，不能把快速主线检查当作真人节奏验收。

## Compatibility实际渲染检查

在本轮开发工作区运行 `godot --path . --script res://scenes/tests/ui/chapter_narration_review.gd`，设置 `AE4PA_CHAPTER_EVIDENCE` 为绝对截图目录，不带 `--ui-smoke`；NVIDIA RTX 3070 Laptop GPU／OpenGL 3.3 Compatibility。退出0：[日志](review_verified.log)。

夹具直接挂载生产Dialogue及Reunion场景。序章后三次由前一场最后一拍通过生产E输入进入，实际跑完背景淡出、淡入与报幕；测试提前E无效、鼠标/E关闭后停在首句、刷新拦截、309开场不记录/不结算、取消清理。它不是人工点击窗口的记录。

五处报幕、七段背景旁白及309首段底框共13状态，中文/英文×960×540、1280×720、1920×1080，共78幅实际渲染PNG。每幅检查图像真实像素尺寸与文字边界，并检查全部六张汇总图；没有发现截字、人物报幕残留或空姓名牌。

| 尺寸 | 中文 | 英文 |
| --- | --- | --- |
| 960×540 | [汇总](contact_zh_CN_960x540.jpg) | [汇总](contact_en_960x540.jpg) |
| 1280×720 | [汇总](contact_zh_CN_1280x720.jpg) | [汇总](contact_en_1280x720.jpg) |
| 1920×1080 | [汇总](contact_zh_CN_1920x1080.jpg) | [汇总](contact_en_1920x1080.jpg) |

原生样图：[309中文底框](zh_CN_narration_309_960x540.png)、[英文底框](en_narration_309_960x540.png)、[咖啡馆报幕](zh_CN_chapter_2_1280x720.png)。全量PNG保留于本机 `work/chapter_review_logs/verified_captures`。正式 `scenes/main.tscn` 已用Godot MCP启动，启动日志另核查；不据此宣称人工通关。

## 初次诊断与限制

初次[刷新检查失败](review.log)发现报幕时重复刷新暴露首句人物，已增加生产刷新/历史拦截后通过。中间一次[尺寸断言失败](review_final.log)使用ViewportTexture逻辑尺寸而不是图像像素尺寸，且一次日志相对路径被Godot解释为user路径；最终改为Image尺寸断言、等待原生窗口完成调整及绝对日志路径，78幅尺寸逐一核实。初次截图未作为最终三尺寸证据。

干净导入退出0，仍有本机编辑器既有Safe save failed诊断；203/205预期的TASK_INACTIVE测试诊断保留于完整路线日志。真人连续计时试玩、手工拖放、macOS／另一设备、导出包以及本轮存读档专项未验证；不覆盖先前各SHA的验收归属。工作区已有无关 `.import`/UID 未清理。
