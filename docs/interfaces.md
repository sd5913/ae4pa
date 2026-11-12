# 怪物员工通道公共接口与 V4 迁移提案

本文件按《Monster Staff Access Godot三周逐步分工 共享美术版 V2》第 01—03 部分的职责起草，供 A/B/C/D 在同一 Godot 项目中接入模块。它对应手册中建议的“接口约定.txt”，统一使用本 Markdown 文件维护，不再创建第二份接口清单。

**阅读顺序：第 1—12 节保留 V3 兼容基线及旧接口约定，遇到冲突以第 13 节和本节的“实际状态”为准；第 13 节仍以 V4 目标提案为主，A 的部分入口已在本地实现。新增接口经审阅并实际实现后才能接正式按钮。** 任务回访、普通门退回和任务检查点将替代旧行为，不能同时执行两套后果。

现行产品规则见 [项目主策划](game-design.md)，人员任务及交付顺序见 [ABCD 分工 2.0](team-plan.md)。本文专门维护接口及其实现状态，本次文档整合不改变已有函数或信号。

函数表示“调用另一个模块做事”，信号表示“通知其他模块某事已经发生”。调用者按本文约定使用接口，模块内部实现由对应负责人决定。

**当前状态（A 本地未提交版本，不等于共享 main）：A-05 已将 B 的员工／三卡双槽接入 1F 与主入口；A-V4-02 的任务 01 状态／计时独立入口与 A-V4-03 的 1F↔2F 回访已加入。** 正式经理对白、201 任务门／污渍、卡片快照、检查点重试、世界模态冻结与正式 UI 尚未接入；不能把独立任务测试当作 201 通关。B 正面偷卡仍只拒绝，C 五怪组件尚未组装进主流程。实现边界见 [M0 交接草案](a_v4_m0_handoff.md)。

| 模块 | 当前真实可用 | 尚待实现 |
|---|---|---|
| GameManager | 旧状态与失败接口、任务 01 独立状态／计时入口、模态停表、经理对白完成标志、合法 1F↔2F 楼梯请求与已到达层；受限开发预览 | 卡片快照／检查点重试、正式对白与 201 组件、后续任务、救援、通关和返回菜单 |
| CardManager | 查询／重置、`collect_card`、`switch_active`、`equip_card`、Q 输入、`cards_changed`／`identity_changed` 实际通知 | UI 接入；空槽／无效操作等规则确认及非游玩输入边界验收 |
| HotelPlayer | 移动、`is_moving`、朝向、`set_walk_bounds`、`set_movement_locked`、相机 | 偷卡／怪物／剧情组件的实际接入 |
| 员工 | `staff.tscn`、`setup(player)`、转身、长按偷取、取消和回头失败，已接 1F；成功通知接临时反馈 | 正面偷取当前仅拒绝，待 B 迭代；转身预告／正式 UI 反馈仍待交付 |
| 房门 | `monster_door.tscn`、`setup(player)`、`reset_cycle`、三状态、可见预警、五怪检测、offset、多门独立测试 | 主流程接入及 V4 剧情拦截／普通退回；实参以门 README 为准 |
| 正式 UI | 仅独立测试骨架 | 菜单、HUD、背包、剧情、失败／结局页面 |

## 1 负责人和依赖

| 负责人 | 实现并维护 | 对外提供 | 主要依赖 |
|---|---|---|---|
| A 组长 | 项目设置、GameManager、Player、主场景、楼层、救援流程、重试与通关连接 | 游戏状态、失败入口、主角引用、楼层组装和 UI 事件连接 | B 的卡片／员工、C 的门、D 的 UI |
| B | CardManager、工作人员、偷卡、三卡与双槽数据 | 当前卡、查询／收集／换卡接口、卡片变化通知、可复用员工场景 | A 的 Player 和 GameManager |
| C | 通用房门、三状态计时、五怪判定 | 可配置的门场景，按约定报告失败 | A 的 Player／GameManager、B 的当前卡和换卡信号 |
| D | 菜单、HUD、背包显示、手册、对白、失败／通关 UI、QA | UI 场景、按钮请求信号、显示方法和测试记录 | A 的游戏状态与流程、B 的卡片接口 |

A 先发布可运行公共底座，B/C/D 再从该版本开发。A 创建 CardManager 的最小骨架并配置 Autoload；B 接手后负责内部实现。D 不写第二份卡片数据；C 不重写 Player；A 组装组件，不复制 B/C 的逻辑。

接口文档由 A 组织确认，B/C/D 补充各自模块的实际情况。变更公共签名时，同时更新本文、调用者和对应验收记录，不能只在个人分支悄悄改名。

## 2 公共名称和数据

为减少跨脚本类型依赖，首版公共标识使用 GDScript `String`，调用时写完整字符串，例如 `"SECURITY"`。不要混用数字编号、中文名或另一套同义名称。以后若改为枚举，由 A 协调全部调用者一起迁移。

| 类别 | 允许值／类型 | 约定 |
|---|---|---|
| 卡片 ID | `"SECURITY"`、`"CLEANER"`、`"MANAGER"` | `"NONE"` 表示没有当前卡或空槽，不是可收集的第四张卡 |
| 佩戴槽 | `int`，`0` 或 `1` | `0` 为槽 A，`1` 为槽 B |
| 怪物 | `"EYE"`、`"NOSE"`、`"HAT"`、`"EAR"`、`"CHECKER"` | 全部使用同一个门组件 |
| 门状态 | `"CLOSED"`、`"WARNING"`、`"OPEN"` | 只有 OPEN 执行怪物检测 |
| 游戏状态 | `"MENU"`、`"LOADING"`、`"INTRO"`、`"PLAYING"`、`"RESCUE_DIALOGUE"`、`"FAILED"`、`"WON"` | 已提供 MENU／PLAYING／FAILED 及同步换层期间的 LOADING；剧情和通关状态随功能接入 |
| 失败原因 | `"STAFF_CAUGHT"`、`"WRONG_CARD"`、`"MOVED_NEAR_EAR"`、`"SWITCHED_NEAR_CHECKER"` | B/C 报告标识，D 转成中文 |
| 楼层 | `int`，`1`—`5` | 不用场景文件名或字符串代替 |
| 主角类型 | `HotelPlayer`，当前继承 `CharacterBody2D` | main 已引入员工检测所需碰撞；仍使用现有水平移动接口 |
| 世界位置 | `Vector2`；横向判定使用 `global_position.x` | 玩家、员工和房门比较同一世界坐标，不混用不同父节点的局部 x |

`GameManager` 和 `CardManager` 是两个 Autoload 名称，只由 A 修改 `project.godot` 配置。主角、员工、房门和 UI 作为场景实例接入，不新增另一套全局管理器。

## 3 A 提供 GameManager

目标文件：`scripts/game_manager.gd`。B/C/D 可以读取公开状态并调用下面的请求函数；状态字段只由 A 的游戏流程代码写入。

| 字段 | 类型 | 含义 |
|---|---|---|
| `game_state` | `String` | 当前游戏状态，默认 MENU |
| `current_floor` | `int` | 当前楼层，默认 1 |
| `has_friend` | `bool` | 是否已完成 309 救援，默认 false |
| `fail_reason` | `String` | 本次失败原因；没有失败时为空字符串 |

| 函数签名 | 调用者 | 职责 | 实现阶段 |
|---|---|---|---|
| `start_game() -> void` | A 接收 D 的开始／重新开始请求后调用 | 重置卡片、楼层、失败和救援进度；已注册宿主时重新装载 1F，否则沿用独立测试的 PLAYING 行为 | 已实现；正式开场仍待接入 |
| `fail(reason: String) -> void` | B 的员工、C 的门 | 仅在 PLAYING 接受失败，先更新为 FAILED 再通知 UI；同次失败不重复处理 | 任务 05 |
| `retry_floor() -> void` | A 接收 D 的 Retry 请求后调用 | 重新进入当前楼层入口并重置门计时；卡片、装备和救援恢复按对应功能阶段的规则执行 | 任务 08、10 |
| `set_floor_host(host: Node2D, enable_preview: bool = false) -> void` | A 的场景入口 | 指定只容纳楼层实例的 World；默认不开启开发预览。宿主须位于世界原点、无旋转、缩放 1 | A-07 已实现 |
| `go_to_floor(floor_number: int) -> void` | A 的旧楼层出口调用 | 现转发 V4 `request_floor_travel`，按对白／任务前置、已到达层和楼梯实际距离核对；不再以三卡判断 1F 上楼 | A-V4-03 本地已改；正式 D 楼梯列表仍待接入 |
| `preview_floor(floor_number: int) -> void` | A 的 F6 开发入口 | 仅宿主显式开启预览、使用 editor 可执行程序且处于 PLAYING 时可跳到 1—5F；不改变卡片或救援数据，导出程序中禁用 | A-07 开发工具，正式流程不调用 |
| `rescue_friend() -> void` | A 的 309 流程 | 完成救援进度，同一局重复调用不重复触发救援通知 | 任务 10 |
| `win() -> void` | A 的 5F 出口逻辑 | 进入 WON，停止游玩输入并通知 D 显示结局；重复触发不重复结算 | 任务 10 |
| `return_to_menu() -> void` | A 接收 D 的返回菜单请求后调用 | 返回 MENU；新一局重置仍统一经过 `start_game()` | 菜单接入阶段 |

| 信号签名 | 发出时机 | 主要接收者 |
|---|---|---|
| `state_changed(new_state: String)` | 状态改变后 | A 的场景协调、D 的界面 |
| `game_failed(reason: String)` | 一次有效失败被接受后 | D 的失败界面，由 A 连接 |
| `floor_changed(floor_number: int)` | 新楼层加载、放置和绑定完成后 | D 的 HUD |
| `friend_rescued()` | 救援进度首次完成后 | A 的跟随显示、D 的任务提示 |
| `game_won()` | 进入 WON 后 | D 的通关界面，由 A 连接 |

当前可用接口以上表为准；`retry_floor`、`rescue_friend`、`win`、`return_to_menu` 及救援／结局信号仍仅为约定，不得把未实现接口接到可点击按钮或把空函数当成完成。

A 的装载顺序为：读取／实例化场景 → LOADING → 旧层移出树并排队释放 → 更新 current_floor → 新层加入宿主、完成出生点、相机及 1F 员工 setup → PLAYING → floor_changed。换层不调用 CardManager 重置，也不改变 has_friend。主入口和 F6 预览监听 floor_changed 后连接当前楼层临时反馈；房门 setup 和正式 UI 仍待接入。

关卡装载过程中由 A 禁止玩家和怪物检测，待绑定完成再允许 PLAYING；具体装载实现属于 A 的内部职责。失败和对白阶段也不继续处理游玩输入。暂停树与 UI 的详细处理在相应功能阶段确定，不在本文件预先指定背包是否暂停。

## 4 B 提供 CardManager

目标文件：`scripts/card_manager.gd`。B 是唯一卡片数据维护者；其他模块通过属性或查询函数读取，通过操作函数请求修改。

| 读取入口 | 类型 | 含义 |
|---|---|---|
| `active_card` | `String` | 当前生效卡，由佩戴槽和当前槽推导；无有效卡为 NONE |
| `active_slot` | `int` | 当前槽 0 或 1 |
| `get_owned_cards() -> Array[String]` | 查询函数 | 返回已获得卡片的副本，外部修改返回数组不改变真实数据 |
| `get_equipped_cards() -> Array[String]` | 查询函数 | 返回长度为 2 的佩戴槽副本，空位为 NONE |
| `has_card(card_id: String) -> bool` | 查询函数 | 是否已经获得该卡 |
| `has_all_cards() -> bool` | 查询函数 | 三张规定 ID 是否全部获得；旧 A-07 使用，V4 不以此判断 1F 上楼 |

| 操作函数签名 | 调用者 | 职责 | 实现阶段 |
|---|---|---|---|
| `reset_for_new_game() -> void` | A 的 GameManager | 清空已获得卡与两个槽，当前槽回 0、当前卡回 NONE，并通知显示刷新 | 任务 05 骨架，由 B 后续维护 |
| `collect_card(card_id: String) -> bool` | B 的工作人员 | 新卡成功入库返回 true；不允许重复获得。第一张进入 A、第二张进入 B、第三张留背包 | B 的偷卡／收集阶段 |
| `switch_active() -> bool` | B 的 Q 输入处理 | 请求切换当前佩戴卡；成功操作返回 true | B 的切卡阶段 |
| `equip_card(card_id: String, slot_index: int) -> bool` | D 的背包按钮 | 请求调整指定槽，保留三卡所有权且最多佩戴两张；成功操作返回 true | B/D 的装备阶段 |

上述收集／切卡／装备方法已由 B 在 main 实现；空槽切换、重复装备和非 PLAYING 输入的实际行为仍需在相应接入阶段与规则核对，不因已有方法就视为全部验收。不得另存一套卡片数据。

| 信号签名 | 作用 | 接收者 |
|---|---|---|
| `cards_changed()` | 卡片数据已更新，刷新 HUD／背包 | D；A 的通行条件显示 |
| `identity_changed(action: String)` | 玩家成功进行了主动切卡或装备替换 | C 的核验客 |

`identity_changed` 的 `action` 为 `"SWITCH_ACTIVE"` 或 `"EQUIP_CARD"`。它表示一次主动身份操作；即使替换的是备用槽，也不能让核验客漏掉该操作。B 先完成数据变更，再同步发出通知，不能通过延迟一帧或清空临时标记丢失事件。

收集卡片、重置新局或单纯刷新界面只使用 `cards_changed`，不伪造玩家主动换卡。打开背包本身不属于装备替换。空槽切换、重复装备、无效操作及 UI 暂停时能否操作，由 B/C/D 在对应功能阶段共同确认；未确认前不宣称这些边界已实现。

## 5 A 提供 Player

目标文件：`scenes/player/player.tscn` 和相邻的 `player.gd`。A 声明 `class_name HotelPlayer`，并把主角加入 `player` 分组；每个可玩的测试／楼层场景只有一个主角。

| 入口 | 类型／签名 | 用途 |
|---|---|---|
| `global_position` | `Vector2`，Godot 节点已有属性 | B/C 读取位置；A 负责出生点和楼层放置 |
| `is_moving` | `bool` | C 的大耳客读取当前横向行走状态 |
| `facing_direction` | `int`，-1 向左、1 向右 | A 的人物朝向与后续跟随显示 |
| `set_walk_bounds(left_x: float, right_x: float) -> void` | 方法 | A 按楼层设置世界坐标中的左右边界 |
| `set_movement_locked(locked: bool) -> void` | 方法 | B 在偷卡期间请求禁止移动，结束／取消后解除该次锁定 |

Player 负责 move_left／move_right，松键即停，无上下移动和跳跃。除移动锁外，非 PLAYING 状态也禁止移动；因此 B 结束偷窃时解锁不能把失败中的角色重新放开。多个界面共同锁定、同时按方向键及边界上的移动状态，在实际功能阶段确认。

Player 不保存当前卡和背包副本；需要身份时读取 CardManager。

## 6 B 提供工作人员场景

以下为目标约定。当前实际 `staff.gd` 使用 `steal_hold_time`（默认 0.8）而非 `steal_duration`，转身由场景 TurnTimer 配置，未暴露 turn_interval 或实现转身预告；正面尝试只发失败的 steal_attempted 通知，没有调用 GameManager.fail。A 接入前需协调这些差异，不直接使用下表中尚不存在的导出字段。

目标文件：`scenes/staff/staff.tscn` 和相邻脚本。保安、保洁、经理使用同一个组件。

| 公开配置 | 类型 | 原型起点 |
|---|---|---|
| `card_id` | `String` | SECURITY／CLEANER／MANAGER 中的一项 |
| `turn_interval` | `float` | 3.0 秒，可调 |
| `steal_radius` | `float` | 55.0 像素，可调 |
| `steal_duration` | `float` | 0.8 秒，可调 |

接入方法为 `setup(player: HotelPlayer) -> void`：A 实例化员工后注入主角；B 的独立测试场景也使用该方法。员工不依赖主场景的绝对节点路径。

B 负责转身、背后判定、偷窃计时和卡片收集。成功调用 `CardManager.collect_card(card_id)` 后，发出 `card_stolen(card_id: String)` 供 A 连接提示；失败调用 `GameManager.fail("STAFF_CAUGHT")`。同一张卡不能重复提供。

A-05 在 `floor_1.tscn` 的 `StaffRoot/SecuritySlot/Staff`、`CleanerSlot/Staff`、`ManagerSlot/Staff` 放入三个员工实例，楼层 ready 时绑定同一个 Player。`floor.gd` 监听 card_stolen 并通过 `notice_requested(text: String)` 提供临时获得消息，主入口／预览连接显示；CardManager 的 cards_changed 驱动双槽及当前卡显示，普通显示刷新不发换卡通知。员工附近的临时文字读取 is_player_in_range／is_player_behind／is_stealing 和 facing_direction，不另写偷卡规则。

E 的按住／松开检测属于 B 的偷窃功能；A 负责救援和出口 E。正式场景接入时 A/B 统一有效目标，避免一次 E 同时偷卡和换楼层。目标优先级及取消细节在任务 08 确认。

## 7 C 提供通用房门

**C-06～C-13 实现补充（2026-11-07）：** 同一 `monster_door` 已实现 EYE/NOSE/HAT 当前卡表、EAR 实际移动检查、CHECKER 同步 `identity_changed` 检查。`setup(player)` 重复绑定不重复订阅，移出场景树断开通知；暂停/非游玩/无有效主角不检查。EAR 的物理优先级为 1，在默认 Player 后读取本帧位移。备用槽装备也属于核验事件，空槽切换沿用 B 实际发出的信号，无效装备和普通刷新不伪造事件。已提供三门错相位测试与本机自动回归；正式美术、主游戏整合及团队试玩未完成。

下表七个字段均已在检查器暴露。`offset` 表示已走过的周期秒数，按三段总长取模（支持负值）；`reset_cycle()` 恢复此配置相位，不保证总为 CLOSED。默认 0 从 CLOSED 开始。参数在实例化前设置，或修改后调用 reset_cycle。选用 OPEN 相位可能在出生点立即检测，A 应将出生点放在范围外并保留预警与等待空间。接入示例、参数边界和验收限制见 [门模块说明](../scenes/doors/README.md)。

目标文件：`scenes/doors/monster_door.tscn` 和相邻脚本。五怪共用组件，只更改配置及素材。

| 公开配置 | 类型 | 原型起点 |
|---|---|---|
| `room_id` | `String` | 如 `"201"` |
| `monster_type` | `String` | EYE／NOSE／HAT／EAR／CHECKER |
| `radius` | `float` | 90.0 像素 |
| `closed_time` | `float` | 5.5 秒 |
| `warning_time` | `float` | 1.4 秒 |
| `open_time` | `float` | 2.8 秒 |
| `offset` | `float` | 初始相位偏移秒数，默认 0.0 |

这些数值由 C 在检查器暴露，A 摆门时填写。位置用门节点的 `position` 设置，检测时使用 `global_position`；不再另存一份可能与节点不一致的 x。

| 方法签名 | 调用者 | 用途 |
|---|---|---|
| `setup(player: HotelPlayer) -> void` | A 或 C 的测试场景 | 注入主角，并连接必要的卡片通知；重复绑定同一实例不重复订阅 |
| `reset_cycle() -> void` | A 的重试流程或 C 的测试场景 | 回到本门配置的初始相位；重载楼层时可由新实例初始化完成 |

C 只在 PLAYING、门为 OPEN、主角在检测半径内时检查：

- EYE／NOSE／HAT 读取 `CardManager.active_card`，错误时调用 `GameManager.fail("WRONG_CARD")`。
- EAR 读取 `player.is_moving`，移动时调用 `GameManager.fail("MOVED_NEAR_EAR")`。
- CHECKER 接收 `CardManager.identity_changed(action)`，在通知发生时检查门和主角范围，违规调用 `GameManager.fail("SWITCHED_NEAR_CHECKER")`。

C 不响应普通走路来判定核验客，也不监听 HUD 刷新当作换卡。检测时没有注入主角的门不得访问空引用；独立场景必须准备主角并绑定。

## 8 D 提供 UI 和剧情

UI 保存在 `scenes/ui/`，不设另一份卡片或楼层真值。A 通过实例引用和信号连接 UI，B/C 不直接查找失败界面的节点。

| 场景目标 | D 提供的接口 | A 的接入方式 |
|---|---|---|
| `main_menu.tscn` | `start_requested()`、`help_requested()` 信号 | 开始流程连接 GameManager；说明按钮连接手册 |
| `hud.tscn` | 初次显示读取 GameManager 和 CardManager；监听 `floor_changed`、`cards_changed` | 放入主场景 UI 层；两槽和当前卡均读取 B 的数据 |
| `bag.tscn` | 用户确认装备时调用 `CardManager.equip_card(card_id, slot_index)` | A 放入 UI 层；D 处理 I 的打开／关闭，布局和暂停策略稍后确认 |
| `help.tscn` | `open_help() -> void`、`close_help() -> void` | 菜单说明按钮和 H 使用同一份说明内容 |
| `failure.tscn` | `show_failure(reason: String) -> void`；`retry_requested()`、`return_to_menu_requested()` 信号 | `game_failed` 连接显示；按钮信号连接 GameManager 对应请求 |
| `dialogue.tscn` | `show_dialogue(dialogue_id: String) -> void`；`dialogue_finished(dialogue_id: String)` 信号 | A 传入 `"INTRO"` 或 `"RESCUE_309"`，结束后继续 A 的流程 |
| `win.tscn` | `show_win() -> void`；`restart_requested()`、`return_to_menu_requested()` 信号 | `game_won` 连接显示，重开连接 `start_game()` |

以上场景名称为本次目标约定。通用提示如“获得保安 ID”由 D 在 HUD 提供 `show_notice(text: String) -> void`；A 把 B 的 `card_stolen` 信号转换成对应文案。

失败文案映射：STAFF_CAUGHT → 偷窃被发现；WRONG_CARD → 当前工作证不符合要求；MOVED_NEAR_EAR → 大耳客开门时仍在移动；SWITCHED_NEAR_CHECKER → 核验客面前更换了工作证。

UI 首次显示时主动读取现有数据，之后监听通知刷新，不能假定“打开界面之前的信号”会重新发送。D 可以做占位排版和展示，背包操作效果须等 B 的对应接口实现后验收。

## 9 输入处理归属

| 输入动作 | 项目设置 | 处理负责人和位置 |
|---|---|---|
| `move_left`、`move_right` | A | A 的 Player |
| `interact` | A | B 的偷卡；A 的救援／出口；有效目标由 A/B 在接入时统一 |
| `switch_id` | A | B 的 CardManager 单一入口；D 不再同时处理 Q |
| `open_bag` | A | D 的背包／UI 控制脚本，只请求 B 修改数据 |
| `open_help` | A | D 的手册／UI 控制脚本 |
| `pause` | A | D 的 UI 发出请求，A 负责游戏流程；具体策略待功能阶段确认 |

按钮和按键必须调用同一业务入口。卡片操作不能因界面和 Autoload 各监听一次而执行两次；非游玩阶段如何开放 UI 由 A/D 在接入时统一。

## 10 场景接入与独立测试

A 的 `scenes/main.tscn` 管理当前楼层实例和 UI 层；楼层、员工和房门作为独立场景引用，保持 V2 的文件归属。A 负责放置 Player、员工、门、出生点与出口，不要求 B/C/D 依赖固定的主场景节点路径。

接入顺序为：加载楼层与 Player → 放置／读取组件 → 对员工和门调用 `setup(player)` → 连接 UI 信号并同步初始状态 → 开始该楼层的游玩更新。楼层卸载后旧实例不能继续触发新楼层逻辑。

| 独立测试场景目标 | 负责人 | 必须自己准备的依赖 |
|---|---|---|
| `scenes/tests/core/core_test.tscn` | A | Player、走廊、公共管理器 |
| `scenes/tests/staff/staff_test.tscn` | B | A 的 Player、一个员工、公共管理器、偷卡结果提示 |
| `scenes/tests/doors/doors_test.tscn` | C | Player、门、可设置身份的调试入口；该入口调用 B 已实现的接口 |
| `scenes/tests/ui/ui_test.tscn` | D | UI 场景、公共管理器和明确标识的测试数据准备 |

F6 独立测试同样使用项目的两个 Autoload。测试场景可以显式开始测试新局，不能每帧重置状态。未完成的卡片功能应显示“尚不可测”，不往正式 UI 写一份假背包数据。调试入口不进入最终玩家操作流程。

B/C/D 提交给 A 的交接内容为：场景及脚本、公开配置说明、使用的接口、F6 启动场景、实际验证结果、截图／日志和未完成项。A 按 V2 先接 B，再接 C，最后接 D；每次接入回归已完成行为。

## 11 调用链核对

下表为按约定进行的文档级核对，未表示代码已运行。

| 场景 | 调用或通知链 | 职责边界 |
|---|---|---|
| 偷卡成功 | B 员工 → `CardManager.collect_card(card_id)` → `cards_changed()`；员工 → `card_stolen(card_id)` → A 连接 D 的提示 | B 修改数据，D 显示 |
| 门前身份错误 | C 门读取 B 的 `active_card` → `GameManager.fail("WRONG_CARD")` → `game_failed(reason)` → D 的 `show_failure(reason)` | C 检测，A 接受失败，D 显示 |
| 主动换卡 | B 的 Q 或 D 背包 → CardManager 操作 → `cards_changed()` 与 `identity_changed(action)` → D 刷新、C 即时检查核验客 | 换卡事实由 B 单点通知 |
| 失败重试 | D 按钮 → `retry_requested()` → A 连接 `GameManager.retry_floor()` → 重载／重置楼层及重新绑定 | D 不直接重载场景 |
| 309 救援 | A 的 309 交互 → D 的 `show_dialogue("RESCUE_309")` → `dialogue_finished(dialogue_id)` → A 的 `rescue_friend()` → `friend_rescued()` | A 管进度和跟随，D 管对白 |
| 五楼通关 | A 的 EXIT → `GameManager.win()` → `game_won()` → D 的 `show_win()` | C 不额外实现出口或结局 |

## 12 后续确认与验收

| 待确认内容 | 负责协调 | 确认阶段 |
|---|---|---|
| 背包交互布局、是否暂停、手册／暂停期间可用的操作 | A/B/D，涉及核验时加入 C | 背包、手册和暂停开发 |
| 空槽切卡、重复装备和无效请求如何反馈 | B/C/D，A 确认 | 三卡双槽与核验客接入 |
| E 的目标选择、长按取消、偷窃期间移动输入 | A/B | 工作人员与主流程接入 |
| 同时按左右键、边界处的移动状态 | A/C | 主角移动及大耳客接入 |
| 装备快照、3F 救援后本层重试及恢复顺序 | A/B/D | 重试与救援开发 |
| 正式开场、场景加载和对白期间的完整状态转换 | A/D | 菜单、剧情和楼层接入 |

本文件登记基础接口和各成员的交付边界，以上问题不阻塞底座搭建。后续每实现一个接口，更新真实可用状态和 [进度记录](progress.md)，再按 [QA](qa.md) 验收；旧 V3-T01—V3-T14 游戏主线用例当前仍未执行；新版用例使用 V4-T 前缀。

## 13 V4 目标接口提案（尚未实现）

本节主要是审阅候选契约；A 的部分首轮入口已在本地实现，具体见本节末的实际状态。依据为 [主策划 V4](game-design.md) 和 [D-01—D-10 衔接建议](v4-migration.md#4-需要审阅的衔接规则)，由 A 在 V4-01 组织 B/C/D 确认。源案没有要求另建任务 Autoload；首轮继续只用 GameManager／CardManager。当前只把任务 01 常量放在 GameManager，其他任务尚未实现。

### 13.1 数据与固定标识

| 所有者 | 目标字段／概念 | 规则与读取者 |
|---|---|---|
| A GameManager | `current_task_id: String`、`task_status: String`、`remaining_time: float` | 无任务为 NONE；同一时间最多一个限时任务。D 只读，不自行扣秒 |
| A | `completed_task_ids`、`story_flags`、`world_flags`、`visited_floors`、`unlocked_note_ids` | 通过返回副本的查询给 B/C/D；不暴露可直接改写的共享数组 |
| A | 任务检查点 Dictionary | 包含接取层／安全点、上述事实及 B 的卡片快照；深拷贝，非磁盘存档 |
| B CardManager | 已有 owned／equipped／active_slot | 保留真实唯一来源；A 只保存 B 导出的副本 |
| C 门实例 | 门周期、来向、一次违规／剧情请求保护 | 临时组件状态，不保存跨层任务是否完成 |
| D UI | 显示状态、模态层栈 | 不持有另一份卡片／任务真值；页面关闭不丢业务进度 |

保留现有 `current_floor`、`has_friend`、三卡大写 ID 和五怪 ID。新增任务状态候选为 `AVAILABLE`、`ACTIVE`、`READY_TO_SUBMIT`、`COMPLETED`、`FAILED`，无任务用 NONE。任务失败与当前游戏 FAILED 可关联，普通门退回使用短暂 `RECOVERING`；对白／模态锁不能被某个单独组件解除。

| 任务 ID | 触发／结算 | 工作对象 ID 与事实 |
|---|---|---|
| TASK_01_CLEAN | 201 接取／交付 | STAFF_CLEANER_1F → CLEANER；STAIN_201 → `stain_201_cleaned` |
| TASK_02_PARCEL | 202 接取／交付 | STAFF_SECURITY_2F → SECURITY；PARCEL_CABINET_2F → `parcel_collected`／`parcel_delivered` |
| TASK_03_AUTHORIZE | 303 接取；按 D-05 建议在登记台结算 | STAFF_MANAGER_1F → MANAGER；REGISTER_309 → `registration_309_approved` |
| TASK_04_PATROL | 402 接取／交付 | STAFF_PATROL_4F → PATROL_RECORD；`patrol_collected`／`patrol_delivered` |
| TASK_05_EXIT | 503 接取／交付 | EXIT_REGISTER_5F → EXIT_FORM；`exit_form_approved`／`exit_form_delivered` |

这些标识是拟议统一命名。A 在任务定义中映射目标、所需当前卡、步骤和通路。对 C／D 不另发一套缩写；世界物品仍只用少量事实，不建通用背包。

### 13.2 A 的目标操作与通知

| 候选签名 | 调用者 | 行为与边界 |
|---|---|---|
| `get_task_view() -> Dictionary` | D、B/C 测试 | 返回副本：任务 ID／状态／步骤／目标地点／所需卡／时限／剩余时间；UI 不解析场景名字推导规则 |
| `is_interaction_allowed(target_id: String) -> bool` | A 目标选择、B 组件 | 查当前任务、故事、已完成和模态状态；工作组件另查距离／朝向／当前卡 |
| `offer_task(task_id: String) -> bool` | C 请求后由 A 协调 | 检查前置，进入介绍／可接取；不启动计时，不覆盖活动任务 |
| `accept_task(task_id: String) -> bool` | D 接受请求经 A | 先深拷贝接取前状态，后设 ACTIVE 与完整时限，重复接受无效 |
| `record_work_result(target_id: String) -> bool` | B 成功事件经 A | 校验任务、来源、步骤、剩余时间和当前权限，写事实；不接受任意 UI 直接设完成 |
| `submit_task(task_id: String) -> bool` | C 交付请求经 A | 校验目标和事实，一次结算；01／02／04／05 必须交付，03 由工作结果按任务定义结算 |
| `retry_current_task() -> void` | D 失败按钮经 A | 恢复接取前检查点，等待再次接受；不同于旧约定 `retry_floor` |
| `get_available_floors() -> Array[int]` | D 楼梯 UI | 返回已到达且可访问的层，加满足条件的下一新层；源层不作为跳转目标 |
| `request_floor_travel(floor_number: int) -> bool` | D／A 楼梯交互 | 必须靠近有效楼梯且 PLAYING／允许的楼梯模态；再次验证条件，拒绝任意调用跳层 |
| `request_safe_return(door: Node2D, reason: String, approach_side: int) -> void` | C 普通违规 | A 选择已登记安全点、中断长按、去重并退回，不回滚任务；不能信任任意传入世界坐标 |
| `request_task_failure(reason: String) -> void` | B 员工／A 超时 | 只接受有效活动任务的一次失败；没有活动任务的处理受 D-01 限制 |

新增事件候选：`task_offered(task_id: String)`、`task_updated()`、`task_completed(task_id: String)`、`task_failed(task_id: String, reason: String)`、`notes_changed()`、`safe_return_started(reason: String)`。D 接任务更新后读取快照；不要求业务信号每帧发出，HUD 可只读刷新剩余秒。现有 `floor_changed`、`cards_changed` 保留。

`STAFF_CAUGHT` 保留为任务失败原因，新增 `TASK_TIMEOUT`；普通门仍可用 `WRONG_CARD`／`MOVED_NEAR_EAR`／`SWITCHED_NEAR_CHECKER` 说明违规，但不再凭 reason 字符串统一进入整任务失败。必须按事件类型分流，D 显示对应 UI。

### 13.3 B 的组件与快照

2026-11-12 用户以 A 身份确认任务门控、正式 E 路由和恢复次序，详见 [A/B 对接约定与 B 的实施步骤](a_v4_m0_handoff.md#6-b-反馈后的-ab-对接约定a-已确认)。B/C/D 仍需核对各自调用点；本节签名为目标接口，不代表 A/B 新方法已经实现或 B 的代码已经提交。

- CardManager 拟增 `export_snapshot() -> Dictionary`、`restore_snapshot(snapshot: Dictionary) -> bool`。内容只含 `owned_cards`／`equipped_cards`／`active_slot`，导出必须深拷贝；恢复先完整验证，无效快照不改状态。有效恢复不调用逐个 collect/equip，不发 `identity_changed`，只发一次 `cards_changed`。
- `collect_card`、`switch_active`、`equip_card` 保留名称；新增状态检查，快照恢复走专用接口，不借玩家操作入口绕过锁。
- Staff 保留 `setup(player)`、`begin_steal()`、`cancel_steal()`；新增目标 ID 和奖励类型 CARD／TASK_ITEM。正式楼层的 E 由 A 只派发给一个目标，B 的独立 F6 可保留测试输入适配层。B 在长按开始和奖励结算前都查 A 的 `is_interaction_allowed(target_id)`；卡奖励继续由 B 修改 CardManager，任务文件发 `task_item_stolen(item_id: String, target_id: String)`，由 A 记事实。
- 工作点拟为 `work_point.tscn`，公开 target_id、interaction_type（CLEAN／PICKUP／AUTHORIZE）、required_card、hold_duration；方法 `setup(player: HotelPlayer)`、`begin_interaction()`、`cancel_interaction()`，成功候选信号 `work_requested(target_id: String)`。A 接受 `record_work_result` 后通知刷新，组件不能先把拒绝的工作当成功。
- 长按期间持续验证资格，离开目标／移动／松键／切卡／打开页面时取消。员工回头被发现优先上报失败；该帧不能又授卡或给文件。
- 员工／工作点的已取／已做状态由 A/B 数据读出并刷新，场景卸载不丢。B 的局部 `_is_stealing` 只是临时进度，不进任务检查点。

### 13.4 C 的目标事件与配置

保留 setup、reset_cycle、七个门参数。拟增加 door_mode（NORMAL／STORY）、task_id、固定触发区、左右安全点引用；A 在楼层放点，C 校验位置。门 ID 仍用 room_id，A 组合楼层形成唯一门引用。

候选信号：`story_intercept_requested(task_id: String, room_id: String)`、`task_submit_requested(task_id: String)`、`rule_violated(reason: String, approach_side: int)`。由 A 连接到任务／退回流程，C 不直接改 completed_task_ids。

剧情门优先级：首次合法接取请求 → 活动任务进度／可交付交互 → 已完成放行。与普通 OPEN 检测互斥，同一帧不能两种后果都发。接受任务允许工作路线、完成才解锁后段，按 D-04 落地。普通门规则仍以 PLAYING／OPEN／范围为主；背包装备的核验使用 D-02 约定的上下文快照，不简单沿用暂停时 `_can_check` 恒假的旧逻辑。

### 13.5 D 的请求与模态边界

| UI 目标 | 候选请求／显示 | 数据来源 |
|---|---|---|
| 任务面板 | `accept_requested(task_id)`；`show_task_offer(task_view)` | A 的任务快照 |
| 任务 HUD | 展示步骤／计时／楼层／卡 | A 任务与楼层，B 卡；无自建 Timer |
| 楼梯面板 | `floor_selected(floor_number)` | A 的当前允许列表，选择后 A 再验证 |
| 失败页 | `task_retry_requested()`、`return_to_menu_requested()` | A 的 task_failed，不自行 reload 场景 |
| 普通警告 | `show_warning(reason)` | A 已接受的安全退回事件 |
| 调查笔记 | `open_notes()`／关闭请求 | A 的已解锁条目，D 的文本资源 |
| 对白 | 沿用 `show_dialogue(id)`、`dialogue_finished(id)` | D 内容，A 决定剧情何时记账 |
| 背包 | 调用 B 的 `equip_card`，操作前保留核验上下文 | B 真数据，C 规则，A 模态协调 |

A/D 统一模态栈：任务介绍／对白／笔记／背包／暂停／楼梯选择打开时取得暂停理由，关闭释放自己的理由；还有其他模态时不得恢复世界。D 页面在世界冻结时仍可响应按钮。楼梯选择属于整合建议的模态范围，加载也暂停计时。

背包真实换装若在冻结前的核验门 OPEN 范围内，记录并处理违规；关闭页面、恢复世界之前先完成安全退回，不能等待下一帧让玩家先跑出范围。内部卡快照恢复不作为主动换装。

### 13.6 输入与执行顺序

1. A 的当前场景协调世界 E 目标；优先 UI，再可交付／救援／剧情对话，再有效工作／偷窃，最后楼梯／出口。同级取最近距离，平局按固定 target_id；具体候选距离由组件给出，不能仅靠显示文字判断。
2. 接受长按后固定该目标到成功／取消；不因附近另一组件出现就切目标。B 处理内部计时，A 负责开始／释放路由，不保留 B 与 A 两套同时消费 E 的监听。
3. Q 仍由 B 单一入口处理；I／H／Esc 由 D 控制并请求 A 模态状态；移动仍由 Player。失败／加载／恢复时均拒绝世界动作。
4. 建议同帧业务顺序：更新有效游玩时间 → 若归零先任务失败 → 校验并接受工作／交付 → 同步状态与通知 → UI 刷新。交付成功后再播对白；不得边播交付对白边继续扣时。
5. 重试顺序以主策划 §7 为准；恢复和普通退回都是原子协调流程，防止跨层旧实例的延迟信号推进新任务。

### 13.7 迁移检查

- 旧 `go_to_floor` 的只前进／三卡门槛已在 A 本地迁为合法楼梯请求；D 正式楼梯 UI 仍待接入，开发 `preview_floor` 继续独立。
- 旧 `retry_floor` 仍未实现，不新增一个假空函数供 D 调用；V4 实现 `retry_current_task`。
- 旧 C `GameManager.fail` 调用迁移为普通违规事件；B 被抓迁移为任务失败，不能把两者合并处理。
- 保留旧自动检查中仍有效的三卡／五怪条件覆盖，对被 V4 改掉的行为先新增预期，再更新旧断言。新增任务测试路径待实现后登记，不把拟议文件名当可运行命令。
- 新增方法／字段完成后，负责人把对应行标为“已实现”，附场景与验证，再由 A 接入。

### 13.8 2026-11-11 A 本地实际状态

| 入口／行为 | 实际状态 | 限制 |
|---|---|---|
| `complete_manager_intro() -> bool` | 已实现 A 侧故事标志；主入口有明确标记的开发代记按钮 | D 正式对白及首看流程未连接 |
| `get_task_view()`、`get_completed_task_ids()`、`get_world_flags()` | 已实现返回副本；当前只定义任务 01 | 后四任务、完整笔记／物品表未落地 |
| `offer_task`、`accept_task`、`record_work_result`、`submit_task` | 已实现任务 01 的状态、清理权限、交付去重与结果；独立测试通过 | 201/C 门、B 污渍点和 D 按钮尚未连接；接受前卡快照未实现 |
| `set_modal_open(modal_id, is_open)` | 已实现多个模态共存时的任务停表 | 目前只停任务秒数，未锁 Player／门／长按；正式 UI 不可直接当完整暂停使用 |
| `request_task_failure`、`task_failed` | 已实现任务 01 超时与有效任务内员工被抓的状态通知 | 检查点恢复待 B 快照；A 已确认无任务时不能开始偷窃，当前 B 旧员工代码尚未落实 |
| `get_available_floors()`、`request_floor_travel()` | 已实现已到达层与下一层门槛、真实楼梯距离校验；1F↔2F 自动测试通过 | D 楼梯列表未连接；2F→3F 需要未实现的任务 02，后段回访限制待 M2 |
| `request_safe_return`、`retry_current_task` | 尚未实现 | 依赖 C 安全点／B 卡片快照，不能接可点击正式按钮 |

现有 `go_to_floor` 只转发合法楼梯请求；1F 不再查三卡。任务 01 的剩余时间由 GameManager 在 PLAYING 且无打开模态时递减，待交付阶段继续计时，归零后拒绝工作和交付。`task_01_smoke.gd`、`floor_return_smoke.gd` 为当前独立检查，验证记录见 [进度](progress.md)。
