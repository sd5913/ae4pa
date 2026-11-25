extends SceneTree
## Real main from new game; deterministic positions/facing and clock, never fake work/card rewards.
var failures: Array[String] = []
var g: Node
var c: Node
var main: Node
var screen: Control
var capture_dir: String = OS.get_temp_dir().path_join("ae4pa-five-monster-native-%d" % OS.get_process_id())
var board: Control
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message); printerr("FAIL: " + message)
func floor_node() -> Node: return main.get_node("World").get_child(0)
func player() -> Node2D: return floor_node().get_node("Player")
func settle() -> void:
	for i in range(4): await physics_frame
	await process_frame
func key(action: String, pressed: bool) -> void:
	var e := InputEventAction.new(); e.action = action; e.pressed = pressed
	Input.parse_input_event(e); await settle()
func tap(action: String = "interact") -> void:
	await key(action, true); await key(action, false)
func drain_story() -> void:
	for i in range(100):
		if not main.dialogue.visible: return
		await tap()
func drain() -> void:
	for i in range(50):
		if not screen.visible: return
		await tap()
	check(false, "monster dialogue terminates")
func move_to(x: float) -> void:
	player().position.x = x; await settle()
func read_carol() -> void:
	# Read D's real equipment/timeout dialogue before requesting world input.
	await settle()
	var flow: Node = main.get_node("MenuLayer/Bag/CarolUIFlow")
	if flow.get("_mode") == "": return
	await create_timer(0.2).timeout
	for beat in range(40):
		if flow.get("_mode") == "": break
		await tap()
	check(flow.get("_mode") == "", "Carol dialogue returns normal input")
func travel(f: int) -> void:
	await read_carol()
	await move_to(3400 if f > g.current_floor else 192)
	check(g.request_floor_travel(f), "actual stair travel " + str(f))
	await settle()
func walk_to(x: float) -> void:
	var action := "move_right" if player().position.x < x else "move_left"
	Input.action_press(action)
	for i in range(300):
		if absf(player().position.x-x)<7.0: break
		await physics_frame
	Input.action_release(action); await settle()
	check(absf(player().position.x-x)<12.0, "real walking reaches work point")
func equip(card: String, second: String = "") -> void:
	# Actual I screen, card selection and equipment buttons; no direct slot fixture.
	if second.is_empty() and c.get_equipped_cards().has(card):
		if c.active_card != card: await tap("switch_id")
		return
	if not floor_node().get_identity_restriction_room().is_empty(): await walk_to(2850)
	var slot: int = c.active_slot
	await tap("open_bag")
	var bag: Control = main.get_node("MenuLayer/Bag")
	for spec: Array in [[card,slot],[second,1-slot]]:
		if spec[0].is_empty() or c.get_equipped_cards()[spec[1]]==spec[0]: continue
		var items: ItemList = bag.get_node("%OwnedCards")
		for i in range(items.item_count):
			if items.get_item_metadata(i)==spec[0]:
				items.select(i);items.item_selected.emit(i)
				bag.get_node("%EquipSlotA" if spec[1]==0 else "%EquipSlotB").pressed.emit()
				break
	await tap("open_bag");await settle()
	check(c.active_card==card and (second.is_empty() or c.get_equipped_cards().has(second)),"actual I/Q prepares requested identities")
func steal(slot: String, card: String) -> void:
	await travel(1)
	var staff: Node = floor_node().get_node("StaffRoot/" + slot + "/Staff")
	staff.facing_direction = 1; staff.patrol_enabled = false
	for n in ["TurnTimer", "TurnWarningTimer", "BehaviorTimer"]: staff.get_node(n).stop()
	await move_to(staff.global_position.x - 35)
	# Deterministic suspicion/facing fixture after the actual Area entered callback.
	staff.set("_is_suspicious", false); staff.set("_cleaner_state", "CLEANING"); staff.facing_direction = 1
	staff.get_node("SuspicionTimer").stop()
	for n in ["TurnTimer", "TurnWarningTimer", "BehaviorTimer"]: staff.get_node(n).stop()
	await key("interact", true); await create_timer(1.0).timeout; await key("interact", false)
	check(c.has_card(card), "real theft obtained " + card)
	await travel(2)
	var room: String=g.get_task_definition(g.current_task_id)["room_id"]
	check(floor_node().get_node("DoorRoot/Room"+room+"/Door").door_state=="OPEN", "unfinished monster is already at door after returning from1F")
func offer(room: String, task: String) -> bool:
	await move_to(floor_node().get_node("DoorRoot/Room" + room).position.x - 110)
	check(floor_node().get_node("DoorRoot/Room"+room+"/Door").door_state=="WARNING", room+" first contact has visible warning before dialogue")
	await capture(room+"_warning")
	for i in range(150):
		if screen.visible: break
		await physics_frame
	check(screen.visible and not board.visible, room + " D intro before acceptance")
	if room in ["203", "204", "205"]: check("201" not in main.get_node("TaskLayer/HUD/%Objective").text, room + " actual HUD has no201 fallback")
	check(floor_node().get_node("Floor2Art/Doors/Room"+room+"/MonsterIdle").is_visible_in_tree(),room+" real artwork monster appears in intro")
	await capture(room + "_intro")
	# D preserves202's established intro-before-offer callback; other offers precede intro.
	if room != "202": check(g.current_task_id == task and g.task_status == "AVAILABLE", room + " actual intercept offers correct task")
	await drain()
	check(g.current_task_id == task and g.task_status == "AVAILABLE" and board.visible, room + " dialogue ends without accepting or releasing")
	if g.current_task_id != task: return false
	board.get("_accept_button").pressed.emit(); await settle()
	check(g.task_status == "ACTIVE", room + " actual accept")
	if room in ["203", "204", "205"]:
		Input.action_press("move_right"); await create_timer(1.4).timeout; Input.action_release("move_right"); await settle()
		check(player().position.x < floor_node().get_node("DoorRoot/Room" + room).position.x, room + " cannot physically pass before work and delivery")
	return true
func work(node_name: String, hold: bool = false) -> void:
	var spot: Node2D = floor_node().get_node("Interactions/" + node_name)
	if node_name.begins_with("Transit"):
		await walk_to(spot.global_position.x)
		check(floor_node().get_interaction_target_id()==spot.target_id,"205 targets its visible workstation")
	else: await move_to(spot.global_position.x)
	await key("interact", true)
	if hold:
		await create_timer(0.65).timeout
		check(player().get_node("Visual/Artwork").cleaning_active, node_name + " real hold retains mop pose")
		await capture(node_name + "_cleaning")
		await create_timer(1.0).timeout
	await key("interact", false)
	if not spot.is_completed(): print("WORK_DIAGNOSTIC ", node_name, " ", spot.get_interaction_state(), " selected=", floor_node().get_interaction_target_id())
	elif node_name.begins_with("Transit"): await capture("205_work_"+node_name)
	if spot.is_completed() and spot.interaction_type == "AUTHORIZE":
		check(spot.get_node("TaskItemVisual/ResultFeedback").visible, node_name + " real approval shows a success result")
		await capture(node_name + "_approved")
func remind(room: String, phase: String) -> void:
	await move_to(floor_node().get_node("DoorRoot/Room" + room).position.x - 35)
	await tap()
	check(screen.visible and screen.get("_id").ends_with(":" + phase), room + " real E reminder " + phase)
	await drain()
func deliver(room: String, task: String) -> void:
	check(g.task_status == "READY_TO_SUBMIT", room + " ready only after real work")
	check(not g.get_world_flags().get("passage_" + room + "_unlocked", false), room + " work alone leaves barrier")
	await move_to(floor_node().get_node("DoorRoot/Room" + room).position.x - 35)
	await tap()
	check(g.get_completed_task_ids().has(task) and screen.get("_id").ends_with(":DELIVERED"), room + " real E settlement before success dialogue")
	check(floor_node().get_node("DoorRoot/Room"+room+"/Door").door_state=="OPEN",room+" monster is visible during real delivery dialogue")
	check(floor_node().get_node("Floor2Art/Doors/Room"+room+"/MonsterIdle").is_visible_in_tree(),room+" real artwork monster appears in delivery")
	await capture(room + "_delivered")
	await drain()
	await remind(room, "COMPLETED")
func retry(room: String) -> void:
	var completed: Array = g.get_completed_task_ids()
	var cards: Dictionary = g.get("_task_checkpoint")["cards"].duplicate(true)
	g._process(999.0) # Actual timeout path; no claim of wall-clock wait.
	check(g.game_state == "FAILED" and g.can_retry_current_task(), room + " timeout retry available")
	await read_carol()
	main.get_node("TaskLayer/Failure/%RetryButton").pressed.emit(); await settle()
	check(g.task_status == "AVAILABLE" and g.remaining_time == 0 and g.current_floor == 2, room + " retry returns own checkpoint without clock")
	check(g.get_completed_task_ids() == completed and c.export_snapshot() == cards, room + " preserves earlier tasks and cards")
	check(board.visible, room + " retry own board")
	board.get("_accept_button").pressed.emit(); await settle()
func capture(name: String) -> void:
	if "--capture" not in OS.get_cmdline_user_args(): return
	await process_frame; await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(capture_dir)
	var path := capture_dir.path_join(name + ".png")
	check(root.get_texture().get_image().save_png(path) == OK, "saved native evidence " + name)
	print("CAPTURE: ", path)
func run() -> void:
	g = root.get_node("GameManager"); c = root.get_node("CardManager")
	root.get_node("Localization").set_language("zh_CN")
	main = load("res://scenes/main.tscn").instantiate()
	main.get_node("StoryLayer/Dialogue").set_progress_file_path_for_test("user://five_monster_intro_%d.cfg" % OS.get_process_id())
	root.add_child(main); await settle()
	main.dialogue.set_skip_transitions_for_test(true)
	screen = main.get_node("TaskLayer/MonsterDialogue"); board = main.get_node("TaskLayer/MissionBoard")
	# Wait for D's actual animated opening before starting the normal new game.
	for i in range(360):
		if not main.get_node("MenuLayer/MainMenu/%StartButton").disabled: break
		await physics_frame
	check(not main.get_node("MenuLayer/MainMenu/%StartButton").disabled, "animated menu becomes ready")
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	await drain_story(); await settle()
	await move_to(floor_node().get_node("StaffRoot/ManagerSlot").position.x + 30)
	await tap(); await drain_story(); await settle()
	check(g.has_completed_manager_intro(), "normal new game real manager conversation")
	g.set_process(false)
	await travel(2)
	if not await offer("201", "TASK_01_CLEAN"): end(); return
	await remind("201", "MISSING_CARD")
	await steal("CleanerSlot", "CLEANER")
	await work("Stain201Slot/CleaningSpot", true)
	await deliver("201", "TASK_01_CLEAN")
	if not await offer("202", "TASK_02_PARCEL"): end(); return
	await remind("202", "MISSING_CARD")
	await steal("SecuritySlot", "SECURITY")
	await equip("SECURITY")
	await work("ParcelCabinet2F")
	await deliver("202", "TASK_02_PARCEL")
	if not await offer("203", "TASK_T03_ROOM_SERVICE"): end(); return
	await remind("203", "MISSING_CARD")
	# Real front theft failure exercises the new203 cross-floor checkpoint, not309.
	await travel(1)
	var manager: Node = floor_node().get_node("StaffRoot/ManagerSlot/Staff")
	manager.patrol_enabled = false; manager.facing_direction = 1
	for n in ["TurnTimer", "TurnWarningTimer", "BehaviorTimer"]: manager.get_node(n).stop()
	await move_to(manager.global_position.x + 35)
	await tap()
	check(g.game_state == "FAILED" and g.fail_reason == "STAFF_CAUGHT", "203 real manager-front catch")
	await read_carol()
	main.get_node("TaskLayer/Failure/%RetryButton").pressed.emit(); await settle()
	check(g.current_floor == 2 and g.task_status == "AVAILABLE" and not c.has_card("MANAGER") and c.has_card("SECURITY"), "203 own checkpoint keeps201/202 but no unearned manager")
	board.get("_accept_button").pressed.emit(); await settle()
	await steal("ManagerSlot", "MANAGER")
	await work("RoomService203")
	check(g.task_status == "ACTIVE", "203 owned manager but wrong active cannot approve")
	await equip("MANAGER")
	await remind("203", "WORK_PENDING")
	await work("RoomService203")
	check(not g.get_world_flags().get("registration_309_approved", false), "203 cannot unlock309")
	await deliver("203", "TASK_T03_ROOM_SERVICE")
	if not await offer("204", "TASK_T04_DUAL_WORK"): end(); return
	await remind("204", "MISSING_CARD") # third-card replacement left wrong pair.
	await equip("CLEANER", "SECURITY")
	await tap("switch_id"); await tap("switch_id")
	check(g.task_status == "ACTIVE", "204 Q twice does not do work")
	await work("Stain204", true)
	check(not g.submit_task("TASK_T04_DUAL_WORK"), "204 only clean cannot submit")
	await remind("204", "CLEAN_ONLY")
	await retry("204")
	check(not g.get_world_flags().get("stain_204_cleaned", false) and g.get_world_flags().get("stain_201_cleaned", false), "204 retry resets own stain only")
	await equip("CLEANER", "SECURITY")
	await work("Stain204", true)
	await tap("switch_id")
	await work("PatrolCabinet204")
	await deliver("204", "TASK_T04_DUAL_WORK")
	if not await offer("205", "TASK_T05_TRANSIT"): end(); return
	await tap("open_bag")
	check(not main.get_node("MenuLayer/Bag").visible,"205 directs equipment preparation away from inspection range")
	await equip("SECURITY", "MANAGER")
	await work("TransitRegister205")
	check(not g.get_world_flags().get("transit_205_approved", false), "205 approval before pickup rejected")
	await work("TransitPickup205")
	await remind("205", "WRONG_IDENTITY")
	await retry("205")
	check(not g.get_world_flags().get("transit_205_collected", false), "205 retry resets pickup")
	await equip("SECURITY", "MANAGER")
	await work("TransitPickup205")
	await move_to(2820)
	await tap("switch_id") # safely outside checker radius
	await remind("205", "PICKUP_ONLY")
	await work("TransitRegister205")
	check(not g.get_available_floors().has(3), "205 work before delivery cannot go3F")
	await deliver("205", "TASK_T05_TRANSIT")
	check(g.get_pending_monster_encounter().is_empty(), "all task encounter requests settled")
	check(not g.has_friend and not g.get_world_flags().get("exit_form_approved", false), "five tutorial tasks never fake rescue or EXIT")
	var checker: Node = floor_node().get_node("DoorRoot/Room205/Door")
	await move_to(checker.global_position.x - 35)
	await tap("switch_id")
	check(checker.door_state=="CLOSED" and g.get_pending_monster_encounter().is_empty(), "completed205 never cycles or re-inspects passing player")
	await move_to(2820)
	await travel(3)
	check(g.current_floor == 3, "after all five deliveries reach real3F")
	end()
func end() -> void:
	if failures.is_empty(): print("PASS: normal new game201–205, real theft/work/E delivery, reminders and retries")
	main.queue_free(); await process_frame
	quit(0 if failures.is_empty() else 1)
