extends SceneTree
## Compares the production 309 caption against a real opening café dialogue beat.
var _failures: Array[String] = []
var _beats_seen: Array[String] = []
var _completion_count := 0
var _evidence := OS.get_environment("AE4PA_REUNION_EVIDENCE")

func _initialize() -> void:
	_run.call_deferred()

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error("REUNION_DIALOGUE_LAYOUT: " + message)

func _settle() -> void:
	for _frame in range(4):
		await process_frame

func _wait_for_beat(cg: Control) -> void:
	var deadline := Time.get_ticks_msec() + 3000
	while cg._playing and cg._displayed_index != cg._index and Time.get_ticks_msec() < deadline:
		await process_frame
	_check(cg._displayed_index == cg._index or not cg._playing, "current CG beat becomes advanceable")

func _send_interact() -> void:
	var event := InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	root.push_input(event, true)

func _click(position: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.pressed = true
	root.push_input(event, true)
	event.pressed = false
	root.push_input(event, true)

func _resize(viewport: Vector2i) -> void:
	root.size = viewport
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(viewport)
	await _settle()

func _shot(label: String) -> void:
	if _evidence.is_empty() or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(_evidence)
	_check(root.get_texture().get_image().save_png(_evidence.path_join(label + ".png")) == OK, "capture " + label)

func _run() -> void:
	var english := "--english" in OS.get_cmdline_user_args()
	TranslationServer.set_locale("en" if english else "zh_CN")
	var cafe: Control = load("res://scenes/ui/dialogue.tscn").instantiate()
	root.add_child(cafe)
	cafe.set_skip_transitions_for_test(true)
	cafe.show_dialogue("V4_INTRO")
	for index in range(cafe._beats.size()):
		if cafe._beats[index].scene == "cafe" and cafe._beats[index].mode == "dialogue":
			cafe._line_index = index
			cafe._set_scene("cafe", false)
			cafe._show_story_beat()
			break
	var cg: Control = load("res://cg309_reunion/reunion_cg.tscn").instantiate()
	cg.auto_play = false
	root.add_child(cg)
	var dialogue: Control = cg.get_node_or_null("Dialogue")
	_check(dialogue != null, "309 uses the same dialogue scene as the opening")
	if dialogue == null:
		quit(1)
		return
	cg.beat_displayed.connect(func(token: String, _speaker: String, _source: String, _parameters: Dictionary) -> void:
		_beats_seen.append(token)
	)
	cg.rescue_cg_finished.connect(func() -> void: _completion_count += 1)
	var frame: Panel = dialogue.get_node("%DialogueFrame")
	var speaker: Label = dialogue.get_node("%Speaker")
	var body: Label = dialogue.get_node("%Line")
	var reference_frame: Panel = cafe.get_node("%DialogueFrame")
	_check(frame.get_theme_stylebox("panel") == reference_frame.get_theme_stylebox("panel"), "shared café frame styling")
	_check(speaker.get_theme_stylebox("normal") == cafe.get_node("%Speaker").get_theme_stylebox("normal"), "shared café nameplate styling")
	_check(not dialogue.is_processing_input() and not dialogue.has_node("MemoryRail"), "309 caption owns no story input or memory controls")

	cafe.hide()
	cg.play()
	_send_interact()
	_check(cg._index == 0 and _beats_seen.is_empty(), "input during the initial fade does not advance")
	await _wait_for_beat(cg)

	for viewport in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		await _resize(viewport)
		var frame_rect := frame.get_global_rect()
		var name_rect := speaker.get_global_rect()
		var body_rect := body.get_global_rect()
		var cafe_rect := reference_frame.get_global_rect()
		var suffix := "%s_%dx%d" % ["en" if english else "zh", viewport.x, viewport.y]
		_check(is_equal_approx(frame_rect.position.x, cafe_rect.position.x) and is_equal_approx(frame_rect.size.x, cafe_rect.size.x), "café frame horizontal geometry " + suffix)
		_check(frame_rect.encloses(body_rect) and name_rect.end.y <= body_rect.position.y, "body inside frame and below nameplate " + suffix)
		_check(not dialogue.get_node("%Portrait").visible and not dialogue.get_node("%Background").visible, "only the CG artwork and one dialogue surface are visible " + suffix)
		await _shot("309_dialogue_" + suffix)

	_click(Vector2(10, 10))
	_check(cg._index == 0, "pointer outside the panel does not advance")
	_click(frame.get_global_rect().get_center())
	_check(cg._index == 1, "pointer advances one beat inside the panel")
	await _wait_for_beat(cg)
	_send_interact()
	await _wait_for_beat(cg)
	_check(cg._index == 2 and not speaker.visible and body.visible, "narration keeps the panel without an empty nameplate")
	await _shot("309_narration_" + ("en" if english else "zh"))
	var longest_index := 0
	for index in range(cg._beats.size()):
		if str(cg._beats[index].text).length() > str(cg._beats[longest_index].text).length():
			longest_index = index
	await _resize(Vector2i(960, 540))
	for index in range(2, cg._beats.size()):
		_check(cg._index == index and _completion_count == 0, "exactly one progression per beat")
		await _settle()
		var body_rect := body.get_global_rect()
		_check(frame.get_global_rect().encloses(body_rect) and (not speaker.visible or speaker.get_global_rect().end.y <= body_rect.position.y), "small window fits actual beat %d" % (index + 1))
		if index == longest_index:
			await _shot("309_long_caption_" + ("en" if english else "zh") + "_960x540")
		_send_interact()
		if index + 1 < cg._beats.size():
			await _wait_for_beat(cg)
	_check(_beats_seen.size() == 36 and _completion_count == 1, "36 recorded beats and a single completion")
	cg.play()
	cg.cancel()
	await _settle()
	_check(_completion_count == 1 and not cg.visible and _beats_seen.size() == 36, "cancel emits neither completion nor a reading record")
	print("REUNION_DIALOGUE_LAYOUT: ", "PASS" if _failures.is_empty() else "FAIL")
	quit(0 if _failures.is_empty() else 1)
