extends SceneTree
const Story = preload("res://scenes/ui/story_revision.gd")
const Portraits = preload("res://scenes/ui/confirmed_character_portraits.gd")
var evidence := OS.get_environment("AE4PA_STORY_EVIDENCE")
var failures: Array[String] = []
var dialogue: Control
var captures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message); printerr("FAIL: " + message)
func settle() -> void:
	for i in range(5): await process_frame
func shot(name: String) -> void:
	await settle()
	var body: Label = dialogue.get_node("%Line")
	var panel: Control = dialogue.get_node("%DialogueFrame")
	check(panel.get_global_rect().encloses(body.get_global_rect()), "text inside frame " + name)
	check(Rect2(Vector2.ZERO,dialogue.size).encloses(body.get_global_rect()), "text inside viewport " + name)
	check(body.get_minimum_size().y <= body.size.y + 1, "all text lines fit " + name)
	var portrait: Control = dialogue.get_node("%Portrait")
	if portrait.visible:
		check(portrait.get_rect().end.x <= body.position.x, "portrait does not overlap text " + name)
	else:
		check(body.position.x < dialogue.size.x * 0.15, "full-width text " + name)
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(evidence.path_join(name + ".png")) == OK, "capture " + name)
	captures += 1
func present(beat: Dictionary, scene: String, name: String) -> void:
	dialogue.cancel_presentation()
	check(dialogue.show_story_sequence("REVIEW", [beat], scene), "opens " + name)
	await shot(name)
func run() -> void:
	check(DisplayServer.get_name() != "headless", "real Compatibility renderer")
	check(not evidence.is_empty(), "explicit evidence path")
	if not failures.is_empty(): quit(1); return
	DirAccess.make_dir_recursive_absolute(evidence)
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await settle()
	main.get_node("MenuLayer/MainMenu")._finish_opening()
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	dialogue = main.get_node("StoryLayer/Dialogue")
	dialogue.set_skip_transitions_for_test(true)
	var game := root.get_node("GameManager")
	game.set_process(false)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(Story.PATH))
	var intro: Array = data.intro
	var samples: Array = []
	for text: String in ["那家旅馆……", "这里写着「员工离店须经管理部门批准」。", "你这人真没情趣。", "没有联系电话，也查不到正常的订房页面。", "先找到她，再弄清楚这里发生了什么。"]:
		for beat: Dictionary in intro:
			if beat.text == text: samples.append([beat,beat.scene])
	samples.append([intro[2],"cafe"])
	for sample: Array in [["lobby","不能。您是她的……？"],["lobby","现在还不是……"],["lobby","包括你吗？"],["checker_intro","保安从值班资料点领，经理在登记台批。要换身份，走远了再换。楼上跟我一样爱从门缝看人的，最容易记住这种事。袖口明明还是那个袖口，牌子倒换了。"],["403_delivered","他说下一趟先走左边。"],["501_intro","我在 309 等的，就是这张？"],["ending","一顿可不够。"]]:
		for beat: Dictionary in data[sample[0]]:
			if beat.text == sample[1]: samples.append([beat,"lobby" if sample[0] == "lobby" else "exterior" if sample[0] == "ending" else ""])
	check(samples.size() == 13, "all distinct scene and expression samples found")
	for locale: String in ["zh_CN","en"]:
		root.get_node("Localization").set_language(locale)
		for viewport_size: Vector2i in [Vector2i(960,540),Vector2i(1280,720),Vector2i(1920,1080)]:
			root.size = viewport_size
			DisplayServer.window_set_size(viewport_size)
			for i in range(samples.size()): await present(samples[i][0], samples[i][1], "%s_%dx%d_%02d" % [locale,viewport_size.x,viewport_size.y,i])
	root.get_node("Localization").set_language("zh_CN")
	root.size = Vector2i(1280,720)
	DisplayServer.window_set_size(Vector2i(1280,720))
	for role: String in Portraits.PORTRAITS:
		for expression: String in Portraits.PORTRAITS[role]:
			var speaker: String = {"carol":"Carol", "terese":"Terese", "manager":"经理"}[role]
			await present({"speaker":speaker,"text":"画面检查","mode":"dialogue","expression":expression,"portrait":true},"cafe" if role == "terese" else "lobby","portrait_" + role + "_" + expression)
	for pair: Array in [["长鼻客","nose"],["独眼客","eye"],["礼帽客","hat"],["大耳客","ear"],["门缝客","checker"]]:
		await present({"speaker":pair[0],"text":"画面检查","mode":"dialogue","expression":"neutral","portrait":true},"","portrait_monster_" + pair[1])
	main.queue_free()
	await process_frame
	print("COMPLETE_DIALOGUE_REVIEW: %s; %d Compatibility captures" % ["PASS" if failures.is_empty() else "FAIL", captures])
	quit(0 if failures.is_empty() else 1)
