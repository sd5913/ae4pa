extends Node2D
## TEST DOUBLE: five independent story mirrors, never a five-task game.
const Catalog = preload("res://scenes/doors/v4_door_catalog.gd")
var selected: Node2D
var status: Label


func _ready() -> void:
	GameManager.start_game()
	var player: HotelPlayer = $Corridor/Player
	$Corridor/DoorRoot.hide()
	status = Label.new()
	status.position = Vector2(100, 90)
	status.text = "TEST DOUBLE · A/D 移动 · T 接受 · Y 可交付 · E 请求 · R 重置镜像\n配置预览：5/1.5/3 秒；不是正式五任务／路障／安全点验证"
	add_child(status)
	var index: int = 0
	for room: String in ["201", "202", "303", "402", "503"]:
		var door: Node2D = preload("res://scenes/doors/monster_door.tscn").instantiate()
		Catalog.configure(door, room)
		door.position = Vector2(450 + index * 500, 560)
		add_child(door)
		door.setup(player)
		door.story_intercept_requested.connect(func(task: String, id: String):
			selected = door
			door.set_story_state("AVAILABLE")
			status.text = "TEST DOUBLE · " + id + " · " + task + "\nT 接受 / Y 可交付 / E 请求 / R 重置；无任务真值、工作或许可"
		)
		door.story_progress_requested.connect(func(task: String): status.text = "TEST DOUBLE · 进度提示 " + task)
		door.task_submit_requested.connect(func(task: String):
			door.set_story_state("COMPLETED")
			status.text = "TEST DOUBLE · 已收到交付请求 " + task + "；303 是否需要交付仍待 A 确认"
		)
		index += 1


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo() or selected == null:
		return
	if event is InputEventKey:
		match event.physical_keycode:
			KEY_T: selected.set_story_state("ACTIVE")
			KEY_Y: selected.set_story_state("READY_TO_SUBMIT")
			KEY_R: selected.set_story_state("NONE")
	if event.is_action_pressed("interact"):
		selected.request_interaction()
