extends SceneTree

const DIALOGUE_FILES := [
	"cg309_reunion/dialogue.json",
	"scenes/ui/monster_dialogues.json",
	"scenes/ui/intro_script.tsv",
	"scenes/ui/story_revision.json",
]

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or not ProjectSettings.load_resource_pack(args[0]):
		push_error("Usage: -- <desktop PCK path> <source project directory>")
		quit(1)
		return

	var valid := true
	for relative_path in DIALOGUE_FILES:
		var expected := FileAccess.get_sha256(args[1].path_join(relative_path))
		if expected.is_empty() or expected != FileAccess.get_sha256("res://" + relative_path):
			push_error("Missing or changed exported dialogue file: " + relative_path)
			valid = false

	for path in ["res://scenes/main.tscn", "res://localization/en.po"]:
		if not ResourceLoader.exists(path):
			push_error("Missing exported resource: " + path)
			valid = false

	if valid:
		print("The PCK contains the main scene, English localization, and all four dialogue files.")
	quit(0 if valid else 1)
