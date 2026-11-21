extends Control
## Display only. Every runtime phase is guarded by A's actual task facts.
signal dialogue_finished(dialogue_id: String)
const DATA_PATH := "res://scenes/ui/monster_dialogues.json"
const MODAL_ID := "MONSTER_DIALOGUE"
const TASKS := {"NOSE": "TASK_01_CLEAN", "EYE": "TASK_02_PARCEL", "HAT": "TASK_T03_ROOM_SERVICE", "EAR": "TASK_T04_DUAL_WORK", "CHECKER": "TASK_T05_TRANSIT"}
var _id := ""
var _index := 0
var _lines: Array = []
var _preview := false
var _speaker := Label.new()
var _body := Label.new()
var _panel: PanelContainer
var _pointer := preload("res://scenes/ui/story_pointer.gd").new()
var _caption := Label.new()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = preload("res://scenes/ui/staff_ui_theme.tres")
	var panel := PanelContainer.new()
	_panel = panel
	add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.anchor_left = 0.1
	panel.anchor_right = 0.9
	panel.offset_top = -290
	panel.offset_bottom = -20
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var content := VBoxContainer.new()
	panel.add_child(content)
	content.add_theme_constant_override("separation", 8)
	content.add_child(_caption)
	_caption.add_theme_font_size_override("font_size", 14)
	content.add_child(_speaker)
	_speaker.add_theme_color_override("font_color", Color("e9bd6b"))
	content.add_child(_body)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.custom_minimum_size.y = 72
	_body.add_theme_font_size_override("font_size", 22)
	hide()

func data() -> Dictionary:
	var value = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	return value if value is Dictionary else {}

func phase_for_201() -> String:
	return phase_for_task("TASK_01_CLEAN", "CLEANER")

func phase_for_task(task_id: String, card_id: String) -> String:
	var view := GameManager.get_task_view()
	if GameManager.get_completed_task_ids().has(task_id): return "COMPLETED"
	if GameManager.can_offer_task(task_id): return "INTRO"
	if view.get("task_id") != task_id: return ""
	match view.get("status"):
		"AVAILABLE": return "INTRO"
		"READY_TO_SUBMIT": return "RETURN"
		"ACTIVE":
			var definition := GameManager.get_task_definition(task_id)
			var required: Array = definition.get("required_cards", [card_id])
			if not required.all(func(card: String): return CardManager.has_card(card)):
				return "MISSING_CARD"
			if required.size() > 1 and not GameManager.has_required_equipment(task_id): return "MISSING_CARD"
			var flags := GameManager.get_world_flags()
			if task_id == "TASK_T04_DUAL_WORK":
				if flags.get("stain_204_cleaned", false): return "CLEAN_ONLY"
				if flags.get("tutorial_patrol_collected", false): return "RECORD_ONLY"
			if task_id == "TASK_T05_TRANSIT" and flags.get("transit_205_collected", false):
				return "PICKUP_ONLY" if CardManager.active_card == "MANAGER" else "WRONG_IDENTITY"
			return "WORK_PENDING"
	return ""

func show_dialogue(dialogue_id: String) -> bool:
	var parts := dialogue_id.split(":")
	if parts.size() != 2 or not TASKS.has(parts[0]): return false
	var task_id: String = TASKS[parts[0]]
	var actual := phase_for_task(task_id, GameManager.get_task_definition(task_id).get("required_card", ""))
	if parts[1] == "DELIVERED":
		if actual != "COMPLETED": return false
	elif actual != parts[1]: return false
	return _open(dialogue_id, false)

func preview_dialogue(dialogue_id: String) -> bool:
	return _open(dialogue_id, true)

func _open(dialogue_id: String, preview: bool) -> bool:
	if visible: return false
	var parts := dialogue_id.split(":")
	if parts.size() != 2: return false
	var rows: Array = data().get(parts[0], {}).get(parts[1], [])
	if rows.is_empty(): return false
	_id = dialogue_id
	_lines = rows
	_index = 0
	_preview = preview
	_caption.text = "独立文案预览 · 尚未接入该任务" if preview else "住客交谈"
	GameManager.set_modal_open(MODAL_ID, true)
	show()
	_render()
	return true

func _render() -> void:
	_speaker.text = _lines[_index][0]
	_body.text = _lines[_index][1]

func advance() -> void:
	if _id.is_empty() or not visible: return
	if _index + 1 < _lines.size():
		_index += 1
		_render()
		return
	var finished := _id
	_id = ""
	hide()
	# Consumer registers the next modal synchronously before this one is released.
	dialogue_finished.emit(finished)
	GameManager.set_modal_open(MODAL_ID, false)
	get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if not visible or _id.is_empty(): return
	var surfaces: Array[Rect2] = [_panel.get_global_rect()]
	var result: int = _pointer.feed(event, surfaces)
	if result == _pointer.ADVANCE:
		advance()
	if result != _pointer.IGNORE:
		get_viewport().set_input_as_handled()

func cancel_dialogue() -> void:
	_id = ""
	hide()
	GameManager.set_modal_open(MODAL_ID, false)

func _exit_tree() -> void:
	GameManager.set_modal_open(MODAL_ID, false)
