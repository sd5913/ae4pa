# C-V4-01～03 独立组件交接（2026-11-12）

> 2026-11-13 更新：PR #12 已合并，main b4c57d0 已有 A 的真实201／普通202／唯一E／安全退回，B 快照与清理组件也已交付。下文“尚未实现”描述属于首次独立交付的历史状态。最新点位、本机复核、C-V4-04／05和待联调项见 [最新交接](v4_m2_handoff.md)。

## 基线、权限与接口状态

分支 `work/member-C-yinshiqi`，HEAD `ce95720`，开工工作区干净。只 fetch 刷新引用；远端 main=`9f8cb9e` 已包含本分支，分支落后 7 个提交，无本分支独有提交。用户保留合并权，本轮没有合并 main，也没有提交、暂存或推送。按 `origin/main` 读取最新 AGENTS、PLANS、game-design、team-plan、interfaces、qa 及 A 的 `a_v4_m0_handoff.md`，没有把旧本地文档当作 V4 接口冻结证据。

最新接口 §13.4 的三个信号仍为候选，`request_safe_return` 尚未实现；A 的部分任务代码也注明只在 A 本地。本次不臆造或调用这些缺失入口，用 `v4_test_receiver.gd` 明确标为 TEST DOUBLE，记录接收事件和模拟退回/任务锁；不能把它当作已完成 A/D 联调。

## F6 与 201 配置

入口：`res://scenes/tests/doors/v4_doors_test.tscn`。

201 同源 `monster_door` 参数：`room_id="201"`、`monster_type="NOSE"`、`door_mode="STORY"`、`task_id="TASK_01_CLEAN"`、`story_radius=120`、位置 `(700,560)`。保留 `setup(player)`、`reset_cycle()`、三段时长、radius、offset 和五怪判断。

- A/D 移动；首次到达固定区自动发介绍请求，和 OPEN/WARNING/CLOSED 无关。
- T 模拟接受、Y 模拟清理完毕、回 201 按 E 请求交付；这些只在测试接收方改变镜像，不代表真正接取/清理。
- 1 调用真实 CardManager 配保安卡；Q 使用真实换卡入口；R 重置独立测试。
- NORMAL 门 x=1100，默认 EYE；左右安全点 x=950/1250；相邻门 x=2000；后段锁 x=1450。
- 工作点 x=900 仅为路线标记。接受后仍可到 x=900 和楼梯侧 x=192；Y 后许可仍关闭，E 交付成功才由测试接收方开放。门关闭不影响后段锁。

生产门不自行监听 E，A 的唯一世界目标路由选择后调用 `request_interaction()`。正式 D UI 不使用 T/Y/R 调试键。

## A 需要连接的候选事件与回调

| 事件 | A 的责任 | 当前状态 |
|---|---|---|
| `story_intercept_requested(task_id, room_id)` | 核对楼层/来源/其他活动任务后请求介绍；不启动倒计时 | 沿用候选签名；测试记录接收 |
| `task_submit_requested(task_id)` | 检查剩余时间、清洁事实、来源和距离，结算后才开后段许可 | 沿用候选签名；门不直接结算 |
| `rule_violated(reason, approach_side)` | 连接时绑定源门实例，读取 room_id，按登记点退回；不回滚任务 | 沿用候选签名，正式退回未接 |
| `story_progress_requested(task_id)` | 再次接近时读取真实进度，仅显示提示；不可重新 offer/accept | 本轮最小提示扩展，待 A 确认 |

`rule_violated` 不增加第三个参数，以免暗改候选契约。按以下方式绑定源门，A 即可同时得到唯一节点、room_id、原因和来向：

```gdscript
door.rule_violated.connect(on_door_violation.bind(door))
# on_door_violation(reason: String, approach_side: int, source: Node2D)
# 若 A 最终采用 request_safe_return(source, reason, approach_side)，在接收方适配。
```

新增最小组件入口（待正式接收方确认）：

- `set_story_state(status)`：A 适配自己的任务视图后推送 NONE/AVAILABLE/ACTIVE/READY_TO_SUBMIT/COMPLETED/FAILED。只是显示/交互镜像，不保存跨层任务真值、倒计时或许可。A 重建门时必须在恢复世界前推送状态。
- NONE 首次触发一次；AVAILABLE 再进区不连播；ACTIVE/READY 再进区只发一次进度提示；READY 不自动提交；COMPLETED 放行，FAILED 等 A 恢复。普通检测与 STORY 模式互斥。
- `request_interaction() -> bool`：仅有效玩家在固定区、PLAYING、非冻结且 READY 时发一次交付请求；返回 true 只表示已发请求，不表示任务已完成。A 接受或拒绝后再推送状态确认；不要每帧刷新来清除交付请求保护。
- `finish_safe_return() -> bool`：A 完成退回并验证全局安全后调用；仍在本门范围内返回 false。只负责解除本门该次去重，不替 A 验证邻门/路障，不移动主角。

`reset_cycle()` 只恢复 offset 对应相位，不清剧情请求、不解除待退回状态。跨层是否已接任务、已完成由 A 恢复镜像；重试从 AVAILABLE/FAILED 等状态显式恢复到 NONE 后才允许重新介绍。换主角绑定会清来向采样和当前玩家的普通违规锁。

## 双向安全点与恢复要求

`approach_side=-1` 表示从门左侧进入，`+1` 表示右侧。取进入水平检测区前最后一次外侧位置；进入后反向行走或翻转朝向都不改变本次来向。首次出生在门区且没有外侧样本时不猜方向、不发退回事件，A 必须把出生/回访/恢复点放在安全区。

报告前设置 pending，同次检测和真实换卡都不会连发；主角移出再返回也不能绕过 A 的待退回协调。A 中断长按、锁输入、处理统一恢复后，验证安全并确认完成；不能只给门一个任意世界坐标让其传送。

安全点至少满足：

1. 严格在本门水平区外；左右点在各自来向侧，不能借退回跨过门或任务路障。
2. 不落在任何相邻门水平区、201 固定剧情区、路障/碰撞体或不允许的出生位置。
3. 与当前位置处于同一可达区域；路径也不能穿过未开放路障。点不在路障上不等于路径安全。
4. 留出缓冲距离，不贴边；扩大 radius 或 story_radius 后重验。测试的 ±150 比 radius=90 多 60px；两点均在 201 的 ±120 区外、邻门区外、x=1450 后段锁前。
5. 同帧多门报告由 A 全局协调去重，弃掉过期来源；恢复期间继续拒绝其他退回，不得两个组件各自移动主角。测试接收方示范同物理帧拒绝第二次退回，正式多源世界联调仍待 A。

测试接收方 `safe_point_valid` 刻意拒绝本门、邻门、剧情区、路障及锁后方位置；不是可直接用于任意正式楼层的安全算法。正式 A 点位及碰撞路径必须重验。任务时间继续/警告模态停表由 A/D 统一管理，测试接收方不提供计时器。

## 实测与未测

Godot `4.7.2.stable.official.ed1daf0bf`，Windows / Compatibility。

- `--headless --max-fps 60 --path . --script res://scenes/tests/doors/v4_doors_smoke.gd`：PASS。覆盖三种相位首次拦截、重复进入不连播、ACTIVE 提示、READY 必须交互、工作/回楼梯路径与独立任务锁、600 组五怪事件后果矩阵、30 组真实换卡/备用槽装备、普通刷新不报警、左右来向与反向朝向、同次违规一次、区域内不能确认退回、测试接收方同帧拒绝二次退回、不安全点拒绝、暂停恢复后真实核验事件。
- `door_cycle_smoke.gd`、`foundation_smoke.gd`：PASS，保留周期与底座回归。
- MCP 实际启动 v4_doors_test，图形输出正常，errors 为空，检查后停止。
- 旧 `eye_door_smoke`、`monster_rules_smoke`、`door_handoff_smoke` 内 V3 FAILED 断言已不适用，本轮不冒充通过；其五怪/身份判定覆盖迁入新脚本。旧脚本保留供后续迁移，当前 V4 验收运行新入口。

待联调：A 的正式任务视图/offer/submit/安全退回，真实后段路障、跨层重建及检查点、D 的对白/进度/警告与 E 消费；背包冻结前上下文、冻结中换装核验及关闭前退回留 M2。本轮没有正式清洁动作、倒计时、卡快照或完成整条 201 主线，不修改 A/B/D 模块或主场景。完整多门同帧的 A 原子协调和碰撞路径验证也不能以测试接收方代记通过。

## 本轮文件与提交状态

只修改 `scenes/doors/monster_door.gd` 与门 README，新增本文件及 `scenes/tests/doors/v4_*` 场景/脚本/UID。未修改公共文档；本记录放在 C 模块内满足用户指定范围。提交、推送和合并由用户操作。

### 2026-11-12 上传授权更新

上文记录的是初次开发时的操作边界。用户随后明确要求“帮我操作上传”，现授权将上述 8 个文件提交至 `work/member-C-yinshiqi`、推送并提 PR，仍不合并 main。上传前重新运行 v4_doors_smoke、door_cycle_smoke、foundation_smoke，均 PASS。

A 最新反馈：201 已在 A 本地改为 NOSE，202 移到 x1550，但真实门尚未实例化。此布局未在 C 本机出现；x560/x1120 及 C 独立测试的 x950/x1250 均不能直接认定为正式安全点。A 接入真实门、E 路由和 request_safe_return 后，双方按最新布局验证安全点与工作/回楼梯路线。测试接收方仍只作独立验证，不代表正式联调完成。
