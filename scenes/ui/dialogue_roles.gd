extends RefCounted
## Approved ZIP matches main assets byte-for-byte. Fixed per-character crop, no scene sprites.
const CROPS := {
	"NOSE": Rect2(100, 90, 825, 1374),
	"EYE": Rect2(20, 120, 984, 1340),
	"HAT": Rect2(60, 20, 900, 1490),
	"EAR": Rect2(35, 260, 954, 1040),
	"CHECKER": Rect2(55, 45, 910, 1455),
}
const ROLES := {
	"NOSE": {"name": "长鼻客", "portrait": "res://assets/final/monster_dialogue_portraits_v1/nose_halfbody.png"},
	"EYE": {"name": "独眼客", "portrait": "res://assets/final/monster_dialogue_portraits_v1/eye_halfbody.png"},
	"HAT": {"name": "礼帽客", "portrait": "res://assets/final/monster_dialogue_portraits_v1/hat_halfbody.png"},
	"EAR": {"name": "大耳客", "portrait": "res://assets/final/monster_dialogue_portraits_v1/ear_halfbody.png"},
	"CHECKER": {"name": "核验客", "portrait": "res://assets/final/monster_dialogue_portraits_v1/checker_halfbody.png"},
	"SYSTEM": {"name": "任务提示", "portrait": ""},
	"CAROL": {"name": "Carol", "portrait": "res://assets/final/confirmed_characters_20261125/carol/smile.png"},
}
# Exact public dialogue IDs, never a room-number guess.
const TASK_ROLES := {
	"TASK_03_INTRO": "HAT",
	"LATE_INTRO_403": "EAR", "LATE_REMINDER_403": "EAR", "LATE_DELIVERED_403": "EAR",
	"LATE_INTRO_501": "CHECKER", "LATE_REMINDER_501": "CHECKER", "LATE_DELIVERED_501": "CHECKER",
}
static func from_speaker(speaker: String) -> String:
	for id: String in ROLES:
		if speaker == id or speaker == ROLES[id]["name"]: return id
	if speaker == "Carol（心想）": return "CAROL"
	if speaker in ["任务提示", "系统提示"]: return "SYSTEM"
	return "CAROL" if speaker in ["女主", "安"] else ""
static func display_name(id: String) -> String:
	return TranslationServer.translate(ROLES.get(id, {}).get("name", id))
static func portrait(id: String) -> Texture2D:
	var path: String = ROLES.get(id, {}).get("portrait", "")
	if path.is_empty(): return null
	var texture: Texture2D = load(path)
	if not CROPS.has(id): return texture
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = CROPS[id]
	return atlas
