extends SceneTree
## Formal-main fixtures isolate captions and the first EXIT key, not a full route.
var failures: Array[String] = []
func _initialize() -> void:
	call_deferred("_run")
func _expect(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func _settle() -> void:
	for i in range(5): await physics_frame
	await process_frame
func _e(pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = KEY_E
	event.pressed = pressed
	Input.parse_input_event(event)
	await _settle()
func _run() -> void:
	root.get_node("Localization").set_language("zh_CN")
	var game = root.get_node("GameManager")
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await _settle()
	main.get_node("MenuLayer/MainMenu")._finish_opening()
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	main.dialogue._finish()
	game.complete_manager_intro()
	game.set_process(false)
	await _work_feedback(main, game)
	# Explicit late-route facts; no claim to replaying earlier tasks.
	game.get("_completed_task_ids").assign(game.TUTORIAL_TASKS + [game.TASK_03_ID])
	game.has_friend = true
	game.get("_world_flags").merge({"rescue_309_completed": true, "registration_309_approved": true})
	game.current_task_id = game.TASK_04_ID
	game.task_status = "ACTIVE"
	game._load_floor(4)
	await _settle()
	var floor_node = main.get_node("World").get_child(0)
	var staff = floor_node.get_node("StaffRoot/PatrolSlot/Staff")
	var label = floor_node.get_node("StaffRoot/PatrolSlot/Caption")
	staff.set_task_eligible(false)
	floor_node._refresh_staff_captions()
	_expect("先在403接任务" in label.text, "Inactive patrol caption explains the prerequisite")
	staff.set_task_eligible(true)
	floor_node._refresh_staff_captions()
	_expect("背后站定" in label.text, "Eligible patrol caption explains the actual hold interaction")
	staff.set_reward_available(false)
	staff.get_node("FeedbackLabel").show()
	floor_node._refresh_staff_captions()
	_expect(label.text.is_empty(), "Local staff feedback must not overlap duplicate floor captions")
	staff.get_node("FeedbackLabel").hide()
	floor_node._refresh_staff_captions()
	_expect(label.text == "返回403交付" and label.position.y == -260, "Completed caption is short and remains above the character")
	await _capture_matrix(main, "403")
	game.get("_completed_task_ids").append_array([game.TASK_04_ID, game.TASK_05_ID])
	game.get("_world_flags").merge({"patrol_delivered": true, "exit_form_approved": true, "exit_form_delivered": true}, true)
	game.current_task_id = game.TASK_05_ID
	game.task_status = "COMPLETED"
	game._load_floor(5)
	await _settle()
	floor_node = main.get_node("World").get_child(0)
	floor_node.player.global_position = floor_node.exit_point.global_position
	await _settle()
	_expect(game.can_escape(), "EXIT fixture satisfies actual escape guards")
	# Close a real modal with E held, release, then attempt exactly one new E press.
	main.bag.open_bag()
	await _e(true)
	main.bag.close_bag()
	await _e(false)
	_expect(not floor_node.get("_needs_e_release"), "Physical-key release clears EXIT input latch after closing the bag")
	await _e(true)
	_expect(game.game_state == "WON", "First new physical E press after release escapes")
	await _e(false)
	for message in failures: printerr("FAIL: ", message)
	print("INTERACTION_FEEDBACK_BATCH: ", "PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)

func _work_feedback(main: Node, game: Node) -> void:
	var cards = root.get_node("CardManager")
	for id in ["CLEANER", "SECURITY", "MANAGER"]: cards.collect_card(id)
	await _settle()
	var flow: Node = main.get_node("MenuLayer/Bag/CarolUIFlow")
	await create_timer(0.2).timeout
	for beat in range(40):
		if flow.get("_mode") == "": break
		await _e(true)
		await _e(false)
	_expect(flow.get("_mode") == "", "Real equipment tutorial finishes before work fixture")
	game.get("_completed_task_ids").assign([game.TASK_01_ID, game.TASK_02_ID, game.TUTORIAL_03_ID])
	game.get("_world_flags").merge({"passage_201_unlocked": true, "passage_202_unlocked": true, "passage_203_unlocked": true})
	game.current_task_id = game.TUTORIAL_04_ID
	game.task_status = "ACTIVE"
	game.remaining_time = 200.0
	game._load_floor(2)
	await _settle()
	var floor_node = main.get_node("World").get_child(0)
	cards.equip_card("MANAGER", 1)
	floor_node._refresh_component_eligibility()
	_expect("同时装备" in floor_node.get_work_interaction_hint("STAIN_204"), "Missing double-slot combination is distinct from inactive task")
	cards.equip_card("SECURITY", 1)
	cards.switch_active()
	floor_node._refresh_component_eligibility()
	_expect("需要当前保洁" in floor_node.get_work_interaction_hint("STAIN_204"), "Reserve cleaner is not the active cleaner identity")
	_expect("上一项工作" in floor_node.get_work_interaction_hint("PATROL_CABINET_204"), "Second work explains existing required order, without changing it")
	game.task_status = "AVAILABLE"
	_expect("先在204" in floor_node.get_work_interaction_hint("STAIN_204"), "Unaccepted task names the correct room instead of suggesting Q")
	game.task_status = "ACTIVE"
	cards.switch_active()
	floor_node._refresh_component_eligibility()
	floor_node.player.position.x = floor_node.get_node("Interactions/Stain204").position.x
	await _settle()
	var point = floor_node.get_node("Interactions/Stain204")
	floor_node.player.is_moving = true
	_expect("先停下" in floor_node.get_work_interaction_hint("STAIN_204"), "Moving player gets a stop-and-retry instruction: " + floor_node.get_work_interaction_hint("STAIN_204") + str([game.current_task_id, game.task_status, point.is_task_active(), cards.get_equipped_cards()]))
	floor_node.player.is_moving = false
	var snapshot = cards.export_snapshot()
	root.get_node("Localization").set_language("en")
	var progress = main.get_node("TaskLayer").interaction_progress
	progress._display(point.get_interaction_state())
	_expect(main.get_node("TaskLayer/HUD/%SwitchHint").text == "Q · " + tr("切换工作证"), "Switch hint refreshes when changing language")
	_expect("Clean" in progress.get("_details").text and "Hold E" in progress.get("_details").text, "Ready progress UI has a translated hold instruction")
	cards.switch_active()
	progress._display(point.get_interaction_state())
	_expect("Use the Housekeeper identity" in progress.get("_details").text, "Blocked progress UI uses the same specific translated identity hint")
	cards.switch_active()
	game.task_status = "AVAILABLE"
	main.get_node("TaskLayer")._refresh_offer_details()
	var details: String = main.get_node("TaskLayer/MissionBoard").get("_hint").text
	_expect(details.begins_with("Required IDs:") and "Equip Housekeeper and Security" in details, "Dynamic task details translate card names, format and instructions")
	_expect(cards.export_snapshot() == snapshot, "Feedback refresh and locale changes never alter cards")
	if "--capture" in OS.get_cmdline_user_args():
		main.bag.open_bag()
		await _capture_matrix(main, "bag")
		main.bag.close_bag()
	root.get_node("Localization").set_language("zh_CN")
	game.get("_world_flags").clear()

func _capture_matrix(main: Node, name: String) -> void:
	if "--capture" not in OS.get_cmdline_user_args() or DisplayServer.get_name() == "headless": return
	var directory := "/private/tmp/b-concentrated-visual"
	DirAccess.make_dir_recursive_absolute(directory)
	if name == "403":
		var floor_node = main.get_node("World").get_child(0)
		floor_node.player.position.x = floor_node.get_node("StaffRoot/PatrolSlot").position.x - 65
		await _settle()
		_expect(main.get_node("InteractionOnboarding")._interaction_has_priority(), "403 staff prompts take priority over optional review panel")
	for locale in ["zh_CN", "en"]:
		root.get_node("Localization").set_language(locale)
		for size in [Vector2i(960,540), Vector2i(1280,720), Vector2i(1920,1080)]:
			root.size = size
			await _settle()
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(directory + "/%s_%s_%d.png" % [name, locale, size.x])
	root.size = Vector2i(1280,720)
	root.get_node("Localization").set_language("zh_CN")
