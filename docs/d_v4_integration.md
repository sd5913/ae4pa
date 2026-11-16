# D-V4-02—06 接入与对白调用表

基线为 A 的 `work/member-A-liuling`，已快进至 `02be61823a97e0b7527bd34256dcd9eda9c1bd9c`。

## UI 接线

| 入口 | 公开接口与数据 | 谁负责下一步 |
|---|---|---|
| 任务详情 | `MissionBoard.open_task_details()` 与 `configure_task_details(details)`；面板读取 `get_task_view()`。按钮调用 `accept_task(task_id)`，成功才发 `task_accepted(task_id)`。 | A 继续提供当前任务、目标、限时及任务文案；任务 02—05 未开放。 |
| 任务失败 | `Failure.show_failure(reason)` 后调用 `configure_retry(available, message)`。TaskLayer 用 `can_retry_current_task()` 决定是否允许，收到 `retry_requested()` 后复核再调用 `retry_current_task()`。 | A 管理检查点；没有可恢复快照时按钮禁用。普通违规沿用 `safe_return_started(reason)` 提示。 |
| 楼梯 | 楼层在现有唯一 E 路由发 `floor_selection_requested()`，TaskLayer 调用 `open_floor_selection()`。页面选项来自 `get_available_floors()`，提交前关闭自己的模态，然后调用 `request_floor_travel(floor_number)`；拒绝时恢复选择。 | A 校验方向、位置和楼层资格。独立楼层场景未接信号时沿用原 E 换层。 |
| 暂停 | Esc 打开／关闭，「继续游戏」关闭；暂停和楼层选择分别登记 `PAUSE`、`FLOOR_SELECT`。候选已登记对白、任务、失败、背包和帮助各自的模态。 | A 负责世界输入和任务钟，D 只登记界面。 |
| 笔记 | 通过 `notebook_changed()` 重读 `get_notebook_view()`，按 `UNKNOWN`、`HINT`、`KNOWN` 展示状态及管理器提供的名称和正文。 | A 管理解锁。 |
| 交互进度 | 每次 `floor_changed` 清理旧订阅，从当前楼层 Staff／CleaningSpot 的 `get_interaction_state()` 以 `target_id` 注册，并监听 `interaction_state_changed(target_id, state)`。从楼层 `get_interaction_target_id()` 选择当前目标，直接显示状态、阻塞原因、0–1 比例、已用／所需时间。完成、取消、抓获、恢复及模态变化重新读取或隐藏。 | B 的组件持有交互状态和时间。A 接入后段任务物件并纳入楼层 E 目标选择后，同一 HUD 可显示对应组件。 |

## 剧情和结局

| 调用方 | 对白 ID／入口 | 触发与完成 |
|---|---|---|
| A 主场景 | `V4_INTRO` | 点击开始，调用 `show_dialogue`。监听 `dialogue_finished("V4_INTRO")` 后恢复 1F 控制。候选已接入。 |
| A 前台 E 路由 | `V4_MANAGER_TALK` | 玩家靠近经理首次交谈。完成由 A 记录，开放 2F。候选已接入。 |
| A／C 任务房 | 任务 01 接取、交付 | 当前走 201 的任务提示、面板和交付事件，暂无独立对白 ID。 |
| A／C 任务房与 B 工作点 | 任务 02—05 的接取和交付 | 202 包裹、303 登记、402 巡房表、503 离店单已有任务定义。独立对白 ID、台词和接线待确认。 |
| A 的 309 E 路由 | `RESCUE_309` | 策划规定登记解除后才能播放。现有两句和完成信号保留，已接闺蜜立绘。策划确认临时兼职被登记为长期合同、登记已解除、楼下员工通道封锁、五楼消防通道可逃离。合同和登记的具体补充台词未确认。候选只有 309 预留点，没有登记解除／救援事件。A 负责消费完成信号、记录救援和开放 4F。批准即结算及救援后回访范围仍待 A 确认。 |
| A 的 5F EXIT | 结局对白 ID 待确认 | 策划要求任务 05 交付且已救援，玩家按 E 后切旅馆外景。候选 EXIT 是预留位，没有通关事件。D 的既有通关页入口为 `show_win()`，按钮发 `restart_requested()`／`return_to_menu_requested()`。A 负责结算和跳转，统计字段待 A 提供。 |
