# 2026-11-26 新剧情接入与验证

验证对象：`main@4ae5577` 上的本地未提交修改，分支 `work/member-C-story-revision-20261126`。本次没有提交、推送或合并 GitHub。实际脚本和数据散列见 [code_sha256.json](code_sha256.json)。原试玩 worktree 和窗口未改动。

环境：Windows，Godot `4.7.2.stable.official.ed1daf0bf`。原生图形检查使用 Compatibility / OpenGL 3.3、NVIDIA GeForce RTX 3070 Laptop GPU；窗口在屏幕外无焦点运行，截图来自实际渲染 viewport。

## 内容与接线

- [用户新稿](../../../scenes/ui/story_revision_source.txt) 共 149 条对白、旁白及文书。新增测试逐字、逐序核对，文本未经改写。开场为三天前的八条聊天记录，不再提前透露 309。
- 咖啡馆、经理谈话、201–205、302、309、警报、403、501、消防出口均接入新稿。工作过程的旁白放在真实工作／交付完成后展示，不提前结算任务。205 的敲门节奏作为剧情描述；沿用现有房门交互，没有另加敲击小游戏。
- 309 保留既有三幅整屏 CG，新稿对应 12 拍；原有救援前置、取消不结算、一次结算、单个同行角色和历史记录接口保留。结算后连续进入警报对白。实际 EXIT 胜利事实仍由 GameManager 判定，雨夜结尾读完才显示成功页；结尾复用现有旅馆雨夜外景。
- 出口灯读取 `exit_form_delivered`，仅批准未交付时仍为红色，交付后变绿。未修改身份、任务时限、偷取、巡逻或通关条件。
- 新稿仅四句与旧说话人及整句文本完全一致，见 [保留清单](../../../scenes/ui/story_portrait_matches.json)：Terese「你这人真没情趣。」、Carol「这是提醒，还是威胁？」、经理「是建议。」、Carol「然后呢？」。保留原表情。其他新稿台词的左侧半身立绘隐藏并清空纹理，避免上一句残留。Carol 仍为组员版，Terese 及经理仍为用户版；未接入本轮候选表情图。未修改的新手教程／缺件提醒继续保留原立绘。
- 新稿英文翻译已加入现有 `en.po`；原序章已读标记增加稿件版本，新稿第一次阅读不会被旧版已读跳过。Windows／Linux／macOS 导出配置均包含新增运行时 JSON；本次未执行二进制导出。

## 自动化结果

以下每项最终运行均退出 0；原始日志在本目录。命令均从项目根目录执行。Windows 实际 Godot 控制台程序位于 `F:\software2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`，每项使用独立的工作区 `APPDATA` 和绝对 `--log-file`；存档 SAVE／LOAD 两进程共用独立测试 profile，不触碰用户存档。

| 命令（省略公共 Godot 路径与绝对日志参数） | 证据 | 范围 |
| --- | --- | --- |
| `--headless --path . --editor --import --quit` | [导入](import_final2.log) | 退出 0；保留编辑器 Safe save failed 宿主诊断，未出现脚本导入错误。 |
| `--headless --path . --script res://scenes/tests/core/foundation_smoke.gd` | [底座](foundation.log) | 管理器、移动、边界、失败生命周期。 |
| `--headless --path . --script res://scenes/tests/core/intro_flow_smoke.gd -- --ui-smoke` | [序章](intro.log) | 真实新局、经理 E、输入隔离、无卡上楼和重新开始。 |
| `--headless --path . --script res://scenes/tests/ui/story_revision_smoke.gd -- --ui-smoke` | [逐句与立绘](revision_latest.log) | 全部 149 拍、四句保留、空白清纹理、八条旧消息、实际 TSV／怪物／CG 数据、英文目录和异说话人序列。 |
| `--headless --path . --script res://scenes/tests/core/localization_smoke.gd -- --ui-smoke` | [本地化](localization2.log) | 新序章翻译及原有实时语言／任务／格式串回归。 |
| `--headless --path . --script res://scenes/tests/core/late_mainline_main_flow_smoke.gd -- --ui-smoke` | [后段](late_final.log) | 403／501 真实工作与交付、失败恢复、EXIT 条件、雨夜背景与结尾后成功、重开／返回菜单。此前任务与救援为明确夹具。 |
| `--headless --path . --script res://scenes/tests/core/full_mainline_escape_smoke.gd -- --ui-smoke` | [完整路线](full_latest.log) | 从正常新游戏开始，201–205、302、真实 309、警报、403、501、实际 EXIT 与结尾到成功。使用测试位置、员工朝向和停表控制，不是真人连续计时试玩。仍出现已知 203／205 工作点 `TASK_INACTIVE` 诊断；最终断言未删除或放宽。 |
| `--headless --path . --script res://scenes/tests/ui/confirmed_portraits_smoke.gd -- --ui-smoke` | [人物版本](portraits2.log) | Carol 组员纹理、Terese 用户四图、经理 neutral 与新咖啡馆五句映射。 |
| `--headless --path . --script res://scenes/tests/ui/reunion_309_smoke.gd -- --ui-smoke` | [309 救援](reunion2.log) | 前置／当前身份、真实 E／鼠标推进、切帧吞重复输入、取消重开、救援一次、警报、同行与换层。 |
| `--headless --path . --script res://scenes/tests/core/memory_cross_process_smoke.gd -- --ui-smoke`，再同 profile 加 `--load` | [SAVE](memory_save.log)、[LOAD](memory_load.log) | 两进程保存读取、309 前后、12 条 CG 历史、警报期间禁止保存、单个同行、501 与恢复后 EXIT。前置任务由既有明确夹具建立。 |
| `--path . --rendering-method gl_compatibility --no-focus --position -12000,-12000 --script res://scenes/tests/ui/story_surface_smoke.gd` | [对白输入与布局](surfaces.log) | 实际渲染下旧记录开屏、E、鼠标、拖动／滚轮、触屏去重、三尺寸对白框、重读和返回菜单。 |
| `--path . --rendering-method gl_compatibility --no-focus --position -12000,-12000 --script res://scenes/tests/ui/story_revision_review.gd -- --ui-smoke` | [60 状态图形夹具](review_final.log) | 中英 × 三尺寸 × 十状态；真实主场景承载，5F 完成路线为显式夹具。选句调用同一对白组件，登记／工作并非由这些截图证明。红灯截图单独翻转交付 flag 验证显示。 |
| `--path . --rendering-method gl_compatibility --no-focus --position -12000,-12000 --script res://scenes/tests/ui/reunion_dialogue_layout_smoke.gd -- --ui-smoke`，另加 `--english` | [中文 CG](cg_zh.log)、[英文 CG](cg_en.log) | CG 中英三尺寸，12 拍一拍一记录、共用对白框、旁白名牌隐藏、取消不记录。 |

## 画面检查

60 个状态均有原生截图，并生成以下缩览；另保留五张完整尺寸世界／结尾图和六张 CG 首拍图。本次查看了全部六张缩览及小尺寸中英文长段落、经理保留图、出口灯和英文 CG 原图，没有发现新稿对白裁切、空白区残图或名牌越界。

- 中文：[960×540](contact_zh_CN_960x540.jpg)、[1280×720](contact_zh_CN_1280x720.jpg)、[1920×1080](contact_zh_CN_1920x1080.jpg)
- English：[960×540](contact_en_960x540.jpg)、[1280×720](contact_en_1280x720.jpg)、[1920×1080](contact_en_1920x1080.jpg)
- [小窗口中文长对白](zh_CN_960x540_long_guest.png)、[小窗口英文长旁白](en_960x540_long_narration.png)、[经理旧 neutral](zh_CN_1280x720_manager_kept.png)、[雨夜结尾](zh_CN_1280x720_ending.png)、[交付后出口灯](en_1280x720_exit_green.png)
- [中文 CG 960](309_dialogue_zh_960x540.png)、[英文 CG 960](309_dialogue_en_960x540.png)

## 修正过程与限制

初次回归失败原始日志归档为 `initial_*`：逐句测试解析器未剥离全角空格；临时标题缺少英文，最终已恢复原游戏标题；旧画像、309、成功页测试仍假定旧咖啡馆 16 句、CG 36 拍或无结尾直接成功。按用户新稿更新预期，保留旧的任务、输入、取消、一次结算和最终 EXIT 检查。独立 309 夹具原先仅 hide 序章，没有关闭对白会话，导致新警报拒绝叠加；改用实际 `_finish()` 后通过。没有把夹具失败记成实际新局失败。

未执行真人键鼠完整试玩、另一台设备／macOS 实机和二进制导出。叙事中的送餐员、广播、敲门及填写文书以对白／旁白呈现，沿用已有操作点；未制作新动画、音效或敲门小游戏。英文为本次补译，尚未经组员文字审校。旧失败和旧基线证据不被本记录覆盖。
