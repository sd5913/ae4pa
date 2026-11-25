extends SceneTree
var main: Node
var game: Node
var failures: Array[String] = []
var folder := OS.get_environment("AE4PA_NARRATIVE_EVIDENCE")
func _initialize() -> void: run.call_deferred()
func check(ok: bool, label: String) -> void:
	print(("PASS: " if ok else "FAIL: ") + label)
	if not ok: failures.append(label)
func settle() -> void:
	for i in range(8): await process_frame
func shot(label: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	if not folder.is_empty(): root.get_texture().get_image().save_png(folder.path_join(label+".png"))
func advance(flow: Node) -> void:
	await create_timer(0.4).timeout
	for pressed in [true,false]:
		var event := InputEventKey.new()
		event.physical_keycode = KEY_E
		event.keycode = KEY_E
		event.pressed = pressed
		flow._input(event)
func drain() -> void:
	var screen: Control = main.get_node("TaskLayer/MonsterDialogue")
	for i in range(100):
		if not screen.visible: return
		screen.advance()
func run() -> void:
	var english := "--english" in OS.get_cmdline_user_args()
	root.size = Vector2i(960,540) if english else Vector2i(1280,720)
	root.get_node("Localization").set_language("en" if english else "zh_CN")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	game = root.get_node("GameManager")
	var cards: Node = root.get_node("CardManager")
	await create_timer(4.2).timeout
	var selector: MenuButton = main.get_node("MenuLayer/MainMenu/%LanguageSelector")
	for i in range(6):
		selector._select_language(i % 2)
		selector.get_popup().popup()
		await settle()
		selector.get_popup().hide()
	check(selector.find_children("*", "Label", true, false).is_empty() and selector.get_popup().item_count == 2 and not selector.text.is_empty(), "language selector has one native text layer and two popup choices")
	selector._select_language(1 if english else 0)
	await shot("cover")
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	var dialogue: Control = main.get_node("StoryLayer/Dialogue")
	dialogue.set_progress_file_path_for_test("user://narrative_smoke_intro.cfg")
	dialogue.set_skip_transitions_for_test(true)
	dialogue._finish_phone_animation()
	for i in range(23): dialogue._advance()
	await shot("narration")
	check(not dialogue.get_node("%StageCue").text.contains("女主") if dialogue.has_node("%StageCue") else true, "visible narration has no production protagonist alias")
	dialogue.hide()
	main._on_dialogue_finished("V4_INTRO")
	main._show_story_dialogue("V4_MANAGER_TALK")
	dialogue._finish()
	await settle()
	var bag: Control = main.get_node("MenuLayer/Bag")
	if "--controls-only" in OS.get_cmdline_user_args():
		main.get_node("World").get_child(0).get_node("Player").position.x = 3400
		var page: Control = main.get_node("TaskLayer/PlayOverlay")
		page.open_floor_selection()
		await shot("floor_selection")
		page.close_page()
		check(game.request_floor_travel(2), "controls capture real 2F travel")
		await settle()
		check(game.offer_task("TASK_01_CLEAN"), "controls capture real offer")
		drain()
		await shot("task_details")
		main._show_menu()
		main._start_session()
		dialogue._finish_phone_animation()
		for i in range(23): dialogue._advance()
		check(dialogue.get_node("%SkipButton").visible, "completed test intro offers replay skip")
		check(is_equal_approx(dialogue.get_node("%SkipButton").position.y, 24), "replay skip is at top safe margin")
		await shot("read_skip_top_right")
		print("NARRATIVE_CONTROLS_REVIEW: ", "PASS" if failures.is_empty() else "FAIL")
		quit(0 if failures.is_empty() else 1)
		return
	var flow: Node = bag.get_node("CarolUIFlow")
	bag.open_bag()
	cards.collect_card("CLEANER")
	cards.collect_card("SECURITY")
	cards.equip_card("CLEANER",0)
	cards.equip_card("SECURITY",1)
	await settle()
	check(flow._mode.is_empty(), "two-slot tutorial waits while bag is open")
	await shot("bag")
	bag.get_node("%CloseButton").pressed.emit()
	await settle()
	check(flow._mode == "equipment", "real two equipped slots trigger Carol dialogue after bag close")
	await shot("equipment")
	for i in range(4): await advance(flow)
	check(flow._mode.is_empty() and flow._tutorial_seen, "four tutorial beats finish once")
	bag.open_bag()
	bag.close_bag()
	await settle()
	check(flow._mode.is_empty(), "opening bag again does not repeat tutorial")
	bag.open_bag()
	var escape := InputEventAction.new()
	escape.action = "pause"
	escape.pressed = true
	bag._input(escape)
	check(not bag.visible and game.is_world_input_allowed(), "Esc closes bag and releases its modal")
	var overlay: Control = main.get_node("TaskLayer/PlayOverlay")
	overlay.toggle_pause()
	await shot("pause")
	check(overlay.find_children("*", "MenuButton",true,false).is_empty(), "pause has no language selector")
	check(overlay._menu.icon == null, "pause menu button has no icon")
	overlay.close_page()
	main.get_node("World").get_child(0).get_node("Player").position.x = 3400
	check(game.request_floor_travel(2), "real 2F transition")
	await settle()
	check(game.offer_task("TASK_01_CLEAN"), "real 201 offer")
	drain()
	main.get_node("TaskLayer/MissionBoard").hide()
	check(game.accept_task("TASK_01_CLEAN"), "accept real task")
	var failed_events: Array = []
	game.game_failed.connect(func(reason: String) -> void: failed_events.append(reason))
	for ready in [false,true]:
		if ready:
			check(game.accept_task("TASK_01_CLEAN"), "reaccept after checkpoint restoration")
			check(game.record_work_result("STAIN_201"), "public work result prepares ready-to-submit fixture")
		await settle()
		game._process(float(game.get_task_view().remaining_time)+1.0) # Explicit accelerated-clock QA fixture.
		await settle()
		check(flow._mode == "timeout", "genuine TASK_TIMEOUT dispatch starts presentation")
		check(not main.get_node("TaskLayer/Failure").visible, "failure menu waits for dialogue")
		await advance(flow)
		check(flow._lines[1] == (flow.TIMEOUT_READY if ready else flow.TIMEOUT_ACTIVE), "timeout second beat matches actual pre-failure task stage")
		flow._failed("TASK_TIMEOUT")
		await settle()
		check(flow._index == 1, "repeated failure notification cannot restart the presentation")
		await shot("timeout_ready" if ready else "timeout_active")
		await advance(flow)
		await advance(flow)
		check(main.get_node("TaskLayer/Failure").visible, "last beat reveals original failure menu")
		check(game.can_retry_current_task(), "A checkpoint remains valid")
		await shot("failure")
		main.get_node("TaskLayer/Failure/%RetryButton").pressed.emit()
		await settle()
		check(game.game_state == "PLAYING" and flow._mode.is_empty(), "existing retry restores task and cleans presentation")
		check(flow._tutorial_seen, "retry preserves this-session tutorial completion")
		main.get_node("TaskLayer/MissionBoard").hide()
	check(failed_events == ["TASK_TIMEOUT","TASK_TIMEOUT"], "failure settles once per actual timeout")
	main._show_menu()
	check(not flow._tutorial_seen and flow._mode.is_empty(), "menu clears session tutorial and presentation")
	print("NARRATIVE_UI_SMOKE: ", "PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
