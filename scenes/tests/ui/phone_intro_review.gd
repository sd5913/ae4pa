extends SceneTree
## Real main-scene opening, with original animation and input enabled (no --ui-smoke).
const ORIGINAL_TEXT: Array[String] = [
	"你睡了吗？", "能来接我吗", "现在？", "你终于舍得回消息了。你这几天去哪了？",
	"我还在之前说过的那家旅馆", "他们不让我离开", "“他们”是谁？", "你先把地址发给我。",
	"三楼", "309号房", "你报警了吗？", "我现在给你打电话。", "电话只响一声便挂断。",
	"不要打", "他们会听见", "谁会听见？", "你房间里有人？", "“对方正在输入”出现又消失。",
	"别相信这里的工作人员", "他们看起来和正常人一样", "什么意思？", "我现在不能继续发消息了", "快一点",
	"Carol又拨了一次，电话里依然只有“对方暂时无法接听”的提示。她退出通话，翻出几天前收到的兼职录取通知。",
]
var failures: Array[String] = []
var evidence := OS.get_environment("AE4PA_PHONE_EVIDENCE")
var captures := 0
var dialogue: Control
var completed: Array[String] = []

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		printerr("FAIL: " + message)

func settle() -> void:
	for i in range(5): await process_frame

func press_e() -> void:
	var event := InputEventKey.new()
	event.device = 77
	event.physical_keycode = KEY_E
	event.pressed = true
	dialogue._input(event)

func click(point: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.device = 77
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	dialogue._input(event)
	event.pressed = false
	dialogue._input(event)

func shot(name: String) -> void:
	await settle()
	if evidence.is_empty() or DisplayServer.get_name() == "headless": return
	# Render explicitly when the verification window is hidden or loses focus.
	RenderingServer.force_draw(false)
	check(root.get_texture().get_image().save_png(evidence.path_join(name + ".png")) == OK, "capture " + name)
	captures += 1

func run() -> void:
	if not evidence.is_empty(): DirAccess.make_dir_recursive_absolute(evidence)
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	await settle()
	main.get_node("MenuLayer/MainMenu")._finish_opening()
	dialogue = main.get_node("StoryLayer/Dialogue")
	# The fixture calls the real handler below; native desktop events must not
	# interleave an extra click while a screenshot waits for the next frame.
	# The main-flow smoke separately covers normal viewport input dispatch.
	dialogue.set_process_input(false)
	dialogue.set_progress_file_path_for_test("user://phone_intro_review.cfg")
	dialogue.reset_progress_file_for_test()
	dialogue.dialogue_finished.connect(func(id: String): completed.append(id))
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	var game := root.get_node("GameManager")
	check(dialogue._dialogue_id == "V4_INTRO" and not game.is_world_input_allowed(), "real Start enters modal prologue")
	for locale: String in ["zh_CN", "en"]:
		root.get_node("Localization").set_language(locale)
		for viewport: Vector2i in [Vector2i(960,540), Vector2i(1280,720), Vector2i(1920,1080)]:
			root.size = viewport
			if DisplayServer.get_name() != "headless": DisplayServer.window_set_size(viewport)
			await settle()
			dialogue.show_dialogue("V4_INTRO")
			var prefix := "%s_%dx%d_" % [locale, viewport.x, viewport.y]
			print("CASE " + prefix)
			check(dialogue._chapter_card.active and dialogue._line_index == 0 and not dialogue.get_node("%SMSPanel").visible, "chapter one fully precedes phone " + prefix)
			check(dialogue._beats.size() == 61, "original chat plus all current prologue beats")
			for i in range(24): check(dialogue._beats[i].text == ORIGINAL_TEXT[i], "original phone/cue wording and order %d" % i)
			press_e()
			check(dialogue._chapter_card.active and dialogue._line_index == 0 and dialogue._phone_tween == null, "early chapter input cannot start or skip phone")
			await create_timer(2.95).timeout
			await shot(prefix + "chapter_1")
			if viewport.x == 1280: press_e()
			else: click(dialogue.get_global_rect().get_center())
			await create_timer(0.95).timeout
			check(not dialogue._chapter_card.active and dialogue._line_index == 0, "chapter dismissal preserves first message")
			check(dialogue._phone_tween != null and dialogue.get_node("%SMSPanel").visible and dialogue.get_node("%VibrationMarks").visible, "original shake and vibration marks start after chapter")
			var angle: float = dialogue.get_node("%SMSPanel").rotation_degrees
			press_e()
			click(dialogue.get_node("%PhoneScreen").get_global_rect().get_center())
			check(dialogue._line_index == 0 and not dialogue.get_node("%PhoneChat").visible, "shake blocks premature opening and advance")
			await shot(prefix + "shake_a")
			await create_timer(0.24).timeout
			check(not is_equal_approx(dialogue.get_node("%SMSPanel").rotation_degrees, angle), "phone rotation changes over time")
			await shot(prefix + "shake_b")
			var deadline := Time.get_ticks_msec() + 4000
			while dialogue._phone_tween != null and Time.get_ticks_msec() < deadline: await process_frame
			check(dialogue._phone_tween == null and dialogue._phone_waiting_for_open and is_zero_approx(dialogue.get_node("%SMSPanel").rotation_degrees), "shake settles and waits for explicit opening")
			check(dialogue.get_node("%PhoneNotification").visible and not dialogue.get_node("%PhoneChat").visible and not dialogue.get_node("%VibrationMarks").visible, "original notification remains after shake")
			check(dialogue.get_node("SMSPanel/PhoneScreen/PhoneNotification/Notice/NotificationText").text == "1 条新消息", "original new-message notification restored")
			await shot(prefix + "notification")
			click(Vector2(12,12))
			check(dialogue._line_index == 0 and dialogue._phone_waiting_for_open, "background click cannot open or consume phone")
			if viewport.x == 1280: press_e()
			else: click(dialogue.get_node("%PhoneScreen").get_global_rect().get_center())
			check(dialogue._line_index == 0 and dialogue.get_node("%PhoneChat").visible and dialogue.get_node("%SMSHistory").get_child_count() == 1, "opening reveals first original bubble without consuming it")
			await shot(prefix + "chat_first")
			var sms_count := 1
			for i in range(1,24):
				press_e()
				await settle()
				check(dialogue._line_index == i and dialogue._phone_tween == null, "each input advances once without repeating shake %s expected=%d actual=%d tween=%s transition=%s" % [prefix, i, dialogue._line_index, dialogue._phone_tween != null, dialogue._transition_in_progress])
				var beat: Dictionary = dialogue._beats[i]
				if beat.mode == "sms":
					sms_count += 1
					check(dialogue.get_node("%SMSPanel").visible and not dialogue.get_node("%DialogueFrame").visible, "message uses original phone")
					var body: Label = dialogue.get_node("%SMSHistory").get_child(-1).get_node("Bubble/Body")
					check(body.text == ORIGINAL_TEXT[i] and body.get_minimum_size().y <= body.size.y + 1, "original bubble wording and wrapped height")
					check(body.get_global_rect().size.x < dialogue.get_node("%SMSScroll").size.x, "bubble fits phone width")
				else:
					check(dialogue.get_node("%StageCue").visible and not dialogue.get_node("%SMSPanel").visible, "original call/typing stage cue retained")
				if i in [3,18,23]: await shot(prefix + "beat_%02d" % i)
			check(sms_count == 21 and dialogue.get_node("%SMSHistory").get_child_count() == 21, "all 21 original bubbles plus three cues restored exactly once")
			press_e()
			check(dialogue._line_index == 24 and dialogue.get_node("%Line").text == "那家旅馆……" and dialogue.get_node("%Portrait").visible and not dialogue.get_node("%SMSPanel").visible, "phone returns to current Carol dialogue without an extra chapter")
			await shot(prefix + "carol_after_phone")
			press_e()
			press_e()
			await create_timer(1.5).timeout
			check(dialogue._chapter_card.active and dialogue._chapter_card._card_id == "cafe_2", "current cafe chapter remains after both Carol lines")
			check(completed.is_empty() and not game.has_completed_manager_intro() and game.get_available_floors().is_empty(), "phone and chapter input never completes prologue or unlocks floors")
			dialogue.cancel_presentation()
	# Cancel a live shake, then restart. No old tween or phone may leak under a new card.
	dialogue.show_dialogue("V4_INTRO")
	await create_timer(2.95).timeout
	dialogue._chapter_card.dismiss()
	await create_timer(0.95).timeout
	check(dialogue._phone_tween != null, "cancellation fixture reaches active shake")
	dialogue.cancel_presentation()
	dialogue.show_dialogue("V4_INTRO")
	await create_timer(1.9).timeout
	check(dialogue._chapter_card.active and not dialogue.get_node("%SMSPanel").visible and dialogue._phone_tween == null and not dialogue._phone_waiting_for_open and completed.is_empty(), "cancel/restart cleans shake and leaves phone hidden until chapter closes")
	dialogue.cancel_presentation()
	dialogue.reset_progress_file_for_test()
	main.queue_free()
	await process_frame
	check(game.is_world_input_allowed(), "unloading opening restores world input")
	print("PHONE_INTRO_REVIEW: %s; %d captures" % ["PASS" if failures.is_empty() else "FAIL", captures])
	quit(0 if failures.is_empty() else 1)
