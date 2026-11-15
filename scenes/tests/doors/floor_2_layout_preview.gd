extends Node2D
## Art-only walk-through: no simulated task completion or monster rule checks.

var _cycle: bool = false
var _elapsed: float = 0.0


func _ready() -> void:
	GameManager.start_game()
	$Player.position = Vector2(240,560)
	$Player.set_walk_bounds(64,3536)
	$Player.get_node("Camera2D").limit_right = 3600
	$Player.get_node("Camera2D").reset_smoothing()
	_reference()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_F1:
		_reference()
	elif event.keycode == KEY_F2:
		_pose("CLOSED")
	elif event.keycode == KEY_F3:
		_pose("WARNING")
	elif event.keycode == KEY_F4:
		_pose("OPEN")
	elif event.keycode == KEY_F5:
		_cycle = true
		_elapsed = 0.0
		$Overlay/Status.text = "美术循环预览 · 仅切换贴图，不执行怪物判定"


func _reference() -> void:
	_cycle = false
	for room: int in range(201,206):
		$Floor2Art.get_node("Doors/Room%d" % room).set_state("WARNING" if room == 204 else "OPEN" if room == 205 else "CLOSED")
	$Overlay/Status.text = "原图状态：201—203 关闭 / 204 预警 / 205 开启"


func _pose(state: String) -> void:
	_cycle = false
	for art: Node in $Floor2Art/Doors.get_children():
		art.set_state(state)
	$Overlay/Status.text = "五门 %s · 仅美术预览" % state


func _process(delta: float) -> void:
	if not _cycle:
		return
	_elapsed = fposmod(_elapsed + delta,9.7)
	var state: String = "CLOSED" if _elapsed < 5.5 else "WARNING" if _elapsed < 6.9 else "OPEN"
	for art: Node in $Floor2Art/Doors.get_children():
		art.set_state(state)
