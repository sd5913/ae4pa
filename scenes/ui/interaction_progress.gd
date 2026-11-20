extends VBoxContainer
## Displays the selected world component's snapshot. B owns all progress and time.

const PROGRESS_TRACK := preload("res://assets/final/ui/hotel_interface/progress_track.png")

const STATUS_TEXT := {
	"READY": "可交互", "BLOCKED": "暂不可用", "ACTIVE": "进行中",
}
const ACTION_TEXT := {"STEAL": "偷取", "CLEAN": "清理", "PICKUP": "领取", "AUTHORIZE": "批准"}
const BLOCK_TEXT := {
	"ALERTED": "员工已警觉", "CURIOUS": "员工正在观察", "OUT_OF_RANGE": "超出交互范围",
	"DISABLED": "交互暂不可用", "INELIGIBLE": "任务条件未满足", "STAFF_MOVING": "等员工停下",
	"PLAYER_MOVING": "先停下", "FRONT": "请到员工背后", "TASK_INACTIVE": "当前步骤未开放",
	"NO_PLAYER": "玩家尚未就绪", "WORLD_LOCKED": "当前无法操作", "WRONG_IDENTITY": "当前工作证不符合要求",
}

var _floor: Node
var _sources: Dictionary = {}
var _target_id := ""
var _status := ""
var _details := Label.new()
var _progress := ProgressBar.new()


func _ready() -> void:
	_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_details.theme_type_variation = &"HudMeta"
	_details.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_details.add_theme_color_override("font_outline_color", Color("292117"))
	_details.add_theme_constant_override("outline_size", 0)
	add_child(_details)
	_progress.max_value = 1.0
	_progress.step = 0.0
	_progress.custom_minimum_size.y = 6.0
	_progress.show_percentage = false
	_progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var track := StyleBoxTexture.new()
	track.texture = PROGRESS_TRACK
	track.texture_margin_left = 22
	track.texture_margin_right = 22
	track.texture_margin_top = 5
	track.texture_margin_bottom = 5
	_progress.add_theme_stylebox_override("background", track)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("d9ad62")
	fill.set_corner_radius_all(4)
	fill.expand_margin_top = -4.0
	fill.expand_margin_bottom = -4.0
	_progress.add_theme_stylebox_override("fill", fill)
	_progress.add_theme_color_override("font_color", Color("fff0ca"))
	_progress.add_theme_color_override("font_outline_color", Color("292117"))
	_progress.add_theme_constant_override("outline_size", 4)
	add_child(_progress)
	hide()
	GameManager.modal_changed.connect(_refresh_target)
	GameManager.state_changed.connect(_refresh_target.unbind(1))


func bind_floor(floor_node: Node) -> void:
	_disconnect_sources()
	_floor = floor_node
	_register_components(floor_node)
	_refresh_target()


func _register_components(node: Node) -> void:
	if node.has_method("get_interaction_state") and node.has_signal("interaction_state_changed"):
		var state: Dictionary = node.get_interaction_state()
		var target_id: String = state.get("target_id", "")
		if not target_id.is_empty() and not _sources.has(target_id):
			_sources[target_id] = node
			node.interaction_state_changed.connect(_on_interaction_state_changed.bind(node))
	for child in node.get_children():
		_register_components(child)


func _disconnect_sources() -> void:
	for source: Node in _sources.values():
		if is_instance_valid(source):
			source.interaction_state_changed.disconnect(_on_interaction_state_changed.bind(source))
	_sources.clear()
	_target_id = ""
	_status = ""
	hide()


func _process(_delta: float) -> void:
	# The floor's selected E target can change just by walking. Some readiness
	# reasons can also change without a component event (for example movement).
	_refresh_target()


func _refresh_target() -> void:
	var target_id := ""
	if GameManager.is_world_input_allowed() and is_instance_valid(_floor) and _floor.is_inside_tree():
		target_id = _floor.get_interaction_target_id()
	var changed := target_id != _target_id
	_target_id = target_id
	var source: Node = _sources.get(_target_id)
	if not is_instance_valid(source):
		hide()
	elif changed or _status != "ACTIVE":
		_display(source.get_interaction_state())


func _on_interaction_state_changed(target_id: String, state: Dictionary, source: Node) -> void:
	if not GameManager.is_world_input_allowed() or _sources.get(target_id) != source:
		return
	if not is_instance_valid(_floor) or not _floor.is_inside_tree() or _floor.get_interaction_target_id() != target_id:
		return
	if state.get("target_id") == target_id:
		_target_id = target_id
		_display(state)


func _display(state: Dictionary) -> void:
	_status = state["status"]
	if not STATUS_TEXT.has(_status):
		hide()
		return
	var kind: String = ACTION_TEXT.get(state["interaction_type"], state["interaction_type"])
	var reason: String = BLOCK_TEXT.get(state["block_reason"], state["block_reason"])
	if float(state["required_time"]) <= 0.0:
		_details.text = tr("%s · %s\n%s") % [tr(kind), tr(STATUS_TEXT[_status]), "按E操作" if state["block_reason"] == "READY" else tr(reason)]
		_progress.hide()
		show()
		return
	_progress.show()
	_details.text = tr("%s · %s · %s  %.2f / %.2f 秒") % [
		tr(kind), tr(STATUS_TEXT[_status]), tr(reason), state["elapsed"], state["required_time"],
	]
	_details.tooltip_text = _details.text + " · " + str(state.get("target_id", ""))
	_details.theme_type_variation = &"HudPrompt" if _status == "BLOCKED" else &"HudMeta"
	if _status == "BLOCKED":
		_details.text = tr("%s：%s") % [tr(kind), tr(reason)]
	_progress.value = state["progress"]
	show()


func _exit_tree() -> void:
	_disconnect_sources()
