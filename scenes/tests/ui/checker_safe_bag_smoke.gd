extends SceneTree
var failures:Array[String]=[]
func _initialize()->void:call_deferred("run")
func tap()->void:
	for pressed in [true,false]:
		var e:=InputEventAction.new();e.action="open_bag";e.pressed=pressed;Input.parse_input_event(e);await process_frame
func run()->void:
	var g:Node=root.get_node("GameManager");var main:Node=load("res://scenes/main.tscn").instantiate();root.add_child(main);await process_frame
	main._start_session();main.dialogue._finish();g.complete_manager_intro();g.set_process(false)
	g.set("_completed_task_ids",["TASK_01_CLEAN","TASK_02_PARCEL","TASK_T03_ROOM_SERVICE","TASK_T04_DUAL_WORK"] as Array[String])
	g.current_task_id="TASK_T05_TRANSIT";g.task_status="ACTIVE";g.remaining_time=200
	g.set("_world_flags",{"passage_201_unlocked":true,"passage_202_unlocked":true,"passage_203_unlocked":true,"passage_204_unlocked":true,"tutorial_room_205_revealed":true})
	g._load_floor(2);await process_frame
	var f:Node=main.get_node("World").get_child(0);var bag:Control=main.get_node("MenuLayer/Bag")
	f.player.position.x=f.get_node("DoorRoot/Room205").position.x-35
	for i in range(4):await physics_frame
	await tap()
	if bag.visible:failures.append("open checker range must not permit bag equipment changes")
	if bag.visible:await tap()
	main.get_node("TaskLayer/HUD").bag_requested.emit();await process_frame
	if bag.visible:failures.append("toolbar must enforce the same checker bag restriction as I")
	if bag.visible:bag.close_bag()
	f.player.position.x=2850
	for i in range(4):await physics_frame
	await tap()
	if not bag.visible:failures.append("205 safe workstation still allows real I equipment")
	if bag.visible:await tap()
	main.get_node("TaskLayer/HUD").bag_requested.emit();await process_frame
	if not bag.visible:failures.append("safe workstation permits toolbar bag access")
	if bag.visible:bag.close_bag()
	main.queue_free();await process_frame
	for message in failures:printerr("FAIL: "+message)
	if failures.is_empty():print("PASS: checker rejects in-range bag and permits safe workstation equipment")
	quit(0 if failures.is_empty() else 1)
