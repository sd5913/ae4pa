extends SceneTree
## Catalog contract: all forced first lessons occur on 2F before later random rooms.
var catalog: GDScript
var door_scene: PackedScene
const FIRST_LESSONS = {
	"201": ["NOSE", "TASK_01_CLEAN"],
	"202": ["EYE", "TASK_02_PARCEL"],
	"203": ["HAT", "TASK_T03_ROOM_SERVICE"],
	"204": ["EAR", "TASK_T04_DUAL_WORK"],
	"205": ["CHECKER", "TASK_T05_TRANSIT"],
}
const ALL_MONSTERS = ["NOSE", "EYE", "HAT", "EAR", "CHECKER"]
var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Node = root.get_node("GameManager")
	game.start_game()
	catalog = load("res://scenes/doors/v4_door_catalog.gd")
	door_scene = load("res://scenes/doors/monster_door.tscn")
	var rows: Array[Dictionary] = catalog.get_rows()
	_expect(rows.size() == 17, "All17 public rooms configured;305/504/505 excluded")
	var first_rooms: Array[String] = []
	for row: Dictionary in rows:
		var room: String = row.room
		var door: Node2D = door_scene.instantiate()
		_expect(catalog.configure(door, room), "Known room configures: " + room)
		_expect(door.room_id == room, "Configured room identity: " + room)
		if FIRST_LESSONS.has(room):
			var expected: Array = FIRST_LESSONS[room]
			_expect(row.first, "2F lesson is marked first: " + room)
			_expect(row.monster == expected[0] and row.pool == [expected[0]], "Fixed 2F lesson species: " + room)
			_expect(row.task == expected[1], "Lesson uses its tutorial task: " + room)
			_expect(door.monster_type == expected[0] and door.task_id == expected[1], "Real door receives lesson species and task: " + room)
			_expect(door.door_mode == "STORY", "2F lesson intercepts as story: " + room)
		else:
			_expect(not row.first, "Later room does not repeat a forced first lesson: " + room)
			_expect(row.pool == ALL_MONSTERS, "Later room can choose every taught species: " + room)
			_expect(door.monster_type in ALL_MONSTERS, "Later door receives a valid random species: " + room)
			_expect(door.door_mode == "NORMAL", "Catalog leaves later door ordinary: " + room)
			var assigned: String = door.monster_type
			catalog.configure(door, room)
			_expect(door.monster_type == assigned, "Room species stays stable within session: " + room)
		if row.first:
			first_rooms.append(room)
		_expect(door.closed_time == 5.0 and door.warning_time == 1.5 and door.open_time == 3.0, "Trial timing remains available: " + room)
		catalog.configure(door, room, false)
		_expect(door.closed_time == 5.5 and door.warning_time == 1.4 and door.open_time == 2.8, "Historical timing remains available: " + room)
		door.free()
	_expect(first_rooms == ["201", "202", "203", "204", "205"], "Exactly five first lessons, all on 2F")
	_expect(catalog.get_rows(2).size() == 5 and catalog.get_rows(3).size() == 4, "Floor filters retain 2F lessons and reserved 305")
	for room: String in ["302", "403", "501"]:
		_expect(not catalog.FIRST.has(room), "Former first room is no longer forced: " + room)
	for room: String in ["305", "504", "505", "999"]:
		var door: Node2D = door_scene.instantiate()
		_expect(catalog.pool(room).is_empty() and not catalog.configure(door, room), "Reserved or unknown room rejected: " + room)
		door.free()
	var copied: Array[Dictionary] = catalog.get_rows(2)
	copied[0].pool.append("INVALID")
	_expect(catalog.pool("201") == ["NOSE"], "Changing returned rows cannot alter later assignments")
	for kind: String in ALL_MONSTERS:
		_expect(not game.has_met_monster(kind), "Catalog configuration does not mark a lesson learned: " + kind)
	_expect(game.get_pending_monster_encounter().is_empty(), "Catalog configuration does not open a runtime encounter")
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS tutorial catalog: 201–205 fixed story lessons, later rooms ordinary/all-five pools, stable assignments and no encounter side effects.")
	quit(0 if failures.is_empty() else 1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
