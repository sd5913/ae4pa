extends SceneTree
var failures: Array[String] = []
var evidence := OS.get_environment("AE4PA_CHAPTER_EVIDENCE")
var captures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message); printerr("FAIL: " + message)
func settle() -> void:
	for i in range(4): await process_frame
func press_e(surface: Control) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = KEY_E
	event.pressed = true
	surface._input(event)
func click(surface: Control) -> void:
	var event := InputEventMouseButton.new()
	event.position = surface.get_global_rect().get_center()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	surface._input(event)
	event.pressed = false
	surface._input(event)
func shot(surface: Control, name: String) -> void:
	for viewport: Vector2i in [Vector2i(960,540),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.mode = Window.MODE_WINDOWED
		root.size = viewport
		if DisplayServer.get_name() != "headless": DisplayServer.window_set_size(viewport)
		await create_timer(0.3).timeout
		await settle()
		if not evidence.is_empty() and DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			var capture := root.get_texture().get_image()
			check(capture.get_size() == viewport, "actual capture size " + name + str(viewport))
			check(capture.save_png(evidence.path_join(name + "_%dx%d.png" % [viewport.x,viewport.y])) == OK, "capture")
			captures += 1
		var cue: Label = surface.get_node("%StageCue")
		if cue.visible:
			check(cue.get_minimum_size().y <= cue.size.y + 1, "background narration fits " + name)
		elif surface.get_node("%DialogueFrame").visible:
			var body: Label = surface.get_node("%Line")
			check(surface.get_node("%DialogueFrame").get_global_rect().encloses(body.get_global_rect()) and body.get_minimum_size().y <= body.size.y + 1, "framed narration fits " + name)
func run() -> void:
	if not evidence.is_empty(): DirAccess.make_dir_recursive_absolute(evidence)
	var dialogue = load("res://scenes/ui/dialogue.tscn").instantiate()
	root.add_child(dialogue)
	await settle()
	for locale: String in ["zh_CN","en"]:
		root.get_node("Localization").set_language(locale)
		dialogue.show_dialogue("V4_INTRO")
		var starts: Array[int] = [0]
		for i in range(1,dialogue._beats.size()):
			if dialogue._beats[i].scene != dialogue._beats[i-1].scene: starts.append(i)
		check(starts.size() == 4, "four prologue chapters")
		for i in range(starts.size()):
			if i > 0:
				dialogue._line_index = starts[i] - 1
				dialogue._set_scene(dialogue._beats[starts[i]-1].scene, false)
				dialogue._show_story_beat()
				press_e(dialogue)
			dialogue._show_story_beat() # Redraws cannot reveal the first beat through a card.
			check(dialogue._chapter_card.active and not dialogue.get_node("%Portrait").visible and not dialogue.get_node("%DialogueFrame").visible, "chapter hides characters and dialogue")
			press_e(dialogue)
			check(dialogue._chapter_card.active and dialogue._line_index == starts[i], "early E cannot skip chapter or first sentence")
			await create_timer(2.95).timeout
			await shot(dialogue, locale + "_chapter_%d" % (i+1))
			if i % 2 == 0: click(dialogue)
			else: press_e(dialogue)
			await create_timer(0.95).timeout
			check(not dialogue._chapter_card.active and dialogue._line_index == starts[i], "dismiss reveals first beat without consuming it")
			dialogue._chapter_card.cancel()
		dialogue.cancel_presentation()
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://scenes/ui/story_revision.json"))
		var count := 0
		for section: String in data:
			for beat: Dictionary in data[section]:
				if not dialogue.uses_background_narration(beat.text) or section == "reunion": continue
				dialogue.present_revision_beat(beat)
				dialogue._set_scene("exterior" if section == "ending" else "cafe" if beat.text.begins_with("几天前") else "exterior" if beat.text.begins_with("回到") else "lobby", false)
				dialogue.get_node("%Background").show()
				dialogue.get_node("Tint").show()
				check(dialogue.get_node("%StageCue").visible and not dialogue.get_node("%DialogueFrame").visible and not dialogue.get_node("%Portrait").visible, "specified narration is background-only")
				await shot(dialogue,locale + "_narration_%d" % count)
				count += 1
		check(count == 7, "seven shared background narrations")
		dialogue.hide()
		var cg = load("res://cg309_reunion/reunion_cg.tscn").instantiate()
		cg.auto_play = false
		root.add_child(cg)
		cg.play()
		check(cg._chapter_card.active and cg._index == -1 and cg._displayed_index == -1, "309 chapter does not record or settle any CG beat")
		press_e(cg)
		check(cg._chapter_card.active, "309 early input locked")
		await create_timer(2.95).timeout
		await shot(cg._dialogue,locale + "_chapter_309")
		click(cg)
		await create_timer(1.0).timeout
		check(cg._index == 0 and not cg._dialogue.get_node("%StageCue").visible and cg._panel.visible and not cg._speaker.visible, "309 opening narration keeps its bottom panel without a nameplate")
		await shot(cg._dialogue,locale + "_narration_309")
		cg.cancel()
		check(not cg._chapter_card.active, "cancel clears chapter")
		cg.queue_free()
		await settle()
		dialogue.show_story_sequence("LATE_ENDING", load("res://scenes/ui/story_revision.gd").beats("ending"), "exterior")
		check(dialogue._chapter_card.active and dialogue._chapter_card._card_id == "ending" and dialogue._line_index == 0, "ending chapter precedes its first CG beat")
		check(not dialogue.get_node("%SkipButton").visible and not dialogue.get_node("%Portrait").visible and not dialogue.get_node("%StageCue").visible, "ending chapter hides underlying controls and narration")
		dialogue._show_story_beat()
		press_e(dialogue)
		check(dialogue._chapter_card.active and dialogue._line_index == 0, "ending refresh and early E do not expose or consume first beat")
		await create_timer(2.95).timeout
		await shot(dialogue, locale + "_chapter_ending")
		click(dialogue)
		press_e(dialogue) # Repeated input while fading cannot leak into the story.
		await create_timer(0.95).timeout
		check(not dialogue._chapter_card.active and dialogue._line_index == 0 and dialogue.get_node("%StageCue").visible, "ending dismissal reveals the first narration exactly once")
		dialogue.cancel_presentation()
		dialogue.show_story_sequence("LATE_ENDING", load("res://scenes/ui/story_revision.gd").beats("ending"), "exterior")
		dialogue.cancel_presentation()
		await create_timer(0.95).timeout
		check(not dialogue.visible and not dialogue._chapter_card.active and dialogue._dialogue_id.is_empty(), "cancel cannot resurrect the ending or emit completion")
	dialogue.queue_free()
	await process_frame
	print("CHAPTER_NARRATION: %s; %d captures" % ["PASS" if failures.is_empty() else "FAIL", captures])
	quit(0 if failures.is_empty() else 1)
