extends CanvasLayer
## D presentation adapter. Managers continue to own equipment, failure and retry facts.
const MODAL := "CAROL_UI_DIALOGUE"
const Pointer = preload("res://scenes/ui/story_pointer.gd")
const EQUIPMENT := [
	"身上只能同时挂两张证……倒是挺会限制人的。",
	"背包里还有位置，以后再拿到的证，就先收在那里。",
	"要换成别的身份，就打开背包，把要用的证换到装备栏里。",
	"身上这两张倒不用来回摘。按{switch_key}就能切换，亮着的那张才算数。行，记住了。",
]
const TIMEOUT_FIRST := "……时间到了？啧，还是慢了一步。"
const TIMEOUT_ACTIVE := "事情还没办完……得先把路线理清楚，不能再乱跑了。"
const TIMEOUT_READY := "明明已经做完了，却没赶上交付。下次得把回去的时间也算进去。"
const TIMEOUT_LAST := "不行，不能就这么算了。再来一次，这回得把路线记牢。"
var _main: Node
var _surface: Control
var _shade: ColorRect
var _pointer := Pointer.new()
var _lines: Array[String] = []
var _index := 0
var _mode := ""
var _tutorial_seen := false
var _pending_equipment := false
var _last_ready := false
var _guide: Control
var _hold_until := 0
var _timeout_presented := false

func _ready() -> void:
	layer = 25
	_bind.call_deferred()

func _bind() -> void:
	_main = get_parent()
	while _main != null and not _main.has_node("World"): _main = _main.get_parent()
	if _main == null: return
	_shade = ColorRect.new()
	_shade.color = Color(0,0,0,0.36)
	_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_shade)
	_surface = preload("res://scenes/ui/dialogue.tscn").instantiate()
	add_child(_surface)
	_surface.hide()
	_shade.hide()
	GameManager.game_failed.connect(_failed)
	GameManager.task_updated.connect(_observe_stage)
	GameManager.state_changed.connect(_state_changed)
	CardManager.cards_changed.connect(_cards_changed)
	_guide = _main.get_node_or_null("InteractionOnboarding/GuidePanel")
	if _guide != null: _guide.visibility_changed.connect(_suppress_old_equipment_hint)
	_cards_changed()
	_observe_stage()

func _suppress_old_equipment_hint() -> void:
	if _guide == null or not _guide.visible: return
	for child in _guide.get_children():
		if child is Label and child.text == tr("两个槽都已装备。关闭背包后按Q切当前身份；亮框表示生效的证件。"):
			_guide.hide()

func _observe_stage() -> void:
	var view: Dictionary = GameManager.get_task_view()
	if view.status in ["ACTIVE", "READY_TO_SUBMIT"]:
		_last_ready = view.status == "READY_TO_SUBMIT"
	elif view.status in ["NONE", "AVAILABLE"]:
		_last_ready = false

func _cards_changed() -> void:
	if not _tutorial_seen:
		_pending_equipment = CardManager.get_equipped_cards().filter(func(id): return id != "NONE").size() == 2

func _process(_delta: float) -> void:
	if _main == null or _surface == null: return
	if _pending_equipment and _mode.is_empty() and GameManager.is_world_input_allowed():
		if _main.get_node("MenuLayer/Bag").visible or _main.get_node("StoryLayer/Dialogue").visible: return
		if _main.get_node("TaskLayer/MonsterDialogue").visible: return
		_pending_equipment = false
		_tutorial_seen = true
		_start("equipment", EQUIPMENT)

func _failed(reason: String) -> void:
	if reason == "TASK_TIMEOUT": _start_timeout.call_deferred()

func _start_timeout() -> void:
	if GameManager.game_state != "FAILED" or GameManager.fail_reason != "TASK_TIMEOUT": return
	if _timeout_presented: return
	_timeout_presented = true
	if not _mode.is_empty(): _close(false)
	_start("timeout", [TIMEOUT_FIRST, TIMEOUT_READY if _last_ready else TIMEOUT_ACTIVE, TIMEOUT_LAST])
	# A has already configured the genuine retry/menu controls in this synchronous failure dispatch.
	_main.get_node("TaskLayer/Failure").hide()
	_main.get_node("TaskLayer/MissionBoard").hide()

func _start(mode: String, lines: Array) -> void:
	_mode = mode
	_lines.assign(lines)
	if mode == "equipment" and CardManager.get_owned_cards().size() >= 3:
		_lines[1] = "多拿到的工作证可以收在背包里，要用时再换上。"
	_index = 0
	_pointer.reset()
	_hold_until = Time.get_ticks_msec() + 180
	GameManager.set_modal_open(MODAL, true)
	_shade.show()
	_show_beat()

func _show_beat() -> void:
	var text := tr(_lines[_index])
	var key := ""
	for event in InputMap.action_get_events("switch_id"):
		if event is InputEventKey:
			key = OS.get_keycode_string(event.physical_keycode if event.physical_keycode else event.keycode)
			break
	_surface.present_character_beat("CAROL", text.replace("{switch_key}",key))
	_surface.mute_world_prompts()

func _input(event: InputEvent) -> void:
	if _mode.is_empty(): return
	var result: int = _pointer.feed(event, [_surface.get_node("%DialogueFrame").get_global_rect()], Time.get_ticks_msec() < _hold_until)
	if result == _pointer.ADVANCE:
		_index += 1
		if _index >= _lines.size(): _close(true)
		else: _show_beat()
	if result != _pointer.IGNORE: get_viewport().set_input_as_handled()

func _close(reveal_menu: bool) -> void:
	var was_timeout := _mode == "timeout"
	_mode = ""
	_surface.hide()
	_surface.restore_world_prompts()
	_shade.hide()
	_pointer.reset()
	GameManager.set_modal_open(MODAL, false)
	if reveal_menu and was_timeout and GameManager.game_state == "FAILED":
		_main.get_node("TaskLayer/Failure").show()
		_main.get_node("TaskLayer/Failure/%RetryButton").grab_focus()

func _state_changed(state: String) -> void:
	if state == "FAILED" and _mode == "equipment": _close(false)
	if state in ["PLAYING", "MENU", "RESTORING", "LOADING"]: _timeout_presented = false
	if state in ["MENU", "RESTORING", "LOADING"] and not _mode.is_empty(): _close(false)
	if state == "MENU":
		_tutorial_seen = false
		_pending_equipment = false
		_last_ready = false

func _exit_tree() -> void:
	GameManager.set_modal_open(MODAL, false)
