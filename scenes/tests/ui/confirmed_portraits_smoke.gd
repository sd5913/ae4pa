extends SceneTree
const Portraits = preload("res://scenes/ui/confirmed_character_portraits.gd")
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
	check(Portraits.portrait("Carol", "worried") == Portraits.portrait("Carol", "pensive"), "Carol worry maps to thinking")
	for expression in ["concerned", "curious"]:
		check(Portraits.portrait("Carol", expression) == Portraits.portrait("Carol", "smile"), expression + " maps to smile")
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
	for speaker in ["Carol", "Terese", "经理"]:
		var id := Portraits.role(speaker)
		for expression in Portraits.PORTRAITS[id]:
			dialogue.call("_display_portrait", speaker, expression)
			check(dialogue.get_node("%Portrait").texture == Portraits.portrait(speaker, expression), "formal scene " + speaker + ":" + expression)
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
