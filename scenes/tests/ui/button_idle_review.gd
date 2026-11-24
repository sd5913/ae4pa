extends SceneTree

var failures: Array[String] = []
var folder := OS.get_environment("AE4PA_BUTTON_IDLE_EVIDENCE")
func _initialize() -> void: run.call_deferred()
func check(ok: bool, label: String) -> void:
	print(("PASS: " if ok else "FAIL: ") + label)
	if not ok: failures.append(label)
func shot(label: String) -> void:
	await RenderingServer.frame_post_draw
	if not folder.is_empty(): root.get_texture().get_image().save_png(folder.path_join(label + ".png"))
func run() -> void:
	var english := "--english" in OS.get_cmdline_user_args()
	root.size = Vector2i(960,540) if english else Vector2i(1280,720)
	root.get_node("Localization").set_language("en" if english else "zh_CN")
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	await create_timer(4.2).timeout
	var menu: Control = main.get_node("MenuLayer/MainMenu")
	var start: Button = menu.get_node("%StartButton")
	var selector: MenuButton = menu.get_node("%LanguageSelector")
	check(start.size.is_equal_approx(Vector2(280,56)) and selector.size == start.size, "cover controls both 280x56 logical pixels")
	var load_memory: Button = menu.get_node("%LoadMemory")
	check(load_memory.size == start.size and is_equal_approx(load_memory.position.y - start.position.y - start.size.y,14) and is_equal_approx(selector.position.y-load_memory.position.y-load_memory.size.y,14), "three cover controls use equal sizes and 14px spacing")
	for i in range(12):
		start.mouse_entered.emit()
		start.button_down.emit()
		start.button_up.emit()
		start.mouse_exited.emit()
	await create_timer(0.2).timeout
	check(start.scale == Vector2.ONE and selector.scale == Vector2.ONE, "repeated hover/press keeps button geometry")
	await shot("cover")
	start.pressed.emit()
	main.dialogue.hide()
	main._on_dialogue_finished("V4_INTRO")
	main._show_story_dialogue("V4_MANAGER_TALK")
	main.dialogue._finish() # Public completion route prepares floor one; not human playthrough.
	for i in range(10): await process_frame
	var hud: Control = main.get_node("TaskLayer/HUD")
	main._show_notice(root.get_node("GameManager").get_story_objective())
	await process_frame
	check(not hud.get_node("%NoticeRow").visible, "no duplicate story objective above task plate")
	var plate: Control = hud.get_node("Margin/Groups/Left/Stack/TaskPlate")
	check(is_equal_approx(plate.get_global_rect().position.y,24), "task plate starts at 24px safe margin")
	for id in ["BagButton", "NotebookButton", "PauseButton", "TaskButton"]:
		var button: Button = hud.get_node("%"+id)
		check(button.get_theme_constant("icon_max_width") == 28, "clear icon size: " + id)
	await shot("hud")
	var player: Node2D = main.get_node("World").get_child(0).get_node("Player")
	var start_position := player.position
	var art: Node2D = player.get_node("Visual/Artwork")
	var staff: Array[Node] = main.get_node("World").find_children("*", "Node2D", true, false).filter(func(n: Node) -> bool: return n.has_method("get_cleaner_behavior_state"))
	var security: Node
	for node in staff:
		if node.get("card_id") == "SECURITY": security = node
	check(security != null, "real floor-one security located")
	for tick in range(360):
		# Six seconds idle, then actual mapped movement in both directions with stops.
		if tick == 180 or tick == 270: Input.action_press("move_right" if tick == 180 else "move_left")
		if tick == 210: Input.action_release("move_right")
		if tick == 300: Input.action_release("move_left")
		if security != null and tick < 150 and not security.get_node("Artwork").get("_walking"):
			var pose: Dictionary = security.get_node("Artwork").get_render_pose()
			# Actual turn-warning and alert poses remain valid; expression frames 7/8 must not loop as idle.
			check(pose.frame in [-1,6,9,10,11], "security neutral or intentional warning pose " + str(tick))
		await create_timer(1.0/30.0).timeout
	check(not art.get("_walking"), "player returns to standing after movement")
	check(player.visual.scale.x == -1, "stopped player keeps last left facing")
	check(player.walk_speed == 160, "movement speed preserved")
	await shot("idle")
	Input.action_release("move_left")
	Input.action_release("move_right")
	print("BUTTON_IDLE_REVIEW: ", "PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
