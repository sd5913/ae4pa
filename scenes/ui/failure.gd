extends Control

const MODAL_ID := "failure"
const THEFT_STORY_PATH := "res://assets/final/ui/theft_failure/story_cn_en.json"
const THEFT_ASSET_ROOT := "res://assets/final/ui/theft_failure/"
const STAFF_NAMES := {"SECURITY": "保安", "CLEANER": "保洁", "MANAGER": "经理"}
const THEFT_MIN_HOLD_SECONDS := 0.8

enum TheftPhase { IDLE, ENTERING, HOLDING, WAIT_FIRST, READING, EXITING }

signal retry_requested()
signal return_to_menu_requested()
signal presentation_finished(staff_role: String)

const REASON_TEXT := {
	"STAFF_CAUGHT": "偷窃被发现",
	"WRONG_CARD": "当前工作证不符合要求",
	"MOVED_NEAR_EAR": "大耳客开门时仍在移动",
	"SWITCHED_NEAR_CHECKER": "核验客面前更换了工作证",
}

var _theft_sequences: Dictionary = {}
var _theft_phase: TheftPhase = TheftPhase.IDLE
var _history_serial := 0
var _theft_role := ""
var _theft_lines: Array = []
var _theft_line_index := -1
var _pending_staff_role := ""
var _staff_sources: Array[Node] = []
var _theft_tween: Tween

@onready var _center: Control = $Center
@onready var _theft_overlay: Control = %TheftOverlay
@onready var _cg: TextureRect = %TheftCG
@onready var _dialogue_frame: Panel = %TheftDialogueFrame
@onready var _speaker: Label = %TheftSpeaker
@onready var _line: Label = %TheftLine
@onready var _prompt: Label = %TheftPrompt


func _ready() -> void:
	visibility_changed.connect(_sync_modal_state)
	_sync_modal_state()
	_load_theft_sequences()
	GameManager.game_failed.connect(_on_game_failed)
	GameManager.floor_changed.connect(_on_floor_changed)
	GameManager.state_changed.connect(_on_game_state_changed)
	_theft_overlay.gui_input.connect(_on_theft_overlay_gui_input)
	_theft_overlay.hide()
	_on_floor_changed(GameManager.current_floor)
	call_deferred("_bind_current_staff")


func _sync_modal_state() -> void:
	if GameManager.has_method("set_modal_open"):
		GameManager.call("set_modal_open", MODAL_ID, visible)


func show_failure(reason: String) -> void:
	%Reason.text = REASON_TEXT.get(reason, "未能通过检查")
	%RetryButton.text = "重试功能待 A 接入"
	%RetryButton.disabled = true
	%RetryButton.tooltip_text = "主场景尚未连接重试请求"
	show()
	if _theft_phase == TheftPhase.IDLE:
		%MenuButton.grab_focus()


## Called by this UI's staff-event observer or by A when routing a caught theft.
## staff_id must be the actual Staff.card_id (SECURITY/CLEANER/MANAGER).
func play_theft_failure(staff_id: String) -> bool:
	if _theft_phase != TheftPhase.IDLE:
		return false
	if not _theft_sequences.has(staff_id):
		return false
	var sequence: Dictionary = _theft_sequences[staff_id]
	var texture_path := THEFT_ASSET_ROOT + str(sequence.get("cg", ""))
	if not ResourceLoader.exists(texture_path):
		return false
	var texture := load(texture_path) as Texture2D
	var lines: Variant = sequence.get("lines", [])
	if texture == null or not lines is Array or lines.size() != 4:
		return false
	for beat: Variant in lines:
		if not beat is Dictionary or str(beat.get("zh", "")).is_empty() or str(beat.get("en", "")).is_empty():
			return false
	_history_serial += 1
	_theft_role = staff_id
	_theft_lines = lines
	_theft_line_index = -1
	_cg.texture = texture
	_cg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_cg.modulate.a = 1.0
	_theft_overlay.modulate.a = 0.0
	_dialogue_frame.hide()
	_center.hide()
	show()
	_theft_overlay.show()
	_theft_phase = TheftPhase.ENTERING
	_theft_tween = create_tween()
	_theft_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_theft_tween.tween_property(_theft_overlay, "modulate:a", 1.0, 0.26).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_theft_tween.finished.connect(_on_theft_fade_in_finished, CONNECT_ONE_SHOT)
	return true


func _load_theft_sequences() -> void:
	if not FileAccess.file_exists(THEFT_STORY_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(THEFT_STORY_PATH))
	if not parsed is Dictionary or not parsed.get("sequences", []) is Array:
		push_error("Invalid theft failure dialogue data: %s" % THEFT_STORY_PATH)
		return
	for sequence: Variant in parsed["sequences"]:
		if sequence is Dictionary:
			_theft_sequences[str(sequence.get("staff_role", ""))] = sequence


func _on_floor_changed(_floor_number: int) -> void:
	call_deferred("_bind_current_staff")


func _bind_current_staff() -> void:
	for staff: Node in _staff_sources:
		if is_instance_valid(staff):
			var previous_callback := Callable(self, "_on_staff_failure_requested").bind(staff)
			if staff.is_connected("task_failure_requested", previous_callback):
				staff.disconnect("task_failure_requested", previous_callback)
	_staff_sources.clear()
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return
	for candidate: Node in current_scene.find_children("*", "Node2D", true, false):
		if candidate.has_signal("task_failure_requested") and str(candidate.get("card_id")) in STAFF_NAMES:
			var callback := Callable(self, "_on_staff_failure_requested").bind(candidate)
			if not candidate.is_connected("task_failure_requested", callback):
				candidate.connect("task_failure_requested", callback)
			_staff_sources.append(candidate)


func _on_staff_failure_requested(reason: String, target_id: String, staff: Node) -> void:
	if reason != "STAFF_CAUGHT" or not is_instance_valid(staff):
		return
	if target_id != str(staff.get("target_id")):
		return
	_pending_staff_role = str(staff.get("card_id"))


func _on_game_failed(reason: String) -> void:
	if reason == "STAFF_CAUGHT":
		# The floor's listener requests the failure before our later staff observer
		# runs. Defer so the actual source card_id is captured before presentation.
		call_deferred("_begin_pending_theft_failure")


func _begin_pending_theft_failure() -> void:
	var staff_id := _pending_staff_role
	_pending_staff_role = ""
	if staff_id.is_empty() or not play_theft_failure(staff_id):
		# Missing identity, image, or dialogue safely falls back to the existing menu.
		show_failure("STAFF_CAUGHT")


func _on_theft_fade_in_finished() -> void:
	if _theft_phase != TheftPhase.ENTERING:
		return
	_theft_phase = TheftPhase.HOLDING
	await get_tree().create_timer(THEFT_MIN_HOLD_SECONDS, true, false, true).timeout
	if _theft_phase == TheftPhase.HOLDING:
		_theft_phase = TheftPhase.WAIT_FIRST
		_prompt.text = tr("点击对话框或按 E")
		_prompt.show()


func _on_theft_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if event.device == InputEvent.DEVICE_ID_EMULATION:
			_theft_overlay.accept_event()
			return
		if _theft_phase == TheftPhase.WAIT_FIRST or _theft_phase == TheftPhase.READING:
			if _dialogue_frame.get_global_rect().has_point(event.position):
				_advance_theft_dialogue()
		_theft_overlay.accept_event()
	elif event is InputEventScreenTouch and event.pressed:
		if event.device == InputEvent.DEVICE_ID_EMULATION:
			_theft_overlay.accept_event()
			return
		if _theft_phase == TheftPhase.WAIT_FIRST or _theft_phase == TheftPhase.READING:
			if _dialogue_frame.get_global_rect().has_point(event.position):
				_advance_theft_dialogue()
		_theft_overlay.accept_event()


func _input(event: InputEvent) -> void:
	if preload("res://scenes/ui/memory_ui.gd").is_open(): return
	if _theft_phase == TheftPhase.IDLE:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.is_action_pressed("interact"):
			if _theft_phase in [TheftPhase.WAIT_FIRST, TheftPhase.READING]:
				_advance_theft_dialogue()
			get_viewport().set_input_as_handled()


func _advance_theft_dialogue() -> void:
	if _theft_phase == TheftPhase.WAIT_FIRST:
		_theft_line_index = 0
		_theft_phase = TheftPhase.READING
		_dialogue_frame.show()
		_prompt.show()
		_update_theft_line()
		return
	if _theft_phase != TheftPhase.READING:
		return
	_theft_line_index += 1
	if _theft_line_index >= _theft_lines.size():
		_finish_theft_presentation()
		return
	_update_theft_line()


func _update_theft_line() -> void:
	var beat: Dictionary = _theft_lines[_theft_line_index]
	var speaker_id := str(beat.get("speaker", ""))
	var display_name: String = "Carol" if speaker_id == "Carol" else TranslationServer.translate(str(STAFF_NAMES.get(speaker_id, speaker_id)))
	_record_history.call_deferred(_theft_line_index,_history_serial)
	_speaker.text = display_name
	_line.text = tr(str(beat.get("zh", "")))
	_prompt.text = tr("点击对话框或按 E")


func _finish_theft_presentation() -> void:
	if _theft_phase != TheftPhase.READING:
		return
	_theft_phase = TheftPhase.EXITING
	_prompt.hide()
	_theft_tween = create_tween()
	_theft_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_theft_tween.tween_property(_theft_overlay, "modulate:a", 0.0, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_theft_tween.finished.connect(_on_theft_fade_out_finished, CONNECT_ONE_SHOT)


func _on_theft_fade_out_finished() -> void:
	var finished_role := _theft_role
	_theft_overlay.hide()
	_theft_phase = TheftPhase.IDLE
	_center.show()
	# A has already configured the genuine failure title and checkpoint buttons.
	show()
	presentation_finished.emit(finished_role)


func _on_game_state_changed(state: String) -> void:
	if state in ["MENU", "LOADING", "PLAYING"] and _theft_phase != TheftPhase.IDLE:
		_cancel_theft_presentation()
	elif state in ["MENU", "LOADING", "PLAYING"]:
		_pending_staff_role = ""
		hide()


func _cancel_theft_presentation() -> void:
	if _theft_tween != null and _theft_tween.is_running():
		_theft_tween.kill()
	_theft_phase = TheftPhase.IDLE
	_theft_role = ""
	_theft_lines.clear()
	_theft_line_index = -1
	_theft_overlay.hide()
	_dialogue_frame.hide()
	_center.show()
	hide()
	_pending_staff_role = ""


func configure_retry(available: bool, message: String) -> void:
	%RetryButton.text = "重新挑战本任务"
	%RetryButton.disabled = not available
	%RetryButton.tooltip_text = message
	if visible and available:
		%RetryButton.grab_focus()


func _on_retry_pressed() -> void:
	if %RetryButton.disabled:
		return
	retry_requested.emit()


func _on_return_to_menu_pressed() -> void:
	return_to_menu_requested.emit()


func _exit_tree() -> void:
	if GameManager.game_failed.is_connected(_on_game_failed):
		GameManager.game_failed.disconnect(_on_game_failed)
	if GameManager.floor_changed.is_connected(_on_floor_changed):
		GameManager.floor_changed.disconnect(_on_floor_changed)
	if GameManager.state_changed.is_connected(_on_game_state_changed):
		GameManager.state_changed.disconnect(_on_game_state_changed)
	for staff: Node in _staff_sources:
		if is_instance_valid(staff):
			var callback := Callable(self, "_on_staff_failure_requested").bind(staff)
			if staff.is_connected("task_failure_requested", callback):
				staff.disconnect("task_failure_requested", callback)
	if GameManager.has_method("set_modal_open"):
		GameManager.call("set_modal_open", MODAL_ID, false)

func _record_history(index: int, serial: int) -> void:
	if _theft_phase != TheftPhase.READING or _theft_line_index != index or _history_serial != serial: return
	var beat: Dictionary = _theft_lines[index]
	preload("res://scenes/ui/memory_history.gd").record("theft:%d:%d:%d" % [get_instance_id(),serial,index],str(beat.speaker),str(beat.zh),"STAFF_CAUGHT")
