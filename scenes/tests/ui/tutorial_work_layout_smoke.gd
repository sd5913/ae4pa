extends SceneTree
var failures:Array[String]=[]
func check(ok:bool,text:String)->void:
	if not ok:failures.append(text)
func _initialize()->void:call_deferred("run")
func run()->void:
	var g:Node=root.get_node("GameManager");g.start_game();g.complete_manager_intro();g.current_floor=2
	var f:Node=load("res://scenes/levels/floor_2.tscn").instantiate();root.add_child(f);await process_frame
	var pickup:Node2D=f.get_node("Interactions/TransitPickup205");var desk:Node2D=f.get_node("Interactions/TransitRegister205")
	check(absf(pickup.position.x-desk.position.x)>=200,"205 pickup and approval do not share overlapping interaction zones")
	for name in ["RoomService203","PatrolCabinet204","TransitPickup205","TransitRegister205"]:
		var work:Node=f.get_node("Interactions/"+name);var visual:Sprite2D=work.get_node("PersistentVisual")
		check(visual.texture.get_height()*visual.scale.y>=150,name+" is a readable grounded prop, not a miniature placeholder")
		check(not work.get_node("Hint").is_visible_in_tree(),name+" does not leave permanent overlapping debug labels")
	var overlay:Node=load("res://scenes/ui/interaction_progress.gd").new();root.add_child(overlay)
	overlay._display({"status":"READY","interaction_type":"PICKUP","block_reason":"READY","elapsed":0.0,"required_time":0.0,"progress":0.0})
	check(not overlay.get("_progress").visible and "按E" in overlay.get("_details").text,"instant pickup has a press prompt rather than a0/0 progress bar")
	overlay.queue_free()
	f.queue_free();await process_frame
	for text in failures:printerr("FAIL: "+text)
	if failures.is_empty():print("PASS: readable separated task props and contextual labels")
	quit(0 if failures.is_empty() else 1)
