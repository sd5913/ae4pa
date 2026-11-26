extends SceneTree
## Explicit task/position/facing fixtures isolate reported bugs, not new mechanics.
var failures: Array[String] = []
var g: Node
var c: Node
var main: Node
func _initialize() -> void:
	create_timer(70).timeout.connect(func() -> void: print("FAIL: bugfix test timeout"); quit(1))
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func settle() -> void:
	for i in range(4): await physics_frame
	await process_frame
func floor_node() -> Node: return main.get_node("World").get_child(0)
func tap(action: String) -> void:
	for pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)
		await settle()
func quiet() -> void:
	floor_node().get("_door_scheduler").set_process(false)
	for door: Node in floor_node().get("_doors"):
		door.set_managed_state("CLOSED")
		door.set_physics_process(false)
func capture(id: String) -> void:
	if "--capture" not in OS.get_cmdline_user_args() or DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "res://docs/qa_evidence/a_playtest_bugs_20261121/screenshots"
	DirAccess.make_dir_recursive_absolute(path)
	check(root.get_texture().get_image().save_png(path + "/" + id + ".png") == OK, "Capture " + id)
func run() -> void:
	g = root.get_node("GameManager")
	c = root.get_node("CardManager")
	root.get_node("Localization").set_language("zh_CN")
	g.set_floor_host(null)
	g.start_game()
	c.switch_active() # Reproduction: Q before collecting the very first card.
	c.collect_card("CLEANER")
	check(c.active_card == "NONE" and c.get_equipped_cards() == ["NONE", "NONE"], "First acquired card remains collected only after premature empty-slot Q")
	c.collect_card("SECURITY")
	check(c.active_card == "NONE" and c.get_equipped_cards() == ["NONE", "NONE"], "Later collection never equips or activates an identity")
	c.equip_card("CLEANER", 0)
	check(c.active_card == "NONE", "Manual equipment into an inactive slot preserves the active identity")
	c.switch_active()
	check(c.active_card == "CLEANER", "Existing Q can activate a manually equipped first ID")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await settle()
	main._start_session()
	var dialogue: Control = main.dialogue
	var beats: Array = dialogue.get("_beats")
	for i in beats.size():
		if beats[i].get("speaker", "") in ["女主", "安", "Carol"] and beats[i].get("mode", "") == "dialogue":
			dialogue.set("_line_index", i)
			dialogue._show_story_beat()
			check(dialogue.get_node("%Speaker").text == "Carol", "Actual opening names the protagonist Carol")
			await capture("carol_intro")
			break
	dialogue._finish()
	g.complete_manager_intro()
	g.set_process(false)
	var reunion = JSON.parse_string(FileAccess.get_file_as_string("res://cg309_reunion/dialogue.json"))
	var speakers: Array[String] = []
	for beat: Dictionary in reunion:
		if not speakers.has(beat.get("speaker", "")): speakers.append(beat.get("speaker", ""))
	check(speakers.has("Carol") and speakers.has("Terese") and not speakers.has("安") and not speakers.has("帕希卡"), "Real309 data uses Carol and Terese")
	# Existing205 story-checker rule must cover Q as well as the already guarded bag.
	g.get("_completed_task_ids").assign(["TASK_01_CLEAN", "TASK_02_PARCEL", "TASK_T03_ROOM_SERVICE", "TASK_T04_DUAL_WORK"])
	g.current_task_id = "TASK_T05_TRANSIT"
	g.task_status = "ACTIVE"
	g.remaining_time = 200
	g.set("_world_flags", {"passage_201_unlocked": true, "passage_202_unlocked": true, "passage_203_unlocked": true, "passage_204_unlocked": true, "tutorial_room_205_revealed": true})
	for card in ["CLEANER", "SECURITY", "MANAGER"]: c.collect_card(card)
	g._load_floor(2)
	await settle()
	quiet()
	var f: Node = floor_node()
	var checker: Node = f.get_node("DoorRoot/Room205/Door")
	f.player.position.x = checker.global_position.x - 35
	checker.set_managed_state("OPEN")
	await settle()
	var before: Dictionary = c.export_snapshot()
	await tap("switch_id")
	check(c.export_snapshot() == before, "Story checker cannot be bypassed with Q")
	check(g.task_status == "ACTIVE", "Rejected story-area Q does not complete/fail the task")
	var bag: Control = main.get_node("MenuLayer/Bag")
	bag.open_bag() # Direct UI entry fixture: cannot bypass the normal I/toolbar guard.
	var owned: ItemList = bag.get_node("%OwnedCards")
	for i in owned.item_count:
		if owned.get_item_metadata(i) == "MANAGER":
			owned.select(i)
			owned.item_selected.emit(i)
	bag.get_node("%EquipSlotA").pressed.emit()
	check(c.export_snapshot() == before, "Story checker cannot be bypassed with a slot button")
	bag.close_bag()
	f.player.position.x = 2850
	await settle()
	var safe_slot: int = c.active_slot
	await tap("switch_id")
	check(c.active_slot != safe_slot, "Q remains usable at the safe workstation")
	# Rescue is a disclosed callback fixture; production follower and door are real.
	g.get("_completed_task_ids").assign(g.TUTORIAL_TASKS + [g.TASK_03_ID])
	g.current_task_id = g.TASK_03_ID
	g.task_status = "COMPLETED"
	g.get("_world_flags")["registration_309_approved"] = true
	g.get("_pending_monster_encounter").clear()
	for kind in ["NOSE", "EYE", "HAT", "EAR", "CHECKER"]: g.get("_seen_monsters")[kind] = true
	g._load_floor(3)
	await settle()
	check(g.rescue_friend(), "Rescue fixture establishes actual companion")
	g.current_task_id = g.TASK_04_ID
	g.task_status = "ACTIVE"
	g.remaining_time = 180
	g._load_floor(4)
	await settle()
	quiet()
	f = floor_node()
	f.player.position.x = f.get_node("DoorRoot/Room403").position.x - 35
	await settle()
	await tap("switch_id")
	check(g.task_status == "ACTIVE" and not g.get_world_flags().get("passage_403_unlocked", false), "Changing cards never bypasses403's real-file delivery")
	check("巡房记录" in main.notice_label.text, "403 explains its actual missing-file/delivery requirement after Q")
	var companion: Node2D = f.get_node("Persica") # Stable internal ID, not the display name.
	var display_name := ""
	for child in companion.get_children():
		if child is Label: display_name = child.text
	check(display_name == "Terese", "World companion label is Terese")
	var door: Node = f.get_node("DoorRoot/Room401/Door")
	door.monster_type = "NOSE"
	f.player.position.x = door.global_position.x + 60
	companion.position.x = f.player.position.x + 350
	c.restore_snapshot({"owned_cards": ["SECURITY"], "equipped_cards": ["SECURITY", "NONE"], "active_slot": 0})
	door._last_managed_x = f.player.position.x + 100
	door.set_managed_state("OPEN")
	door._physics_process(0)
	check(f.player.position == f.return_point.position, "Real ordinary door returns Carol to stairs")
	check(absf(companion.global_position.x - f.player.global_position.x) <= 80, "Terese returns with Carol in the same frame")
	await settle()
	# Only the actual stair's direction should be offered; don't change travel rules.
	g.get("_visited_floors").assign([3, 4, 5])
	f.player.position = f.return_point.position
	await settle()
	check(not f.return_hint.visible, "Downstairs keeps its selection without an on-floor hint")
	await capture("terese_stairs")
	main.get_node("TaskLayer").open_floor_selection()
	var overlay: Node = main.get_node("TaskLayer/PlayOverlay")
	var choices: Array[String] = []
	for child in overlay.get("_choices").get_children(): choices.append(child.text)
	check(choices.has("3F") and not choices.has("5F"), "Downstairs menu never offers an unreachable upstairs destination")
	await capture("stairs_4f_choices")
	overlay.close_page()
	if failures.is_empty(): print("PASS: playtest_bugfix_smoke")
	for message in failures: print("FAIL: ", message)
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
