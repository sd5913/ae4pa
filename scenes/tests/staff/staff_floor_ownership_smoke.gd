extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _expect(value: bool,message: String) -> void:
	if not value:
		failures.append(message)

func _settle_range() -> void:
	for _step in range(3):
		await physics_frame

func _check_1f_theft_reach(floor_node: Node) -> void:
	for role: String in ["Security", "Cleaner", "Manager"]:
		var staff: Node = floor_node.get_node("StaffRoot/" + role + "Slot/Staff")
		staff.get_node("BehaviorTimer").stop()
		staff.facing_direction = 1
		floor_node.player.global_position.x = staff.global_position.x - 125.0
		await _settle_range()
		_expect(staff.is_player_in_range() and staff.is_player_behind(), role + " can be approached from 125 pixels behind")
		floor_node.player.global_position.x = staff.global_position.x + 125.0
		await _settle_range()
		_expect(not staff.is_player_in_range() and not staff.is_observing_player(), role + " has no added front reach")
		floor_node.player.global_position.x = staff.global_position.x + 90.0
		await _settle_range()
		_expect(staff.is_player_in_range() and staff.is_observing_player(), role + " retains front warning reach")
		staff.get_node("SuspicionTimer").stop()
		staff._end_suspicion(false)
		floor_node.player.global_position.x = staff.global_position.x - 180.0
		await _settle_range()
		_expect(not staff.is_player_in_range(), role + " cannot be approached from 180 pixels behind")

func _check_staff_route(staff: Node, first: float, last: float, label: String) -> void:
	_expect(is_equal_approx(staff.global_position.x, first), label + " starts at the left endpoint")
	staff.get_node("BehaviorTimer").stop()
	staff._on_behavior_timer_timeout()
	staff._on_behavior_timer_timeout()
	staff._process(0.25)
	_expect(staff.global_position.x > first and staff.global_position.x < last, label + " walks between endpoints")
	staff._process(20.0)
	_expect(is_equal_approx(staff.global_position.x, last), label + " stops at the right endpoint")
	_expect(staff.get_node("BehaviorTimer").time_left > staff.steal_hold_time, label + " pauses long enough for a full hold")
	staff._on_behavior_timer_timeout()
	staff._on_behavior_timer_timeout()
	staff._process(20.0)
	_expect(is_equal_approx(staff.global_position.x, first), label + " returns to the left endpoint")

func _run() -> void:
	var game = root.get_node("GameManager")
	var cards = root.get_node("CardManager")
	var host := Node2D.new()
	root.add_child(host)
	game.set_floor_host(host,true)
	game.start_game()
	game.set_process(false)
	cards.collect_card("SECURITY")
	var previous: WeakRef
	for destination in [1,2,1,2,1,3,2,1]:
		game._load_floor(destination)
		await process_frame
		await process_frame
		_expect(host.get_child_count() == 1,"Only one current floor")
		if previous != null:
			_expect(previous.get_ref() == null,"Unloaded floor is freed")
		var floor_node := host.get_child(0)
		previous = weakref(floor_node)
		var staff_root := floor_node.get_node("StaffRoot")
		_expect(staff_root.get_child_count() == (3 if destination == 1 else 0),"Card staff count on floor %d" % destination)
		_expect(cards.has_card("SECURITY"),"Owned card survives floor reload")
		if destination == 1:
			var guard := staff_root.get_node("SecuritySlot/Staff")
			_expect(not guard.is_reward_available(),"Owned security card cannot respawn")
	var first_floor := host.get_child(0)
	await _check_1f_theft_reach(first_floor)
	_check_staff_route(first_floor.get_node("StaffRoot/CleanerSlot/Staff"), 2645.0, 3115.0, "1F cleaner")
	game._load_floor(4)
	await process_frame
	_check_staff_route(host.get_child(0).get_node("StaffRoot/PatrolSlot/Staff"), 1420.0, 1670.0, "4F patrol")
	var patrol: Node = load("res://scenes/staff/patrol_staff_4f.tscn").instantiate()
	_expect(patrol.target_id == "STAFF_PATROL_4F" and patrol.reward_type == "TASK_ITEM","4F patrol record remains independent")
	patrol.free()
	game.set_floor_host(null)
	host.queue_free()
	await process_frame
	game.set_process(true)
	for message in failures:
		printerr("FAIL: ",message)
	print("STAFF_FLOOR_OWNERSHIP: ","PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
