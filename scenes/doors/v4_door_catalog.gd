extends RefCounted
## C configuration proposal only. A owns assembly, task eligibility and route locks.
const ROWS: Array[Dictionary] = [
	{"room": "201", "floor": 2, "monster": "NOSE", "task": "TASK_01_CLEAN"},
	{"room": "202", "floor": 2, "monster": "EYE", "task": "TASK_02_PARCEL"},
	{"room": "203", "floor": 2, "monster": "EAR", "task": ""},
	{"room": "204", "floor": 2, "monster": "CHECKER", "task": ""},
	{"room": "205", "floor": 2, "monster": "HAT", "task": ""},
	{"room": "301", "floor": 3, "monster": "EYE", "task": ""},
	{"room": "302", "floor": 3, "monster": "CHECKER", "task": ""},
	{"room": "303", "floor": 3, "monster": "HAT", "task": "TASK_03_AUTHORIZE"},
	{"room": "304", "floor": 3, "monster": "NOSE", "task": ""},
	{"room": "305", "floor": 3, "monster": "EAR", "task": ""},
	{"room": "401", "floor": 4, "monster": "EAR", "task": ""},
	{"room": "402", "floor": 4, "monster": "EYE", "task": "TASK_04_PATROL"},
	{"room": "403", "floor": 4, "monster": "NOSE", "task": ""},
	{"room": "404", "floor": 4, "monster": "CHECKER", "task": ""},
	{"room": "405", "floor": 4, "monster": "HAT", "task": ""},
	{"room": "501", "floor": 5, "monster": "HAT", "task": "", "proposed": true},
	{"room": "502", "floor": 5, "monster": "NOSE", "task": "", "proposed": true},
	{"room": "503", "floor": 5, "monster": "CHECKER", "task": "TASK_05_EXIT"},
	{"room": "504", "floor": 5, "monster": "EYE", "task": "", "proposed": true},
	{"room": "505", "floor": 5, "monster": "EAR", "task": "", "proposed": true},
]


static func get_rows(floor_number: int = 0) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row: Dictionary in ROWS:
		if floor_number == 0 or row.floor == floor_number:
			result.append(row.duplicate(true))
	return result


## Explicit call only: never mutates A's existing M1 NORMAL 202.
## use_trial_timing=false preserves historical defaults for comparison.
static func configure(door: Node2D, room: String, use_trial_timing: bool = true) -> bool:
	for row: Dictionary in ROWS:
		if row.room != room:
			continue
		door.room_id = row.room
		door.monster_type = row.monster
		door.task_id = row.task
		door.door_mode = "STORY" if not row.task.is_empty() else "NORMAL"
		door.radius = 90.0
		door.story_radius = 120.0
		door.closed_time = 5.0 if use_trial_timing else 5.5
		door.warning_time = 1.5 if use_trial_timing else 1.4
		door.open_time = 3.0 if use_trial_timing else 2.8
		door.offset = float(int(room) % 100 - 1) * 2.0
		door.reset_cycle()
		return true
	return false
