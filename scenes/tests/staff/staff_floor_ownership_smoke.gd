extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _expect(value: bool,message: String) -> void:
	if not value:
		failures.append(message)

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
