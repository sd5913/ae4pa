extends Node2D
## A owns floor assembly and E routing; B/C retain their component implementations.

signal floor_selection_requested()
signal notice_requested(text: String)
signal formatted_notice_requested(template: String, arguments: Array)
signal manager_talk_requested()
signal task_offer_requested(task_id: String)
signal task_dialogue_requested(task_id: String)
signal rescue_open_requested()

const CARD_NAMES: Dictionary = {"SECURITY": "保安", "CLEANER": "保洁", "MANAGER": "经理"}
const STAFF_TARGET_IDS: Dictionary = {"CLEANER": "STAFF_CLEANER_1F", "SECURITY": "STAFF_SECURITY_1F", "MANAGER": "STAFF_MANAGER_1F"}

@export_range(1, 5) var floor_number: int = 1
@export var corridor_width: float = 3600.0
@export var task_01_barrier_x: float = 0.0
@export var task_02_barrier_x: float = 0.0
@export_range(1.0, 160.0) var manager_talk_radius: float = 90.0

var _held_staff: Node
var _held_work: CleaningSpot
var _work: CleaningSpot
var _works: Array[CleaningSpot] = []
var _needs_e_release: bool = false
var _doors: Array[Node2D] = []
var _safe_points: Dictionary = {}

@onready var player: HotelPlayer = $Player
@onready var exit_point: Marker2D = $Interactions/ExitPoint
@onready var exit_hint: Label = $Interactions/ExitPoint/Hint
@onready var return_point: Marker2D = $Interactions/ReturnPoint
@onready var return_hint: Label = $Interactions/ReturnPoint/Hint


func _ready() -> void:
	player.global_position = $SpawnPoint.global_position
	player.set_walk_bounds(64.0, corridor_width - 64.0)
	var camera: Camera2D = player.get_node("Camera2D")
	camera.limit_right = roundi(corridor_width)
	camera.reset_smoothing()
	for slot: Node2D in $StaffRoot.get_children():
		_add_caption(slot, "", -165.0)
		var staff: Node = slot.get_node("Staff")
		staff.setup(player)
		if staff.target_id.is_empty():
			staff.target_id = STAFF_TARGET_IDS[staff.card_id]
		staff.requires_task_eligibility = true
		staff.task_failure_requested.connect(_on_staff_failure.bind(staff))
		staff.card_stolen.connect(_on_card_stolen)
		# A dispatches formal-floor E; B's own F6 adapter remains unchanged.
		staff.set_process_unhandled_input(false)
	_setup_doors()
	_work = get_node_or_null("Interactions/Stain201Slot/CleaningSpot")
	for path: String in ["Interactions/Stain201Slot/CleaningSpot", "Interactions/ParcelCabinet2F", "Interactions/Register309"]:
		var work: CleaningSpot = get_node_or_null(path)
		if work != null:
			_works.append(work)
			work.setup(player)
			work.work_requested.connect(_on_work_requested.bind(work))
	if $Interactions.has_node("RescuePoint") and not has_node("Floor3Art"):
		_add_caption($Interactions/RescuePoint, "309 · 救援接入位\n对白与救援尚未实现", -165.0)
	_refresh_exit_hint()
	_refresh_staff_captions()
	GameManager.modal_changed.connect(_on_modal_changed)
	GameManager.state_changed.connect(_on_state_changed)
	GameManager.task_updated.connect(_apply_task_route)
	CardManager.identity_changed.connect(_on_identity_changed)
	_needs_e_release = Input.is_action_pressed("interact")
	_apply_task_route()
	queue_redraw()


func _process(delta: float) -> void:
	_refresh_component_eligibility()
	_try_offer_task_02()
	_try_offer_task_03()
	_resolve_known_card_encounter()
	if is_instance_valid(_held_staff):
		if not GameManager.is_world_input_allowed() or not _held_staff.is_player_in_range() or player.is_moving or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or not GameManager.is_interaction_allowed(_held_staff.target_id):
			_cancel_held_interaction()
		elif not _held_staff.is_stealing():
			_held_staff = null
	if is_instance_valid(_held_work):
		if not GameManager.is_world_input_allowed() or player.is_moving or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or not _held_work.can_interact():
			_cancel_held_interaction()
		else:
			_held_work.advance_interaction(delta)
			if is_instance_valid(_held_work) and not _held_work.is_interacting():
				_held_work = null
	_refresh_exit_hint()
	_refresh_staff_captions()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_id") and not GameManager.is_world_input_allowed():
		get_viewport().set_input_as_handled()
	# Observe release even when a UI consumes it before _unhandled_input.
	if event.is_action_released("interact"):
		_cancel_held_interaction()
		_needs_e_release = false


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or event.is_echo():
		return
	if _needs_e_release or not GameManager.is_world_input_allowed():
		return
	var target: Dictionary = _choose_interaction_target()
	if target.is_empty():
		return
	get_viewport().set_input_as_handled()
	_needs_e_release = true
	if target["kind"] == "STAIR":
		if floor_selection_requested.has_connections():
			floor_selection_requested.emit()
		else:
			GameManager.request_floor_travel(target["floor"])
	elif target["kind"] == "OFFER":
		task_offer_requested.emit(target["node"].task_id)
	elif target["kind"] == "STORY":
		target["node"].request_interaction()
	elif target["kind"] == "TALK":
		if GameManager.has_completed_manager_intro():
			_emit_notice("到右端楼梯按 E 上 2F，再向右找到 201 房门；任务在那里接取。")
		else:
			manager_talk_requested.emit()
	elif target["kind"] == "RESCUE_GATE":
		if GameManager.has_friend:
			_emit_notice("帕希卡已同行；前往五楼消防出口。")
		elif not GameManager.get_completed_task_ids().has(GameManager.TASK_03_ID) or not GameManager.get_world_flags().get("registration_309_approved", false):
			_emit_notice("309尚未获准；先完成302的管理授权任务。")
		elif CardManager.active_card != "CLEANER":
			_emit_notice("309：需要当前生效的保洁身份；持有或备用槽不算开门权限。")
		else:
			rescue_open_requested.emit()
	elif target["kind"] == "WORK":
		var work: CleaningSpot = target["node"]
		if work.begin_interaction():
			_held_work = work if work.is_interacting() else null
		else:
			_emit_notice("先接受对应任务并切到所需当前身份；清理须长按 E，包裹柜按 E 领取。")
	elif GameManager.is_interaction_allowed(target["id"]):
		var staff: Node = target["node"]
		if staff.begin_steal():
			_held_staff = staff
	else:
		_emit_notice("先接受对应任务；此处不会开始偷窃")


func get_interaction_target_id() -> String:
	if not GameManager.is_world_input_allowed():
		return ""
	if is_instance_valid(_held_staff):
		return _held_staff.target_id
	if is_instance_valid(_held_work):
		return _held_work.target_id
	return _choose_interaction_target().get("id", "")


func _choose_interaction_target() -> Dictionary:
	var candidates: Array[Dictionary] = []
	if floor_number == 3 and has_node("Interactions/RescuePoint") and absf(player.global_position.x - $Interactions/RescuePoint.global_position.x) <= 70.0:
		candidates.append({"id": "RESCUE_309", "kind": "RESCUE_GATE", "priority": 1, "distance": absf(player.global_position.x - $Interactions/RescuePoint.global_position.x)})
	for work: CleaningSpot in _works:
		if work.visible and not work.is_completed() and absf(player.global_position.x - work.global_position.x) <= 70.0:
			candidates.append({"id": work.target_id, "kind": "WORK", "node": work, "priority": 1 if work.can_interact() else 3, "distance": absf(player.global_position.x - work.global_position.x)})
	for door: Node2D in _doors:
		if door.door_mode == "STORY" and GameManager.current_task_id == door.task_id and GameManager.task_status in ["AVAILABLE", "READY_TO_SUBMIT"]:
			var distance: float = absf(player.global_position.x - door.global_position.x)
			if distance <= door.story_radius:
				candidates.append({"id": "ROOM_" + door.room_id, "kind": "OFFER" if GameManager.task_status == "AVAILABLE" else "STORY", "node": door, "priority": 0, "distance": distance})
	for slot: Node in $StaffRoot.get_children():
		var staff: Node2D = slot.get_node("Staff")
		if _can_talk_to_manager(staff):
			candidates.append({"id": "MANAGER_TALK", "kind": "TALK", "node": staff, "priority": 3 if GameManager.has_completed_manager_intro() else 0, "distance": absf(player.global_position.x - staff.global_position.x)})
			continue
		if staff.is_player_in_range():
			var target_id: String = staff.target_id
			candidates.append({"id": target_id, "kind": "STAFF", "node": staff, "priority": 1 if GameManager.is_interaction_allowed(target_id) else 3, "distance": absf(player.global_position.x - staff.global_position.x)})
	for destination: int in [floor_number - 1, floor_number + 1]:
		if destination < 1 or destination > 5:
			continue
		var stair: Marker2D = return_point if destination < floor_number else exit_point
		var distance: float = absf(player.global_position.x - stair.global_position.x)
		if distance <= 70.0:
			candidates.append({"id": "STAIRS_%s_%dF" % ["DOWN" if destination < floor_number else "UP", floor_number], "kind": "STAIR", "floor": destination, "priority": 2, "distance": distance})
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a["priority"] != b["priority"]:
			return a["priority"] < b["priority"]
		if a["distance"] != b["distance"]:
			return a["distance"] < b["distance"]
		return a["id"] < b["id"]
	)
	return candidates[0] if not candidates.is_empty() else {}


func _can_talk_to_manager(staff: Node2D) -> bool:
	# Conversation has its own symmetric range; theft keeps B's facing/Area rules.
	return staff.card_id == "MANAGER" and not GameManager.is_interaction_allowed(STAFF_TARGET_IDS["MANAGER"]) and absf(player.global_position.x - staff.global_position.x) <= manager_talk_radius


func _cancel_held_interaction() -> void:
	if is_instance_valid(_held_staff):
		var staff: Node = _held_staff
		_held_staff = null
		staff.cancel_steal()
	if is_instance_valid(_held_work):
		var work: CleaningSpot = _held_work
		_held_work = null
		work.cancel_interaction()


func _refresh_component_eligibility() -> void:
	for slot: Node in $StaffRoot.get_children():
		var staff: Node = slot.get_node("Staff")
		staff.set_interaction_enabled(GameManager.is_world_input_allowed())
		staff.set_task_eligible(GameManager.is_interaction_allowed(staff.target_id))
	for work: CleaningSpot in _works:
		var task_id: String = ""
		for enabled_id: String in GameManager.ENABLED_TASKS:
			if GameManager.get_task_definition(enabled_id)["target_id"] == work.target_id:
				task_id = enabled_id
				break
		if task_id.is_empty():
			work.set_task_active(false)
			continue
		var flag: String = GameManager.get_task_definition(task_id)["work_flag"]
		var completed: bool = GameManager.get_world_flags().get(flag, false)
		if work.is_completed() != completed:
			work.set_completed(completed)
		work.visible = not completed if work.interaction_type == "CLEAN" else true
		work.set_task_active(GameManager.is_interaction_allowed(work.target_id))


func _on_staff_failure(reason: String, target_id: String, staff: Node) -> void:
	if is_inside_tree() and floor_number == GameManager.current_floor and reason == "STAFF_CAUGHT" and is_ancestor_of(staff) and target_id == staff.target_id and GameManager.is_interaction_allowed(target_id):
		GameManager.request_task_failure(reason)


func _on_work_requested(target_id: String, source: CleaningSpot) -> void:
	if not is_inside_tree() or floor_number != GameManager.current_floor or not _works.has(source) or not is_ancestor_of(source) or target_id != source.target_id:
		return
	if not GameManager.record_work_result(target_id):
		source.reset_completion_report()
	_refresh_component_eligibility()


func _on_modal_changed() -> void:
	_cancel_held_interaction()
	_refresh_component_eligibility()
	_needs_e_release = _needs_e_release or Input.is_action_pressed("interact")
	for door: Node2D in _doors:
		door.set_physics_process(GameManager.is_world_input_allowed())
	_apply_task_route() # Refresh work/staff eligibility after the task modal closes.


func _on_state_changed(state: String) -> void:
	if state != "PLAYING":
		_cancel_held_interaction()
	_refresh_component_eligibility()
	for door: Node2D in _doors:
		door.set_physics_process(GameManager.is_world_input_allowed())


func _on_identity_changed(_action: String) -> void:
	_cancel_held_interaction()
	_resolve_known_card_encounter()


func _exit_tree() -> void:
	_cancel_held_interaction()


func _apply_task_route() -> void:
	_refresh_component_eligibility()
	var right_bound: float = corridor_width - 64.0
	if task_01_barrier_x > 0.0 and not GameManager.get_world_flags().get("passage_201_unlocked", false):
		right_bound = task_01_barrier_x - 24.0
		if not _doors.is_empty() and GameManager.task_status in ["NONE", "AVAILABLE"]:
			right_bound = minf(right_bound, $DoorRoot/Room201.global_position.x - 112.0)
	if task_02_barrier_x > 0.0 and not GameManager.get_world_flags().get("passage_202_unlocked", false):
		right_bound = minf(right_bound, task_02_barrier_x - 24.0)
	player.set_walk_bounds(64.0, right_bound)
	if has_node("Interactions/Task01Barrier"):
		$Interactions/Task01Barrier.visible = not GameManager.get_world_flags().get("passage_201_unlocked", false)
	if has_node("Interactions/Task02Barrier"):
		$Interactions/Task02Barrier.visible = GameManager.get_world_flags().get("passage_201_unlocked", false) and not GameManager.get_world_flags().get("passage_202_unlocked", false)
	for door: Node2D in _doors:
		if door.door_mode == "STORY":
			door.set_story_state("COMPLETED" if GameManager.get_completed_task_ids().has(door.task_id) else GameManager.task_status if GameManager.current_task_id == door.task_id else "NONE")
	if floor_number == 3 and has_node("Interactions/RescuePoint/TaskHint"):
		$Interactions/RescuePoint/TaskHint.text = "帕希卡已同行" if GameManager.has_friend else "309 · 当前保洁身份 · E 开门" if GameManager.get_world_flags().get("registration_309_approved", false) else "309 · 先取得管理批准"
	queue_redraw()


func get_task_checkpoint_position(task_id: String) -> Dictionary:
	if not GameManager.ENABLED_TASKS.has(task_id) or floor_number != GameManager.get_task_definition(task_id)["offer_floor"] or _doors.is_empty():
		return {}
	var marker_path: String = "Interactions/Task03AcceptSafe" if task_id == GameManager.TASK_03_ID else "Interactions/Task01AcceptSafe" if task_id == GameManager.TASK_01_ID else "Interactions/Task02AcceptSafe"
	var marker: Node2D = get_node(marker_path)
	var room: Node2D = get_node("DoorRoot/Room" + GameManager.get_task_definition(task_id)["room_id"])
	var destination: Vector2 = marker.global_position
	if destination.x < 64.0 or destination.x > room.global_position.x - 120.0 or not is_equal_approx(destination.y, player.global_position.y):
		return {}
	for door: Node2D in _doors:
		var exclusion_radius: float = door.story_radius if door.door_mode == "STORY" else door.radius
		if absf(destination.x - door.global_position.x) <= exclusion_radius:
			return {}
	return {"position": destination}


func _setup_doors() -> void:
	var scheduler := preload("res://scenes/doors/door_scheduler.gd").new()
	scheduler.player = player
	for slot: Node2D in $DoorRoot.get_children():
		var room := str(slot.get_meta("room_number"))
		if preload("res://scenes/doors/v4_door_catalog.gd").pool(room).is_empty():
			continue
		var door: Node2D = preload("res://scenes/doors/monster_door.tscn").instantiate()
		door.name = "Door"
		preload("res://scenes/doors/v4_door_catalog.gd").configure(door,room)
		if room in ["202", "302"]:
			door.door_mode = "STORY" # A's formal task adapter; C's catalog remains reusable.
		# Coordinated production floors; old standalone component adapters keep their API.
		door.managed_cycle = true
		slot.set_meta("monster_type",door.monster_type)
		slot.add_child(door)
		door.set_managed_state("CLOSED")
		door.setup(player)
		door._last_managed_x = player.global_position.x
		if room in ["201", "202", "302"]:
			door.story_intercept_requested.connect(_on_story_intercept.bind(door))
			door.task_submit_requested.connect(_on_task_submit.bind(door))
			door.story_progress_requested.connect(_on_story_progress)
		if room == "202" and has_node("Interactions/Room202LeftSafe"):
			_safe_points[door] = [$Interactions/Room202LeftSafe,$Interactions/Room202RightSafe]
		_doors.append(door)
		scheduler.doors.append(door)
		if has_node("Floor2Art"):
			$Floor2Art.bind_door(room,door)
		elif has_node("Floor3Art"):
			$Floor3Art.bind_door(room,door)
		elif has_node("Floor4Art"):
			$Floor4Art.bind_door(room,door)
		elif has_node("Floor5Art"):
			$Floor5Art.bind_door(room,door)
	add_child(scheduler)
	GameManager.monster_encounter_requested.connect(_on_monster_encounter)


func _on_monster_encounter(context: Dictionary) -> void:
	if not _doors.any(func(door: Node2D): return door.room_id == context.room_id):
		return
	if context.room_id == "201" and GameManager.offer_task(context.task_id):
		return
	if context.room_id in ["202", "302"]:
		_try_offer_followup(GameManager.TASK_02_ID if context.room_id == "202" else GameManager.TASK_03_ID)
		return
	if floor_number in [2, 3] and not context.first_encounter and context.monster_type in ["NOSE", "EYE", "HAT"]:
		_emit_notice("%s需要当前%s身份；按Q切换到对应工作证后通过。", [context.room_id, {"NOSE": "保洁", "EYE": "保安", "HAT": "经理"}[context.monster_type]])
		return
	var message := (
		"%s：首次遇见 %s。已登记强制任务请求，等待聊天／任务接入。" if context.first_encounter
		else "%s：未满足 %s 的通行规则。已登记强制任务请求，等待聊天／任务接入。"
	)
	_emit_notice(message, [context.room_id, context.monster_type])


func _try_offer_task_02() -> void:
	_try_offer_followup(GameManager.TASK_02_ID)


func _try_offer_task_03() -> void:
	# Formal302 intercept is independent of C's ordinary door animation phase.
	if floor_number == 3 and GameManager.is_world_input_allowed() and GameManager.can_offer_task(GameManager.TASK_03_ID) and GameManager.get_pending_monster_encounter().is_empty() and absf(player.global_position.x - $DoorRoot/Room302.global_position.x) <= 120.0:
		GameManager.request_monster_encounter("302", "HAT", "STORY_TASK")
	_try_offer_followup(GameManager.TASK_03_ID)


func _try_offer_followup(task_id: String) -> void:
	if not GameManager.is_world_input_allowed() or not GameManager.can_offer_task(task_id):
		return
	var room_id: String = GameManager.get_task_definition(task_id)["room_id"]
	if GameManager.get_pending_monster_encounter().get("room_id", "") != room_id:
		return
	var room: Node2D = get_node_or_null("DoorRoot/Room" + room_id)
	if room == null or absf(player.global_position.x - room.global_position.x) > 120.0:
		return
	if task_dialogue_requested.has_connections():
		task_dialogue_requested.emit(task_id)
	else:
		GameManager.offer_task(task_id) # Explicit core adapter; F5 uses real task dialogue.


func _resolve_known_card_encounter() -> void:
	if floor_number not in [2, 3] or not GameManager.is_world_input_allowed():
		return
	var context: Dictionary = GameManager.get_pending_monster_encounter()
	if context.is_empty() or context.get("first_encounter", true):
		return
	var required: Dictionary = {"NOSE": "CLEANER", "EYE": "SECURITY", "HAT": "MANAGER"}
	for door: Node2D in _doors:
		if door.room_id == context.room_id and door.door_mode == "NORMAL" and required.get(door.monster_type, "") == CardManager.active_card:
			GameManager.resolve_monster_encounter(context.room_id)
			_emit_notice("%s身份核对通过，可以继续前进。", [context.room_id])
			return


func _on_story_intercept(task_id: String, _room_id: String, door: Node2D) -> void:
	if not GameManager.is_world_input_allowed():
		return
	if task_id in [GameManager.TASK_02_ID, GameManager.TASK_03_ID]:
		_try_offer_followup(task_id)
		return
	GameManager.offer_task(task_id)
	door.set_story_state(GameManager.task_status if GameManager.current_task_id == task_id else "NONE")


func _on_task_submit(task_id: String, door: Node2D) -> void:
	if GameManager.is_world_input_allowed() and absf(player.global_position.x - door.global_position.x) <= door.story_radius:
		GameManager.submit_task(task_id)
	door.set_story_state(GameManager.task_status if GameManager.current_task_id == task_id else "NONE")


func _on_story_progress(task_id: String) -> void:
	if task_id == GameManager.TASK_03_ID:
		_emit_notice("回1F取得经理证，装备并切为当前身份，再到3F登记台按E批准309。")
		return
	if task_id == GameManager.TASK_02_ID:
		_emit_notice("包裹已领取，在202按E交付。" if GameManager.task_status == "READY_TO_SUBMIT" else "202任务进行中：取得保安证，切为当前身份，再去保管柜领取包裹。")
		return
	_emit_notice("工作完成后回 201 按 E 交付" if GameManager.task_status == "READY_TO_SUBMIT" else "当前任务进行中，请完成清理后返回")


func _on_door_violation(reason: String, approach_side: int, door: Node2D) -> void:
	GameManager.request_safe_return(door, reason, approach_side)


func get_safe_return_position(door: Node2D, approach_side: int) -> Dictionary:
	if approach_side not in [-1, 1] or not _safe_points.has(door) or not _doors.has(door):
		return {}
	if not is_ancestor_of(door) or not door.has_method("finish_safe_return"):
		return {}
	var point: Node2D = _safe_points[door][0 if approach_side == -1 else 1]
	var destination: Vector2 = point.global_position
	# C's recorded entry side wins even if this frame crossed the door centre.
	if (destination.x - door.global_position.x) * approach_side <= door.radius:
		return {}
	if destination.x < 64.0 or destination.x > corridor_width - 64.0:
		return {}
	if not is_equal_approx(destination.y, player.global_position.y):
		return {}
	for other: Node2D in _doors:
		var exclusion_radius: float = other.story_radius if other.door_mode == "STORY" else other.radius
		if absf(destination.x - other.global_position.x) <= exclusion_radius:
			return {}
		if other != door and other.global_position.x >= minf(destination.x, player.global_position.x) - exclusion_radius and other.global_position.x <= maxf(destination.x, player.global_position.x) + exclusion_radius:
			return {} # Do not carry the player through a neighbouring danger region.
	if task_01_barrier_x > 0.0 and not GameManager.get_world_flags().get("passage_201_unlocked", false):
		if maxf(destination.x, player.global_position.x) >= task_01_barrier_x - 24.0:
			return {}
	if task_02_barrier_x > 0.0 and not GameManager.get_world_flags().get("passage_202_unlocked", false):
		if maxf(destination.x, player.global_position.x) >= task_02_barrier_x - 24.0:
			return {}
	return {"position": destination}


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_exit_hint()
		_refresh_staff_captions()


func _refresh_exit_hint() -> void:
	return_hint.text = tr("靠近后按 E → %dF") % (floor_number - 1) if floor_number > 1 and GameManager.get_available_floors().has(floor_number - 1) else ""
	if floor_number == 5:
		exit_hint.text = "EXIT · 终点接入位\n通关功能待 A-10"
	elif floor_number == 1 and not GameManager.get_available_floors().has(2):
		exit_hint.text = "先完成经理初次对白，再上 2F"
	elif floor_number == 2 and not GameManager.get_available_floors().has(3):
		exit_hint.text = "完成 201 和 202 任务后开放 3F"
	elif floor_number == 3 and not GameManager.has_friend:
		exit_hint.text = "先进入 309 找到帕希卡，再前往五楼出口"
	elif not GameManager.get_available_floors().has(floor_number + 1):
		exit_hint.text = "下一层尚未开放"
	else:
		exit_hint.text = tr("靠近后按 E → %dF") % (floor_number + 1)


func _on_card_stolen(card_id: String) -> void:
	_refresh_staff_captions()
	_emit_notice("获得%s ID", [CARD_NAMES[card_id]])
	if not CardManager.get_equipped_cards().has(card_id):
		_emit_notice("已收藏%s工作证：两个装备槽已满。按I打开证件管理，选择此卡并替换槽A或B，再按Q切换。", [CARD_NAMES[card_id]])


func _emit_notice(template: String, arguments: Array[String] = []) -> void:
	# Keep the original notice signal for existing scene and preview consumers.
	notice_requested.emit(template if arguments.is_empty() else template % arguments)
	formatted_notice_requested.emit(template, arguments)


func _refresh_staff_captions() -> void:
	for slot: Node in $StaffRoot.get_children():
		var staff: Node = slot.get_node("Staff")
		var label: Label = slot.get_node("Caption")
		var role_name := tr(CARD_NAMES[staff.card_id])
		if _can_talk_to_manager(staff):
			label.text = "经理 · 按 E 查看去向" if GameManager.has_completed_manager_intro() else "经理 · 按 E 交谈（任意一侧）"
		elif CardManager.has_card(staff.card_id):
			label.text = tr("%s · ID 已取得") % role_name
		elif staff.is_stealing():
			label.text = tr("%s · 偷取中\n请保持不动并按住 E") % role_name
		elif staff.is_player_in_range():
			if not GameManager.is_interaction_allowed(staff.target_id):
				label.text = tr("%s · 先接受对应任务") % role_name
			else:
				label.text = tr("%s · 身后按住 E 0.8 秒") % role_name if staff.is_player_behind() else tr("%s · 当前在正面\n请绕到背后") % role_name
		else:
			label.text = tr("%s · 朝%s") % [role_name, tr("右 →") if staff.facing_direction > 0 else tr("左 ←")]


func _add_caption(slot: Node2D, caption: String, top: float) -> void:
	var label := Label.new()
	label.name = "Caption"
	label.position = Vector2(-160, top)
	label.size = Vector2(320, 64)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 18)
	label.text = caption
	slot.add_child(label)


func _draw() -> void:
	var wall_colors: Array[Color] = [Color("33464a"), Color("2a3d4d"), Color("3c3549"), Color("30433e"), Color("493c35")]
	draw_rect(Rect2(0, 0, corridor_width, 720), Color("172226"))
	draw_rect(Rect2(0, 180, corridor_width, 380), wall_colors[floor_number - 1])
	for x: int in range(160, int(corridor_width), 160):
		draw_line(Vector2(x, 180), Vector2(x, 560), Color(1, 1, 1, 0.05))
	draw_rect(Rect2(0, 560, corridor_width, 160), Color("111b20"))
	draw_line(Vector2(0, 560), Vector2(corridor_width, 560), Color("b89862"), 3.0)
	for slot: Node2D in $DoorRoot.get_children():
		draw_rect(Rect2(slot.position + Vector2(-65, -150), Vector2(130, 150)), Color("17232b"))
		draw_rect(Rect2(slot.position + Vector2(-65, -150), Vector2(130, 150)), Color("9a927f"), false, 3.0)
	draw_rect(Rect2(exit_point.position + Vector2(-30, -110), Vector2(60, 110)), Color("507e70"))
