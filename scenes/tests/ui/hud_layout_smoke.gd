extends SceneTree
var main: Node
var game: Node
var cards: Node
var failures: Array[String] = []
var folder := OS.get_environment("AE4PA_HUD_EVIDENCE")
var phase := "after"
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	print(("PASS: " if ok else "FAIL: ") + message)
	if not ok: failures.append(message)
func drain() -> void:
	var screen = main.get_node("TaskLayer/MonsterDialogue")
	for i in range(80):
		if not screen.visible: return
		screen.advance()
func capture(label: String, dimensions: Vector2i = Vector2i(1280,720)) -> void:
	root.size = dimensions
	for i in range(4): await process_frame
	await RenderingServer.frame_post_draw
	var hud: Control = main.get_node("TaskLayer/HUD")
	check(hud.get_node("%RemainingTime").get_line_count() == 1, "status/time stays on one line at " + label)
	check(hud.get_node("Margin/Groups/Left/Stack/TaskPlate").get_global_rect().end.y <= 240, "task plate stays above door warning/name zone at " + label)
	check(not hud.get_node("%TaskTitle").get_global_rect().intersects(hud.get_node("%RemainingTime").get_global_rect()), "title/status do not overlap at " + label)
	if not folder.is_empty():
		check(root.get_texture().get_image().save_png(folder.path_join(phase+"-"+label+".png")) == OK, "capture "+label)
func run() -> void:
	if "--after" in OS.get_cmdline_user_args(): phase = "after"
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	root.get_node("Localization").set_language("zh_CN")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	main.dialogue.hide()
	main._on_dialogue_finished("V4_INTRO")
	main._show_story_dialogue("V4_MANAGER_TALK")
	main.dialogue._finish() # QA setup through A's actual completion callback.
	game.set_process(false) # Explicit QA clock fixture; player settings stay isolated.
	await capture("none")
	main.get_node("World").get_child(0).get_node("Player").position.x = 3400
	check(game.request_floor_travel(2), "real 2F travel")
	await process_frame
	check(game.offer_task("TASK_01_CLEAN"), "explicit201 offer fixture for UI layout; full warning is tested by main flow")
	drain()
	main.get_node("TaskLayer/MissionBoard").hide()
	check(game.accept_task("TASK_01_CLEAN"), "accept 201")
	cards.collect_card("CLEANER")
	check(game.record_work_result("STAIN_201") and game.submit_task("TASK_01_CLEAN"), "real 201 setup settlement")
	drain()
	main._show_story_dialogue("TASK_02_INTRO")
	drain()
	main.get_node("TaskLayer/MissionBoard").hide()
	check(game.accept_task("TASK_02_PARCEL"), "accept 202")
	cards.collect_card("SECURITY")
	game._process(64.0)
	main._show_notice("204需要当前保安身份；按Q切换到对应工作证后通过。") # Layout evidence fixture, not a new rule.
	await capture("active")
	if phase == "after": await capture("active-1920",Vector2i(1920,1080))
	var parcel: Node2D = main.get_node("World").get_child(0).get_node("Interactions/ParcelCabinet2F")
	main.get_node("World").get_child(0).get_node("Player").global_position.x = parcel.global_position.x
	for i in range(5): await physics_frame
	await capture("blocked-progress")
	check(main.get_node("TaskLayer").interaction_progress.visible, "real component readiness replaces generic hint")
	cards.switch_active()
	check(game.record_work_result("PARCEL_CABINET_2F"), "real parcel pickup")
	await capture("ready")
	check(game.submit_task("TASK_02_PARCEL"), "real parcel delivery")
	drain()
	await capture("completed")
	if phase == "after":
		await capture("completed-960",Vector2i(960,540))
		var hud = main.get_node("TaskLayer/HUD")
		check(not "剩余时间" in hud.get_node("%RemainingTime").text, "completed state has no remaining-time claim")
		check(not hud.get_node("%ActiveCardValue").visible, "no duplicate floor identity")
		check(hud.get_node("%SlotAValue").text == "保洁" and hud.get_node("%SlotBValue").text == "保安", "short slot identities")
		check(hud.get_node("%SlotBActive").visible and not hud.get_node("%SlotAActive").visible, "one active marker")
		check(not hud.get_node("%NoticeRow").visible, "satisfied identity does not leave an obsolete warning")
		main.bag.open_bag()
		await capture("bag")
		check(main.bag.visible, "existing bag still opens")
		main.bag.close_bag()
		var overlay = main.get_node("TaskLayer/PlayOverlay")
		overlay.toggle_pause()
		await capture("pause")
		check(overlay.visible, "existing pause still opens")
		overlay.close_page()
		main.dialogue.show_dialogue("RESCUE_309")
		await capture("dialogue")
		check(main.dialogue.visible, "dialogue still opens with original theme")
		main.dialogue.hide()
		game.set_modal_open("STORY_DIALOGUE", false)
		var view: Dictionary = game.get_task_view().duplicate(true)
		view["name"] = "二楼夜班住客待领包裹核验与交付任务"
		view["status"] = "ACTIVE"
		hud._apply_task_view(view,"前往二楼保管柜领取完整包裹并确认封条，完成后返回 202 房间向独眼客交付。")
		hud.set_process(false)
		await capture("long-fixture")
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
