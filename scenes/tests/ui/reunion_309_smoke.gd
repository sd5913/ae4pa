extends SceneTree
var main: Node
var game: Node
var cards: Node
var errors: Array[String] = []
func _initialize() -> void:
	create_timer(50.0).timeout.connect(func(): print("FAIL: reunion host fixture timed out"); quit(1))
	run.call_deferred()
func check(ok: bool, message: String) -> void:
	print(("PASS: " if ok else "FAIL: ")+message)
	if not ok: errors.append(message)
func floor_node() -> Node: return main.get_node("World").get_child(0)
func player() -> Node2D: return floor_node().get_node("Player")
func settle() -> void:
	for i in range(3): await physics_frame
	await process_frame
func tap(mouse: bool = false) -> void:
	var event: InputEvent
	if mouse:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.position = root.get_final_transform() * main.get_node("Room309Reunion").cg.get("_panel").get_global_rect().get_center()
		click.pressed = true
		event = click
	else:
		var action := InputEventAction.new()
		action.action = "interact"
		action.pressed = true
		event = action
	Input.parse_input_event(event)
	await settle()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()
func drain_monster() -> void:
	var screen = main.get_node("TaskLayer/MonsterDialogue")
	for i in range(80):
		if not screen.visible: return
		screen.advance()
func shot(id: String) -> void:
	var path := OS.get_environment("AE4PA_309_EVIDENCE")
	if path.is_empty() or DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(path.path_join(id+".png")) == OK,"screenshot "+id)
func run() -> void:
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	TranslationServer.set_locale("zh_CN")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	main.get_node("MemoryService").storage_root = "user://reunion_309_smoke"
	main.get_node("MenuLayer/Bag/CarolUIFlow")._tutorial_seen = true
	await settle()
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	main.dialogue.hide()
	main._on_dialogue_finished("V4_INTRO")
	game.complete_manager_intro()
	game.set_process(false)
	player().position.x = floor_node().get_stair_interaction_center(true)
	check(game.request_floor_travel(2),"prerequisite fixture travels to2F")
	await settle()
	game.offer_task("TASK_01_CLEAN")
	drain_monster()
	main.get_node("TaskLayer/MissionBoard").hide()
	game.accept_task("TASK_01_CLEAN")
	cards.collect_card("CLEANER")
	check(cards.equip_card("CLEANER", 0), "fixture equips collected cleaner in slot A")
	game.record_work_result("STAIN_201")
	game.submit_task("TASK_01_CLEAN")
	drain_monster()
	game.offer_task("TASK_02_PARCEL")
	main.get_node("TaskLayer/MissionBoard").hide()
	game.accept_task("TASK_02_PARCEL")
	cards.collect_card("SECURITY")
	check(cards.equip_card("SECURITY", 1), "fixture equips collected security in slot B")
	cards.switch_active()
	game.record_work_result("PARCEL_CABINET_2F")
	game.submit_task("TASK_02_PARCEL")
	drain_monster()
	check(load("res://scenes/tests/core/tutorial_test_setup.gd").complete_remaining(game, cards, main),"explicit203–205 fixture for independent309 regression")
	main.get_node("TaskLayer/MissionBoard").hide()
	player().position.x = floor_node().get_stair_interaction_center(true)
	check(game.request_floor_travel(3),"real3F permission after five tutorial deliveries")
	await settle()
	game.offer_task("TASK_03_AUTHORIZE")
	main.get_node("TaskLayer/MissionBoard").hide()
	game.accept_task("TASK_03_AUTHORIZE")
	player().position = floor_node().get_node("Interactions/RescuePoint").position
	await tap()
	var host = main.get_node("Room309Reunion")
	check(not is_instance_valid(host.cg) and not game.has_friend,"registration prerequisite is retained")
	cards.collect_card("MANAGER")
	cards.equip_card("MANAGER",1)
	check(game.record_work_result("REGISTER_309"),"manager approval still requires manager")
	await tap()
	check(not is_instance_valid(host.cg) and not game.has_friend,"manager cannot open309 despite owning cleaner")
	cards.switch_active()
	check(cards.active_card == "CLEANER","actual current cleaner")
	await tap()
	await create_timer(1.0).timeout
	check(is_instance_valid(host.cg) and host.cg.visible,"real floor E opens CG")
	if not is_instance_valid(host.cg): quit(1); return
	var cg: Control = host.cg
	check(cg.get("_beats").size() == 36,"36 original Chinese beats")
	check(not game.has_friend and not game.get_available_floors().has(4),"opening CG does not rescue or open4F")
	check(not game.is_world_input_allowed() and not main.get_node("TaskLayer").visible,"CG hides HUD and locks world")
	await shot("approach")
	var echo := InputEventKey.new()
	echo.physical_keycode = KEY_E
	echo.pressed = true
	echo.echo = true
	Input.parse_input_event(echo)
	await settle()
	check(cg.get("_index") == 0,"key echo does not skip")
	echo.pressed = false
	echo.echo = false
	Input.parse_input_event(echo)
	await settle()
	await tap()
	check(cg.get("_index") == 1,"one E advances one beat")
	await tap(true)
	check(cg.get("_index") == 2,"one click advances one beat")
	await tap()
	check(cg.get("_index") == 2,"transition consumes rapid extra click")
	await create_timer(0.4).timeout
	await shot("hug")
	host.cancel()
	check(not game.has_friend and game.is_world_input_allowed(),"cancel is not success and releases modal")
	await tap()
	await create_timer(1.0).timeout
	cg = host.cg
	check(is_instance_valid(cg), "cancelled sequence can reopen through real E")
	if not is_instance_valid(cg): quit(1); return
	var completions: Array = []
	cg.rescue_cg_finished.connect(func(): completions.append(true))
	for i in range(36):
		if cg.get("_transitioning"): await create_timer(0.5).timeout
		if i == 18: await shot("leave")
		if i == 25:
			root.size = Vector2i(960, 540)
			await settle()
			await shot("small-long-line")
			check(cg.get_node("Dialogue/%Line").get_line_count() <= 3, "small window wraps long Chinese without shrinking")
			root.size = Vector2i(1280, 720)
		await tap(i%2==1)
	check(game.has_friend and completions.size() == 1,"last beat settles real rescue exactly once")
	check(floor_node().has_node("Persica") and game.get_available_floors().has(4),"one real follower and4F access")
	await shot("following")
	var companion: Node2D = floor_node().get_node("Persica")
	var before := companion.global_position.x
	player().position.x += 150
	await create_timer(0.8).timeout
	check(companion.global_position.x > before,"Persica actually follows movement")
	player().position = floor_node().get_node("Interactions/RescuePoint").position
	await tap()
	check(not is_instance_valid(host.cg) and floor_node().find_children("Persica","",false,false).size() == 1,"revisit neither replays nor duplicates")
	player().position.x = floor_node().get_stair_interaction_center(true)
	check(game.request_floor_travel(4),"existing route opens4F after rescue")
	await settle()
	check(floor_node().has_node("Persica"),"follower survives floor reload by real rescue fact")
	main._show_menu()
	await settle()
	check(not is_instance_valid(host.cg) and game.is_world_input_allowed() == false,"menu cleans CG")
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	await settle()
	check(not game.has_friend and not floor_node().has_node("Persica"),"new game has no test rescue/follower")
	main.queue_free()
	await process_frame
	quit(0 if errors.is_empty() else 1)
