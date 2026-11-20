extends SceneTree
var failures: Array[String] = []
var violations: Array[String] = []
func _initialize() -> void: call_deferred("run")
func check(ok: bool, text: String) -> void:
	if not ok: failures.append(text)
func run() -> void:
	var g: Node = root.get_node("GameManager")
	var c: Node = root.get_node("CardManager")
	g.start_game(); g.current_floor = 3
	for kind in ["NOSE", "EYE", "HAT", "EAR", "CHECKER"]: g.get("_seen_monsters")[kind] = true
	var floor_node: Node = load("res://scenes/levels/floor_3.tscn").instantiate()
	root.add_child(floor_node); await process_frame
	floor_node.set_process(false)
	var p: Node2D = floor_node.get_node("Player"); p.set_physics_process(false)
	var door: Node = floor_node.get_node("DoorRoot/Room301/Door")
	door.monster_type = "EAR"; door.set_managed_state("OPEN")
	p.global_position.x = door.global_position.x - 30; p.set("is_moving", true)
	g.request_monster_encounter("301", "EAR", "WRONG_RULE")
	floor_node._resolve_known_card_encounter()
	check(not g.get_pending_monster_encounter().is_empty(), "moving near learned EAR keeps request")
	p.set("is_moving", false); floor_node._resolve_known_card_encounter()
	check(g.get_pending_monster_encounter().is_empty(), "standing still resolves learned EAR without new tutorial")
	g.resolve_monster_encounter("301")
	door.rule_violated.connect(func(reason: String, _side: int): violations.append(reason))
	door.monster_type = "CHECKER"
	c.switch_active() # Actual identity event while in open checker radius.
	check(violations == ["SWITCHED_NEAR_CHECKER"], "switching near learned CHECKER emits the real violation")
	floor_node._resolve_known_card_encounter()
	check(g.get_pending_monster_encounter().is_empty() and door._violation_pending, "known checker uses safe-return acknowledgment rather than a centre-wall encounter")
	p.global_position.x = door.global_position.x - 150
	check(door.finish_safe_return(), "safe retreat acknowledges learned checker violation")
	floor_node._resolve_known_card_encounter()
	check(g.get_pending_monster_encounter().is_empty(), "retreat to safe area permits learned CHECKER retry")
	floor_node.queue_free(); await process_frame
	for text in failures: printerr("FAIL: " + text)
	if failures.is_empty(): print("PASS: learned EAR and CHECKER ordinary rules remain active after2F")
	quit(0 if failures.is_empty() else 1)
