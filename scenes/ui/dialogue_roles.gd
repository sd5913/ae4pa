extends RefCounted
## Empty portraits are intentional: scene sprites are not formal portraits.
const ROLES := {
	"NOSE": {"name": "长鼻客", "portrait": ""},
	"EYE": {"name": "独眼客", "portrait": ""},
	"HAT": {"name": "礼帽客", "portrait": ""},
	"EAR": {"name": "大耳客", "portrait": ""},
	"CHECKER": {"name": "核验客", "portrait": ""},
	"SYSTEM": {"name": "任务提示", "portrait": ""},
	"CAROL": {"name": "Carol", "portrait": "res://assets/final/ui/dialogue_portraits/an/an_neutral.png"},
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
	return load(path) if not path.is_empty() else null
