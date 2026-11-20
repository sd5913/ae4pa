extends SceneTree
var main: Node
var game: Node
var cards: Node
var output := "/private/tmp/ae4pa-ui-before"
var layouts: Dictionary = {}
func _initialize() -> void:
	call_deferred("_run")
func _shot(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output + "/" + name + ".png")
	var controls: Array = []
	for n in main.find_children("*", "Control", true, false):
		if not n.is_visible_in_tree(): continue
		var data := {"path": str(main.get_path_to(n)), "rect": [n.global_position.x,n.global_position.y,n.size.x,n.size.y],"minimum": [n.get_combined_minimum_size().x,n.get_combined_minimum_size().y]}
		if n is Label:
			data["text"] = n.atr(n.text)
			data["lines"] = n.get_line_count()
			data["visible_lines"] = n.get_visible_line_count()
		controls.append(data)
	layouts[name] = controls
	print("CAPTURED ", name)
func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if not args.is_empty(): output = args[0]
	DirAccess.make_dir_recursive_absolute(output)
	root.get_node("Localization").set_language("en")
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await _shot("menu")
	main.get_node("MenuLayer/Notebook").open_help()
	await _shot("help")
	main.get_node("MenuLayer/Notebook").close_help()
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	main.dialogue.set_skip_transitions_for_test(true)
	await create_timer(0.8).timeout
	await _shot("phone")
	main.dialogue._finish()
	game.complete_manager_intro()
	game.set_process(false)
	var floor_node: Node = main.get_node("World").get_child(0)
	floor_node.player.global_position = floor_node.exit_point.global_position
	game.request_floor_travel(2)
	await process_frame
	game.offer_task(game.TASK_01_ID)
	var board: Control = main.get_node("TaskLayer/MissionBoard")
	board.get("_accept_button").pressed.emit()
	cards.collect_card("CLEANER")
	game.record_work_result("STAIN_201")
	game.submit_task(game.TASK_01_ID)
	main.call("_show_story_dialogue", "TASK_02_INTRO")
	main.dialogue.call("_on_continue_pressed")
	main.dialogue.call("_on_continue_pressed")
	await _shot("dialogue202")
	for i in range(8):
		if not main.dialogue.visible: break
		main.dialogue.call("_on_continue_pressed")
	await _shot("offer202")
	board.get("_accept_button").pressed.emit()
	cards.collect_card("SECURITY")
	cards.collect_card("MANAGER")
	await _shot("hud202")
	main.get_node("MenuLayer/Bag").open_bag()
	await _shot("bag")
	main.get_node("MenuLayer/Bag").close_bag()
	main.get_node("TaskLayer/PlayOverlay").toggle_pause()
	await _shot("pause")
	main.get_node("TaskLayer/PlayOverlay").close_page()
	game.request_task_failure("TASK_TIMEOUT")
	await _shot("failure202")
	var file := FileAccess.open(output+"/layouts.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(layouts,"  "))
	print("UI REVIEW CAPTURES COMPLETE")
	await create_timer(3).timeout
	quit()
