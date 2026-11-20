extends Node
const Screen = preload("res://scenes/ui/monster_dialogue.gd")
var screen: Control
var _intro_shown := false
var _delivery_shown := false
var _eye_delivery_shown := false
var _new_intros: Dictionary = {}
var _new_deliveries: Dictionary = {}

func _ready() -> void:
	_setup.call_deferred()

func _setup() -> void:
	screen = Screen.new()
	screen.name = "MonsterDialogue"
	get_parent().add_child(screen)
	screen.dialogue_finished.connect(_finished)
	GameManager.task_offered.connect(_offered)
	GameManager.task_completed.connect(_completed)
	GameManager.state_changed.connect(_state_changed)

func _offered(task_id: String) -> void:
	if task_id in [GameManager.TUTORIAL_03_ID, GameManager.TUTORIAL_04_ID, GameManager.TUTORIAL_05_ID] and not _new_intros.has(task_id):
		if screen.show_dialogue(_monster_for_task(task_id) + ":INTRO"):
			_new_intros[task_id] = true
			get_parent().board.hide()
		return
	if task_id != "TASK_01_CLEAN" or _intro_shown or not is_instance_valid(screen) or not screen.is_node_ready(): return
	if screen.show_dialogue("NOSE:INTRO"):
		_intro_shown = true
		get_parent().board.hide()

func _finished(id: String) -> void:
	if screen.get("_preview"): return
	for task_id: String in _new_intros:
		if id == _monster_for_task(task_id) + ":INTRO" and GameManager.current_task_id == task_id and GameManager.task_status == "AVAILABLE":
			get_parent().open_offer(task_id)
			return
	if id == "EYE:INTRO":
		get_parent().get_parent()._on_dialogue_finished("TASK_02_INTRO")
		return
	if id == "NOSE:INTRO" and GameManager.game_state == "PLAYING" and GameManager.task_status == "AVAILABLE":
		get_parent().open_offer("TASK_01_CLEAN")

func _completed(task_id: String) -> void:
	if task_id in [GameManager.TUTORIAL_03_ID, GameManager.TUTORIAL_04_ID, GameManager.TUTORIAL_05_ID]:
		if not _new_deliveries.has(task_id) and screen.show_dialogue(_monster_for_task(task_id) + ":DELIVERED"):
			_new_deliveries[task_id] = true
		return
	if task_id == "TASK_02_PARCEL" and not _eye_delivery_shown:
		if screen.show_dialogue("EYE:DELIVERED"): _eye_delivery_shown = true
		return
	if task_id != "TASK_01_CLEAN" or _delivery_shown: return
	if screen.show_dialogue("NOSE:DELIVERED"):
		_delivery_shown = true

func show_task_reminder(task_id: String = "TASK_01_CLEAN") -> bool:
	var monster := _monster_for_task(task_id)
	if monster.is_empty(): return false
	var phase: String = screen.phase_for_task(task_id, GameManager.get_task_definition(task_id).get("required_card", ""))
	return not phase.is_empty() and screen.show_dialogue(monster + ":" + phase)

func _monster_for_task(task_id: String) -> String:
	for monster: String in Screen.TASKS:
		if Screen.TASKS[monster] == task_id: return monster
	return ""

func _state_changed(state: String) -> void:
	if state != "PLAYING" and is_instance_valid(screen):
		screen.cancel_dialogue()
	if state == "MENU":
		_intro_shown = false
		_delivery_shown = false
		_eye_delivery_shown = false

		_new_intros.clear()
		_new_deliveries.clear()
