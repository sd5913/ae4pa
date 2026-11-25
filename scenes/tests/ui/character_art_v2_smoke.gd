extends SceneTree
## Asset/layout fixture, not a claim of a human full-route playthrough.
const Art = preload("res://scenes/ui/character_art_v2.gd")
const WorldArt = preload("res://scenes/ui/character_world_art_v2.gd")
var failures: Array[String] = []
var evidence := OS.get_environment("AE4PA_CHARACTER_EVIDENCE")
var dialogue: Control

func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	print(("PASS: " if ok else "FAIL: ") + message)
	if not ok: failures.append(message)
func settle() -> void:
	for i in range(5): await process_frame
func shot(label: String) -> void:
	if evidence.is_empty() or DisplayServer.get_name() == "headless": return
	await settle()
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(evidence)
	check(root.get_texture().get_image().save_png(evidence.path_join(label + ".png")) == OK, "screenshot " + label)
func run() -> void:
	var game: Node = root.get_node("GameManager")
	var cards: Node = root.get_node("CardManager")
	var english := "--english" in OS.get_cmdline_user_args()
	root.get_node("Localization").set_language("en" if english else "zh_CN")
	dialogue = load("res://scenes/ui/dialogue.tscn").instantiate()
	root.add_child(dialogue)
	await settle()
	for viewport in [Vector2i(960,540), Vector2i(1280,720), Vector2i(1920,1080)]:
		root.size = viewport
		if DisplayServer.get_name() != "headless": DisplayServer.window_set_size(viewport)
		await settle()
		for role: String in Art.ROLES:
			var speaker: String = {"an":"Carol", "friend":"Terese", "manager":"经理"}[role]
			dialogue.present_character_beat("CAROL", "先找到 Terese，再弄清楚这里发生了什么。" if not english else "Find Terese first. Then we can work out what happened here.")
			dialogue.get_node("%Background").texture = dialogue.BACKGROUNDS.cafe
			dialogue.get_node("%Background").show()
			dialogue.get_node("%Speaker").text = tr(speaker)
			var first := Rect2()
			var texture_size := Vector2.ZERO
			for expression: String in Art.EXPRESSIONS:
				dialogue._display_portrait(speaker, expression)
				await settle()
				var portrait: TextureRect = dialogue.get_node("%Portrait")
				var rect := portrait.get_global_rect()
				if expression == "neutral":
					first = rect
					texture_size = portrait.texture.get_size()
				check(rect.is_equal_approx(first) and texture_size == portrait.texture.get_size(), "%s %s fixed canvas %s" % [role, expression, viewport])
				check(absf(rect.end.y - dialogue.get_node("%DialogueFrame").get_global_rect().end.y) < 0.1, role + " portrait flush with dialogue bottom")
				check(rect.position.x >= 0 and rect.position.y >= 0 and rect.end.x <= viewport.x, role + " portrait inside viewport")
				if expression == "neutral": await shot(("en" if english else "zh") + "_%s_%dx%d" % [role, viewport.x, viewport.y])
			check(Art.portrait(role, "unknown") == Art.portrait(role, "neutral"), role + " unknown expression safely falls back to new neutral")
	for id: String in WorldArt.FILES:
		var art := WorldArt.new()
		art.setup(id)
		var idle := art.pose(false, 0.0, 190.0)
		check(idle.new_art and idle.source == art.pose(false, 300.0, 190.0).source, id + " idle does not cycle expression/turn frames")
		var ratio := -1.0
		for i in range(8):
			var pose := art.pose(true, float(i) / 8.0, 190.0)
			check(pose.frame == i and pose.new_art, id + " eight-frame atlas cell " + str(i))
			var current_ratio: float = pose.destination.size.y / pose.source.size.y
			if i == 0: ratio = current_ratio
			check(is_equal_approx(ratio, current_ratio), id + " fixed walk scale")
			var bounds: Rect2 = art._data.bounds[i]
			check(absf(pose.destination.position.y + bounds.end.y * ratio) < 0.01, id + " planted foot baseline")
		if id == "an": check(art.pose(false, 0.0, 190.0, true).texture.resource_path.ends_with("carol_cleaning.png"), "cleaning uses the new Carol pose")
	game.start_game()
	dialogue.hide()
	var player: Node2D = load("res://scenes/player/player.tscn").instantiate()
	root.add_child(player)
	await settle()
	var artwork: Node = player.get_node("Visual/Artwork")
	check(artwork.get_render_pose().new_art, "production Player uses refreshed artwork")
	for id in ["CLEANER", "SECURITY", "MANAGER"]:
		cards.collect_card(id)
		cards.equip_card(id, 0)
		await settle()
		var view: Dictionary = artwork.get_node("IdentityOutfit").get_outfit_view()
		check(view.card_id == id, "existing identity feedback survives new geometry: " + id)
	var follower: Node2D = load("res://scenes/persica_follower.gd").new()
	root.add_child(follower)
	follower.setup(player)
	check(follower._art.character_id == "terese", "309 follower uses approved blonde Terese")
	follower.free()
	player.free()
	dialogue.free()
	if not evidence.is_empty() and DisplayServer.get_name() != "headless":
		await capture_formal_scenes(english)
	print("CHARACTER_ART_V2_SMOKE: ", "PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)

func capture_formal_scenes(english: bool) -> void:
	# Documented fixture: genuine main scene, intro completion callback, no task wins.
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	root.size = Vector2i(960, 540) if english else Vector2i(1280, 720)
	DisplayServer.window_set_size(root.size)
	await settle()
	await shot(("en" if english else "zh") + "_cover")
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	main.dialogue._finish_phone_animation()
	await shot(("en" if english else "zh") + "_phone_avatars")
	main.dialogue.hide()
	main._on_dialogue_finished("V4_INTRO")
	await settle()
	check(main.get_node("World").get_child_count() == 1, "formal floor-one scene loads")
	await shot(("en" if english else "zh") + "_formal_floor1")
	var floor_node: Node = main.get_node("World").get_child(0)
	var actual_player: Node2D = floor_node.get_node("Player")
	for node in floor_node.find_children("*", "Node2D", true, false):
		if node.get_script() == load("res://scenes/staff/staff.gd") and node.card_id == "MANAGER":
			actual_player.global_position.x = node.global_position.x - 180
			break
	var visual_companion: Node2D = load("res://scenes/persica_follower.gd").new()
	floor_node.add_child(visual_companion)
	visual_companion.setup(actual_player)
	# Visual fixture only: add one companion without writing rescue / reward facts.
	await shot(("en" if english else "zh") + "_world_actors_fixture")
	main.get_node("MenuLayer/Bag/CarolUIFlow")._tutorial_seen = true
	for identity in ["CLEANER", "SECURITY", "MANAGER"]:
		var cards: Node = root.get_node("CardManager")
		cards.collect_card(identity)
		cards.equip_card(identity, 0)
		await shot(("en" if english else "zh") + "_outfit_" + identity.to_lower())
	actual_player.get_node("Visual/Artwork").set_cleaning_visual(true)
	await shot(("en" if english else "zh") + "_cleaning_pose_fixture")
	main.queue_free()
	await settle()
	var cg: Control = load("res://cg309_reunion/reunion_cg.gd").new()
	cg.auto_play = false
	root.add_child(cg)
	cg.play()
	for name in ["approach", "hug", "leave"]:
		var index := 0
		for i in range(cg._beats.size()):
			if cg._beats[i].frame == name:
				index = i
				break
		cg._index = index - 1
		cg._transitioning = false
		cg._show_next()
		await create_timer(0.7).timeout
		await shot(("en" if english else "zh") + "_309_" + name)
	cg.cancel()
	cg.free()
