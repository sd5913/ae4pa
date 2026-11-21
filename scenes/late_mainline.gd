extends Node
## A's thin adapter: reuse D's dialogue and success screens, never store task truth.
const MODAL := "LATE_TASK_STORY"
var _dialogue_id := ""
var _offer_after := ""
var _win: Control
@onready var main: Node = get_parent()

func _ready() -> void:
	main.get_node("StoryLayer/Dialogue").dialogue_finished.connect(_finished)
	GameManager.task_completed.connect(_completed)
	GameManager.game_won.connect(_won)
	GameManager.state_changed.connect(_state_changed)
	_win = load("res://scenes/ui/win.tscn").instantiate()
	main.get_node("MenuLayer").add_child(_win)
	_win.get_node("%StatisticsNote").hide() # Statistics are not part of this integration.
	_win.restart_requested.connect(main._start_session)
	_win.return_to_menu_requested.connect(main._show_menu)

func open_task_intro(task_id: String) -> void:
	if not GameManager.can_offer_task(task_id): return
	var definition := GameManager.get_task_definition(task_id)
	var lines: Array[String] = [definition["name"], definition["instructions"], "接受后限时180秒；工作完成仍需返回本房交付。"]
	_open("INTRO_" + definition["room_id"], task_id, lines, task_id)

func show_reminder(task_id: String) -> void:
	var definition := GameManager.get_task_definition(task_id)
	var completed := GameManager.get_completed_task_ids().has(task_id)
	if not completed and GameManager.current_task_id != task_id: return
	var line: String = GameManager.get_task_view()["step"]
	if completed:
		line = "巡房记录已交付，去五楼501办理离店。" if task_id == GameManager.TASK_04_ID else "离店单已交付，带Terese去右端消防出口。"
	_open("REMINDER_" + definition["room_id"], task_id, [line])

func _completed(task_id: String) -> void:
	if not GameManager.LATE_TASKS.has(task_id): return
	var definition := GameManager.get_task_definition(task_id)
	var line := "巡房记录已收到。4F通路已开放，可以上五楼办理离店。" if task_id == GameManager.TASK_04_ID else "离店手续已交付。现在可以带Terese去消防出口。"
	_open("DELIVERED_" + definition["room_id"], task_id, [line])

func _open(id: String, task_id: String, lines: Array[String], offer_after: String = "") -> void:
	if not _dialogue_id.is_empty() or GameManager.game_state != "PLAYING": return
	var dialogue: Control = main.get_node("StoryLayer/Dialogue")
	if dialogue.visible: return
	var room: String = GameManager.get_task_definition(task_id)["room_id"]
	# Open before freezing: the resident remains visible during the actual dialogue.
	var floor_node: Node = main.get_node("World").get_child(0)
	var door: Node = floor_node.get_node("DoorRoot/Room" + room + "/Door")
	for other: Node in floor_node.get("_doors"):
		other.set_managed_state("OPEN" if other == door else "CLOSED")
	floor_node.get("_door_scheduler").active = door
	_dialogue_id = "LATE_" + id
	_offer_after = offer_after
	GameManager.set_modal_open(MODAL, true)
	main.get_node("TaskLayer").hide()
	if not dialogue.show_task_dialogue(_dialogue_id, room + " · " + GameManager.get_task_definition(task_id)["name"], lines):
		_clear()

func _finished(id: String) -> void:
	if id != _dialogue_id: return
	var offer := _offer_after
	_dialogue_id = ""
	_offer_after = ""
	main.get_node("TaskLayer").show()
	# Register the offer modal before releasing ours; no input or timer frame leaks.
	if not offer.is_empty() and GameManager.can_offer_task(offer): GameManager.offer_task(offer)
	GameManager.set_modal_open(MODAL, false)

func _won() -> void:
	main.get_node("TaskLayer").close_views()
	main.get_node("TaskLayer").hide()
	_win.show_win()

func _state_changed(state: String) -> void:
	if state != "WON": _win.hide()
	if state in ["MENU", "FAILED", "RESTORING", "LOADING", "WON"]: _clear()

func _clear() -> void:
	if not _dialogue_id.is_empty():
		main.get_node("StoryLayer/Dialogue").hide()
		_dialogue_id = ""
		_offer_after = ""
	GameManager.set_modal_open(MODAL, false)

func _exit_tree() -> void:
	GameManager.set_modal_open(MODAL, false)
