extends SceneTree
## Real upper-floor instances with disclosed unlocked/learned-state fixtures.
## Never changes random pools or selected resident types.
var g: Node
var c: Node
var failures: Array[String] = []
var rows: Array[Dictionary] = []
var captured: Array[String] = []
var session_seed: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures.append(label)
func settle() -> void:
	for i in range(5): await physics_frame
	await process_frame
func freeze(f: Node) -> void:
	f.set_process(false);f.player.set_physics_process(false)
	f.get("_door_scheduler").set_process(false)
	for d in f.get("_doors"):d.set_physics_process(false);d.set_managed_state("CLOSED")
func capture_resident(f: Node, door: Node2D) -> void:
	if "--capture" not in OS.get_cmdline_user_args() or captured.has(door.monster_type): return
	captured.append(door.monster_type)
	f.player.position.x=door.global_position.x-150
	f.player.get_node("Camera2D").reset_smoothing()
	await process_frame;await RenderingServer.frame_post_draw
	var dir := "res://scenes/tests/doors/evidence/c_closeout_20261122/ordinary_screenshots"
	DirAccess.make_dir_recursive_absolute(dir)
	root.get_texture().get_image().save_png(dir.path_join(door.room_id+"_"+door.monster_type+".png"))
func run() -> void:
	root.size=Vector2i(1280,720)
	g=root.get_node("GameManager");c=root.get_node("CardManager")
	var host := Node2D.new();root.add_child(host);g.set_floor_host(host)
	g.start_game();g.set_process(false)
	g.get("_completed_task_ids").assign(g.TUTORIAL_TASKS+[g.TASK_03_ID,g.TASK_04_ID,g.TASK_05_ID])
	g.current_task_id="NONE";g.task_status="NONE";g.has_friend=true
	for kind in ["NOSE","EYE","HAT","EAR","CHECKER"]:g.get("_seen_monsters")[kind]=true
	var signals: Array[Dictionary]=[]
	g.safe_return_started.connect(func(reason: String):signals.append({"reason":reason,"signal_source":"GameManager.safe_return_started","floor":g.current_floor}))
	for audit_seed in [20261122,20261123,20261124]:
		session_seed=audit_seed
		seed(audit_seed)
		g.get("_room_monsters").clear()
		for number in [3,4,5]:
			g._load_floor(number);var f: Node=host.get_child(0);freeze(f);await settle()
			var assignment: Dictionary={}
			for door: Node2D in f.get("_doors"):
				assignment[door.room_id]=door.monster_type
				if door.door_mode!="NORMAL":continue
				var art: Node=f.get_node("Floor%dArt" % number)
				var visual: Node2D=art.get_node("Doors/Room"+door.room_id)
				var before_count: int=signals.size()
				var required: String={"NOSE":"CLEANER","EYE":"SECURITY","HAT":"MANAGER"}.get(door.monster_type,"")
				for state in ["CLOSED","WARNING","OPEN"]:
					door.set_managed_state(state);art._process(0)
					check(visual.state==state,"Room"+door.room_id+" artwork matches "+state)
					check(visual.get_node("MonsterIdle").is_visible_in_tree()==(state=="OPEN"),"Room"+door.room_id+" resident visible only when open")
					check(visual.get_node("MonsterIdle").kind==door.monster_type,"Room"+door.room_id+" resident identity matches detector")
					if state=="OPEN": await capture_resident(f,door)
					if state!="OPEN":
						f.player.position.x=door.global_position.x-40;f.player.is_moving=true;door._physics_process(0)
						check(signals.size()==before_count,"Room"+door.room_id+" closed/warning safe")
				check(visual.scale.x>0 and is_equal_approx(visual.scale.x,visual.scale.y),"Room"+door.room_id+" uniform positive door scale")
				for side in [-1,1]:
					door.set_managed_state("CLOSED");c.reset_for_new_game()
					if not required.is_empty():c.collect_card(required)
					f.player.position.x=door.global_position.x+side*40;f.player.is_moving=false
					door._last_managed_x=door.global_position.x+side*150;door.set_managed_state("OPEN")
					var origin: Vector2=f.player.global_position
					door._physics_process(0)
					check(f.player.global_position==origin,"Room"+door.room_id+" valid rule permits side "+str(side))
					if not required.is_empty():
						c.equip_card("NONE",c.active_slot);door._physics_process(0)
					elif door.monster_type=="EAR":
						f.player.is_moving=true;door._physics_process(0)
					else:c.switch_active()
					var destination: Vector2=f.player.global_position
					rows.append({"session_seed":session_seed,"room":door.room_id,"monster":door.monster_type,"side":side,"state":"OPEN","origin":[origin.x,origin.y],"destination":[destination.x,destination.y],"signal":"rule_violated -> floor._on_door_violation -> GameManager.safe_return_started","pending":g.get_pending_monster_encounter()})
					check(destination==f.return_point.global_position,"Room"+door.room_id+" violation returns to left stairs from side "+str(side))
					await settle()
					check(g.game_state=="PLAYING" and g.get_pending_monster_encounter().is_empty(),"Room"+door.room_id+" return resumes without story interception")
				door.set_managed_state("CLOSED");art._process(0)
			var normals: Array = f.get("_doors").filter(func(d): return d.door_mode=="NORMAL")
			var sched: Node=f.get("_door_scheduler")
			var overlap := false
			for tick in range(400):
				f.player.position.x=normals[tick%normals.size()].global_position.x-180
				sched._process(0.13)
				var count := 0
				for item in f.get("_doors"):
					if item.door_state!="CLOSED":count+=1
				if count>1:overlap=true
			check(not overlap,"Floor"+str(number)+" 400 scheduler ticks never overlap warning/open doors")
			g._load_floor(number);f=host.get_child(0);freeze(f);await settle()
			for d in f.get("_doors"):check(assignment[d.room_id]==d.monster_type,"Room"+d.room_id+" same-session revisit stable")
	var out: String="res://scenes/tests/doors/evidence/c_closeout_20261122/ordinary_trace.json"
	FileAccess.open(out,FileAccess.WRITE).store_string(JSON.stringify({"baseline":"569b5d0941aaef73a327eaa19def1b0b95bcb798","seeds":[20261122,20261123,20261124],"fixture":"unlocked tasks and learned residents; actual room draws; scheduler paused for each phase","failures":failures,"rows":rows,"safe_return_signals":signals},"  "))
	g.set_floor_host(null);host.queue_free();await process_frame
	g.set_process(true)
	print("C_ORDINARY_AUDIT: PASS" if failures.is_empty() else "C_ORDINARY_AUDIT: FAIL")
	quit(0 if failures.is_empty() else 1)
