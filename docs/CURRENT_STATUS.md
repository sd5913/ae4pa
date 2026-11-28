# 当前项目状态

核对日期：2026-11-23（香港时间）。当前基线：GitHub [`main@cac0214`](https://github.com/sd5913/ae4pa/commit/cac0214d9845a2bae8c6dcb7a55000755e10e19c)。阶段 A 文档、阶段 B Linux／Windows CI、阶段 C 项目 Skills 已合并，见[执行清单](../PLANS.md#开发工作流升级)。此页记录当前实现、可复核的自动化结果和仍待完成的验收；历史证据保留在 [QA](qa.md) 与[进度记录](progress.md)。

## 本地工作分支附加验证（2026-11-24）

以下是独立工作分支 `work/member-A-disguise-onboarding` 对 `main@ac58302b29499a4243dd302876a8f24e84be013a` 的分支改动验证；这些修改尚未进入 GitHub `main`。成功偷取工作证现在只增加收藏；第一次装备与激活由玩家在安全位置手动完成，NPC 正在观察时会阻止 Q 换身份和背包装备。新增逐步引导及对应英文文本。如果检查点撤回首张证件，立即清除引导与背包高亮，重新取证后恢复首张证件引导。

- Godot `4.7.2.stable.official.ed1daf0bf`：`foundation_smoke`、`staff_core_smoke`、`work_items_smoke`、`known_monster_rules_smoke`、`task_door_lifecycle_smoke`、`late_mainline_main_flow_smoke -- --ui-smoke`、首次身份引导、三卡背包、身份服装、游戏操作回归、检查点回归、`v4_identity_smoke`、`checker_safe_bag_smoke`、`player_identity_outfit_smoke` 及 `full_mainline_escape_smoke` 均退出 0。完整主线本次从正式新局通过 201–205、302、309 救援、403、501 到 EXIT 成功页。
- `localization_smoke` 在当前沙箱未能完成：测试无法向 Godot `user://` 写入对白进度文件（`Unable to save completed intro state: Can't open file`），因此不能将该项标记为通过；翻译断言之后的流程未由该次运行完整验证。
- 正式主场景通过 Godot MCP 在本机以 Compatibility 渲染器启动；启动日志未见运行时脚本错误。本次没有人工操作窗口或目视评估教学提示和布局；日志仍有原项目其他脚本的整数除法、类型等警告。
- `full_mainline_escape_smoke` 在 `main@dca61f7` 上的两次 EXIT 断言失败仍是历史记录；本分支的完整路线已有新的退出 0 证据，不覆盖旧记录。先前最新 main CI 的 203／205 `TASK_INACTIVE` 诊断也保留为历史日志；本次完整路线仅出现测试预期的错误身份交互诊断。
- 真人试玩、原生画面与真实鼠标拖放、Windows／macOS 同提交验收及目标系统导出仍未在本分支验证。用户此前确认另一轮真人完整通关且未发现问题，但该轮 SHA 和平台待补录，不能记作本分支或跨平台验收。

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

## C 确认人物立绘增量（2026-11-26）

原始27张确认素材已通过 PR #80 归档。接入代码 `3daaa314976eb4343e327470aa176357e407bf3d` 基于 main@230521d：Carol五表情、Terese四表情及16句咖啡馆映射、经理统一neutral已替换正式半身对白；Carol教学/任务组件同样使用新立绘，Q版动画尚为源素材。Windows Godot4.7.2四项针对性功能回归及中英三尺寸60个Compatibility立绘渲染检查通过；导入退出0但保留编辑器safe-save提示。详见[独立证据与未测范围](qa_evidence/confirmed_portraits_20261125/README.md)，不替代其他模块、真人、导出和跨平台验收。

C 合并复测：`000940b` 已整合 main@4d86f95（A教学与D角色美术更新），保留其场景Q版、头像、封面和CG；半身对白优先使用用户本次确认的Carol/Terese原图，经理全部neutral。五项功能检查及60状态Compatibility复测退出0，见同一证据页。前文“Q版尚为源素材”指本次C单独交付，不撤回D已在main接入的Q版。

C最终同步3563072已保留PR #76存档集成（main@4e6405a）；此前D记忆UI“未接入磁盘”的表述属于旧基线，最新存档范围与限制以A在进度记录和qa_evidence/a_memory_integration_20261125的交接为准。本轮C在此基线上四项功能、存档UI和60状态立绘复测退出0。

## 最终人物选择修正（2026-11-26）

按用户最新明确要求，01d9f25保留当前试玩main@4d86f95的组员Carol半身立绘（对白、表情、教学/任务均保留），仅Terese四张及经理neutral使用用户版本。此前C替换Carol的条目属于被本次要求替代的历史方案。五项针对性功能回归和66状态Compatibility检查退出0，[最终证据](qa_evidence/confirmed_portraits_20261125/README.md)。原始27张确认素材完整保留。

## 2026-11-26 用户新剧情接入（本地分支）

`work/member-C-story-revision-20261126` 在 main@4ae5577 上有未提交修改，尚未推送或合并。用户新稿的 149 拍已接入正式主线，开场改为三天前旧消息，309 后新增警报，实际 EXIT 后播放雨夜结尾再显示成功。仅四句完全相同的说话人／台词保留原立绘，其他新增或改写对白左侧留空；Carol／Terese／经理的最终人物选择保持。

本地 Windows Godot 4.7.2 完整新局至 EXIT、任务后段、逐句立绘、原人物解析、序章输入、本地化、309 与两进程存读回归退出 0；中英三尺寸 60 状态及 CG 图形检查通过。它们是独立工作区证据，不能替代 GitHub main、真人连续计时、macOS 或导出验收。详见[本次记录](qa_evidence/story_revision_20261126/README.md)。

## 2026-11-26 完整对话清单与最终确认立绘（最新本地状态）

用户最新170段完整清单已替代上节149段删节稿，恢复两段卧室、咖啡馆、旅馆外及完整经理对白。Carol13/Terese7/经理3种确认表情按句接入，五怪使用固定半身，309仅整幅CG，旁白/CG框收回左侧留白。新局至真实EXIT、存读档、逐句/输入/本地化及中英三尺寸画面复测通过。仍为 main@4ae5577 之上的未提交本地工作，未推送合并；跨平台、导出、真人连续试玩未测。[本次范围、命令、诊断及画面](qa_evidence/complete_dialogue_20261126/README.md)。

## 2026-11-26 同步 main 与发布候选复核

用户已授权提交、push及合入main。远端main与开发基线4ae5577一致，无冲突；运行时代码与确认立绘已提交至c895c0a。独立干净检出导入、逐句170段/23表情、正式序章和完整新局八项任务至实际EXIT均退出0。既有无关导入文件保留本地未提交。[审查、命令和提交指纹](qa_evidence/complete_dialogue_20261126/publish/README.md)。GitHub远端检查与最终合并状态以本次PR为准；前文未提交/未授权属于接入时历史状态。


## 2026-11-27 场景衔接与旁白增量（最新本地状态）

此前完整清单已通过PR #86合入main@67c27fd8。本轮work/story-chapter-cues-20261127在此基线上新增「序章1卧室／2咖啡馆回忆／3卧室／4旅馆外／309重逢」五处报幕，配无人背景、淡入和停留后点击/E继续。七段旁白恢复背景字；用户随后指定309开头长旁白保留底部框。170段剧情、立绘和救援/EXIT接口保留。

独立无缓存候选导入、七项功能回归（含实际新局八任务至EXIT）、中英三尺寸78幅Compatibility报幕/旁白检查均退出0。[候选指纹、命令、画面、初次失败与限制](qa_evidence/chapter_narration_20261127/README.md)。本轮仍为未提交本地增量；真人、macOS/另一设备、导出与存读专项未复测。


2026-11-27发布接力：用户现已授权本轮提交、push和合入main；同步远端后确认基线仍为67c27fd8，沿用本轮候选散列与已完成验证。最终远端CI和合并状态以本轮PR为准。


## 2026-11-28 已确认动效报幕接入（本地）

`work/animated-chapter-cards-20261128` 基于 bcf13b1，保留上一项人物尺寸增量，将原五处报幕替换为已确认的棕金纸纹动效，并在逃离 CG 前新增「终章 · 共赴长夜」。罩层实时处理下层原场景，透明文字和装饰分层播放，不使用设计预览中的生成场景图替换原背景；报幕期间隐藏跳过按钮。入场 2.8 秒、点击/E 后退场 0.85 秒，首句和原结算接口保留。

独立无缓存候选导入、F5 底座／正式开场／本地化／完整新局八任务至 EXIT 四项功能回归，以及中英三尺寸 84 幅 Compatibility 实际报幕与旁白检查均退出 0。长英文标题的菱形避让修正后重跑图形矩阵；实际工程新增资源导入亦退出 0。未提交、推送或导出；真人、跨平台与存读专项未测。见[本轮代码、命令、指纹与实际画面](qa_evidence/animated_chapters_20261128/README.md)。

## 2026-11-28 报幕罩层保色修订（本地）

按用户实机反馈，罩层改为保留原场景色相、叠加半透明暖棕纸纹，取消先灰度化后整体棕色映射；标题附近柔和压暗。唯一运行差异为chapter_paper.gdshader，文字、装饰、时间、剧情和输入未改。独立验证副本重新导入退出0，最终材质中英三尺寸84幅Compatibility报幕/旁白与门控复查退出0。未重新执行完整主线或导出；原运行中的游戏须重启加载。见[保色修订证据](qa_evidence/animated_chapters_20261128/color_revision/README.md)。未提交推送。

2026-11-28 罩层浓度追加：棕色染层由18%–26%提高到35%–45%，继续保留场景色相。仅材质参数变化，Compatibility双语三尺寸84幅复查退出0。见[最新不透明度记录](qa_evidence/animated_chapters_20261128/color_revision/README.md)。

2026-11-28 报幕发布接力：用户已授权提交、push及合入main。本次只发布报幕，人物放大8%和其他候选美术仍独立保留本地。已移除人物尺寸增量后复测确切暂存候选：四项功能及中英三尺寸84幅Compatibility检查全部退出0。[发布候选、指纹、复核范围与日志](qa_evidence/animated_chapters_20261128/publish/README.md)。最终远端CI和合并状态以本次PR为准。

## 2026-11-29 恢复序章一后的原手机聊天（本地）

按用户要求，从历史版本原样恢复 21 条聊天气泡与 3 段电话／输入状态提示，接在「序章 1 · 卧室」报幕后。复用原手机界面和摇晃动画，恢复「1 条新消息」通知，原 170 段及 A001「维斯佩拉……」保留。独立验证目录及源工程导入退出 0；194 段对白／表情、正式开场、翻译、输入组件、独立预览和六处报幕门控六项检查退出 0；中英三尺寸 Compatibility 实际开场 54 张复跑通过并已检查。首轮图形索引断言失败及复跑诊断、导入 safe-save 提示均保留，未把未定位的首轮失败说成已修复；未复测完整通关、存读迁移、导出和跨平台。见[来源、命令、指纹、画面与限制](qa_evidence/phone_intro_restore_20261129/README.md)。未提交推送；原有立绘尺寸改动保留。下次从正式新游戏「序章 1」后查看手机。

## 2026-11-29 手机聊天与 A001 发布候选

用户已授权 push 并合入 main。发布分支 `work/restore-phone-intro-20261129` 基于最新 `main@9d8a09ab585af528d5ba85b7e7b2a711481a63c7`，保留音乐 PR #85；只加入手机聊天恢复、A001 台词修订和相关测试证据，排除独立的人物放大 8% 及候选美术。上述历史工作树检查含该人物增量，不能直接记作此发布候选画面；本分支将由精确 head 的 GitHub CI 检查，合并以该结果为准。已按 pr-risk-review 核对输入门控、信号与状态归属、JSON／TSV 一致性、资源／UID 和英文键；当前差异未发现可复现的新增阻塞，首轮图形索引失败原因仍未定位，历史日志保留。独立无缓存导入与发布候选复核在本地继续进行。

## 2026-11-29 PR #90 发布复核与测试清理

发布候选已无缓存导入，正式开场、194 段对白、翻译及完整八任务到 EXIT 均退出 0；Compatibility 中英三尺寸 54 张实际手机画面通过并查看。首轮远端翻译 PASS 后仍有退出资源错误，因此测试在引擎运行时释放主场景并等待四帧，不放宽任何断言或 CI 错误规则。图形额外推进追踪到测试 helper 之外的一次输入分发，截图夹具隔离原生窗口输入后复跑通过；实际输入分发仍由正式开场检查覆盖。临时诊断未进入游戏运行代码。见[最终来源、命令、日志、指纹与画面](qa_evidence/phone_intro_restore_20261129/publish/README.md)。主线与测试当前结论以此条及 PR #90 最新 head CI 为准；历史失败保留，未新增真人／跨平台／存读迁移验收。
2026-11-29 PR #90 退出诊断：398e47a 的构建仍在翻译断言全部通过后报告两个 ObjectDB 实例及一个资源未释放，单纯释放主场景未解决远端退出检查；不得视为已修复。仅对该检查增加 --verbose 输出以定位资源路径，保留 grep 错误失败条件和全部断言。远端修订与最终结论继续记录于 PR #90。
## 2026-11-29 PR #90 音频退出残留定位

--verbose 远端日志已确认残留为 the_haunted_ballroom_1.mp3 的 AudioStreamMP3 / AudioStreamPlaybackMP3，并非对白数据或图片。释放主场景后固定四帧在高帧率 headless 环境中可能早于下一次音频混音，因此本地化测试改为使用 WeakRef 观察播放实例，在最多一秒内等待实际释放，并新增失败断言；未改音乐运行逻辑或忽略 CI 错误。本地正常模式检查退出 0，证据见[精确资源名称](qa_evidence/phone_intro_restore_20261129/publish/ci_audio_leak_excerpt.log)与[释放断言结果](qa_evidence/phone_intro_restore_20261129/publish/localization_audio_release.log)；最新 head 的远端检查待完成。