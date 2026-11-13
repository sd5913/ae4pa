extends PanelContainer

const ACTIVE_COLOR := Color(0.97, 0.72, 0.39)
const CARD_NAMES := {
	"NONE": "未装备",
	"SECURITY": "保安工作证",
	"CLEANER": "保洁工作证",
	"MANAGER": "经理工作证",
}

@onready var _floor_value: Label = %FloorValue
@onready var _active_card_value: Label = %ActiveCardValue
@onready var _slot_a_value: Label = %SlotAValue
@onready var _slot_b_value: Label = %SlotBValue
@onready var _objective: Label = %Objective
@onready var _remaining_time: Label = %RemainingTime

var _last_task_display := ""


func _ready() -> void:
	GameManager.state_changed.connect(_refresh_floor.unbind(1))
	# The foundation exposes the floor value before the floor transition signal.
	if GameManager.has_signal(&"floor_changed"):
		GameManager.connect(&"floor_changed", _refresh_floor.unbind(1))
	CardManager.cards_changed.connect(_refresh_cards)
	if GameManager.has_signal("task_updated"):
		GameManager.connect("task_updated", _refresh_task_display)
	if GameManager.has_signal("task_offered"):
		GameManager.connect("task_offered", _refresh_task_display.unbind(1))
	if GameManager.has_signal("task_completed"):
		GameManager.connect("task_completed", _refresh_task_display.unbind(1))
	if GameManager.has_signal("task_failed"):
		GameManager.connect("task_failed", _refresh_task_display.unbind(2))
	visibility_changed.connect(_on_visibility_changed)
	_refresh()


func _process(_delta: float) -> void:
	# Read A's authoritative clock for display; this UI does not advance a timer.
	_refresh_task_display()


func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		_refresh()


func _refresh() -> void:
	_refresh_floor()
	_refresh_cards()
	_refresh_task_display()


func _refresh_floor() -> void:
	_floor_value.text = "%dF" % GameManager.current_floor


func _refresh_task_display() -> void:
	if not GameManager.has_method("get_task_view"):
		_apply_task_display("任务数据待 A 接口同步", "剩余时间：待 A 接口同步")
		return
	var task_view: Dictionary = GameManager.call("get_task_view")
	var task_name: String = str(task_view.get("name", ""))
	var location: String = str(task_view.get("location", ""))
	var status: String = str(task_view.get("status", ""))
	var target_id: String = str(task_view.get("target_id", ""))
	var step: String = str(task_view.get("step", ""))
	var objective := "当前无任务" if task_name.is_empty() else "%s · %s" % [task_name, location]
	if not target_id.is_empty():
		objective += "\n目标：%s · %s" % [target_id, step]
	var remaining_time: float = float(task_view.get("remaining_time", 0.0))
	var total_seconds := maxi(0, ceili(remaining_time))
	var formatted_time := "剩余时间：%d:%02d · %s" % [total_seconds / 60, total_seconds % 60, status]
	_apply_task_display(objective, formatted_time)


func _apply_task_display(objective: String, remaining_time: String) -> void:
	var display := objective + "\n" + remaining_time
	if display == _last_task_display:
		return
	_last_task_display = display
	_objective.text = objective
	_remaining_time.text = remaining_time


func _refresh_cards() -> void:
	var active_card: String = CardManager.active_card
	var active_slot: int = CardManager.active_slot
	var equipped: Array[String] = CardManager.get_equipped_cards()
	_active_card_value.text = _card_name(active_card)
	_set_slot(_slot_a_value, equipped[0], active_card != "NONE" and active_slot == 0)
	_set_slot(_slot_b_value, equipped[1], active_card != "NONE" and active_slot == 1)


func _set_slot(label: Label, card_id: String, is_active: bool) -> void:
	var card_name: String = _card_name(card_id)
	label.text = card_name + " · 生效" if is_active else card_name
	label.self_modulate = ACTIVE_COLOR if is_active else Color.WHITE


func _card_name(card_id: String) -> String:
	return str(CARD_NAMES.get(card_id, "未知工作证"))
