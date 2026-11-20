# HUD 字号与信息层级验证（2026-11-20）

工作区：ae4pa-monster-dialogue-current；分支 work/member-D-monster-dialogue-current；基线 0ce69db。仅本地修改，未提交、推送或合入 main。

## 缩放和主题

- project.godot 原配置：1280×720，canvas_items，aspect=keep；未改项目设置、世界、相机或角色比例。
- 新增独立 hud_theme.tres，只给 HUD 使用，不修改 staff_ui_theme.tres。中文无衬线优先本机 Microsoft YaHei UI／微软雅黑，兼容 PingFang SC／Noto Sans CJK SC，并保留项目既有 hotel_staff_cjk.otf 作为字形回退。
- 楼层 28；关键提示和任务标题 20；目标 18；状态、时间、卡名、生效 16；A/B 与辅助按键 14。标题轻微加粗；正文暖白，标题浅金，次要信息灰绿，轻微阴影。
- 外边距 24，组间距 24，内容间距 8。任务牌保留原黄铜图；因为卷纹侵入，文字安全区横向 96、上下 32，均在逻辑画布中定义。
- 顶部左侧为提示与任务，右侧为楼层与两槽。任务标题／状态同一行、目标独立换行，避免牌面向世界下挤。A/B 仍指槽位；生效以文字、菱形与原金边共同表示。
- 楼层下隐藏旧的重复身份显示；隐藏节点仍可供旧接口读取，不改变卡片状态。

## 真实数据与接口边界

- 任务和时钟继续来自 get_task_view()，没有新 Timer。完成不显示剩余时间，也不虚构完成用时。
- READY_TO_SUBMIT 仍显示“待交付”和真实剩余时间：当前 A 的倒计时持续至真实交付，不能用 UI 假装停表。
- 下一目标从实际任务定义、enabled 列表、完成记录和前置条件读取，不写死 302，不发起任务或解锁。
- 当前无统一“下一主线目标”公开视图；没有可用后继任务时明确写“后续目标待主线接口提供”，不猜救援／逃脱流程。
- 保留 A 现有各阶段目标内容；D 只拆分标题、目标与状态。真实组件的 BLOCKED／ACTIVE 等提示优先于一般通知，elapsed／required_time 仍由组件提供，详细快照可悬停查看。
- 旧通知源文本保留，只隐藏旧显示实例，在 HUD 展示一次。只压缩已明确为当前身份要求的句式；遇到当前任务房门仍显示真实工作／交付目标，不能变成换证通关。确切身份要求已被当前 active_card 满足时，不留下旧警告。

## 修改文件

- scenes/ui/hud.tscn、hud.gd、hud_theme.tres、interaction_progress.gd
- scenes/task_hud.gd：只改展示传参，不改阶段条件
- scenes/task_ui.gd：只调整真实交互进度控件的显示挂点
- scenes/tests/ui/ui_test.gd：标题断言改查独立标题；活动状态核对真实时钟，非活动状态核对不冒充倒计时
- scenes/tests/ui/hud_layout_smoke.gd：真实 main 的尺寸／状态／卡槽／已有弹窗检查
- docs/qa.md、docs/progress.md、本证据目录

未修改 GameManager、CardManager、任务定义、怪物、门、楼层、全局主题、背包或对白场景。

## 本次实际验证

Windows；Godot 4.7.2.stable.official.ed1daf0bf，Compatibility / NVIDIA OpenGL。
所有运行使用项目外隔离 APPDATA／LOCALAPPDATA，未覆盖玩家已有进度。

| 检查 | 结果 | 日志 |
|---|---|---|
| 图形窗口加载真实 main 并渲染 HUD；1280×720、1920×1080、960×540 | 退出 0 | [after.log](after.log) |
| 当前 UI 回归 | 退出 0 | [ui-regression.log](ui-regression.log) |
| 202 正式主场景回归 | 退出 0 | [task02-regression.log](task02-regression.log) |
| git diff --check、新增文本空白与本页相对链接 | 通过 | 收尾命令检查 |

命令：
- godot --path . --script res://scenes/tests/ui/hud_layout_smoke.gd；AE4PA_HUD_EVIDENCE 指定截图输出目录
- godot --headless --path . --scene res://scenes/tests/ui/ui_test.tscn -- --ui-smoke
- godot --headless --path . --script res://scenes/tests/core/task_02_main_flow_smoke.gd

主场景渲染检查覆盖：无任务与空槽、进行中、待交付、完成、两槽及切换生效标记、过期身份提醒消失、真实组件受阻原因优先、长任务名、两行目标和三位房号；状态／时间保持单行且不与标题重叠，任务牌未遮挡所测房号、玩家与门上预警。新主题未渗入背包、暂停和对白，打开显示也已检查。

截图由真实 Godot 图形运行产生并查看，非设计稿。状态准备使用公开 API／A 现有回调和测试用卡片，跳过序章阅读、控制位置与时钟；204 通知复用用户给出的文字作为排版夹具，不证明该门有新任务。长文案只作用于复制的 UI 视图，不写管理器。不是本次人工完整五任务试玩或完整输入验收。

## 修改前后

| 内容 | 修改前 | 修改后 |
|---|---|---|
| 进行中与提示，1280×720 | [before-active.png](before-active.png) | [after-active.png](after-active.png) |
| 任务完成 | [before-completed.png](before-completed.png) | [after-completed.png](after-completed.png) |

- [1920×1080](after-active-1920.png)、[960×540](after-completed-960.png)
- [待交付](after-ready.png)、[无任务与空槽](after-none.png)、[长标题／两行目标夹具](after-long-fixture.png)
- [真实交互受阻提示](after-blocked-progress.png)
- [背包](after-bag.png)、[暂停](after-pause.png)、[对白](after-dialogue.png)

进行中对照使用同一状态与场景位置。后续截图为验证真实工作组件而移动过测试玩家，场景位置与门动画相位可能不同；游戏代码未改相机或玩家尺寸。

提交收尾：最新 origin/main 为 a802721，201／202 怪物对白已由 PR48 合入，本轮不重复提交。本文件上方为验证时记录；本轮按新授权整理提交／推送并准备新的 main 审查 PR，未重跑已通过测试，实际提交和 PR 状态见对应 PR。
