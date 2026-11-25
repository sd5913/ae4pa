extends SceneTree
const Portraits = preload("res://scenes/ui/confirmed_character_portraits.gd")
const TeamArt = preload("res://scenes/ui/character_art_v2.gd")
const DialogueRoles = preload("res://scenes/ui/dialogue_roles.gd")
var failures: Array[String] = []
func check(ok: bool, label: String) -> void:
	print(("PASS " if ok else "FAIL ") + label)
	if not ok: failures.append(label)
func _initialize() -> void: run.call_deferred()
func run() -> void:
	for id in Portraits.PORTRAITS:
		for expression in Portraits.PORTRAITS[id]:
			var texture: Texture2D = Portraits.PORTRAITS[id][expression]
			check(texture.get_size() == Vector2(1280, 1440), id + ":" + expression + " canvas")
	check(Portraits.role("Carol").is_empty(), "Carol bypasses personal portrait overrides")
	check(DialogueRoles.portrait("CAROL") == TeamArt.portrait("an"), "Carol shared adapter retains team version")
	for expression in ["neutral", "surprised", "stern", "worried"]:
		check(Portraits.portrait("经理", expression) == Portraits.portrait("经理", "neutral"), "manager fixed " + expression)
	check(Portraits.portrait("Terese", "playful") != Portraits.portrait("Terese", "teasing"), "Terese playful distinct from teasing")
	var counts := {}
	for line in FileAccess.get_file_as_string("res://scenes/ui/intro_script.tsv").split("\n"):
		var f := line.split("\t")
		if f.size() == 5 and f[0] == "cafe" and f[1] == "闺蜜":
			counts[f[2]] = counts.get(f[2], 0) + 1
	check(counts == {"neutral":4, "happy":4, "teasing":6, "playful":2}, "16 cafe lines use approved assignments")
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	await process_frame
	var dialogue = main.get_node("StoryLayer/Dialogue")
	for expression in TeamArt.EXPRESSIONS + ["pensive", "concerned", "curious", "determined"]:
		dialogue.call("_display_portrait", "Carol", expression)
		var key: String = dialogue.EXPRESSION_ALIASES.get(expression, expression)
		check(dialogue.get_node("%Portrait").texture == TeamArt.portrait("an", key), "Carol team expression " + expression)
	dialogue.present_character_beat("CAROL", "先找到 Terese。")
	check(dialogue.get_node("%Portrait").texture == TeamArt.portrait("an"), "Carol task/tutorial retains team portrait")
	for speaker in ["Terese", "经理"]:
		var id := Portraits.role(speaker)
		for expression in Portraits.PORTRAITS[id]:
			dialogue.call("_display_portrait", speaker, expression)
			check(dialogue.get_node("%Portrait").texture == Portraits.portrait(speaker, expression), "formal scene " + speaker + ":" + expression)
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
