extends SceneTree
var failures: Array[String] = []
func _initialize() -> void:
	call_deferred("_run")
func _expect(ok: bool,message: String) -> void:
	if not ok:
		failures.append(message)
func _visual(node: Node) -> Node:
	for child in node.get_children():
		if child.get_script() == load("res://scenes/work/task_item_visual.gd"):
			return child
	return null
func _run() -> void:
	var game = root.get_node("GameManager")
	var cards = root.get_node("CardManager")
	game.start_game()
	var player: Node2D = load("res://scenes/player/player.tscn").instantiate()
	root.add_child(player)
	player.position = Vector2(852,560)
	var work: Node2D = load("res://scenes/work/cleaning_spot.tscn").instantiate()
	work.position = player.position
	root.add_child(work)
	work.setup(player)
	work.set_task_active(true)
	cards.collect_card("CLEANER")
	await physics_frame
	await physics_frame
	_expect(work.begin_interaction(),"Valid cleaner starts work")
	_expect(player.get_node("Visual/Artwork").cleaning_active,"Hold starts mop pose")
	work.cancel_interaction()
	_expect(not player.get_node("Visual/Artwork").cleaning_active,"Cancel clears mop immediately")
	_expect(work.begin_interaction(),"Cleaning can restart")
	work.advance_interaction(1.5)
	await process_frame
	_expect(work.is_completed() and not player.get_node("Visual/Artwork").cleaning_active,"Completion clears mop")
	_visual(work)._sync()
	_expect(not _visual(work).get("_item").visible,"Completed stain disappears")
	var parcel: Node = load("res://scenes/work/parcel_cabinet_2f.tscn").instantiate()
	root.add_child(parcel)
	_expect(not parcel.get_node("ItemVisual").visible,"No extra small envelope")
	parcel.set_completed(true)
	_visual(parcel)._sync()
	_expect(parcel.get_node("PersistentVisual").visible and parcel.get_node("PersistentVisual").texture.resource_path.ends_with("parcel_cabinet_empty.png"),"Parcel gone / original cabinet retained")
	parcel.set_completed(false)
	_visual(parcel)._sync()
	_expect(parcel.get_node("PersistentVisual").texture.resource_path.ends_with("mail_package_cabinet.png"),"Checkpoint restores cabinet parcel")
	var patrol: Node = load("res://scenes/staff/patrol_staff_4f.tscn").instantiate()
	root.add_child(patrol)
	patrol.set_reward_available(false)
	_visual(patrol)._sync()
	_expect(patrol.visible and not _visual(patrol).get("_item").visible,"4F file hides / NPC remains")
	patrol.set_reward_available(true)
	_visual(patrol)._sync()
	_expect(_visual(patrol).get("_item").visible,"4F reward restore")
	for id in ["an","manager","security","cleaner"]:
		var image: Image = (load("res://assets/final/characters/approved_actions/%s.png" % id) as Texture2D).get_image()
		_expect(image.get_width()%3 == 0 and image.get_height()%4 == 0,"12 fixed cells: "+id)
	var full: Image = (load("res://assets/final/floor_2_layers/05_interactive/mail_package_cabinet.png") as Texture2D).get_image()
	var empty: Image = (load("res://assets/final/work/parcel_cabinet_empty.png") as Texture2D).get_image()
	var changed_outside := false
	for y in full.get_height():
		for x in full.get_width():
			if not Rect2i(299,237,96,72).has_point(Vector2i(x,y)) and full.get_pixel(x,y) != empty.get_pixel(x,y):
				changed_outside = true
	_expect(not changed_outside,"All cabinet pixels outside parcel cubby are unchanged")
	work.free()
	parcel.free()
	patrol.free()
	player.free()
	for message in failures:
		printerr("FAIL: ",message)
	print("FINAL_VISUAL_INTEGRATION: ","PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
