extends "res://scenes/tests/core/full_mainline_escape_smoke.gd"
## C audit of actual main flow. Uses the inherited disclosed positions/facing/clock
## controls, real input/theft/work/dialogue/retry APIs, never grants task rewards.
var audit_rows: Array[Dictionary] = []
var audit_dir := "res://scenes/tests/doors/evidence/c_closeout_20261122"

func _initialize() -> void:
	capture_dir = ProjectSettings.globalize_path(audit_dir.path_join("screenshots_serial"))
	root.size = Vector2i(1280,720)
	super._initialize()

func snapshot(label: String) -> void:
	if not is_instance_valid(main) or not main.has_node("World") or main.get_node("World").get_child_count() == 0: return
	var f: Node = floor_node()
	var doors: Array = []
	for d in f.get("_doors"):
		var visual: Node = f.get_node_or_null("Floor%dArt/Doors/Room%s/MonsterIdle" % [g.current_floor,d.room_id])
		doors.append({"room":d.room_id,"monster":d.monster_type,"mode":d.door_mode,"state":d.door_state,"x":d.global_position.x,"visible_monster":visual.is_visible_in_tree() if visual != null else false,"visual_kind":visual.kind if visual != null else "","modulate_alpha":visual.modulate.a if visual != null else 0.0})
	audit_rows.append({"label":label,"game_state":g.game_state,"can_escape":g.can_escape(),"open_modals":g.get("_open_modals").duplicate(true),"world_flags":g.get_world_flags(),"needs_e_release":f.get("_needs_e_release"),"interaction_target":f.get_interaction_target_id(),"main_dialogue_visible":main.dialogue.visible,"monster_dialogue_visible":screen.visible if is_instance_valid(screen) else false,"floor":g.current_floor,"player_x":player().global_position.x,"task":g.current_task_id,"status":g.task_status,"pending":g.get_pending_monster_encounter(),"doors":doors,"follower":f.has_node("Persica")})

func check(ok: bool, message: String) -> void:
	super.check(ok,message)
	print("AUDIT_CHECK ", "PASS " if ok else "FAIL ", message)
	if is_instance_valid(g): snapshot(message)

func capture(name: String) -> void:
	snapshot(name)
	await super.capture(name)

func checker_controls(room: String) -> void:
	var original: Vector2 = player().position
	await move_to(floor_node().get_node("DoorRoot/Room"+room).position.x-35)
	var prior: Dictionary = c.export_snapshot()
	await tap("switch_id")
	check(c.export_snapshot()==prior,room+" actual in-range Q rejected")
	await tap("open_bag")
	var bag: Control = main.get_node("MenuLayer/Bag")
	check(not bag.visible,room+" actual in-range I rejected")
	if bag.visible: bag.close_bag()
	await capture(room+"_restricted")
	var safe: Node2D = floor_node().get_node("Interactions/TransitPickup205" if room=="205" else "Interactions/ExitRegister5F")
	await move_to(safe.position.x)
	check(floor_node().get_identity_restriction_room().is_empty(),room+" workstation is outside checker range")
	var slot_before: int = c.active_slot
	await tap("switch_id")
	check(c.active_slot!=slot_before,room+" safe-area Q actually changes slot")
	await tap("switch_id")
	check(c.export_snapshot()==prior,room+" outside-range Q can restore identity")
	await tap("open_bag")
	check(bag.visible,room+" safe-area I opens bag")
	if bag.visible: await tap("open_bag")
	await move_to(original.x)

func offer(room: String, task: String) -> bool:
	var accepted: bool = await super.offer(room,task)
	if accepted and room=="205": await checker_controls(room)
	return accepted

func work(node_name: String, hold: bool=false) -> void:
	await super.work(node_name,hold)
	#501 is intentionally closed during work. Restriction is tested after real
	#approval makes it ready and returning to the door opens it.
	if node_name=="ExitRegister5F" and g.task_status=="READY_TO_SUBMIT": await checker_controls("501")

func travel_exit() -> void:
	await move_to(floor_node().exit_point.global_position.x)
	snapshot("EXIT_before_real_E")
	await tap()
	snapshot("EXIT_after_real_E")
	await capture("full_escape")

func _finish_chain() -> void:
	snapshot("final_before_exit")
	DirAccess.make_dir_recursive_absolute(audit_dir)
	var file := FileAccess.open(audit_dir.path_join("main_flow_trace.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"baseline":"569b5d0941aaef73a327eaa19def1b0b95bcb798","mode":"automated graphical actual-main flow, not manual certification","failures":failures,"trace":audit_rows},"  "))
	await super._finish_chain()
