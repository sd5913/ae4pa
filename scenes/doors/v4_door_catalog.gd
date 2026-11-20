extends RefCounted
## Session-stable semi-random room assignments. No route unlocks here.
const FIRST = {"201":"NOSE", "202":"EYE", "203":"HAT", "204":"EAR", "205":"CHECKER"}
const TASKS = {"NOSE":"TASK_01_CLEAN", "EYE":"TASK_02_PARCEL", "HAT":"TASK_T03_ROOM_SERVICE", "EAR":"TASK_T04_DUAL_WORK", "CHECKER":"TASK_T05_TRANSIT"}

static func pool(room: String) -> Array:
	if FIRST.has(room):
		return [FIRST[room]]
	var n := int(room)
	if n in [301,302,303,304,401,402,403,404,405,501,502,503]:
		return ["NOSE","EYE","HAT","EAR","CHECKER"]
	return []

static func get_rows(floor_number: int = 0) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for f in range(2,6):
		for i in range(1,6):
			var room := str(f*100+i)
			if room in ["305","504","505"]:
				continue
			if floor_number == 0 or floor_number == f:
				rows.append({"room":room,"floor":f,"monster":pool(room)[0],"pool":pool(room),"first":FIRST.has(room),"task":TASKS[pool(room)[0]]})
	return rows

static func configure(door: Node2D, room: String, use_trial_timing: bool = true) -> bool:
	if pool(room).is_empty():
		return false
	door.room_id = room
	door.monster_type = GameManager.get_room_monster(room)
	door.task_id = TASKS[door.monster_type]
	door.door_mode = "STORY" if FIRST.has(room) else "NORMAL"
	door.closed_time = 5.0 if use_trial_timing else 5.5
	door.warning_time = 1.5 if use_trial_timing else 1.4
	door.open_time = 3.0 if use_trial_timing else 2.8
	door.offset = 0.0
	return true
