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
	gm.current_floor = 4
	var floor_node = load("res://scenes/levels/floor_4.tscn").instantiate()
	root.add_child(floor_node)
	await process_frame
	var art = floor_node.get_node("Floor4Art")
	check(floor_node._doors.size()==5,"Five regular rooms")
	check(not floor_node.get_node("FloorBackground").visible,"Old flat background hidden")
	check(art.get_node("Architecture").get_child_count()==9,"Independent architecture and stair backing")
	check(art.get_node("Furniture").get_child_count()==10,"Independent furniture objects, not baked scene")
	for room in ["401","402","403","404","405"]:
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
	art._process(0.0)
	check(floor_node.get_node("Interactions/ReturnPoint").global_position==Vector2(192,560),"Left stairs interaction preserved")
	check(floor_node.get_node("Interactions/ExitPoint").global_position==Vector2(3400,560),"Right stairs interaction preserved")
	for node in art.find_children("*","CollisionObject2D",true,false):
		check(false,"Art added collision: "+str(node.name))
	for child in floor_node.get_children():
		if child.get_script()==load("res://scenes/doors/door_scheduler.gd"):
			child.set_process(false)
	floor_node.player.set_physics_process(false)
	floor_node.player.global_position.x = 192
	Input.action_press("move_right")
	for i in range(45):floor_node.player._physics_process(0.5)
	Input.action_release("move_right")
	check(floor_node.player.global_position.x>3300,"Can move across component art")
	floor_node.queue_free()
	await process_frame
	for f in failures:printerr("FAIL: ",f)
	print("FLOOR_4_LAYOUT: PASS" if failures.is_empty() else "FLOOR_4_LAYOUT: FAIL")
	quit(0 if failures.is_empty() else 1)
