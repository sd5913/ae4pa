# 怪物员工通道公共接口与 V4 迁移提案

最新整合候选（2026-11-14）在 A 个人分支 work/member-A-liuling 维护，基线为 main 0145926。已接正常菜单、任务 01 真实接受／清理／交付／检查点恢复、I 背包和 H 渐进笔记。当前入口及签名见第 17—19 节，发布核对见最新进度。远端 main 新增的 D PR #23（007437a）与此候选的联调另行核对。

本文件按《Monster Staff Access Godot三周逐步分工 共享美术版 V2》第 01—03 部分的职责起草，供 A/B/C/D 在同一 Godot 项目中接入模块。它对应手册中建议的“接口约定.txt”，统一使用本 Markdown 文件维护，不再创建第二份接口清单。

**阅读顺序：先读第 19 节菜单／笔记、第 18 节 UI 和第 17 节检查点，再读第 16 节对白与第 15／14 节任务接线；第 1—12 节保留 V3 兼容基线，第 13 节以 V4 提案为主。当前接入以第 17—19 节及最新进度为准；第 13—16 节的“缺快照／清理／重试”保留为历史记录。新增接口经审阅并实际实现后才能接正式按钮。** 本轮用户已授权集中提交／push 到 A 分支；下文“本地未提交”“待同步 C”“D 对白未接”均为此前开发阶段记录，共享 main 的可用性仍以合并状态为准。

现行产品规则见 [项目主策划](game-design.md)，人员任务及交付顺序见 [ABCD 分工 2.0](team-plan.md)。本文专门维护接口及其实现状态，本次文档整合不改变已有函数或信号。

函数表示“调用另一个模块做事”，信号表示“通知其他模块某事已经发生”。调用者按本文约定使用接口，模块内部实现由对应负责人决定。

**当前状态：任务 01 的真实组件循环已在 A 本地自动验证，F5 因缺 D 接受／失败 UI 仍停在任务介绍；完整 M1 未验收。** 员工、工作和卡片内部实现仍由 B 维护；当前只运行任务 01，未提前开放后续任务、救援和结局。

| 模块 | 当前真实可用 | 尚待实现 |
|---|---|---|
| GameManager／A 楼层 | 任务 01、五任务定义、1F↔2F、唯一 E、真实 201／普通退回、B 清理／被抓、接受前检查点与重试；A 本地已验 | D 正式页面、后四任务运行、救援及结局 |
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
| `is_interaction_allowed(target_id: String) -> bool` | A 目标选择、B 组件 | 任务 01 本地已实现，具体资格与限制见 §13.8；工作组件另查距离／朝向／当前卡 |
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

2026-11-12 用户以 A 身份确认任务门控、正式 E 路由和恢复次序，详见 [A/B 对接约定与 B 的实施步骤](a_v4_m0_handoff.md#6-b-反馈后的-ab-对接约定a-已确认)。B/C/D 仍需核对各自调用点；A 的资格查询已在本地实现（见 §13.8），本节的 B 扩展仍是目标接口，不代表 B 的代码已经提交。

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

### 13.8 2026-11-12 A 本地实际状态

| 入口／行为 | 实际状态 | 限制 |
|---|---|---|
| `complete_manager_intro() -> bool` | 已实现 A 侧故事标志；主入口有明确标记的开发代记按钮 | D 正式对白及首看流程未连接 |
| `get_task_view()`、`get_task_definition(task_id)`、`get_completed_task_ids()`、`get_world_flags()` | 已实现返回副本；五任务数据现已定义，任务 01 实际消费 | 后四任务运行、完整笔记／物品表未落地 |
| `is_interaction_allowed(target_id: String) -> bool` | 已实现任务 01 的只读资格；A 楼层现调用它门控正式员工 E | B 内部尚未调用；直接 B F6／结算复核仍未迁移，不代表 B 完整门控已验收 |
| `offer_task`、`accept_task`、`record_work_result`、`submit_task` | 已实现任务 01 的状态、清理权限、交付去重与结果；独立测试通过 | 201/C 门、B 污渍点和 D 按钮尚未连接；接受前卡快照未实现 |
| `set_modal_open(modal_id, is_open)` | 已实现多模态停表、A 世界 E／工作／交付／楼梯拒绝及当前长按取消 | 未冻结 Player／门／员工周期；正式 UI 不可直接当完整暂停使用 |
| `request_task_failure`、`task_failed` | 已实现任务 01 超时与有效任务内员工被抓的状态通知 | 检查点恢复待 B 快照；A 已确认无任务时不能开始偷窃，当前 B 旧员工代码尚未落实 |
| `get_available_floors()`、`request_floor_travel()` | 已实现已到达层与下一层门槛、真实楼梯距离校验；1F↔2F 自动测试通过 | D 楼梯列表未连接；2F→3F 需要未实现的任务 02，后段回访限制待 M2 |
| `request_safe_return` | A 实现及真实 C 副本验证通过，细节见 §15 | 当前旧 C 工作区尚未启用；C 人工和 D 警告联调待验 |
| `retry_current_task` | 尚未实现 | 等 B 卡片快照，不能接可点击正式重试按钮 |

现有 `go_to_floor` 只转发合法楼梯请求；1F 不再查三卡。任务 01 的剩余时间由 GameManager 在 PLAYING 且无打开模态时递减，待交付阶段继续计时，归零后拒绝工作和交付。`task_01_smoke.gd`、`floor_return_smoke.gd` 为当前独立检查，验证记录见 [进度](progress.md)。

资格查询的当前精确边界：必须 PLAYING、当前任务 `TASK_01_CLEAN` 为 ACTIVE、剩余时间大于 0、没有打开的模态。此时 `STAFF_CLEANER_1F` 仅在尚未拥有 CLEANER 时返回 true，`STAIN_201` 仅在 `stain_201_cleaned` 尚未为 true 时返回 true。其他 ID（含后续任务目标、旧 `STAFF_SECURITY_1F`、空串及大小写错误）均返回 false。READY_TO_SUBMIT、AVAILABLE、FAILED、COMPLETED、无任务均不开放这两个动作。

该查询不授卡、不扣时、不记录工作，不判断距离、朝向、按住时长或当前生效身份，也不绑定接取楼层。A 楼层现用它门控 E，且持续失去资格时取消；B 仍需在内部开始／结算前复核。工作结果仍经 A 的 `record_work_result` 复核楼层及当前卡。员工组件自带监听未改，但正式楼层实例已由 A 禁用该监听。独立命令：`godot --headless --path . --script res://scenes/tests/core/interaction_allowed_smoke.gd`。

## 14 201 首闭环接线清单

本节是任务 01 的接线入口，按 2026-11-12 当前源码核对。**“本地可用”只指 A 未提交工作区，不能在仅有 main 的电脑直接调用。** 远端 main 为 `9f8cb9eb986c35702497780e360bc21cc5fa2306`；main 仍是旧楼层源码＋V4 文档。A HEAD 为 `df4a3eb`，尚未同步 main，比个人跟踪分支 ahead 6；main 比 A HEAD 多六个文档提交。同步由用户在 GitHub Desktop 操作，本轮不执行 fetch／pull／merge。

### 14.1 固定 ID、数据和事件载荷

| 内容 | 唯一所有者 | 读取／传递方式 |
|---|---|---|
| `TASK_01_CLEAN`、任务状态、210 秒、已完成任务 | A GameManager | `get_task_view()`、`get_completed_task_ids()` 返回副本；D 不建 Timer |
| `STAFF_CLEANER_1F` → `CLEANER`、两槽／当前槽 | B CardManager／员工 | 员工先查 A 资格；卡片只由 B 授予、查询及恢复 |
| `STAIN_201` → `stain_201_cleaned` | A 保存完成事实，B 执行动作 | B 成功请求经 `record_work_result` 校验；显示从 `get_world_flags()` 重建 |
| `passage_201_unlocked` | A GameManager | 仅 `submit_task` 成功写 true；A 楼层据此限制／开放后段 |
| 当前楼层、已到达层、经理初次对白完成 | A GameManager | D 白话完成后请求 `complete_manager_intro`；楼梯读 `get_available_floors()` |
| 门 CLOSED／WARNING／OPEN、检测证据、来向 | C 门实例 | C 报事件，不写任务／卡／通路，不重载楼层 |
| 页面内容／显示状态、用户请求 | D UI | A 连接请求与展示；不保存另一份任务／世界真值 |

`get_task_view()` 当前精确键：`task_id: String`、`status: String`、`remaining_time: float`、`time_limit: float`、`step: String`、`target_id: String`、`required_card: String`。任务 01 的 target_id 为 STAIN_201、required_card 为 CLEANER；step 在 ACTIVE 为 CLEAN_STAIN、READY_TO_SUBMIT 为 RETURN_TO_201，其他状态为空。当前没有任务名称、地点文案、笔记或检查点字段，D 不可读取不存在的键；这些显示文案由 D 按任务 ID 配置。

### 14.2 A 的真实入口与缺口

| 签名／通知 | 真实状态 | 接线与限制 |
|---|---|---|
| `complete_manager_intro() -> bool` | A 本地可用 | D 首次经理对白完成后调用；重复 false。正式对白尚未连接 |
| `offer_task(task_id: String) -> bool` | A 本地可用 | C 请求后 A 校验经理标记、2F、任务 NONE；成功只设 AVAILABLE 并发 task_offered，不计时 |
| `accept_task(task_id: String) -> bool` | A 本地状态版可用 | D 接受请求经 A；须 AVAILABLE 且在 2F。目前没有保存卡快照，**仅用于开发状态检查，不是可恢复的正式接取** |
| `is_interaction_allowed(target_id: String) -> bool` | A 本地可用 | 任务 01 ACTIVE、正剩余秒、PLAYING、无模态；保洁未取得／污渍未完成；其余目标 false |
| `record_work_result(target_id: String) -> bool` | A 本地可用 | B 工作请求经 A；要求 2F、当前 CLEANER、正确目标、ACTIVE、正剩余秒、无模态；成功变 READY_TO_SUBMIT，仍扣时 |
| `submit_task(task_id: String) -> bool` | A 本地可用 | C 的真实 201 E 请求经 A；要求 2F、可交付、已清理、正剩余秒、无模态；立即结算并开通路，之后再播对白 |
| `is_world_input_allowed() -> bool` | A 本地可用 | PLAYING 且无打开模态；只说明世界输入资格，不代表完整冻结 Player／员工／门 |
| `set_modal_open(modal_id: String, is_open: bool) -> void`、`modal_changed()` | A 本地可用 | D 每页使用自己的稳定 ID，打开／关闭成对；多页共存时只释放自己的暂停理由。重复设置不重复通知 |
| `get_available_floors() -> Array[int]`、`request_floor_travel(floor_number: int) -> bool` | A 本地可用 | 真楼梯距离≤70、已访问／合法下一层、无模态；列表页先读，选择时关闭自己的模态后请求，其他页面仍开则拒绝 |
| `request_task_failure(reason: String) -> void` | A 本地可用 | B 只对有效偷窃被抓报告 STAFF_CAUGHT；A 超时报告 TASK_TIMEOUT；重复失败不结算两次 |
| `get_interaction_target_id() -> String` | A 本地楼层方法 | 唯一员工／楼梯目标；新版 C 接入后还提供 READY 的 ROOM_201，优先级 0。空串表示无世界目标；工作点／经理谈话待交付 |
| `retry_current_task() -> void` | **尚未实现** | 等 B 真实快照；D 失败按钮禁用，不接旧 retry_floor，不把新局当重试 |
| `request_safe_return(door: Node2D, reason: String, approach_side: int) -> void` | A 已实现、真实 C 新版副本验证通过 | 只接受当前楼层已登记普通门／安全点，详见 §15；旧 C 不接 fail，不冒充当前工作区已联调 |

A 任务通知均已存在于本地：`task_offered(task_id: String)`、`task_updated()`、`task_completed(task_id: String)`、`task_failed(task_id: String, reason: String)`，另有 `floor_changed(floor_number: int)`／`state_changed(new_state: String)`／`game_failed(reason: String)`。UI 打开时先主动读快照，之后监听更新；剩余时间可只读刷新，无需每帧业务信号。

### 14.3 B/C/D 的接头及下一步位置

| 负责方／位置 | 现有可用 | 缺少的目标签名／接法 |
|---|---|---|
| B：1F `StaffRoot/CleanerSlot/Staff` | `setup(player: HotelPlayer) -> void`、`begin_steal() -> bool`、`cancel_steal() -> void`、`is_player_in_range() -> bool`、`card_stolen(card_id: String)`；main 源码已有这些旧入口 | 稳定 target_id 与任务资格检查（开始／结算各一次）、正面任务失败、B 独立输入适配约定。A 已在楼层用 `set_process_unhandled_input(false)` 关闭实例自带 E，只转发选中的开始／取消；不改 B F6 |
| B：CardManager Autoload | `has_card`、active_card、查询副本、收集／装备／Q、cards_changed／identity_changed | `export_snapshot() -> Dictionary`、`restore_snapshot(snapshot: Dictionary) -> bool` 尚不存在；格式和原子恢复按 §13.3／M0 §6.3，A 不直接写 B 数组 |
| B：2F `Interactions/Stain201Slot`（x=980） | 只有 A 的 Marker，**没有污渍组件** | `setup(player: HotelPlayer) -> void`、`begin_interaction() -> bool`、`cancel_interaction() -> void`、`work_requested(target_id: String)` 为目标接头，待 B 确认。A 连接 work_requested→record_work_result；B 仅以 A 的 world_flags 为成功真值，初次／task_updated 时刷新，不先隐藏污渍 |
| C：2F `DoorRoot/Room201`（x=700） | C-V4-01～03 已经 PR #12 发布并合入 main；A 本机仍为 NOSE Marker 与旧门脚本，待按该版本接入，见 §14.6 | A 推送 `set_story_state(status)` 镜像；介绍／交付信号接 A offer／submit，唯一 E 调 `request_interaction() -> bool`。true 表示发出请求，A 再确认任务结算 |
| C：一扇普通门 | PR #12 已发布违规事件、来向采样和单次保护；A 本机仍是旧版直接 fail | `rule_violated(reason: String, approach_side: int)` 连接时绑定门实例；A 安全退回后调用 `finish_safe_return() -> bool`，仍在本门范围内会返回 false，还需 A 验证邻门与路径 |
| D：经理对白／任务页 | 尚无正式场景交付 | `dialogue_finished(dialogue_id: String)`→A；经理 ID 建议 MANAGER_INTRO（待 D 表确认）。`accept_requested(task_id: String)`→A accept；`show_task_offer(task_view: Dictionary)` 为目标展示方法 |
| D：楼梯／失败／警告 | 尚无正式场景交付 | `floor_selected(floor_number: int)`→A travel；`task_retry_requested()` 目前禁用；`show_warning(reason: String)` 等 A safe_return 实现后接。页面打开／关闭均经 set_modal_open |

所有表中“目标接头”是待对应成员核对的签名，不得把 signal／method 已写在文档中当作组件已交付。A 不向成员自动发送消息，本文由用户交接。B 员工直接调用 begin_steal 的独立 F6 目前仍是旧基线，不具备任务门控；A 的楼层路由只保证正式楼层 E，不代替 B 内部结算复核。

### 14.4 E 优先级、路线与未决边界

目标次序为：D 模态 UI 优先消费 → 201 交付／剧情（优先级 0，**组件待接**）→ 有资格员工／工作（1）→ 楼梯（2）→ 条件不足提示（3）。同级比较水平距离，再比较固定 target_id；按下后锁定，按住不换目标，成功／取消后须松开再按。A 当前实现员工和楼梯；未知任务员工只提示。松键、离开范围、尝试移动、identity_changed、开模态、失败、卸载均取消；UI 消费松键也要被 A 观察，关闭 UI 或换层不能让同一 E 连触发。

2F 当前 A 布局为：左梯 x192 → 201/NOSE x700 → 污渍接入位 x980 → 路障 x1250 → 202/EYE x1550 → 203/EAR x2000 → 204/CHECKER x2450 → 205/HAT x2900。路障通过 Player 现有边界实现，未交付时中心不超过 x1226，清洁不撤销它；交付后开放到走廊右端。接受前的 C 固定拦截／任务门通行表现尚未实现，不能以当前可走到污渍接入位算通过。

| 规则 | 已确认部分 | 仍需核对／验证 |
|---|---|---|
| 提前偷卡 | A 已确认接受对应任务才可偷；未接受只提示、不触发被抓 | B 内部开始／结算门控和正面被抓版本未交付；不能把 A E 路由当成 B 全面验收 |
| 工作路线 | 本次用户重申：任务 01 能回 1F、回 2F 清洁、返 201 交付；交付才开后段 | C 的剧情／普通检测互斥、接受后任务门免重复惩罚的具体实现 |
| 左右安全点 | 必须退回来侧并保持当前任务，不能退过路障或落危险区 | A 放了 `Task01AcceptSafe` x560 与 `Room201RightSafe` x1120 **接入占位**，尚未作为重试／普通门安全点使用；C 需验证半径、相邻门、方向与连退抑制，普通门具体点另定 |
| 模态停表 | 源案已定对白／手册／背包／暂停停表；A 多模态停表及世界 E 屏蔽已实现 | 世界冻结范围、背包核验上下文和 warning／stairs 的正式页面时序待 B/C/D；当前 Player／员工周期仍可运行 |
| 归零与交付同帧 | 正剩余秒才接受，归零后拒绝；清洁后继续计时，交付立即结算后播对白 | “先扣本帧时间再处理所有结果”的统一排队／调度尚未冻结。当前 _process 与直接 API 调用有先后差异，已有测试仅证明 _process 归零后拒绝，不能声称双调用顺序都已统一 |
| 失败重试 | A 已确认接取前深拷贝；恢复回 2F 待接受，剩余 0，重新接受才给完整 210 秒 | B 快照缺失，A 恢复链尚未实现；D 关页／取消、C 周期重建须联调 |

目标恢复顺序：FAILED 锁世界 → 关闭所有模态并取消当前长按／旧连接 → B 原子恢复卡片、两槽和当前槽（不发 identity_changed）→ A 恢复任务前世界／通路／故事／访问状态 → 重载 2F → 应用污渍／门／路障 → 放主角到经 C 验证的接取安全点、重置相机 → UI 同步 → AVAILABLE、剩余 0。任何恢复失败不得显示“恢复成功”或开始新计时。普通门安全退回不走这条链，不清卡、污渍、通路或当前任务。

### 14.5 core 入口与正式 F5 门槛

F6／运行当前场景：`res://scenes/tests/core/task_01_core_test.tscn`。使用真实 Player、楼层加载、GameManager、CardManager 和现有 B 员工；所有代记对白／介绍／清洁／交付／失败按钮都明确标为开发操作。**没有假卡片快照；重试按钮禁用。** 本机 project.godot 的 F5 入口保持用户原设置，不自动改为该测试或 main。

自动检查入口：`world_interaction_smoke.gd`（真实 E、取消、模态、通路、回访）、`task_01_core_smoke.gd`（开发入口接线）、已有 `task_01_smoke.gd`、`interaction_allowed_smoke.gd`、`floor_return_smoke.gd`、`foundation_smoke.gd`，均在 `scenes/tests/core/`。命令统一为 `godot --headless --path . --max-fps 120 --script res://scenes/tests/core/<脚本>`；本机无 godot 的 PATH 别名时使用实际 Godot 可执行文件。底座的共享 main 入口断言在临时副本验证，本机 F5 不改。

组件齐后再由 A 连接 B 工作／卡快照 → C 201／一扇普通门 → D 正式页面，使用共享 main 做 F5 正常交付、偷窃被抓、超时重试、普通门退回四路径。未用正式组件完成的路径继续未执行；开发代记、测试夹具或源码审查均不算 V4-T03／04／07／09 已通过。

### 14.6 C 反馈与版本交接核对

后续发布核对：用户提供新版提交 1379a16 和 PR #12，并说明已经审查。A 通过只读 GitHub API 确认 [PR #12](https://github.com/sd5913/ae4pa/pull/12) 已合并，head 为 `1379a16b7f563783a57a93fe15de82c4be6d468d`；已读该提交的 v4_handoff.md。交接明确 STORY 的 story_radius 为 120，新增 set_story_state、request_interaction 和 finish_safe_return；测试接收方为 TEST DOUBLE，C 独立验证由 C 报告通过，真实 A 接入与安全点继续待联合验收。下文保留首次反馈时的版本核对记录。A 当前源码仍待用户安排 GitHub Desktop 同步该交付版本。

2026-11-12 用户转发 C 的交接反馈：C 报告独立组件已支持 STORY／NOSE／TASK_01_CLEAN、固定区拦截、介绍与交付信号、`request_interaction()`、普通 `rule_violated(reason, approach_side)`、来向采样、单次报告保护和 `finish_safe_return()`，并称说明在 `scenes/doors/v4_handoff.md`。这是 **C 的完成报告，尚不是 A 已取得代码或联合验收通过**。

A 本机核对：该交接文件不存在；`monster_door.gd` 仍是直接调用 GameManager.fail 的旧版，没有上述 V4 入口。GitHub 插件查询返回 403，随后只读 gh api 核对已知 C 分支 `work/member-C-yinshiqi`（当时 HEAD `ce95720f63905d3698bf3da0f5715c2d8f535aac`）与 main 的 doors 目录，两者清单和源码 SHA 相同，均没有 v4_handoff.md。这不排除新版仍在 C 本机或其他分支；下一交接必须给出含新版代码的分支、提交／PR，以及说明和独立测试结果。A 不据转述重写 C 组件，也不替用户同步或合并。

C 关于旧布局的提醒适用于共享旧场景。A 当前本地 `floor_2.tscn` 已是 201/NOSE x700、202/EYE x1550；201 仍只是 Marker，不等于真实剧情门。以所有门半径暂为 90 的静态距离计算，x560 与 201 距离 140，x1120 与 201／202 分别距离 420／430，均不在该假设的检测范围内。但 STORY 触发区、实际半径、其他门／路障、重生后重复触发与恢复时序尚未联合验证，两个点继续保持“占位、未确认安全”。

拿到对应版本后，A 的接入顺序为：独立运行 C 测试 → 在 Room201 下实例化并 setup(Player) → 接介绍／交付到 offer_task／submit_task，并将 request_interaction 纳入唯一 E → 对普通门事件绑定来源实例，从实例读取 room_id → 实现带安全点校验的 request_safe_return，恢复输入及检测时协调 finish_safe_return → 验证往返工作路线、双向安全退回和任务／卡片／剩余时间保留。C 的两参数 rule_violated 不额外虚构 room_id 参数；finish_safe_return 的具体抑制解除规则必须按收到的源码与 C 核对。

### 14.7 D 的实际读取、请求和通知交接

2026-11-12 用户转发 D 的接口问题，本节由 A 当前代码及临时副本实际输出核对。**这些新增任务接口仍在 A 本地，尚未作为功能代码发布到 main；D 只有共享 main 时不能假定已可调用。** 序章结束和经理对白结束分开通知：序章结束由 A 衔接世界流程，不调用 complete_manager_intro；经理对白结束才由 A 主场景调用 `complete_manager_intro() -> bool`，成功须 PLAYING 且未完成过，重复或非 PLAYING 返回 false。对白 ID 与 D 的实际通知签名仍以其交付表核对。

**读取示例与刷新**

以下是使用真实楼层／两个 Autoload，在 2F 接受任务 01 后、尚未推进下一帧计时的实际返回（键顺序不构成约定）：

```gdscript
GameManager.get_task_view()
# {
#   "task_id": "TASK_01_CLEAN",
#   "status": "ACTIVE",
#   "remaining_time": 210.0,
#   "time_limit": 210.0,
#   "step": "CLEAN_STAIN",
#   "target_id": "STAIN_201",
#   "required_card": "CLEANER"
# }

GameManager.get_available_floors()
# [1]  # 当前 2F，已到达 1F；任务 02 尚未完成，不能去 3F。
```

同一实际调用链中：新局 task_id／status 均为 NONE、两个时间均为 0.0、其余字符串为空；只看任务介绍时 status 为 AVAILABLE、remaining_time 为 0.0、time_limit 为 210.0、step 为空，target_id／required_card 仍为 STAIN_201／CLEANER。楼层列表在 1F 经理对白前为 `[]`、对白完成后为 `[2]`、2F 返回 1F 后为 `[2]`；列表不含当前层，不是全部五层菜单。非 PLAYING 返回空列表，PLAYING 时打开模态仍可读取列表。

| UI 内容 | 实际通知与刷新位置 |
|---|---|
| 任务面板／HUD 任务字段 | 初始化先连接信号、主动读取一次；`task_offered(task_id: String)` 用于打开介绍，`task_updated()` 后重读完整任务快照；按需在 floor_changed／state_changed 后刷新显示 |
| HUD 剩余秒 | 当前没有 remaining_time_changed，task_updated 不逐帧发。D 在自己的 _process 只读 GameManager.remaining_time 显示，可用 `ceili(maxf(GameManager.remaining_time, 0.0))`；只格式化，不减 delta、不另建任务 Timer。只在 ACTIVE／READY_TO_SUBMIT 显示运行倒计时，其他状态按任务状态显示 |
| 楼梯列表 | 每次打开页面主动读；`floor_changed(floor_number: int)`、`task_updated()`、`state_changed(new_state: String)` 后重新读取。complete_manager_intro 成功**没有专用通知，也不发 task_updated**，由 A 在经理结束回调中协调刷新，或 D 下次打开时重新读；不要等待不存在的 floors_changed |
| 卡片显示 | 从 CardManager 主动读，收到 `cards_changed()` 后刷新；不要从任务快照推断所有权 |

任务完成后 remaining_time 保留交付时的余量并停止递减，并非强制置 0；UI 用 status 判断“已完成”。模态时仍为 ACTIVE 也可能停表，UI只读真实值，不自行判断是否继续扣秒。

**操作的完整签名与拒绝语义**

| 真实签名 | 具体调用 | 返回与条件 |
|---|---|---|
| `accept_task(task_id: String) -> bool` | `GameManager.accept_task("TASK_01_CLEAN")` | PLAYING、当前 2F、当前任务 ID 一致且 AVAILABLE 才 true，设 ACTIVE／210 秒并发 task_updated；未介绍、错任务、已接受／完成／失败、离开 2F 等返回 false，不重启时间。目前仍缺接受前检查点，只是状态接口 |
| `request_floor_travel(floor_number: int) -> bool` | 在有效楼梯附近调用 `GameManager.request_floor_travel(1)` | PLAYING、无模态、有有效楼层宿主、目的地在 get_available_floors、玩家距对应楼梯水平≤70 才进入真实加载；参数为整数层号。非游玩、仍有模态、远处请求、当前层／未知层／未解锁层等返回 false，校验拒绝时不换层 |
| `set_modal_open(modal_id: String, is_open: bool) -> void` | `GameManager.set_modal_open("TASK_OFFER", true)`／`false` | 没有成功／失败返回；非空 ID 的状态实际改变时发 modal_changed()。空 ID 或重复设置忽略；它不是引用计数器，也不负责创建／关闭 UI 节点 |

前两个方法只返回 bool，没有额外错误码或拒绝原因信号。请求 false 后 D 刷新真实状态，不将它当作游戏失败，也不从 fail_reason 读取请求错误原因。

任务面板可以在自己的 TASK_OFFER 模态仍打开时请求 accept：当前代码允许，且实测返回 true／210 秒。推荐 D 先请求接受，成功再关闭该面板并释放自己的模态；若其他页面仍开，任务保持停表。失败则保持／刷新面板。楼梯相反：其请求明确拒绝任何打开模态，D 先关闭楼梯页并释放 STAIRS，再请求 travel；其他模态若仍存在，返回 false，不能擅自清除它们。

**多页面登记与关闭 E**

每个可同时存在的页面使用自己的稳定非空 ID，如 DIALOGUE_PROLOGUE、DIALOGUE_MANAGER、TASK_OFFER、BAG、HELP、PAUSE、STAIRS；这些只是示例字符串，不是新增枚举。D 在显示前登记 true，在真实关闭／移除时登记 false，只释放自己的 ID。同一 ID 的两次 true 只算一个，若允许同类页面多实例，必须使用不同实例 ID 或限制单实例。

实测 `BAG=true → PAUSE=true → BAG=false` 后调用 _process，剩余时间不变，travel 返回 false；PAUSE=false 后才允许有效楼梯请求。A 目前实现的是任务停表、世界 E／工作／交付／楼梯屏蔽和长按取消，尚未冻结全部玩家移动、员工转身、门周期或处理完整背包核验，D 不把它宣传为完整世界暂停。

关闭／确认页面的那次 **E 由 D 消费**：D 处理该按键时先 `get_viewport().set_input_as_handled()`（在 Control 的 _gui_input 中可用 accept_event），再完成关闭／接受及 set_modal_open(false)，不把同一事件转发给世界，也不手动补发 E。A 楼层通过 modal_changed 设置“须松键”保护，并在 _input 观察释放（即使 UI 消费），释放后下一次按下才可触发世界动作；鼠标关闭时若 E 仍按着同样不能穿透。D 的 UI 实际实现仍须与此接法联调。

**任务失败与普通门警告**

- 真实任务失败通知为 `task_failed(task_id: String, reason: String)`，任务 01 使用 STAFF_CAUGHT／TASK_TIMEOUT。A 已先设 task_status／game_state 为 FAILED，再通知 UI；随后还会发兼容 `game_failed(reason: String)` 和 task_updated。D 以 **task_failed 单一入口** 打开任务失败页，不让两条信号各开一次。
- 目前没有已实现的 A 普通门警告通知。C 报告的 `rule_violated(reason, approach_side)` 要先绑定来源门交给 A 安全退回，不由 D 直接当任务失败处理。§13 的 `safe_return_started(reason: String)` 仍是拟议通知，尚未声明，D 不能直接 connect。D 可准备独立的 `show_warning(reason: String)` 展示方法，等 A request_safe_return／事件实现后再连接。
- `retry_current_task` 与检查点恢复仍未实现，D 正式“重新挑战本任务”保持禁用，不接旧 retry_floor，不用 start_game 冒充重试；失败展示与重试可用性分别处理。

### 14.8 保洁模块的新交付反馈（待取得代码）

同次用户转发的第二段标为“C 发来”，正文却称 B-V4-01～03、B 分支，内容属于 B 的员工／卡片／工作职责。先按 **B 模块交付反馈、发送者标注待核对** 记录，不改 ABCD 归属。报告称保洁部分、快照和污渍 ID 已按约定完成，独立与旧回归通过，员工被抓改为任务失败信号，准备提交 B 分支／PR。

A 当前本机 CardManager 仍没有 export_snapshot／restore_snapshot，尚无 scenes/work 目录，Staff 也没有报告中的新失败信号，因此状态仍是“成员报告已完成，A 未取得／未验证”。不因报告就启用重试或重写 B 内部模块。

该 PR 需要明确：分支／提交、实际快照签名及三个字段、STAIN_201、任务资格查询的接入方式、外部 E 开始／取消方式、工作结果事件与接受确认方式、员工被抓信号的准确名称／参数、真实测试入口及结果。A 收到后先独立验收，再接 GameManager 资格 → 楼层唯一 E → record_work_result → 接受前检查点和失败恢复；普通退回仍走 C/A 的另一条链。提交／推送／开 PR 由对应成员按自己的授权完成，A 本轮不替其操作或发送消息。

## 15 清单修正后的 A 接口增量（2026-11-12）

本节覆盖 §13／14 中早期的“尚未实现”描述。[逐项结果](a_checklist_results.md)区分当前工作区和真实 C 新版临时副本；本轮未改 B/C/D 内部文件，也未同步／合并 Git。

### 15.1 任务定义和 D 读取

新增 `GameManager.get_task_definition(task_id: String) -> Dictionary`，返回 `scripts/task_definitions.gd` 的深拷贝，未知 ID 返回 `{}`。字段包括 name、location、offer_floor、room_id、prerequisites、time_limit、required_card、staff_target_id、target_id、work_type、work_floor、steps、work_flag、completion_flags、settlement、confirmation_required；文件类奖励另有 reward_id。它是静态任务说明，**不是“当前允许接受”的查询**，后四任务仍被现有 offer_task 拒绝。

`get_task_view()` 保留原有七键，新增 `name`／`location`；任务 01 为“打扫走廊”／“2F · 201”，NONE 时为空串。其 time_limit／target_id／required_card 从同一数据源读取，accept 时使用定义中的 210 秒。步骤原契约保持，D 不根据定义自行推进状态。02—05 的数据已定义，运行流程继续待后续里程碑；任务 03 的 AUTHORIZE_PROPOSED／D-05 明确为待确认。

### 15.2 真实 C 组件适配

A 的 `floor.gd` 在 2F 的 Room201／Room202 下实例化同源 monster_door，前提是组件真实具备 set_story_state 和 finish_safe_return。当前工作区旧 C 不满足，释放未入树实例并显示“待同步 C PR #12”，不会接入仍调用整层 fail 的旧门。固定 C 提交 1379a16 已在本机 Git 中，只在临时副本加载验证；没有覆盖 C 的整个脚本。

201 为 STORY／NOSE／TASK_01_CLEAN／story_radius 120，连接介绍到 offer_task、交付到 submit_task、进度到临时提示。只在 task_updated／请求确认时同步镜像，不逐帧清除 C 去重状态。READY 且在范围内才加入唯一 E，ID 为 ROOM_201、优先级 0；D 模态继续优先消费，关闭后仍须松 E。组件 physics 检测在 A 模态打开时停用，避免拒绝介绍后永久吃掉首次请求；完整世界冻结／背包核验仍未实现。

新版接入时，201 未接／只看介绍阶段的 Player 右界为 x580，能到固定触发区；接受后右界为 x1226，可去 x980 工作，仍不能越过 x1250 锁。只有交付后才开放后段。202 暂为 M1 的 NORMAL／EYE，**不是任务 02 门已完成**；203—205 及后续楼层继续 Marker，留 M2／M3 组装。

### 15.3 A 的安全退回契约

新增 `request_safe_return(door: Node2D, reason: String, approach_side: int) -> void` 和 `safe_return_started(reason: String)`；函数不返回成功值。楼层将 C 的两参 rule_violated 绑定源门后转交 A，不增加 room_id 信号参数。只接受当前宿主楼层登记的真实普通门、非空原因和 -1／+1 来向；过期、外来、未知方向、模态或非 PLAYING 请求忽略。同物理帧只处理一个有效退回。

楼层内部 `get_safe_return_position(door: Node2D, approach_side: int) -> Dictionary` 只查询已登记点，失败 `{}`，成功含 position。2F Room202 左／右点为 x1400／1700（y560）；不会使用 C 独立场景 x950／1250。每次重新验证：点在来向侧且严格超出本门半径、走廊边界、同一水平地面、不在任何已实例化门／剧情区、整个移动区段不穿邻门区或未开放任务路障。当前走廊无额外障碍碰撞；后续新增碰撞／门位须重新验路线，不能把此检查当任意关卡寻路。

有效请求进入 SAFE_RETURN，state_changed 立即取消员工长按，锁 Player 移动，C 按状态停止检测；移动并重置相机后，调用真实 finish_safe_return。确认成功才发 safe_return_started，延迟恢复 PLAYING／移动，避免同步接收方再次退回。确认失败输出错误并保持锁定，不报告成功；当前实际布局已验证确认成功。该临时状态停止任务扣时，恢复后从原余量继续；不改 task_status、卡片、世界事实或已完成任务。主入口／core 暂时显示警告文字，D 正式页仍待联调；此信号不是 task_failed，不打开任务失败页。

201 x700、污渍位 x980、锁 x1250、202 x1550 是本次共同接入基准。x560／1120 保留为 201 接取／右侧占位，尚未用于任务检查点，不因普通 202 自动测试通过就代记检查点安全或 C 人工试玩通过。B 快照缺失，retry_current_task 仍不存在、按钮禁用。

### 15.4 运行与验证状态

F5 已恢复 `res://scenes/main.tscn`，取代 §14.5 的“本机入口不改”旧记录；该入口仍为开发主场景。safe_return_smoke 使用真实 C 组件，当前旧组件会明确 BLOCKED／退出 2；在含 C 1379a16 的临时副本 PASS。其工作结果以显式开发调用推进，不证明 B 清洁／正式 UI／完整 M1。三份参考 CSV 新增 keep 导入配置，防止被误当翻译表；CSV 内容未改。

## 16 序章与经理对白正式接线（2026-11-12）

A 主场景 `StoryLayer/Dialogue` 直接引用 D 原有 `scenes/ui/dialogue.tscn`，没有修改 D 脚本／场景／TSV／素材。F5 和主入口新局调用 A 的会话重置，再 `show_dialogue("V4_INTRO")`。序章完成只回到可操作 1F，**不调用 complete_manager_intro**。

新增 `GameManager.has_completed_manager_intro() -> bool` 只读查询；floor 在经理员工现有交互范围内、尚未完成初次谈话时，提供唯一世界目标 `MANAGER_TALK`（优先级 0），E 只发 `manager_talk_requested()`。main 接该请求并显示 `V4_MANAGER_TALK`。D 的 `dialogue_finished(dialogue_id: String)` 必须与 A 当前播放 ID 一致才接受；只有 V4_MANAGER_TALK 完成时调用真实 complete_manager_intro，开放 2F，重复完成不再生效。

main 仅登记／释放自己的 `STORY_DIALOGUE` 模态，D 组件不改任务真值。模态暂停任务、取消长按并屏蔽世界 E；主场景通过 modal_changed 同步 Player 移动锁，不会因关闭对白清除另一页面的模态。对白期间 main 的 _input 提前消费 Q，B 原 CardManager 仍是唯一换卡执行者；未修改其独立 F6 或装备逻辑。D 自己处理 E／鼠标继续，A 既有松键保护防止关闭对白的 E 继续偷卡／上楼。

对白显示时隐藏 A 开发覆盖层，防止透明区域点到后面的开发按钮；完成后才恢复覆盖层。主入口已删除 CompleteIntro 代记按钮，保留明确标识的开发新局。新局重置本次经理完成标志并重播序章，D 的已读存储和跳过策略沿用原组件；已读不等于新局自动完成经理。卸载主场景释放自己的模态，其他模块的独立输入保持不变。

`intro_flow_smoke.gd` 使用真实场景、TSV、输入事件、员工范围、两 Autoload 和楼梯；已读测试文件仅写 /private/tmp。覆盖序章／经理独立完成、移动／Q、E／鼠标单次推进、模态叠加、关闭 E、防重复、无卡上楼、新局和卸载。foundation 先通过真实继续按钮完成序章再测移动，不把对白锁移动当回归故障。D 独立 intro_preview 使用其专用 user:// 测试文件，沙箱禁止保存时须在可访问该测试目录的环境运行，不能把保存失败算通过。

尚缺：B 快照／清理／正面失败及 D 任务面板／HUD／失败重试等；F5 不具备完整 201 任务闭环。经理对白已接入也不代表首次跳过及完整模态冻结决策已由全员确认。

### 16.1 首轮 F5 反馈后的谈话与引导修正

本地未提交修正：floor 新增 `manager_talk_radius=90` 的对称水平交谈范围，经理谈话不再读 B 的偷窃 Area／背后判定。实际探针未复现“仅背身能谈”：旧版在 40px 的四种朝向／来侧都能谈，85px 全不响应；本次修正解决范围耦合与可发现性，不把用户感受直接写成已证实的方向代码错误。

初次 MANAGER_TALK 仍优先级 0，首次完成后同 ID 为优先级 3 的路线提示，E 只提醒右梯→2F 201，不重复整段对白。将来 GameManager 对经理偷窃目标确实返回允许时，谈话候选让位给 B 真实偷卡；该后续任务尚未启用。经理头顶提示与可交谈范围一致，B 偷窃组件／转向仍未修改。

main 现在连接 task_offered／task_updated 并显示持续 Objective；201 的真实介绍会明确显示“接受任务界面尚未开放，本次试玩到此”，任务保持 AVAILABLE／0 秒。该临时反馈不是 D 的任务面板，也不添加接受／完成按钮；D-V4-02 仍须交付完整面板，A 再接真实接受调用。经理初谈完成仅开放楼梯，不在 1F 自动发任务。

本次验证和后续责任见 [QA 首轮记录](qa.md#2026-11-12-首轮-f5-试玩反馈)。B 负责不同角色的待机／转向预告与节奏，A 负责主场景交互与接线，D 负责任务展示及接受／失败页面；不为了让当前预览看似能继续而重写其他成员组件或伪造任务成功。


## 17 任务 01 检查点与真实 B 组件接入（2026-11-13）

本节描述 A 整合候选的实际接口，候选在 work/member-A-liuling 维护。仅任务 01；D 评审分支的选定组件现已接入 F5，接线和组件来源见 §18。自动化脚本不能代替人工联合验收。

| 入口／事件 | 当前行为及接入方式 |
|---|---|
| `accept_task(task_id: String) -> bool` | 保留 PLAYING／2F／AVAILABLE／同 ID 校验；有真实楼层宿主时先验证 201 安全点，再深拷贝 B `export_snapshot()` 和 A 世界／故事／已完成／已到达层事实，成功才 ACTIVE／210 秒。TASK_OFFER 模态可保持打开直至接受成功，之后 D 只释放自己的模态。无宿主的独立状态测试可接受，但不创建物理恢复点，也不能重试 |
| `can_retry_current_task() -> bool` | FAILED 状态、FAILED 任务、有宿主及同任务真实检查点，并通过 B `validate_snapshot()` 才允许；供 D 决定按钮可用性。落点还会在恢复时对新楼层再次校验 |
| `retry_current_task() -> bool` | 校验快照→RESTORING 取消长按→实例化接取层并核验保存落点→B `restore_snapshot()`→替换旧层、恢复 A 事实并清模态→重建工作／门镜像、主角与相机→PLAYING／AVAILABLE／0 秒；发 `floor_changed(2)` 和 `task_offered(task_id)` 等待重新接受。失败返回 false；无效卡快照或危险／变更落点不修改原卡片与失败世界；重复点击不重复加载 |
| D 的关闭／刷新责任 | 监听 `state_changed("RESTORING")` 关闭旧任务／失败／暂停等页面并清本地开关；GameManager 清登记不会替 D 隐藏 UI 节点。收到 task_offered 后读 get_task_view 并重新展示接受页；不要自动接受。当前 core 已同步清自己的暂停开关；F5 由 A task_ui.gd 关闭选定的 D 页面，其他后续模态仍须各自接入 |
| B 员工 | A 为正式实例设稳定 target_id、requires_task_eligibility=true，按真实查询刷新 set_task_eligible；连接 `task_failure_requested(reason, target_id)`，只接当前楼层合法来源的 STAFF_CAUGHT。正面和偷窃中转身都走同一任务失败链；移除楼层的迟到事件拒绝 |
| B 工作点 | 2F 的 `Interactions/Stain201Slot/CleaningSpot` 直接实例化 B cleaning_spot，A setup(player)、set_task_active 并选择唯一 E；当前 CLEANER 且真实 Area 范围内长按 1.5 秒，A 推进 advance_interaction，收到 cleaning_completed 后调用 record_work_result。移动／松 E／换卡／开模态／换层／失败取消长按；清理只 READY_TO_SUBMIT，回真实 201 按 E 才 COMPLETED 并放行 |
| 世界持久化与恢复 | 污渍显示读取 A stain_201_cleaned；回访重建后仍隐藏。失败恢复撤销任务期取得的卡／污渍，保留接取前事实；B 恢复仅一次 cards_changed，无 identity_changed。后续任务、309 跟随与笔记正式 UI 尚未接入，不宣称已实测 |
| 安全点与普通退回 | 任务 01 采用 2F x560／y560，捕获和新层恢复均校验实际 201 STORY 半径及其他门排除区、走廊边界；x1120 仍不是重试点。普通门继续 request_safe_return，不调用任务重试、不回滚卡片／任务／时间 |
| 输入与开发入口 | A 楼层在非 world_input_allowed 时消费世界 Q，B 独立场景不改；唯一 E 增 WORK。F6 task_01_core_test 使用真实工作和交付，已删代记 Clean／Deliver；只保留明确标注的经理／介绍／接受／失败开发控制。F5 已接 D 接受／失败按钮，来源与范围见 §18 |

2026-11-13 已同步 main `f559dc4` 的 B 保洁行为：未被当前身份识别的玩家进入范围会触发短暂 CURIOUS 并改变朝向；好奇本身不发送任务失败，正面按 E 仍发送 STAFF_CAUGHT。A 维持原资格查询、唯一 E 和失败来源校验；测试等待真实 SuspicionTimer 结束再按实际朝向绕后，不在生产实例关闭好奇。F5 本地现接 D 评审组件；F6 开发接受仍不能算正式接取。

验证命令及限制见最新 [进度](progress.md)；新增 `scenes/tests/core/task_checkpoint_smoke.gd` 驱动真实 B/C 与 E/Q，数据夹具仅用于接取前成果及可重复计时／转身条件，不代记人工验收。


## 18 201 主入口任务 UI 接线（2026-11-13）

当前为 A 个人分支整合候选，基于 main `0145926`。从 D 评审分支 `work/member-D-v4-ui-review` 的固定提交 `eb5e019` 原样复制 `mission_board.gd/.uid/.tscn`、`hud.gd/.uid/.tscn`、`failure.gd/.uid/.tscn`、`card_display.gd/.uid` 和 `staff_ui_theme.tres` 共 12 个文件。没有合并 D 整条旧分支，也没有覆盖 `dialogue.gd/.tscn`、TSV 和素材。评审分支存在不代表已合入 main；发布授权另行处理。

| 接头 | 实际行为 |
|---|---|
| A `scenes/task_ui.gd` | 挂在 main 的 TaskLayer；装配原 D MissionBoard／HUD／Failure，只管理显示、焦点、模态和请求适配，不另存任务／计时／卡真值 |
| 任务介绍 | `GameManager.task_offered(task_id)` → `TaskUI.open_offer(task_id)`；校验当前任务／AVAILABLE／PLAYING／2F。D 面板读 get_task_view，A 补所需身份、210 秒及工作路线 |
| 接受与关闭 | D 接受按钮调用真实 `accept_task(task_id)`，成功后由 A 关闭面板；面板可见登记 TASK_OFFER，隐藏只释放该项，不清其他模态。关闭不会自动接受或开始计时 |
| 重新打开 | floor 在真实 201 STORY 范围内把 AVAILABLE 的 ROOM_201 纳入唯一 E；发 `task_offer_requested(task_id)` → main → TaskUI.open_offer。没有重复调用 offer_task 或改 C 的任务镜像 |
| HUD | 原 D HUD 继续订阅卡片／楼层；A `scenes/task_hud.gd` 继承原脚本，将任务 01 状态与路线显示为中文，仍读取 GameManager 时钟。A 只在实例内把 D 两个 PanelContainer 子节点移入 VBox，避免重叠 |
| 失败和重试 | game_failed → D show_failure → A 适配超时／被抓标题及重试可用性。按钮发 retry_requested，A 再校验失败页可见且 can_retry_current_task，才调用 retry_current_task；RESTORING 关闭旧面板，恢复后的 task_offered 打开 AVAILABLE／0 秒接受页 |
| 旧控件复位 | D 原任务面板在 task_failed 会显示自己的禁用重试控件；A 每次呈现接受页都隐藏该控件并复位文字颜色，防止恢复／新局出现“待 A 接入”残留。失败页的原菜单按钮在本实例明确改名“重新开始（重播序章）”，连接 main 新局，不伪造主菜单 |
| 输入与卸载 | TASK_OFFER／TASK_FAILURE 取消长按并锁 Player；可见页面消费世界 E/Q，释放 E 仍由楼层观察。关闭／接受后须松 E 再操作世界；TaskUI 卸载释放自己的两个模态。序章／经理对白期间隐藏 TaskLayer，继续沿用 STORY_DIALOGUE |
| 普通门与楼梯 | 普通退回继续显示主入口警告，不弹任务失败／重试页；D 面板内楼层按钮在接受页隐藏，楼层选择不绕过真实楼梯 E／距离／许可。正式楼梯列表、普通警告页、背包／手册／暂停与 M2 核验另行接入 |

D 组件目前没有公开的接受详情／重试配置方法；A 适配层临时读取 `_hint`、`_status`、`_retry_button`、`_floor_buttons` 四个现有字段及现有节点。D 后续修改这些字段时须同步 A，建议增加稳定的配置入口；本轮不擅改 D 内部接口。任务 02 以后仍未启用，适配层的路线文字仅面向任务 01。

验证入口为 `res://scenes/tests/core/task_ui_smoke.gd`：先独立实例验证 D 组件，再运行真实 F5、对白、E 路由、D 按钮、B 卡／清理、C 交付和 A 恢复。任务时钟、楼层内位置和转身阶段使用明确自动化夹具；没有直接授卡或代记清理完成来完成 F5 链路。窗口截图仅是画面检查，人工验收和跨机器结果见 [QA](qa.md)。


## 19 菜单、背包和渐进调查笔记（2026-11-13）

A 当前工作区在 §18 基础上接入 D `eb5e019` 的 main_menu、help、bag 三组场景／脚本／UID，累计 21 个 D 原样组件文件。F5 首先进入正常菜单，开始按钮播放真实序章。失败页返回菜单，新一局由开始按钮清空会话后启动。

| 接口或归属 | 当前实现 |
|---|---|
| `GameManager.return_to_menu() -> void` | 取消安全退回中的延迟恢复，清模态登记并进入 MENU。主入口关闭自己挂载的页面／对白并显示菜单，开始游戏才重置任务／卡片 |
| `get_notebook_view() -> Dictionary` | 返回 unlocked 与 entries。entries 按 EYE／NOSE／HAT／EAR／CHECKER 排列，每项含 id、name、status、text，status 为 UNKNOWN／HINT／KNOWN。嵌套数据为新构建副本 |
| 笔记真值 | 从 _manager_intro_finished 和 _completed_task_ids 派生。经理交谈前全 UNKNOWN，之后 EYE／NOSE 为两条模糊 HINT，201 有效交付后 NOSE 为 KNOWN。卡片获得或清理未交付不揭示规则 |
| `notebook_changed()` | 新局、经理完成、任务 01 交付和任务恢复后通知 UI 重读。恢复使用既有经理／已完成任务快照，D 不维护独立解锁数组 |
| H 和菜单说明 | main 统一输入，原 D help 自收 H 停用。A `scenes/notebook.gd` 继承 D 帮助页，工作证页读当前所有权，调查页读真实笔记，当前未知规则保持未知 |
| I | main 统一打开／关闭原 D bag，原独立 I 输入停用。装备仍调用 CardManager.equip_card，卡变化仍由 B 发通知。A bag_adapter.gd 仅修正从空背包首次获得卡后残留的空状态文字 |
| 模态 | D 原页面继续登记大小写敏感的 `help`／`bag`，与 TASK_OFFER／TASK_FAILURE／STORY_DIALOGUE 共存。主入口在失败、恢复、加载或菜单时关闭自己挂载的页面，卸载释放对应模态 |
| 输入 | 主菜单／笔记／背包可见时消费世界 E/Q，模态锁移动并停任务计时，释放 E 仍由楼层观察。游戏中按 H/I 需世界可操作，已打开页面用同键关闭；菜单操作说明始终可访问 |
| 计时边界 | 有效提交时余量大于零立即结算，后续时钟回调不逆转 COMPLETED。归零失败已生效则拒绝工作／提交。notebook_smoke 覆盖两种同步调用顺序，沿用现有单一计时器 |

任务 02 以后的笔记、D-02 完整世界冻结与核验上下文、正式暂停和楼梯 UI 仍按对应阶段接入。当前笔记入口仅实现已可玩任务 01 的事实。D 后续可用公开组件入口替换 A 的继承适配，需保持上述读取与生命周期约定。B/C/D 后续 prompt 见 [协作交接](a_bcd_handoff.md)。
