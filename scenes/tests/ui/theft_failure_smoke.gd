extends Node

const FAILURE_SCENE := "res://scenes/ui/failure.tscn"
const ROLES := ["SECURITY", "CLEANER", "MANAGER"]
const FailureScreen = preload("res://scenes/ui/failure.gd")

var failures: Array[String] = []
var screen: FailureScreen
var evidence_dir := OS.get_environment("THEFT_FAILURE_EVIDENCE")


func _ready() -> void:
	_run.call_deferred()


func _check(condition: bool, message: String) -> void:
	print(("PASS: " if condition else "FAIL: ") + message)
	if not condition:
		failures.append(message)


func _run() -> void:
	TranslationServer.set_locale("en" if "--english" in OS.get_cmdline_user_args() else "zh_CN")
	screen = load(FAILURE_SCENE).instantiate()
	add_child(screen)
	await get_tree().process_frame
	var finished: Array[String] = []
	screen.presentation_finished.connect(func(role: String) -> void: finished.append(role))
	_check(not screen.play_theft_failure("NOT_A_STAFF_ID"), "unknown staff identity falls back without starting a CG")
	for role: String in ROLES:
		_check(screen.play_theft_failure(role), role + " selects its matching real CG and starts once")
		_check(not screen.play_theft_failure(role), "duplicate theft signal cannot stack a second presentation")
		screen._advance_theft_dialogue()
		_check(screen._theft_line_index == -1, role + " input during fade-in cannot advance the script")
		await get_tree().process_frame
		var texture: Texture2D = screen.get_node("%TheftCG").texture
		_check(texture != null, role + " CG texture loads")
		var image := texture.get_image()
		_check(image.get_width() > 0 and image.get_height() > 0, role + " CG has a valid image")
		await get_tree().create_timer(0.34, true).timeout
		_check(screen._theft_phase != FailureScreen.TheftPhase.WAIT_FIRST, role + " CG remains in its reveal/hold phase before 0.8 seconds")
		await get_tree().create_timer(0.75, true).timeout
		_check(screen._theft_phase == FailureScreen.TheftPhase.WAIT_FIRST, role + " CG is fully held before first dialogue input")
		screen._advance_theft_dialogue()
		_check(screen._theft_phase == FailureScreen.TheftPhase.READING and screen._theft_line_index == 0, role + " first click shows only the first line")
		var is_english := TranslationServer.get_locale().begins_with("en")
		var expected_names := {
			"SECURITY": "Security Guard" if is_english else "保安",
			"CLEANER": "Housekeeper" if is_english else "保洁",
			"MANAGER": "Manager" if is_english else "经理",
		}
		var expected_staff_name: String = expected_names[role]
		_check(screen.get_node("%TheftSpeaker").text == expected_staff_name, role + " speaker name follows the active locale")
		var initial_line: String = str(screen.get_node("%TheftLine").text)
		var source_lines: Array = screen._theft_lines
		_check(initial_line == str(source_lines[0]["en" if is_english else "zh"]), role + " line one uses the active translation")
		if not evidence_dir.is_empty() and DisplayServer.get_name() != "headless":
			DirAccess.make_dir_recursive_absolute(evidence_dir)
			await RenderingServer.frame_post_draw
			var image_view: Image = get_tree().root.get_texture().get_image()
			var screenshot_path := evidence_dir.path_join(("en" if is_english else "zh") + "_" + role.to_lower() + ".png")
			_check(image_view.save_png(screenshot_path) == OK, role + " dialogue screenshot saved")
		var echo := InputEventKey.new()
		echo.pressed = true
		echo.echo = true
		echo.physical_keycode = KEY_E
		screen._input(echo)
		_check(screen._theft_line_index == 0 and screen.get_node("%TheftLine").text == initial_line, role + " key echo does not advance")
		var beats: Array[String] = [initial_line]
		var e_press := InputEventKey.new()
		e_press.pressed = true
		e_press.physical_keycode = KEY_E
		e_press.keycode = KEY_E
		screen._input(e_press)
		_check(screen._theft_line_index == 1, role + " one E press advances one line")
		beats.append(screen.get_node("%TheftLine").text)
		for expected_index: int in range(2, 4):
			var click := InputEventMouseButton.new()
			click.button_index = MOUSE_BUTTON_LEFT
			click.pressed = true
			click.position = screen.get_node("%TheftDialogueFrame").get_global_rect().get_center()
			screen._on_theft_overlay_gui_input(click)
			beats.append(screen.get_node("%TheftLine").text)
			_check(screen._theft_line_index == expected_index, role + " advances exactly one line per action")
		for index: int in range(beats.size()):
			_check(beats[index] == str(source_lines[index]["en" if is_english else "zh"]), role + " beat %d matches supplied localized script" % (index + 1))
		_check(beats.size() == 4 and beats[0] != beats[1] and beats[2] != beats[3], role + " displays four ordered dialogue beats")
		screen._advance_theft_dialogue()
		_check(screen._theft_phase == FailureScreen.TheftPhase.EXITING, role + " needs a final separate action to end the dialogue")
		await get_tree().create_timer(0.32, true).timeout
		_check(screen._theft_phase == FailureScreen.TheftPhase.IDLE and not screen.get_node("%TheftOverlay").visible,
			role + " fades out and reveals the existing failure menu")
		_check(screen.get_node("%Center").visible, role + " retains the retry/menu controls")
		_check(finished == [role], role + " completion signal fires exactly once")
		if role != ROLES.back():
			screen.hide()
			await get_tree().process_frame
			finished.clear()
	if failures.is_empty():
		print("THEFT_FAILURE_SMOKE: PASS")
		get_tree().quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("THEFT_FAILURE_SMOKE: FAIL (%d)" % failures.size())
		get_tree().quit(1)
