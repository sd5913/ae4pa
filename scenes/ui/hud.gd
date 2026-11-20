extends PanelContainer

const CardDisplay = preload("res://scenes/ui/card_display.gd")
const ACTIVE_SLOT_FRAME := preload("res://assets/final/ui/hotel_interface/card_slot_active.png")
const INACTIVE_SLOT_FRAME := preload("res://assets/final/ui/hotel_interface/card_slot_inactive.png")
const ACTIVE_COLOR := Color(0.97, 0.72, 0.39)

@onready var _floor_value: Label = %FloorValue
@onready var _active_card_value: Label = %ActiveCardValue
@onready var _slot_a_value: Label = %SlotAValue
@onready var _slot_b_value: Label = %SlotBValue
@onready var _slot_art: Array[TextureRect] = [%SlotAArt, %SlotBArt]
@onready var _slot_frames: Array[TextureRect] = [%SlotAFrame, %SlotBFrame]
@onready var _objective: Label = %Objective
@onready var _remaining_time: Label = %RemainingTime
@onready var _task_title: Label = %TaskTitle
@onready var _notice: Label = %Notice
@onready var _notice_key: Label = %NoticeKey
@onready var _active_markers: Array[Label] = [%SlotAActive, %SlotBActive]
var _notice_source: Label
var _last_notice := ""

var _last_task_display := ""


func _ready() -> void:
	_notice_source = get_node_or_null("../../DeveloperOverlay/Margin/Info/Notice")
	if is_instance_valid(_notice_source):
		_notice_source.hide() # Keep A's source text intact; display it once inside HUD.
	%SwitchHint.text = "%s · %s" % [_action_key("switch_id"), tr("切换工作证")]
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


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh()


func _process(_delta: float) -> void:
	# Read A's authoritative clock for display; this UI does not advance a timer.
	_refresh_task_display()
	if is_instance_valid(_notice_source):
		set_notice(_notice_source.text)
	var interacting := false
	for child in %InteractionArea.get_children():
		interacting = interacting or child.visible
	%NoticeRow.visible = not interacting and not _notice.text.is_empty()
	%SwitchHint.visible = interacting or _notice_key.text.is_empty()


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
	var step: String = str(task_view.get("step", ""))
	# The task title has its own label; keep the target readable independently.
	var step_names := {"GET_CLEANER":"取得保洁工作证", "CLEAN_STAIN":"使用保洁身份清理污渍", "RETURN_TO_201":"返回 201 交付", "GET_SECURITY":"取得保安工作证", "PICKUP_PARCEL":"使用保安身份领取包裹", "RETURN_TO_202":"返回 202 交付包裹", "GET_MANAGER":"取得经理工作证", "EQUIP_MANAGER":"装备经理工作证", "AUTHORIZE_309":"使用经理身份批准 309 登记"}
	var objective := tr("当前无任务") if task_name.is_empty() else tr(step_names.get(step, "打开任务详情查看目标"))
	_apply_task_view(task_view, objective)


func _apply_task_view(view: Dictionary, objective: String) -> void:
	var status := str(view.get("status", "NONE"))
	var title := tr(str(view.get("name", "")))
	if title.is_empty(): title = tr("当前无任务")
	var states := {"NONE":"暂无任务", "AVAILABLE":"待接受", "ACTIVE":"进行中", "READY_TO_SUBMIT":"待交付", "COMPLETED":"已完成", "FAILED":"任务失败"}
	var meta := tr("状态：%s") % tr(states.get(status, status))
	if status in ["ACTIVE", "READY_TO_SUBMIT"]:
		var seconds := maxi(0, ceili(float(view.get("remaining_time", 0))))
		var clock := tr("剩余时间 %02d:%02d") % [seconds / 60, seconds % 60]
		meta = clock if status == "ACTIVE" else meta + " · " + clock
	elif status == "COMPLETED":
		title += " · " + tr("已完成")
		objective = _next_objective(str(view.get("task_id", "")))
	_task_title.text = title
	_apply_task_display(objective, meta)
	_remaining_time.self_modulate = Color("d7e5cf") if status == "COMPLETED" else Color.WHITE


func _next_objective(completed_id: String) -> String:
	if GameManager.has_friend: return tr("前往五楼消防出口，与帕希卡一起离开")
	# Read the real catalog and prerequisites. UI never opens or offers a task.
	var catalog: Dictionary = preload("res://scripts/task_definitions.gd").TASKS
	var completed: Array = GameManager.get_completed_task_ids()
	for id: String in catalog:
		var definition: Dictionary = GameManager.get_task_definition(id)
		var prerequisites: Array = definition.get("prerequisites", [])
		if not prerequisites.has(completed_id) or not GameManager.ENABLED_TASKS.has(id) or completed.has(id): continue
		var eligible := true
		for requirement: String in prerequisites:
			if requirement == "HAS_FRIEND": eligible = eligible and GameManager.has_friend
			elif requirement == "MANAGER_INTRO": eligible = eligible and GameManager.has_completed_manager_intro()
			else: eligible = eligible and completed.has(requirement)
		if eligible:
			return tr("下一步：前往 %dF · %s") % [definition["offer_floor"], definition["room_id"]]
	return tr("后续目标待主线接口提供")


func set_notice(message: String) -> void:
	var view: Dictionary = GameManager.get_task_view()
	var cache_key := message + str(view.get("status")) + str(view.get("step")) + CardManager.active_card
	if cache_key == _last_notice: return
	_last_notice = cache_key
	_notice.tooltip_text = message
	_notice_key.text = ""
	var normal_identity := RegEx.new()
	normal_identity.compile("^(\\d{3})需要当前(保安|保洁|经理)身份[；;]")
	var match_result := normal_identity.search(message)
	if match_result:
		_notice.text = "%s：需要%s身份" % [match_result.get_string(1), match_result.get_string(2)]
		_notice_key.text = "[ %s ] %s" % [_action_key("switch_id"), tr("切换工作证")]
		var definition: Dictionary = GameManager.get_task_definition(str(view.get("task_id", "")))
		if str(view.get("status")) in ["AVAILABLE", "ACTIVE", "READY_TO_SUBMIT"] and str(definition.get("room_id", "")) == match_result.get_string(1):
			_notice.text = _objective.text # A task barrier requires actual work/delivery.
			_notice_key.text = ""
		elif CardManager.active_card == {"保安":"SECURITY", "保洁":"CLEANER", "经理":"MANAGER"}.get(match_result.get_string(2)):
			_notice.text = "" # This exact identity requirement is already satisfied.
			_notice_key.text = ""
	else:
		# Keep full details on hover; preserve the first actual reason/action.
		_notice.text = message.split("；")[0].split(" · ")[0].split("，")[0]
	var text_width: float = _notice.get_theme_font("font").get_string_size(_notice.text, HORIZONTAL_ALIGNMENT_LEFT, -1, _notice.get_theme_font_size("font_size")).x
	_notice.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_notice.custom_minimum_size.x = minf(text_width + 8, 528)


func _action_key(action: String) -> String:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return OS.get_keycode_string(event.physical_keycode if event.physical_keycode != 0 else event.keycode)
	return tr("未绑定")


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
	_active_card_value.text = CardDisplay.name_for(active_card)
	for index: int in range(_slot_art.size()):
		var icon := _slot_art[index]
		icon.texture = CardDisplay.art_for(equipped[index])
		icon.visible = icon.texture != null
		_slot_frames[index].texture = (
			ACTIVE_SLOT_FRAME if active_card != "NONE" and active_slot == index else INACTIVE_SLOT_FRAME
		)
	_set_slot(_slot_a_value, equipped[0], active_card != "NONE" and active_slot == 0)
	_set_slot(_slot_b_value, equipped[1], active_card != "NONE" and active_slot == 1)
	for index in range(2):
		_active_markers[index].visible = active_card != "NONE" and active_slot == index


func _set_slot(label: Label, card_id: String, is_active: bool) -> void:
	var names := {"CLEANER":"保洁", "SECURITY":"保安", "MANAGER":"经理", "NONE":"未装备"}
	label.text = tr(names.get(card_id, CardDisplay.name_for(card_id)))
	label.self_modulate = ACTIVE_COLOR if is_active else Color.WHITE
