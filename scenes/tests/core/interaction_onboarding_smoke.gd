extends SceneTree
## Explicit task/history/position fixtures; production main, staff, bag and door detection.
var failures: Array[String] = []
var g: Node
var c: Node
var main: Node
func _initialize() -> void:
	create_timer(55).timeout.connect(func(): print("FAIL: onboarding timeout"); quit(1))
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func settle() -> void:
	for i in range(4): await physics_frame
	await process_frame
func tap(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await settle()
	event = InputEventAction.new()
	event.action = action
	event.pressed = false
	Input.parse_input_event(event)
	await settle()
func floor_node() -> Node: return main.get_node("World").get_child(0)
func quiet() -> void:
	floor_node().get("_door_scheduler").set_process(false)
	for door in floor_node().get("_doors"):
		door.set_managed_state("CLOSED")
		door.set_physics_process(false)
func capture(id: String) -> void:
	if "--capture" not in OS.get_cmdline_user_args() or DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	var variant := ("en" if "--english" in OS.get_cmdline_user_args() else "cn") + ("960" if "--small" in OS.get_cmdline_user_args() else "1280")
	var path := "res://docs/qa_evidence/a_interaction_onboarding_20261121/screenshots/" + variant
	DirAccess.make_dir_recursive_absolute(path)
	check(root.get_texture().get_image().save_png(path + "/" + id + ".png") == OK, "Capture " + id)
func mouse_move(at: Vector2, held: bool = false) -> void:
	if DisplayServer.get_name() != "headless" and not held:
		Input.warp_mouse(root.get_final_transform() * at)
		await process_frame
	var motion := InputEventMouseMotion.new()
	motion.position = at
	motion.global_position = at
	motion.relative = at - root.get_mouse_position()
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT if held else 0
	root.push_input(motion,true)
	await settle()
func mouse_button(at: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = at
	event.global_position = at
	event.pressed = pressed
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	root.push_input(event,true)
	await settle()
func native_drag(bag: Control) -> void:
	if DisplayServer.get_name() == "headless": return # Pointer drag is validated in the native Compatibility run.
	var owned: ItemList = bag.get_node("%OwnedCards")
	var start := owned.global_position + owned.get_item_rect(1).get_center()
	var target: Control = bag.get_node("Case/CardDropA")
	var finish := target.get_global_rect().get_center()
	var id := str(owned.get_item_metadata(1))
	await mouse_move(start)
	await mouse_button(start,true)
	for distance in [6,16,32,48]: await mouse_move(start+Vector2(distance,0),true)
	await mouse_move(finish,true)
	check(root.gui_is_dragging(), "Real mouse motion starts the D bag drag")
	await capture("bag_drag")
	await mouse_button(finish,false)
	check(c.get_equipped_cards()[0] == id, "Real mouse drop equips selected card in A")
	check(not root.gui_is_dragging(), "Mouse release clears drag preview")
	await capture("bag_equipped")
func run() -> void:
	root.size = Vector2i(960,540) if "--small" in OS.get_cmdline_user_args() else Vector2i(1280,720)
	g = root.get_node("GameManager")
	c = root.get_node("CardManager")
	root.get_node("Localization").set_language("en" if "--english" in OS.get_cmdline_user_args() else "zh_CN")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await settle()
	main._start_session()
	main.dialogue._finish()
	g.complete_manager_intro()
	g.set_process(false)
	var f: Node = floor_node()
	var marker: Node = f.get_node_or_null("InteractionMarkers")
	check(marker != null, "Formal floor has visible stair range markers")
	f.player.position.x = f.exit_point.position.x - 69
	await settle()
	await capture("stair_range")
	check(g.get_stair_destinations().has(2), "69px inside stairs permits existing destination")
	if marker != null: check(marker.is_in_stair_range(f.exit_point), "Marker matches actual inside range")
	f.player.position.x = f.exit_point.position.x - 71
	await settle()
	check(g.get_stair_destinations().is_empty(), "71px outside stairs cannot travel")
	if marker != null: check(not marker.is_in_stair_range(f.exit_point), "Marker matches actual outside range")
	g.current_task_id = g.TASK_01_ID
	g.task_status = "ACTIVE"
	g.remaining_time = 240
	var staff: Node = f.get_node("StaffRoot/CleanerSlot/Staff")
	staff.patrol_enabled = false
	staff.set_cleaner_behavior_enabled(false)
	for timer in ["TurnTimer", "TurnWarningTimer", "BehaviorTimer"]: staff.get_node(timer).stop()
	staff.facing_direction = 1
	f.player.position.x = staff.global_position.x - 50
	await settle()
	staff.facing_direction = 1 # Facing fixture after real Area entry/suspicion callback.
	var guide: Node = staff.get_node_or_null("InteractionGuide")
	if guide != null: guide._process(0)
	check(guide != null, "Eligible staff has a rear-side visual guide")
	if guide != null:
		check(guide.visible and guide.get_rear_direction() == -1, "Guide shows actual left rear side: " + str([guide.visible,guide.get_rear_direction(),staff.is_task_eligible(),staff.is_reward_available(),g.is_world_input_allowed(),f.player.position.x,staff.global_position.x]))
		staff.facing_direction = -1
		await settle()
		check(guide.get_rear_direction() == 1, "Guide follows real staff turning")
	await capture("staff_rear")
	f.player.global_position.x = 2000
	await settle()
	await tap("switch_id")
	check(c.active_card == "NONE", "Early Q with empty slots does not invent an identity")
	var before_first_card: Dictionary = c.export_snapshot()
	c.collect_card("CLEANER")
	await settle()
	await capture("first_identity")
	check(c.get_owned_cards() == ["CLEANER"] and c.get_equipped_cards() == ["NONE", "NONE"] and c.active_card == "NONE", "First collected ID stays in collection without equipment or active identity")
	check(not staff.call("_is_player_recognized"), "Staff cannot recognize an ID that is only collected")
	if guide != null: check(not guide.visible, "Collected staff guide does not suggest repeat theft")
	var outfit: Node = f.player.get_node_or_null("Visual/Artwork/IdentityOutfit")
	check(outfit != null, "Player has identity-specific wearable")
	if outfit != null: check(outfit.get("card_id") == "NONE", "First theft preserves the default outfit")
	var onboarding: Node = main.get_node_or_null("InteractionOnboarding")
	check(onboarding != null, "Progressive guide joins actual main scene")
	if onboarding != null:
		check(onboarding.get_identity_hint().contains("魔法工作证") and onboarding.get_identity_hint().contains("I"), "First theft explains the magic work ID and safety step")
		onboarding._process(3.1)
	f.player.global_position.x = staff.global_position.x + 30
	staff.facing_direction = 1
	await settle()
	check(staff.is_observing_player(), "Staff observation uses current actual facing and proximity")
	var observed_snapshot: Dictionary = c.export_snapshot()
	c.switch_active()
	check(c.export_snapshot() == observed_snapshot, "Q identity change is blocked before mutation while staff is watching")
	main.bag.open_bag()
	await settle()
	var observed_payload := {"source": main.bag.get_instance_id(), "card_id": "CLEANER"}
	check(not main.bag._can_drop_card(Vector2.ZERO, observed_payload, 0) and main.bag._status.text.contains("有人正在看着你"), "Observed staff blocks drag equipment with a clear reason")
	main.bag.get_node("%EquipSlotA").pressed.emit()
	check(c.active_card == "NONE" and c.get_equipped_cards() == ["NONE", "NONE"], "Observed staff blocks bag equipment before any identity change")
	main.bag.close_bag()
	f.player.global_position.x = 2000
	await settle()
	if onboarding != null: check(onboarding.get("_first_disguise_step") == "READY_FOR_BAG", "Early I and closing do not deadlock first disguise teaching: " + str(onboarding.get("_first_disguise_step")) + " / " + str(f.get_identity_change_block_reason(false)))
	main.bag.open_bag()
	await settle()
	if onboarding != null: check(onboarding.get("_first_disguise_step") == "EQUIP", "Opening the bag from a safe position advances the tutorial")
	check(main.bag._selected_card_id() == "CLEANER", "First tutorial selects the newly collected cleaner ID")
	check(main.bag.get_node("%EquipSlotA").modulate == Color("ffe3a1"), "First tutorial highlights equipment slot A")
	# The real retry path restores this authoritative snapshot before the new attempt.
	check(c.restore_snapshot(before_first_card), "Pre-theft checkpoint card snapshot restores")
	if onboarding != null:
		check(onboarding.get_identity_hint().is_empty(), "Rolled-back first theft removes the disguise hint immediately")
	check(main.bag.get_node("%EquipSlotA").modulate == Color.WHITE, "Rolled-back first theft clears slot A focus")
	main.bag.close_bag()
	check(c.collect_card("CLEANER"), "First ID can be picked up again after retry")
	if onboarding != null:
		check(onboarding.get("_first_disguise_step") == "ACQUIRED", "Reacquiring the first ID restarts the collection step")
		onboarding._process(3.1)
	main.bag.open_bag()
	await settle()
	check(main.bag._selected_card_id() == "CLEANER" and main.bag.get_node("%EquipSlotA").modulate == Color("ffe3a1"), "Reacquired first ID restarts the equipment focus")
	main.bag.get_node("%EquipSlotA").pressed.emit()
	main.bag.close_bag()
	await settle()
	check(c.active_card == "NONE" and c.get_equipped_cards() == ["CLEANER", "NONE"], "Equipping an inactive slot does not implicitly change the current identity")
	await tap("switch_id")
	await settle()
	check(c.active_card == "CLEANER" and outfit.get("card_id") == "CLEANER", "Manual activation synchronizes identity and outfit")
	staff.set_cleaner_behavior_enabled(false)
	staff.facing_direction = 1
	f.player.global_position.x = staff.global_position.x - 90
	await settle()
	Input.action_press("move_right")
	for i in range(70): await physics_frame
	Input.action_release("move_right")
	await settle()
	check(not staff.is_suspicious() and g.game_state == "PLAYING", "Wearing the matching uniform while passing staff is not theft evidence")
	f.player.global_position.x = 2000
	await settle()
	if onboarding != null:
		check(onboarding.get_identity_hint().contains("伪装成功"), "First activation shows disguise feedback")
		onboarding._process(5.0)
		check(onboarding.get_identity_hint().contains("不要在工作人员或怪物注视下切换"), "First disguise teaching explains the observation restriction")
		onboarding._process(7.0)
	c.collect_card("SECURITY")
	await settle()
	check(c.get_equipped_cards() == ["CLEANER", "NONE"] and c.active_card == "CLEANER", "Second collected ID does not replace the first identity")
	if onboarding != null: check(onboarding.get_identity_hint().contains("I"), "Later card teaches the existing bag flow")
	main.bag.open_bag()
	await settle()
	var security_owned: ItemList = main.bag.get_node("%OwnedCards")
	for i in security_owned.item_count:
		if security_owned.get_item_metadata(i) == "SECURITY":
			security_owned.select(i)
			security_owned.item_selected.emit(i)
	main.bag.get_node("%EquipSlotB").pressed.emit()
	main.bag.close_bag()
	await settle()
	check(c.get_equipped_cards() == ["CLEANER", "SECURITY"] and c.active_card == "CLEANER", "Manual second equip preserves the active first identity")
	c.switch_active()
	await settle()
	if outfit != null: check(outfit.get("card_id") == "SECURITY", "Wearable follows actual Q identity")
	var before_move: Dictionary = c.export_snapshot()
	var empty_slot_fixture: Dictionary = before_move.duplicate(true)
	empty_slot_fixture["active_slot"] = 0
	c.restore_snapshot(empty_slot_fixture)
	c.equip_card("CLEANER",1) # Earlier equipment use must not suppress a newly acquired third-card guide.
	if onboarding != null: check(onboarding.get_identity_hint().contains("Q"), "Moving the active card teaches how to leave the now-empty slot")
	c.restore_snapshot(before_move)
	c.collect_card("MANAGER")
	await settle()
	if onboarding != null: check(onboarding.get_identity_hint().contains("I") and onboarding.get_identity_hint().contains("A"), "Third unequipped card teaches bag replacement")
	var bag: Control = main.bag
	bag.open_bag()
	await settle()
	await capture("bag_collection")
	await native_drag(bag)
	check(bag.has_method("_card_drag_data"), "Actual D bag supports source card dragging")
	if bag.has_method("_card_drag_data"):
		var owned: ItemList = bag.get_node("%OwnedCards")
		var index := -1
		for i in owned.item_count:
			if owned.get_item_metadata(i) == "MANAGER": index = i
		owned.force_drag({"source": bag.get_instance_id(), "card_id": "MANAGER"}, Control.new())
		var data: Variant = bag._card_drag_data(owned.get_item_rect(index).get_center())
		check(data is Dictionary, "Drag produces owned-card payload")
		var before: Dictionary = c.export_snapshot()
		check(not bag._can_drop_card(Vector2.ZERO, {"card_id":"FAKE"}, 0), "Invalid external drag rejected")
		check(c.export_snapshot() == before, "Cancelled/invalid drag preserves cards")
		bag._drop_card(Vector2.ZERO, data, 1)
		check(c.get_equipped_cards()[1] == "MANAGER" and c.has_card("SECURITY"), "Drop replaces actual target slot without losing previous card")
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	Input.parse_input_event(release)
	await settle()
	bag.close_bag()
	# Real 205 inspection region must reject drag just as it rejects the button.
	g.get("_completed_task_ids").assign(g.TUTORIAL_TASKS.slice(0,4))
	g.current_task_id = g.TUTORIAL_05_ID
	g.task_status = "ACTIVE"
	g.remaining_time = 240
	g.set("_world_flags", {"tutorial_room_205_revealed": true, "passage_201_unlocked": true, "passage_202_unlocked": true, "passage_203_unlocked": true, "passage_204_unlocked": true})
	g._load_floor(2)
	await settle()
	quiet()
	f = floor_node()
	var checker: Node = f.get_node("DoorRoot/Room205/Door")
	var ordinary: Node = f.get_node("DoorRoot/Room201/Door")
	for slot: Node in f.get_node("StaffRoot").get_children():
		slot.get_node("Staff").set("_player_in_range", false)
	f.player.position.x = ordinary.global_position.x - 35
	ordinary.set_managed_state("CLOSED")
	await settle()
	check(f.get_identity_change_block_reason(false).is_empty(), "A closed ordinary monster door is not observing the player")
	checker.set_managed_state("OPEN")
	f.player.position.x = checker.global_position.x - 35
	await settle()
	bag.open_bag() # Direct UI-entry fixture to probe the guard even though toolbar rejects it.
	await settle()
	var payload := {"source":bag.get_instance_id(), "card_id":"CLEANER"}
	var restricted_before: Dictionary = c.export_snapshot()
	check(not bag._can_drop_card(Vector2.ZERO,payload,0), "Open 205 inspector rejects drag qualification")
	bag._drop_card(Vector2.ZERO,payload,0)
	check(c.export_snapshot() == restricted_before, "Rejected inspection-area drag cannot alter either slot")
	bag.close_bag()
	f.player.position.x = 2850
	await settle()
	bag.open_bag()
	await settle()
	check(bag._can_drop_card(Vector2.ZERO,payload,0), "Safe work area still permits replacement")
	# Keyboard on existing Equip button uses the same replacement path.
	var owned_list: ItemList = bag.get_node("%OwnedCards")
	owned_list.select(0)
	owned_list.item_selected.emit(0)
	bag.get_node("%EquipSlotA").grab_focus()
	var accept := InputEventAction.new()
	accept.action = "ui_accept"
	accept.pressed = true
	root.push_input(accept,true)
	accept = InputEventAction.new()
	accept.action = "ui_accept"
	accept.pressed = false
	root.push_input(accept,true)
	await settle()
	check(c.get_equipped_cards()[0] == "CLEANER", "Existing keyboard Equip action remains available")
	bag.close_bag()
	# Knowledge unlock must follow real tutorial completions, not room randomization.
	g.get("_completed_task_ids").assign([g.TASK_01_ID,g.TASK_02_ID])
	check(g.get_notebook_view()["entries"][2]["status"] != "KNOWN", "Uncompleted hat tutorial stays unknown")
	g.get("_completed_task_ids").assign(g.TUTORIAL_TASKS)
	for entry in g.get_notebook_view()["entries"]: check(entry["status"] == "KNOWN", "Completed tutorial unlocks " + entry["id"])
	for kind in ["NOSE","EYE","HAT","EAR","CHECKER"]: g.get("_seen_monsters")[kind] = true
	g.current_task_id = g.TUTORIAL_05_ID
	g.task_status = "COMPLETED"
	g._load_floor(3)
	await settle()
	quiet()
	f = floor_node()
	var door: Node = f.get_node("DoorRoot/Room301/Door")
	door.monster_type = "NOSE"
	f.player.position.x = door.global_position.x - 170
	door.set_managed_state("WARNING")
	await settle()
	await capture("monster_review")
	if onboarding != null: check(onboarding.get("_monster_kind") == "NOSE", "3F guide identifies actual door monster")
	f.player.position.x = 1420
	await settle()
	for i in range(30):
		if main.get("_active_dialogue_id") == "TASK_03_INTRO": break
		await process_frame
	check(main.get("_active_dialogue_id") == "TASK_03_INTRO", "302 still opens real required introduction")
	var lines: Array = main.dialogue.get("_lines")
	check(lines.size() <= 2, "302 introduction limits simultaneous instructions")
	# Visible first line must be short; existing 03 flow verifies approval and entry.
	check(main.dialogue.get_node("%Line").text.length() < (120 if TranslationServer.get_locale().begins_with("en") else 65), "302 first objective is short")
	await capture("302_short_intro")
	if main.dialogue.visible: main.dialogue._finish()
	await settle()
	main.get_node("TaskLayer/MissionBoard").get("_accept_button").pressed.emit()
	await settle()
	var register: Node2D = f.get_node("Interactions/Register309")
	f.player.position.x = register.global_position.x
	await settle()
	for pressed in [true,false]:
		var action := InputEventAction.new()
		action.action = "interact"
		action.pressed = pressed
		Input.parse_input_event(action)
		await settle()
	if onboarding != null: check(onboarding.get("_monster_kind").is_empty(), "Monster refresher does not follow player away from its actual door")
	check(g.task_status == "COMPLETED", "Actual manager registration still completes 302 task")
	check(main.notice_label.text == tr("302授权完成：309入住已获准。切为保洁身份去309寻找Terese。"), "Cleaner entry instruction appears after real approval")
	await capture("309_next_step")
	# A real ordinary-door violation must still explain both cause and return location.
	f.player.position.x = door.global_position.x + 60
	door._last_managed_x = f.player.position.x + 100
	door.set_managed_state("OPEN")
	door._physics_process(0)
	await settle()
	check(f.player.position == f.return_point.position, "Ordinary wrong identity retains actual floor-stair return")
	check(main.notice_label.text.begins_with(tr("已退回本层楼梯。%s：%s。%s").get_slice("%s",0)), "Return notice names the floor-stair result before its actual monster cause")
	check(main.get_node("TaskLayer/HUD/%Notice").text.contains(tr("当前身份不符")), "Visible HUD retains actual violation cause rather than only its source label")
	await capture("ordinary_door_return")
	if failures.is_empty(): print("PASS: interaction_onboarding_smoke")
	for message in failures: print("FAIL: ", message)
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
