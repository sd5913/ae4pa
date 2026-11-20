extends SceneTree
var failures: Array[String] = []
func _initialize() -> void:
	run.call_deferred()
func check(ok: bool, message: String) -> void:
	print(("PASS: " if ok else "FAIL: ") + message)
	if not ok: failures.append(message)
func drain(screen: Control) -> void:
	for i: int in range(80):
		if not screen.visible: return
		screen.advance()
	check(false, "dialogue terminates")
func run() -> void:
	var game: Node = root.get_node("GameManager")
	var cards: Node = root.get_node("CardManager")
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	main.dialogue.hide()
	main._on_dialogue_finished("V4_INTRO")
	game.complete_manager_intro()
	var player: Node2D = main.get_node("World").get_child(0).get_node("Player")
	player.position.x = 3400
	check(game.request_floor_travel(2), "real manager gate permits 2F")
	await process_frame
	var screen: Control = main.get_node("TaskLayer/MonsterDialogue")
	var board: Control = main.get_node("TaskLayer/MissionBoard")
	check(game.request_monster_encounter("201", "NOSE", "FIRST_ENCOUNTER"), "real pending encounter request")
	check(not screen.visible, "a pending request alone never skips the first warning")
	main.get_node("World").get_child(0).get_node("Player").position.x=553.625
	for i in range(150):
		if screen.visible:break
		await physics_frame
	check(game.get_task_view().get("task_id") == "TASK_01_CLEAN" and game.get_task_view().get("status") == "AVAILABLE", "real encounter produces the 201 offer")
	check(screen.visible and not board.visible and not game.is_world_input_allowed(), "201 introduction is shown before task board with world locked")
	await capture("201-introduction")
	var completed: Array[String] = []
	screen.dialogue_finished.connect(func(id: String) -> void: completed.append(id))
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	screen._unhandled_input(event)
	check(screen.get("_index") == 1, "E advances exactly one line")
	var echo := InputEventKey.new()
	echo.physical_keycode = KEY_E
	echo.pressed = true
	echo.echo = true
	screen._unhandled_input(echo)
	check(screen.get("_index") == 1, "keyboard echo cannot advance dialogue")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	screen._unhandled_input(click)
	check(screen.get("_index") == 2, "left click advances exactly one line")
	game.set_modal_open("OTHER_PAGE", true)
	drain(screen)
	screen.advance()
	check(completed == ["NOSE:INTRO"] and board.visible and not game.is_world_input_allowed(), "intro finishes once and hands off atomically to task panel")
	check(game.get_pending_monster_encounter().get("room_id") == "201", "closing intro leaves pending encounter unresolved")
	board.hide()
	check(not game.is_world_input_allowed(), "dialogue does not release another page modal")
	game.set_modal_open("OTHER_PAGE", false)
	check(game.accept_task("TASK_01_CLEAN"), "accept actual 201 task")
	check(screen.phase_for_201() == "MISSING_CARD" and not game.submit_task("TASK_01_CLEAN"), "no card or work cannot submit")
	cards.collect_card("CLEANER")
	cards.equip_card("CLEANER", 0)
	check(screen.phase_for_201() == "WORK_PENDING" and not game.submit_task("TASK_01_CLEAN"), "card and active identity alone cannot settle")
	cards.collect_card("SECURITY")
	cards.equip_card("SECURITY", 1)
	cards.switch_active()
	check(not game.submit_task("TASK_01_CLEAN"), "two cards and a Q switch do not complete work")
	cards.switch_active()
	check(not screen.show_dialogue("NOSE:DELIVERED"), "success dialogue rejects unearned settlement")
	check(game.record_work_result("STAIN_201"), "real cleaning report")
	check(screen.phase_for_201() == "RETURN" and not game.get_world_flags().get("passage_201_unlocked", false), "work finished still requires return and delivery")
	check(game.submit_task("TASK_01_CLEAN"), "authoritative delivery succeeds")
	check(screen.visible and screen.get("_id") == "NOSE:DELIVERED", "success dialogue appears only after real settlement")
	await capture("201-delivered")
	drain(screen)
	screen.advance()
	check(completed == ["NOSE:INTRO", "NOSE:DELIVERED"], "each completion signal emitted once")
	check(not game.submit_task("TASK_01_CLEAN") and screen.phase_for_201() == "COMPLETED", "repeat interaction cannot settle again")
	check(not screen.show_dialogue("EAR:DELIVERED") and not screen.show_dialogue("CHECKER:DELIVERED"), "unfinished dual-card task contracts cannot claim runtime success")
	var all: Dictionary = screen.data()
	for monster: String in all:
		for phase: String in all[monster]:
			check(screen.preview_dialogue(monster + ":" + phase), "explicit preview " + monster + ":" + phase)
			drain(screen)
	check(game.get_world_flags().get("passage_201_unlocked", false) and not game.has_friend, "previews do not change rescue facts")
	main._show_story_dialogue("TASK_02_INTRO")
	check(screen.visible and screen.get("_id") == "EYE:INTRO", "A task02 entry shows on-site per-speaker eye dialogue")
	await capture("202-introduction")
	drain(screen)
	check(game.get_task_view().get("task_id") == "TASK_02_PARCEL" and board.visible and not game.is_world_input_allowed(), "eye intro hands back to A real offer atomically")
	board.hide()
	check(game.accept_task("TASK_02_PARCEL"), "real parcel task accepts")
	check(not game.submit_task("TASK_02_PARCEL"), "security card without parcel cannot submit")
	cards.switch_active()
	check(game.record_work_result("PARCEL_CABINET_2F"), "actual security identity records parcel pickup")
	check(not game.get_world_flags().get("passage_202_unlocked", false), "pickup alone does not open passage")
	check(game.submit_task("TASK_02_PARCEL"), "real parcel delivery succeeds")
	check(screen.get("_id") == "EYE:DELIVERED", "eye confirmation follows real delivery")
	await capture("202-delivered")
	drain(screen)
	check(game.get_completed_task_ids().has("TASK_02_PARCEL"), "preview UI never replaces parcel settlement")
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)


func capture(label: String) -> void:
	var folder := OS.get_environment("AE4PA_MONSTER_EVIDENCE")
	if folder.is_empty() or DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(folder.path_join(label + ".png")) == OK, "capture " + label)
