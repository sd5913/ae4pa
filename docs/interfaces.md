# 怪物员工通道公共接口约定

本文件按《Monster Staff Access Godot三周逐步分工 共享美术版 V2》第 01—03 部分的职责起草，供 A/B/C/D 在同一 Godot 项目中接入模块。它对应手册中建议的“接口约定.txt”，统一使用本 Markdown 文件维护，不再创建第二份接口清单。

函数表示“调用另一个模块做事”，信号表示“通知其他模块某事已经发生”。调用者按本文约定使用接口，模块内部实现由对应负责人决定。

**当前状态：公共管理器骨架、Player、主场景和测试走廊已实现并在 A 本机验证。** 员工、房门、正式 UI 和后续流程尚未实现。V2 规定了职责和功能，但没有固定以下全部函数名、参数和信号；这些名称是本次为协作拟定的约定。A 组织 B/C/D 对照文档接入，成员确认仍待进行。背包、暂停及详细交互继续在相应功能阶段确认。

| 模块 | 当前真实可用 | 尚待实现 |
|---|---|---|
| GameManager | 四个状态字段、`start_game`、`fail`、`state_changed`、`game_failed` | 楼层、重试、救援、通关和返回菜单 |
| CardManager | 当前卡／槽只读属性、查询副本、`has_card`、`has_all_cards`、`reset_for_new_game`、`cards_changed` | 收集、切换和装备操作；`identity_changed` 已声明但尚无主动换卡行为 |
| HotelPlayer | 移动、`is_moving`、朝向、`set_walk_bounds`、`set_movement_locked`、相机 | 偷卡／怪物／剧情组件的实际接入 |
| 员工／房门／正式 UI | 仅独立测试场景骨架和放置 slot | 本文各模块的业务接口与功能 |

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
| 游戏状态 | `"MENU"`、`"INTRO"`、`"PLAYING"`、`"RESCUE_DIALOGUE"`、`"FAILED"`、`"WON"` | 基础阶段先提供 MENU／PLAYING／FAILED；剧情和通关状态随功能接入 |
| 失败原因 | `"STAFF_CAUGHT"`、`"WRONG_CARD"`、`"MOVED_NEAR_EAR"`、`"SWITCHED_NEAR_CHECKER"` | B/C 报告标识，D 转成中文 |
| 楼层 | `int`，`1`—`5` | 不用场景文件名或字符串代替 |
| 主角类型 | `HotelPlayer`，继承 `Node2D` | A 在 Player 脚本声明该类名；B/C 使用相同类型 |
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
| `start_game() -> void` | A 接收 D 的开始／重新开始请求后调用 | 初始化新一局，重置卡片、楼层和救援进度；底座测试先进入 PLAYING，正式开场和 1F 由 A 后续接入 | 任务 05 提供骨架；任务 08 接正式流程 |
| `fail(reason: String) -> void` | B 的员工、C 的门 | 仅在 PLAYING 接受失败，先更新为 FAILED 再通知 UI；同次失败不重复处理 | 任务 05 |
| `retry_floor() -> void` | A 接收 D 的 Retry 请求后调用 | 重新进入当前楼层入口并重置门计时；卡片、装备和救援恢复按对应功能阶段的规则执行 | 任务 08、10 |
| `go_to_floor(floor_number: int) -> void` | A 的楼层出口逻辑 | 检查通行条件，装载目标楼层，摆好主角并绑定组件后恢复游玩 | 任务 10 |
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

基础阶段只要求 `state_changed`、`game_failed`、`start_game`、`fail` 及上述字段真实可用。其他接口先登记，未实现前不得把它们接到可点击按钮或把无操作的空函数当成完成。

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
| `has_all_cards() -> bool` | 查询函数 | 三张规定 ID 是否全部获得，供 A 检查 1F 出口 |

| 操作函数签名 | 调用者 | 职责 | 实现阶段 |
|---|---|---|---|
| `reset_for_new_game() -> void` | A 的 GameManager | 清空已获得卡与两个槽，当前槽回 0、当前卡回 NONE，并通知显示刷新 | 任务 05 骨架，由 B 后续维护 |
| `collect_card(card_id: String) -> bool` | B 的工作人员 | 新卡成功入库返回 true；不允许重复获得。第一张进入 A、第二张进入 B、第三张留背包 | B 的偷卡／收集阶段 |
| `switch_active() -> bool` | B 的 Q 输入处理 | 请求切换当前佩戴卡；成功操作返回 true | B 的切卡阶段 |
| `equip_card(card_id: String, slot_index: int) -> bool` | D 的背包按钮 | 请求调整指定槽，保留三卡所有权且最多佩戴两张；成功操作返回 true | B/D 的装备阶段 |

基础阶段实现空数据读取和重置即可。未完成的收集／切卡／装备功能保持“未实现”，不要在多个脚本中各写临时卡片逻辑来假装可用。

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

目标文件：`scenes/staff/staff.tscn` 和相邻脚本。保安、保洁、经理使用同一个组件。

| 公开配置 | 类型 | 原型起点 |
|---|---|---|
| `card_id` | `String` | SECURITY／CLEANER／MANAGER 中的一项 |
| `turn_interval` | `float` | 3.0 秒，可调 |
| `steal_radius` | `float` | 55.0 像素，可调 |
| `steal_duration` | `float` | 0.8 秒，可调 |

接入方法为 `setup(player: HotelPlayer) -> void`：A 实例化员工后注入主角；B 的独立测试场景也使用该方法。员工不依赖主场景的绝对节点路径。

B 负责转身、背后判定、偷窃计时和卡片收集。成功调用 `CardManager.collect_card(card_id)` 后，发出 `card_stolen(card_id: String)` 供 A 连接提示；失败调用 `GameManager.fail("STAFF_CAUGHT")`。同一张卡不能重复提供。

E 的按住／松开检测属于 B 的偷窃功能；A 负责救援和出口 E。正式场景接入时 A/B 统一有效目标，避免一次 E 同时偷卡和换楼层。目标优先级及取消细节在任务 08 确认。

## 7 C 提供通用房门

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

本文件登记基础接口和各成员的交付边界，以上问题不阻塞底座搭建。后续每实现一个接口，更新真实可用状态和 [进度记录](progress.md)，再按 [QA](qa.md) 验收；T01—T14 游戏主线用例当前仍未执行。
