extends SceneTree
const Story = preload("res://scenes/ui/story_revision.gd")
const Portraits = preload("res://scenes/ui/confirmed_character_portraits.gd")
const Roles = preload("res://scenes/ui/dialogue_roles.gd")
var failures: Array[String] = []
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message); printerr("FAIL: " + message)
func run() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(Story.PATH))
	check(Portraits.PORTRAITS.carol.size() == 13 and Portraits.PORTRAITS.terese.size() == 7 and Portraits.PORTRAITS.manager.size() == 3, "13/7/3 approved expressions")
	for id: String in Portraits.PORTRAITS:
		for expression: String in Portraits.PORTRAITS[id]:
			var speaker: String = {"carol":"Carol", "terese":"Terese", "manager":"经理"}[id]
			var texture := Portraits.portrait(speaker, expression)
			check(texture != null and texture.get_width() > 0 and texture.get_height() > 0, id + ":" + expression)
	check(Portraits.portrait("Carol", "坚定") == Portraits.portrait("Carol", "hunting"), "determined uses approved hunting")
	check(Portraits.portrait("Carol", "思考") == Portraits.portrait("Carol", "沉思"), "thinking alias")
	check(Portraits.portrait("Carol", "狐疑") != Portraits.portrait("Carol", "怀疑"), "dubious and suspicious are distinct")
	check(Roles.portrait("CAROL") == Portraits.portrait("Carol", "平常"), "task/tutorial shares approved Carol")
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	var dialogue: Control = main.get_node("StoryLayer/Dialogue")
	var portrait: TextureRect = dialogue.get_node("%Portrait")
	for id: String in Portraits.PORTRAITS:
		var speaker: String = {"carol":"Carol", "terese":"Terese", "manager":"经理"}[id]
		for expression: String in Portraits.PORTRAITS[id]:
			dialogue._display_portrait(speaker, expression)
			check(portrait.texture == Portraits.portrait(speaker, expression), "formal rendering " + id + ":" + expression)
	root.get_node("Localization").set_language("en")
	var count := 0
	var tokens: Array[String] = []
	for section: String in data:
		for beat: Dictionary in data[section]:
			count += 1
			check(not tokens.has(beat.beat_id), "unique beat despite repeated source labels")
			tokens.append(beat.beat_id)
			check(tr(beat.text) != beat.text, "English translation: " + beat.text)
			dialogue.present_revision_beat(beat)
			await process_frame
			check(portrait.visible == bool(beat.portrait), "portrait visibility: " + beat.text)
			if beat.portrait:
				check(portrait.texture != null, "approved portrait resolves")
				if not Portraits.role(beat.speaker).is_empty():
					check(portrait.texture == Portraits.portrait(beat.speaker, beat.expression), "exact authored expression: " + beat.text)
			else:
				check(portrait.texture == null, "narration/CG clears preceding portrait")
				check(dialogue.get_node("%StageCue").visible and not dialogue.get_node("%DialogueFrame").visible if dialogue.uses_background_narration(beat.text) else dialogue.get_node("%Line").position.x < dialogue.size.x * 0.15, "background narration or full-width blank layout")
	check(count == 170, "all 170 full-list beats included")
	dialogue.cancel_presentation()
	root.get_node("Localization").set_language("zh_CN")
	dialogue.set_skip_transitions_for_test(true)
	dialogue.show_dialogue("V4_INTRO")
	var scenes: Array[String] = []
	var actual: Array[String] = []
	for beat: Dictionary in dialogue._beats:
		if scenes.is_empty() or scenes[-1] != beat.scene: scenes.append(beat.scene)
		if beat.mode != "title": actual.append(beat.text)
	var expected: Array[String] = []
	for beat: Dictionary in data.intro: expected.append(beat.text)
	check(scenes == ["bedroom", "cafe", "bedroom", "exterior"], "bedroom/cafe/bedroom/exterior restored in order")
	check(actual == expected and actual[0] == "那家旅馆……", "actual intro uses complete authored content")
	dialogue.cancel_presentation()
	dialogue.show_dialogue("V4_MANAGER_TALK")
	check(dialogue._beats.size() == 23 and dialogue._beats[-1].text == "现在还不是……", "complete manager scene including restored ending")
	dialogue.cancel_presentation()
	var monster: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://scenes/ui/monster_dialogues.json"))
	for pair: Array in [["NOSE","nose"],["EYE","eye"],["HAT","hat"],["EAR","ear"],["CHECKER","checker"]]:
		for phase: String in ["INTRO", "DELIVERED"]:
			var rows: Array = monster[pair[0]][phase]
			check(rows.size() == data[pair[1] + "_" + phase.to_lower()].size(), "monster phase count")
			for i in range(rows.size()): check(Story.monster_beat(rows[i]) == data[pair[1] + "_" + phase.to_lower()][i], "actual monster phase text and expression parity")
	var cg: Array = JSON.parse_string(FileAccess.get_file_as_string("res://cg309_reunion/dialogue.json"))
	check(cg.size() == data.reunion.size(), "reunion caption count")
	for i in range(cg.size()): check(cg[i].text == data.reunion[i].text and not cg[i].portrait, "CG text preserved without portraits")
	var finished: Array[String] = []
	dialogue.dialogue_finished.connect(func(id: String): finished.append(id))
	check(dialogue.show_story_sequence("COMPLETE_TEST", Story.beats("501_intro")), "world sequence opens")
	for i in range(Story.beats("501_intro").size()): dialogue._advance()
	check(finished == ["COMPLETE_TEST"] and not dialogue.visible, "world sequence completes once")
	dialogue._advance()
	check(finished.size() == 1, "extra input cannot repeat completion")
	main.queue_free()
	await process_frame
	if failures.is_empty(): print("PASS: 170 beats, 23 approved expressions, four prologue scenes, manager ending, monster/CG routing, English and completion isolation")
	quit(0 if failures.is_empty() else 1)
