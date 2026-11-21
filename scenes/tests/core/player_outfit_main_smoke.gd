extends SceneTree
## Main scene, real Q and D bag buttons. Explicit owned-card/position fixtures only.
var failures: Array[String]=[]
var main: Node
var game: Node
var cards: Node
func _initialize() -> void:
	create_timer(65).timeout.connect(func(): print("FAIL: main outfit timeout");quit(1))
	call_deferred("run")
func check(ok: bool,message: String) -> void:
	if not ok: failures.append(message)
func settle() -> void:
	for i in range(5): await physics_frame
	await process_frame
func outfit() -> Node: return main.get_node("World").get_child(0).get_node("Player/Visual/Artwork/IdentityOutfit")
func tap(action: String) -> void:
	for pressed in [true,false]:
		var event:=InputEventAction.new()
		event.action=action;event.pressed=pressed
		Input.parse_input_event(event)
		await settle()
func capture(name: String) -> void:
	if DisplayServer.get_name()=="headless" or "--capture" not in OS.get_cmdline_user_args(): return
	await process_frame
	await RenderingServer.frame_post_draw
	var path:="res://docs/qa_evidence/a_player_outfits_20261121/main"
	DirAccess.make_dir_recursive_absolute(path)
	check(root.get_texture().get_image().save_png(path+"/"+name+".png")==OK,"Main capture "+name)
func run() -> void:
	root.size=Vector2i(1280,720)
	game=root.get_node("GameManager");cards=root.get_node("CardManager")
	root.get_node("Localization").set_language("zh_CN")
	main=load("res://scenes/main.tscn").instantiate();root.add_child(main)
	await settle()
	main._start_session();main.dialogue._finish();game.complete_manager_intro()
	game.set_process(false)
	var floor_node: Node=main.get_node("World").get_child(0)
	floor_node.player.position.x=3260
	cards.collect_card("CLEANER")
	await settle()
	check(outfit().get_outfit_view()["headwear"]=="headscarf","Formal main first collected ID wears cleaner headscarf")
	await capture("cleaner_idle")
	Input.action_press("move_left")
	for i in range(12): await physics_frame
	check(floor_node.player.is_moving and outfit().global_transform.x.x<0,"Actual leftward movement mirrors headscarf with player")
	await capture("cleaner_walk_left")
	Input.action_release("move_left");await settle()
	cards.collect_card("SECURITY")
	check(outfit().get_outfit_view()["card_id"]=="CLEANER","Collecting inactive ID does not layer its hat")
	await tap("switch_id")
	check(cards.active_card=="SECURITY" and outfit().get_outfit_view()["headwear"]=="cap","Actual main Q replaces scarf with security cap")
	Input.action_press("move_right")
	for i in range(12): await physics_frame
	await capture("security_walk_right")
	Input.action_release("move_right");await settle()
	cards.collect_card("MANAGER")
	check(outfit().get_outfit_view()["card_id"]=="SECURITY","Un-equipped third ID cannot change outfit")
	main.bag.open_bag();await settle()
	var owned: ItemList=main.bag.get_node("%OwnedCards")
	for i in owned.item_count:
		if owned.get_item_metadata(i)=="MANAGER": owned.select(i);owned.item_selected.emit(i)
	main.bag.get_node("%EquipSlotB").pressed.emit();main.bag.close_bag();await settle()
	check(cards.active_card=="MANAGER" and outfit().get_outfit_view()["jacket"],"Real bag replacing active B equips manager upper garment")
	check(outfit().get_outfit_view()["headwear"]=="NONE","Manager suit clears both prior headwear")
	await capture("manager_idle")
	await tap("switch_id")
	check(cards.active_card=="CLEANER" and not outfit().get_outfit_view()["jacket"],"Main Q restores original yellow coat with cleaner scarf")
	await capture("cleaner_restored")
	var before: Dictionary=cards.export_snapshot()
	game.current_task_id=game.TASK_01_ID;game.task_status="ACTIVE";game.remaining_time=200
	# Actual checkpoint storage and rollback are covered by the full main-line regression.
	cards.restore_snapshot({"owned_cards":["CLEANER","SECURITY","MANAGER"],"equipped_cards":["SECURITY","MANAGER"],"active_slot":1})
	check(outfit().get_outfit_view()["jacket"],"Snapshot callback updates main appearance immediately")
	cards.restore_snapshot(before)
	check(outfit().get_outfit_view()["headwear"]=="headscarf","Restoring prior cards restores prior appearance")
	main._start_session();main.dialogue._finish();await settle()
	check(cards.active_card=="NONE" and outfit().get_outfit_view()["headwear"]=="NONE" and not outfit().get_outfit_view()["jacket"],"Normal new session clears outfit without stale callbacks")
	for message in failures: print("FAIL: ",message)
	if failures.is_empty(): print("PASS: player_outfit_main_smoke")
	main.queue_free();await process_frame
	quit(0 if failures.is_empty() else 1)
