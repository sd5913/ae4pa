extends SceneTree
var failures: Array[String] = []
func _initialize() -> void: call_deferred("run")
func run() -> void:
	TranslationServer.set_locale("en")
	for source: String in [
		"女主再拨，显示“对方暂时无法接听”。她翻到几天前的兼职录取通知。",
		"几天前，傍晚的咖啡馆。两杯饮料放在桌上，闺蜜把手机递给女主。",
		"女主从聊天记录里打开旧地址，拿起外套和钥匙。",
		"楼上传来关门声，女主看向楼梯。",
	]:
		var translated := TranslationServer.translate(source)
		if not translated.contains("Carol"): failures.append("English narration still uses old protagonist name: " + translated)
	for beat: Dictionary in JSON.parse_string(FileAccess.get_file_as_string("res://cg309_reunion/dialogue.json")):
		if beat.get("speaker", "") in ["安", "帕希卡"] or beat.get("speaker_en", "") in ["An", "Persica"]:
			failures.append("309 speaker name not migrated")
	var monster_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://scenes/ui/monster_dialogues.json"))
	for monster: Dictionary in monster_data.values():
		for lines: Array in monster.values():
			for line: Array in lines:
				if line[0] == "安" or str(line[0]).begins_with("安（"):
					failures.append("Monster speaker still uses old name: " + line[0])
	for message in failures: print("FAIL: ", message)
	if failures.is_empty(): print("PASS: character_names_smoke")
	quit(0 if failures.is_empty() else 1)
