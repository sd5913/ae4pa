extends "res://scenes/tests/core/five_monster_main_flow_smoke.gd"
## Extends the real new-game five-monster flow, without prerequisite API fixtures.
## Positions/staff facing/task clock remain explicit deterministic test controls.
## Later ordinary door schedulers stay active; selected work/approach points are safe.

func end() -> void:
	if not failures.is_empty():
		await _finish_chain()
		return
	var music: AudioStreamPlayer = main.get_node("BackgroundMusic")
	_check_music(music, "the_haunted_ballroom_1.mp3")
	await move_to(floor_node().get_node("DoorRoot/Room302").position.x - 116)
	check(main.dialogue.visible, "full run enters real302 intro")
	await drain_story()
	board.get("_accept_button").pressed.emit()
	await settle()
	await equip("MANAGER")
	await work("Register309")
	await drain_story() # Read the new registration result before returning to world input.
	check(g.get_completed_task_ids().has(g.TASK_03_ID), "full run really approves309")
	check(floor_node().get_node("Interactions/Register309/TaskItemVisual/ResultFeedback").visible, "302 approval has explicit success feedback")
	check("309" in main.get_node("TaskLayer/HUD/%Objective").text and "Terese" in main.get_node("TaskLayer/HUD/%Objective").text, "302 completion names309 and the rescue objective")
	await move_to(2850)
	await equip("CLEANER")
	await move_to(floor_node().get_node("Interactions/RescuePoint").position.x)
	await tap()
	await create_timer(0.8).timeout
	var host: Node = main.get_node("Room309Reunion")
	check(is_instance_valid(host.cg), "full run opens actual309 CG")
	if not is_instance_valid(host.cg):
		await _finish_chain()
		return
	_check_music(music, "the_haunted_ballroom_1.mp3")
	for i in range(60):
		if not is_instance_valid(host.cg): break
		if host.cg.get("_transitioning"): await create_timer(0.5).timeout
		await tap()
	check(g.has_friend and floor_node().has_node("Persica"), "full run actual revised rescue enables follower")
	_check_music(music, "propulsive_tension_2.mp3")
	check(main.dialogue.visible and main.dialogue.get("_dialogue_id") == "LATE_ALARM", "rescue hands off to the alarm without leaking world input")
	await drain_story()
	await travel(4)
	await move_to(floor_node().get_node("DoorRoot/Room403").position.x - 116)
	await drain_story()
	check(g.current_task_id == g.TASK_04_ID and board.visible, "full run actual403 offer")
	board.get("_accept_button").pressed.emit()
	await settle()
	var staff: Node = floor_node().get_node("StaffRoot/PatrolSlot/Staff")
	staff.set_cleaner_behavior_enabled(false) # Freeze the patrol before positioning the theft fixture.
	staff.facing_direction = 1
	for name in ["TurnTimer", "TurnWarningTimer", "BehaviorTimer", "SuspicionTimer"]: staff.get_node(name).stop()
	await move_to(staff.global_position.x - 40)
	await key("interact", true)
	await create_timer(0.9).timeout
	await key("interact", false)
	check(g.task_status == "READY_TO_SUBMIT", "full run real patrol theft")
	await move_to(floor_node().get_node("DoorRoot/Room403").position.x - 50)
	await tap()
	await drain_story()
	check(g.get_completed_task_ids().has(g.TASK_04_ID), "full run actual403 delivery")
	await travel(5)
	await move_to(floor_node().get_node("DoorRoot/Room501").position.x - 116)
	await drain_story()
	check(g.current_task_id == g.TASK_05_ID and board.visible, "full run actual501 offer")
	board.get("_accept_button").pressed.emit()
	await settle()
	await move_to(floor_node().get_node("Interactions/ExitRegister5F").position.x)
	await equip("MANAGER")
	await work("ExitRegister5F")
	check(g.task_status == "READY_TO_SUBMIT", "full run current-manager exit approval")
	await move_to(floor_node().get_node("DoorRoot/Room501").position.x - 50)
	await tap()
	await drain_story()
	_check_music(music, "propulsive_tension_2.mp3")
	await travel_exit()
	check(g.game_state == "WON" and main.dialogue.get("_dialogue_id") == "LATE_ENDING" and not main.get_node("MenuLayer/Win").visible, "actual EXIT plays the rain ending before showing success")
	var finale := music.stream as AudioStreamMP3
	check(music.playing and finale != null and not finale.loop and finale.resource_path.get_file() == "the_final_word.mp3",
		"the finale chapter card switches to The Final Word once")
	await drain_story()
	check(not music.playing, "the finale score stops when the dialogue ends")
	check(g.game_state == "WON" and main.get_node("MenuLayer/Win").visible, "normal new game through all eight tasks/309 to actualEXIT success")
	main._show_menu()
	check(not music.playing, "returning to the menu stops background music")
	main._start_session()
	_check_music(music, "the_haunted_ballroom_1.mp3")
	await _finish_chain()

func _check_music(player: AudioStreamPlayer, filename: String) -> void:
	var track := player.stream as AudioStreamMP3
	check(player.playing and track != null and track.loop and track.resource_path.get_file() == filename,
		"looping background music plays " + filename)

func travel_exit() -> void:
	await move_to(floor_node().exit_point.global_position.x)
	await tap()
	await capture("full_escape")

func _finish_chain() -> void:
	if failures.is_empty(): print("PASS: full_mainline_escape from normal new game, all eight real tasks and actual309 CG")
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
