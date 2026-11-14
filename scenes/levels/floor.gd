extends Node2D
## A owns floor assembly and E routing; B/C retain their component implementations.

signal notice_requested(text: String)
signal manager_talk_requested()
signal task_offer_requested(task_id: String)

const CARD_NAMES: Dictionary = {"SECURITY": "保安", "CLEANER": "保洁", "MANAGER": "经理"}
const STAFF_TARGET_IDS: Dictionary = {"CLEANER": "STAFF_CLEANER_1F", "SECURITY": "STAFF_SECURITY_1F", "MANAGER": "STAFF_MANAGER_1F"}

@export_range(1, 5) var floor_number: int = 1
@export var corridor_width: float = 3600.0
@export var task_01_barrier_x: float = 0.0
@export_range(1.0, 160.0) var manager_talk_radius: float = 90.0

var _held_staff: Node
var _held_work: CleaningSpot
var _work: CleaningSpot
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
		staff.target_id = STAFF_TARGET_IDS[staff.card_id]
		staff.requires_task_eligibility = true
		staff.task_failure_requested.connect(_on_staff_failure.bind(staff))
		staff.card_stolen.connect(_on_card_stolen)
		# A dispatches formal-floor E; B's own F6 adapter remains unchanged.
		staff.set_process_unhandled_input(false)
	_setup_doors()
	_work = get_node_or_null("Interactions/Stain201Slot/CleaningSpot")
	if _work != null:
		_work.setup(player)
		_work.cleaning_completed.connect(_on_cleaning_completed)
	if $Interactions.has_node("RescuePoint"):
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
	if is_instance_valid(_held_staff):
		if not GameManager.is_world_input_allowed() or not _held_staff.is_player_in_range() or player.is_moving or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or not GameManager.is_interaction_allowed(STAFF_TARGET_IDS[_held_staff.card_id]):
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
		GameManager.request_floor_travel(target["floor"])
	elif target["kind"] == "OFFER":
		task_offer_requested.emit(target["node"].task_id)
	elif target["kind"] == "STORY":
		target["node"].request_interaction()
	elif target["kind"] == "TALK":
		if GameManager.has_completed_manager_intro():
			notice_requested.emit("到右端楼梯按 E 上 2F，再向右找到 201 房门；任务在那里接取。")
		else:
			manager_talk_requested.emit()
	elif target["kind"] == "WORK":
		if _work.begin_interaction():
			_held_work = _work
		else:
			notice_requested.emit("接受清理任务并将保洁卡切到当前身份，再在污渍处按住 E 1.5 秒。")
	elif GameManager.is_interaction_allowed(target["id"]):
		var staff: Node = target["node"]
		if staff.begin_steal():
			_held_staff = staff
	else:
		notice_requested.emit("先接受对应任务；此处不会开始偷窃")


func get_interaction_target_id() -> String:
	if not GameManager.is_world_input_allowed():
		return ""
	if is_instance_valid(_held_staff):
		return STAFF_TARGET_IDS[_held_staff.card_id]
	if is_instance_valid(_held_work):
		return _held_work.target_id
	return _choose_interaction_target().get("id", "")


func _choose_interaction_target() -> Dictionary:
	var candidates: Array[Dictionary] = []
	if is_instance_valid(_work) and _work.visible and absf(player.global_position.x - _work.global_position.x) <= 70.0:
		candidates.append({"id": _work.target_id, "kind": "WORK", "node": _work, "priority": 1 if _work.can_interact() else 3, "distance": absf(player.global_position.x - _work.global_position.x)})
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
			var target_id: String = STAFF_TARGET_IDS[staff.card_id]
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
	if is_instance_valid(_work):
		var cleaned: bool = GameManager.get_world_flags().get("stain_201_cleaned", false)
		if _work.is_completed() != cleaned:
			_work.set_completed(cleaned)
		_work.visible = not cleaned
		_work.set_task_active(GameManager.is_interaction_allowed(_work.target_id))


func _on_staff_failure(reason: String, target_id: String, staff: Node) -> void:
	if is_inside_tree() and floor_number == GameManager.current_floor and reason == "STAFF_CAUGHT" and is_ancestor_of(staff) and target_id == staff.target_id and GameManager.is_interaction_allowed(target_id):
		GameManager.request_task_failure(reason)


func _on_cleaning_completed(target_id: String) -> void:
	if not is_inside_tree() or floor_number != GameManager.current_floor or target_id != _work.target_id:
		return
	if not GameManager.record_work_result(target_id):
		_work.reset_completion_report()
	_refresh_component_eligibility()


func _on_modal_changed() -> void:
	_cancel_held_interaction()
	_refresh_component_eligibility()
	_needs_e_release = _needs_e_release or Input.is_action_pressed("interact")
	for door: Node2D in _doors:
		door.set_physics_process(GameManager.is_world_input_allowed())


func _on_state_changed(state: String) -> void:
	if state != "PLAYING":
		_cancel_held_interaction()
	_refresh_component_eligibility()
	for door: Node2D in _doors:
		door.set_physics_process(GameManager.is_world_input_allowed())


func _on_identity_changed(_action: String) -> void:
	_cancel_held_interaction()


func _exit_tree() -> void:
	_cancel_held_interaction()


func _apply_task_route() -> void:
	_refresh_component_eligibility()
	var right_bound: float = corridor_width - 64.0
	if task_01_barrier_x > 0.0 and not GameManager.get_world_flags().get("passage_201_unlocked", false):
		right_bound = task_01_barrier_x - 24.0
		if not _doors.is_empty() and GameManager.task_status in ["NONE", "AVAILABLE"]:
			right_bound = minf(right_bound, $DoorRoot/Room201.global_position.x - 120.0)
	player.set_walk_bounds(64.0, right_bound)
	if has_node("Interactions/Task01Barrier"):
		$Interactions/Task01Barrier.visible = right_bound < corridor_width - 64.0
	for door: Node2D in _doors:
		if door.door_mode == "STORY":
			door.set_story_state(GameManager.task_status if GameManager.current_task_id == door.task_id else "NONE")
	queue_redraw()


func get_task_checkpoint_position(task_id: String) -> Dictionary:
	if floor_number != 2 or task_id != GameManager.TASK_01_ID or _doors.is_empty():
		return {}
	var destination: Vector2 = $Interactions/Task01AcceptSafe.global_position
	if destination.x < 64.0 or destination.x > $DoorRoot/Room201.global_position.x - 120.0 or not is_equal_approx(destination.y, player.global_position.y):
		return {}
	for door: Node2D in _doors:
		var exclusion_radius: float = door.story_radius if door.door_mode == "STORY" else door.radius
		if absf(destination.x - door.global_position.x) <= exclusion_radius:
			return {}
	return {"position": destination}


func _setup_doors() -> void:
	for slot: Node2D in $DoorRoot.get_children():
		# M1 assembles 201 plus one ordinary door, without enabling task 02.
		if floor_number != 2 or slot.name not in ["Room201", "Room202"]:
			_add_caption(slot, "%s · %s\n房门接入位" % [slot.get_meta("room_number"), slot.get_meta("monster_type")], -230.0)
			continue
		var door: Node2D = preload("res://scenes/doors/monster_door.tscn").instantiate()
		if not door.has_method("finish_safe_return") or not door.has_method("set_story_state"):
			door.free()
			_add_caption(slot, "%s · 门组件待同步 C PR #12" % slot.get_meta("room_number"), -230.0)
			continue # Never connect the V3 component that still fails the whole floor.
		door.name = "Door"
		door.room_id = str(slot.get_meta("room_number"))
		door.monster_type = slot.get_meta("monster_type")
		if slot.name == "Room201":
			door.door_mode = "STORY"
			door.task_id = GameManager.TASK_01_ID
			door.story_radius = 120.0
			door.story_intercept_requested.connect(_on_story_intercept.bind(door))
			door.task_submit_requested.connect(_on_task_submit.bind(door))
			door.story_progress_requested.connect(_on_story_progress)
		else:
			_safe_points[door] = [$Interactions/Room202LeftSafe, $Interactions/Room202RightSafe]
			door.rule_violated.connect(_on_door_violation.bind(door))
		slot.add_child(door)
		door.setup(player)
		_doors.append(door)


func _on_story_intercept(task_id: String, _room_id: String, door: Node2D) -> void:
	if not GameManager.is_world_input_allowed():
		return
	GameManager.offer_task(task_id)
	door.set_story_state(GameManager.task_status if GameManager.current_task_id == task_id else "NONE")


func _on_task_submit(task_id: String, door: Node2D) -> void:
	if GameManager.is_world_input_allowed() and absf(player.global_position.x - door.global_position.x) <= door.story_radius:
		GameManager.submit_task(task_id)
	door.set_story_state(GameManager.task_status if GameManager.current_task_id == task_id else "NONE")


func _on_story_progress(_task_id: String) -> void:
	notice_requested.emit("工作完成后回 201 按 E 交付" if GameManager.task_status == "READY_TO_SUBMIT" else "当前任务进行中，请完成清理后返回")


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
	return {"position": destination}


func _refresh_exit_hint() -> void:
	return_hint.text = "靠近后按 E → %dF" % (floor_number - 1) if floor_number > 1 and GameManager.get_available_floors().has(floor_number - 1) else ""
	if floor_number == 5:
		exit_hint.text = "EXIT · 终点接入位\n通关功能待 A-10"
	elif floor_number == 1 and not GameManager.get_available_floors().has(2):
		exit_hint.text = "先完成经理初次对白，再上 2F"
	elif floor_number == 2 and not GameManager.get_available_floors().has(3):
		exit_hint.text = "完成 201 和 202 任务后开放 3F"
	elif floor_number == 3 and not GameManager.has_friend:
		exit_hint.text = "先完成 309 救援才能上楼\n救援功能待 A-08"
	elif not GameManager.get_available_floors().has(floor_number + 1):
		exit_hint.text = "下一层尚未开放"
	else:
		exit_hint.text = "靠近后按 E → %dF" % (floor_number + 1)


func _on_card_stolen(card_id: String) -> void:
	_refresh_staff_captions()
	var message: String = "获得%s ID" % CARD_NAMES[card_id]
	notice_requested.emit(message)


func _refresh_staff_captions() -> void:
	for slot: Node in $StaffRoot.get_children():
		var staff: Node = slot.get_node("Staff")
		var label: Label = slot.get_node("Caption")
		var role_name: String = CARD_NAMES[staff.card_id]
		if _can_talk_to_manager(staff):
			label.text = "经理 · 按 E 查看去向" if GameManager.has_completed_manager_intro() else "经理 · 按 E 交谈（任意一侧）"
		elif CardManager.has_card(staff.card_id):
			label.text = "%s · ID 已取得" % role_name
		elif staff.is_stealing():
			label.text = "%s · 偷取中\n请保持不动并按住 E" % role_name
		elif staff.is_player_in_range():
			if not GameManager.is_interaction_allowed(STAFF_TARGET_IDS[staff.card_id]):
				label.text = "%s · 先接受对应任务" % role_name
			else:
				label.text = "%s · 身后按住 E 0.8 秒" % role_name if staff.is_player_behind() else "%s · 当前在正面\n请绕到背后" % role_name
		else:
			label.text = "%s · 朝%s" % [role_name, "右 →" if staff.facing_direction > 0 else "左 ←"]


func _add_caption(slot: Node2D, caption: String, top: float) -> void:
	var label := Label.new()
	label.name = "Caption"
	label.position = Vector2(-160, top)
	label.size = Vector2(320, 64)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
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
