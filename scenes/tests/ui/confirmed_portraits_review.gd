extends SceneTree
const Portraits = preload("res://scenes/ui/confirmed_character_portraits.gd")
var failures := 0
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var folder := OS.get_environment("AE4PA_PORTRAIT_EVIDENCE")
	if folder.is_empty(): folder = "user://confirmed_portraits_review"
	DirAccess.make_dir_recursive_absolute(folder)
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	await process_frame
	main.get_node("MenuLayer/MainMenu").hide()
	var dialogue = main.get_node("StoryLayer/Dialogue")
	dialogue.set_progress_file_path_for_test("user://portrait_review.cfg")
	dialogue.set_skip_transitions_for_test(true)
	dialogue.show_dialogue("V4_INTRO")
	dialogue.call("_finish_phone_animation")
	for locale in ["zh_CN", "en"]:
		root.get_node("Localization").set_language(locale)
		for resolution in [Vector2i(960,540), Vector2i(1280,720), Vector2i(1920,1080)]:
			root.size = resolution
			DisplayServer.window_set_size(resolution)
			for role in Portraits.PORTRAITS:
				for expression in Portraits.PORTRAITS[role]:
					dialogue.get("_beats").assign([{"scene":"cafe","speaker":"Carol" if role=="carol" else "Terese" if role=="terese" else "经理","expression":expression,"mode":"dialogue","text":"恐怖电影里的人要是都像你一样谨慎，电影十分钟就结束了。"}])
					dialogue.set("_line_index", 0)
					dialogue.call("_set_scene", "cafe", false)
					dialogue.call("_show_story_beat")
					dialogue.show()
					for tick in range(5): await process_frame
					var portrait: TextureRect = dialogue.get_node("%Portrait")
					var rect := portrait.get_global_rect()
					if not portrait.is_visible_in_tree() or portrait.texture != Portraits.PORTRAITS[role][expression]:
						failures += 1
						push_error("Portrait not displayed " + role + ":" + expression)
					if not dialogue.get_global_rect().grow(1).encloses(rect):
						failures += 1
						push_error("Portrait bounds " + role + ":" + expression)
					await RenderingServer.frame_post_draw
					var path := folder.path_join("%s_%dx%d_%s_%s.png" % [locale,resolution.x,resolution.y,role,expression])
					if root.get_texture().get_image().save_png(path) != OK: failures += 1
	print("PORTRAIT_VISUAL_FIXTURE failures=",failures," renderer=",RenderingServer.get_current_rendering_method())
	quit(failures)
