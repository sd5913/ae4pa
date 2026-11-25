extends SceneTree
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, label: String) -> void:
 print(("PASS: " if ok else "FAIL: ")+label)
 if not ok: failures += 1
func run() -> void:
 root.size = Vector2i(960,540) if "--english" in OS.get_cmdline_user_args() else Vector2i(1280,720)
 root.get_node("Localization").set_language("en" if "--english" in OS.get_cmdline_user_args() else "zh_CN")
 var main: Node = load("res://scenes/main.tscn").instantiate()
 root.add_child(main)
 current_scene = main
 main.get_node("MenuLayer/MainMenu")._finish_opening()
 main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
 main.dialogue._finish()
 var game := root.get_node("GameManager")
 game.complete_manager_intro()
 await create_timer(0.5).timeout
 var player: Node = main.get_node("World").get_child(0).get_node("Player")
 player.restore_stamina_state({})
 var origin: float = player.position.x
 var started := Time.get_ticks_msec()
 Input.action_press("move_right")
 while player.position.x-origin<480: await physics_frame
 print("WALK_480_SECONDS: ",(Time.get_ticks_msec()-started)/1000.0)
 Input.action_release("move_right")
 player.position.x = origin
 player.restore_stamina_state({})
 var shift := InputEventKey.new()
 shift.physical_keycode = KEY_SHIFT
 shift.location = KEY_LOCATION_LEFT
 shift.pressed = true
 player._input(shift)
 started = Time.get_ticks_msec()
 Input.action_press("move_right")
 while player.position.x-origin<480: await physics_frame
 print("RUN_480_SECONDS: ",(Time.get_ticks_msec()-started)/1000.0)
 await create_timer(1.2).timeout
 check(not player.stamina.running and player.stamina.exhausted,"exhaustion falls back to walking")
 var x: float = player.position.x
 await create_timer(0.5).timeout
 check(player.position.x>x,"exhaustion never forces player stationary")
 Input.action_release("move_right")
 await create_timer(3).timeout
 check(player.stamina.value>=30 and not player.stamina.running,"recovery leaves run off")
 player._input(shift)
 Input.action_press("move_left")
 await create_timer(1).timeout
 check(player.stamina.running and player.facing_direction==-1,"explicit toggle restarts run in last requested direction")
 Input.action_release("move_left")
 game.set_modal_open("STAMINA_REVIEW",true)
 var saved: float = player.stamina.value
 await create_timer(1.1).timeout
 check(player.stamina.value==saved and not player.stamina.running,"modal freezes drain and recovery")
 game.set_modal_open("STAMINA_REVIEW",false)
 await create_timer(0.2).timeout
 await RenderingServer.frame_post_draw
 var folder := OS.get_environment("RUN_EVIDENCE")
 if not folder.is_empty(): root.get_texture().get_image().save_png(folder.path_join("hud-en.png" if "--english" in OS.get_cmdline_user_args() else "hud-zh.png"))
 print("RUN_STAMINA_REVIEW: ","PASS" if failures==0 else "FAIL")
 quit(0 if failures==0 else 1)
