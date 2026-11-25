extends SceneTree
const State = preload("res://scenes/player/run_stamina.gd")
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, label: String) -> void:
 print(("PASS: " if ok else "FAIL: ")+label)
 if not ok: failures += 1
func run() -> void:
 for fps in [30,60,120]:
  var state := State.new()
  state.toggle()
  for i in fps: state.tick(1.0/fps,false)
  check(state.value==100,"idle does not drain at %d fps"%fps)
  for i in fps*3: state.tick(1.0/fps,true)
  check(state.value<0.01 and not state.running and state.exhausted,"three second exhaustion at %d fps"%fps)
  for i in 20: state.toggle()
  check(not state.running,"toggle spam cannot bypass exhaustion")
  for i in fps: state.tick(1.0/fps,false)
  check(state.value<0.01,"one second recovery delay")
  for i in fps*2: state.tick(1.0/fps,false)
  check(state.value>=30 and not state.running,"recovery never restarts run")
  state.toggle()
  check(state.running,"explicit toggle after threshold runs")
  state.restore({})
  check(state.value==100 and not state.running,"old payload defaults to full walk")
 var main: Node = load("res://scenes/main.tscn").instantiate()
 root.add_child(main)
 current_scene = main
 main.get_node("MenuLayer/MainMenu")._finish_opening()
 main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
 main.dialogue._finish()
 root.get_node("GameManager").complete_manager_intro()
 await create_timer(1).timeout
 var player: Node = main.get_node("World").get_child(0).get_node("Player")
 player.restore_stamina_state({"value":60})
 var game := root.get_node("GameManager")
 game.set_modal_open("RUN_TEST",true)
 player._physics_process(2)
 check(player.stamina.value==60 and not player.stamina.running,"modal freezes stamina and disables running")
 game.set_modal_open("RUN_TEST",false)
 var shift := InputEventKey.new()
 shift.physical_keycode = KEY_SHIFT
 shift.location = KEY_LOCATION_LEFT
 shift.pressed = true
 shift.echo = true
 player._input(shift)
 check(not player.stamina.running,"key echo does not toggle")
 shift.echo = false
 Input.action_press("interact")
 player._input(shift)
 check(not player.stamina.running,"held interaction cannot enable running")
 Input.action_release("interact")
 check(InputMap.has_action("toggle_run"),"independent InputMap action exists")
 player.set_physics_process(false)
 player.set_walk_bounds(-10000,10000)
 for fps in [30,60,120]:
  player.position.x = 0
  player.restore_stamina_state({})
  player.stamina.toggle()
  Input.action_press("move_right")
  for i in fps*3: player._physics_process(1.0/fps)
  Input.action_release("move_right")
  check(absf(player.position.x-648.0)<1.0,"actual player distance consistent at %d fps"%fps)
  check(not player.stamina.running,"actual player exhausts at %d fps"%fps)
 player.restore_stamina_state({"value":55})
 game._load_floor(2) # Explicit floor fixture, not a claim of legal stair navigation.
 for i in 6: await process_frame
 player = main.get_node("World").get_child(0).get_node("Player")
 check(is_equal_approx(player.stamina.value,55) and not player.stamina.running,"floor rebuild preserves stamina and defaults to walk")
 check(game.offer_task("TASK_01_CLEAN"),"offer actual checkpoint task")
 var monster: Node = main.get_node("TaskLayer/MonsterDialogue")
 for i in 50:
  if not monster.visible: break
  monster.advance()
 main.get_node("TaskLayer/MissionBoard").hide()
 check(game.accept_task("TASK_01_CLEAN"),"accept actual checkpoint task")
 var accepted: float = player.stamina.value
 player.restore_stamina_state({"value":2,"exhausted":true})
 game.request_task_failure("WRONG_CARD")
 check(game.retry_current_task(),"restore actual task checkpoint")
 player = main.get_node("World").get_child(0).get_node("Player")
 check(is_equal_approx(player.stamina.value,accepted) and not player.stamina.running,"retry restores acceptance stamina rather than refilling")
 game.start_game()
 player = main.get_node("World").get_child(0).get_node("Player")
 check(player.stamina.value==100 and not player.stamina.running,"new game refills stamina")
 print("RUN_STAMINA: ","PASS" if failures==0 else "FAIL")
 quit(0 if failures==0 else 1)
