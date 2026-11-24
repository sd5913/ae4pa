# D：剧情 UI、双装备教学与超时演出（2026-11-23）

实测代码提交：`81c5451abeed7c8f75c88d5b16ce045bce0bd9aa`。工作区 `ae4pa-d-delivery-closeout`，分支 `work/member-D-ui-polish-v4`。Windows，Godot `4.7.2.stable.official.ed1daf0bf`，Compatibility。测试使用独立用户配置，未覆盖玩家设置。本轮未生成 CG、未替换人物图片、未修改管理器或主场景规则。

## 修改与接线

- 语言重影来自 OptionButton 原生文字和自定义 Label 两层。改为 MenuButton 的唯一原生文字层与 PopupMenu；箭头由代码绘制在右内侧20px。重复切换、弹出、关闭和本地化状态检查保留。
- 六条制作式旁白改为自然叙述，保留内部角色ID，仅修改玩家正文与对应英文键。去掉统一旁白括号。具体前后对照见 [text_changes.md](text_changes.md)。已读跳过固定右上24px；首次阅读限制与输入隔离未改变。
- 只抑制 HUD 重复目标和已列明的任务播报，保留错误、真实交互反馈与数据接口。背包底部关闭改为代码绘制圆形叉号；保留 CloseButton 标识、焦点、I 和 Esc。装饰弹窗通过统一主题加大左右和底部安全边距。暂停仅保留无图标的返回菜单／继续按钮，不再实例化语言控件。
- `scenes/ui/carol_ui_flow.gd` 由现有 D 背包场景加载，复用标准 dialogue 场景的 CAROL 立绘和姓名框。读取真实2/2装备，等待背包及其他模态关闭才开始；本局一次，恢复检查点不重播，新局清除。切换键来自 InputMap；三张卡已满时使用相应替代句，不声称仍有空收藏位。旧 A 引导中的双槽系统句仅在 D 表现层抑制。
- 超时监听既有 `game_failed("TASK_TIMEOUT")`，使用最近一次公开 `get_task_view().status` 展示未完成／待交付两种第二拍。这只是失败演出选句快照，不保存任务真值。演出只登记自己的模态并延后 Failure 显示；未再调用失败结算。重复通知不能重播。展示完成后恢复 A 已配置的原菜单。
- 更正此前接线记录：`scenes/task_ui.gd` 已连接 Failure 请求到 A 的检查点／菜单流程。本轮保留并验证该连接；同时修复偷窃CG结束时重新调用 show_failure 会覆盖既有重试配置的问题。没有新增 A 接口需求。

## 自动与图形结果

以下最终运行均退出0；日志在 `logs/`：

- 资源导入、本地化、intro_flow、story_surface、完整 ui_test。
- `third_card_bag_smoke.gd -- --ui-smoke`：读取完新增教学后，保留原三收藏／双装备、换槽、Q切换、HUD、反馈与快照断言。
- task_checkpoint、theft_failure：原偷窃／超时恢复、结算与CG回归。
- 新 `narrative_ui_smoke.gd` 图形运行中文1280×720、英文960×540：唯一语言文字层、六次切换、背包开着不叠教学、四拍教学一次、Esc关闭／模态释放、两种超时选句、重复失败通知不重播、原重试恢复、每次失败仅一个事实事件、菜单清理。
- 同脚本 `--controls-only`：真实楼梯／任务面板、已读重播右上24px。
- `git diff --check`。

旧本地化测试的 OptionButton 类型、暂停语言入口和旧下边距预期已按本轮明确需求更新，其余状态与输入断言保留。初次运行的控件类型错误、遗漏引用、旧边距预期及缺少 `--ui-smoke` 的三卡测试失败日志作为历史保留，不计为通过。

## 证据与限制

- `zh1280/` 与 `en960/`：cover、narration、bag、equipment、pause、floor_selection、task_details、read_skip_top_right、timeout_active、timeout_ready、failure。
- `equipment_timeout.avi`：Godot Movie Maker，479帧／30FPS，约15.97秒，含双装备教学、两种超时对白与原失败菜单。
- 所有本轮图形截图来自实例化的正式 `scenes/main.tscn`。任务前置通过真实公开API准备，超时通过推进 A 的实际 `_process` 加速时钟触发；不是人工等待完整时限或人工完整新局通关。录屏同属自动化正式场景证据，不能替代真人测试。
- 已目视检查语言文字、中文旁白、双装备画面、英文待交付超时、暂停及英文任务详情安全边距。正常游戏另从同一绝对路径启动，供用户继续实际操作。
- A 审查入口：`scenes/main.tscn`；重点复核物理鼠标／键盘、语言弹出状态、已读跳过、任务超时后重试与返回菜单。无需新增任务接口。人工全流程、导出和跨机器结果未在本轮代记。
