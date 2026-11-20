extends SceneTree
var failures: Array[String] = []
func _initialize() -> void:
	call_deferred("run")
func check(value: bool, message: String) -> void:
	if not value:
		failures.append(message)
func run() -> void:
	var gm = root.get_node("GameManager")
	gm.start_game()
	gm.current_floor = 3
	var floor_node = load("res://scenes/levels/floor_3.tscn").instantiate()
	root.add_child(floor_node)
	await process_frame
	var art = floor_node.get_node("Floor3Art")
	check(not floor_node.get_node("FloorBackground").visible,"Old flat background hidden")
	check(load("res://scenes/doors/v4_door_catalog.gd").pool("305").is_empty(),"305 removed from encounter pool")
	check(not floor_node.has_node("DoorRoot/Room305") and floor_node._doors.size()==4,"305 removed, four regular doors")
	check(art.get_node("Architecture").get_child_count()==8,"Eight independent architecture components")
	check(art.get_node("Furniture").get_child_count()==16,"Independent furniture objects, not baked scene")
	for room in ["301","302","303","304"]:
		var door = floor_node.get_node("DoorRoot/Room"+room+"/Door")
		var visual = art.get_node("Doors/Room"+room)
		check(door.global_position.is_equal_approx(visual.global_position),"Door detector matches art: "+room)
		door.set_physics_process(false)
		door.set_managed_state("OPEN")
		art._process(0.0)
		check(visual.state=="OPEN" and visual.get_node("MonsterIdle").visible,"Actual OPEN state and animation: "+room)
		door.set_managed_state("CLOSED")
		art._process(0.0)
		check(not visual.get_node("MonsterIdle").visible,"Closed hides animation: "+room)
	check(art.get_node("Doors/Room309").global_position.is_equal_approx(floor_node.get_node("Interactions/RescuePoint").global_position),"309 rescue point matches art")
	check(not art.get_node("Doors/Room309").has_node("MonsterIdle"),"309 never displays a monster")
	gm.has_friend = true
	art._process(0.0)
	check(art.get_node("Doors/Room309").state=="OPEN","309 art reads existing rescue flag")
	check(floor_node.get_node("Interactions/ReturnPoint").global_position==Vector2(192,560),"Left stairs interaction preserved")
	check(floor_node.get_node("Interactions/ExitPoint").global_position==Vector2(3400,560),"Right stairs interaction preserved")
	for node in art.find_children("*","CollisionObject2D",true,false):
		check(false,"Art added collision: "+str(node.name))
	for child in floor_node.get_children():
		if child.get_script()==load("res://scenes/doors/door_scheduler.gd"):
			child.set_process(false)
	floor_node.player.set_physics_process(false)
	# Art-only traversal fixture; production302 gate is tested separately.
	gm._completed_task_ids.append(gm.TASK_03_ID)
	floor_node._apply_task_route()
	floor_node.player.global_position.x = 192
	Input.action_press("move_right")
	for i in range(45):floor_node.player._physics_process(0.5)
	Input.action_release("move_right")
	check(floor_node.player.global_position.x>3300,"Can move across component art")
	floor_node.queue_free()
	await process_frame
	for f in failures:printerr("FAIL: ",f)
	print("FLOOR_3_LAYOUT: PASS" if failures.is_empty() else "FLOOR_3_LAYOUT: FAIL")
	quit(0 if failures.is_empty() else 1)
