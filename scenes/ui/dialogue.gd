extends Control

signal dialogue_finished(dialogue_id: String)

const INTRO_LINES: Array[String] = [
	"他们不让我离开……我在309号房。",
	"前往 309 房间，营救被困的同伴。",
]
const RESCUE_309_LINES: Array[String] = [
	"你终于来了！",
	"下面的路被封了，五楼有紧急出口！",
]
const MODAL_ID := "dialogue"

var _dialogue_id := ""
var _lines: Array[String] = []
var _line_index := 0

@onready var _speaker: Label = %Speaker
@onready var _line: Label = %Line
@onready var _continue_button: Button = %ContinueButton
@onready var _skip_button: Button = %SkipButton


func _ready() -> void:
	visibility_changed.connect(_sync_modal_state)
	_sync_modal_state()


func _sync_modal_state() -> void:
	if GameManager.has_method("set_modal_open"):
		GameManager.set_modal_open(MODAL_ID, visible)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not event.is_action_pressed("interact") or event.is_echo():
		return
	_advance()
	get_viewport().set_input_as_handled()


func show_dialogue(dialogue_id: String) -> void:
	match dialogue_id:
		"INTRO":
			_lines = INTRO_LINES.duplicate()
			_speaker.text = "手机消息"
		"RESCUE_309":
			_lines = RESCUE_309_LINES.duplicate()
			_speaker.text = "闺蜜"
		_:
			return
	_dialogue_id = dialogue_id
	_line_index = 0
	_refresh_line()
	show()
	_continue_button.grab_focus()


func _advance() -> void:
	if _line_index + 1 < _lines.size():
		_line_index += 1
		_refresh_line()
		return
	_finish()


func _finish() -> void:
	if _dialogue_id.is_empty():
		return
	var finished_id := _dialogue_id
	_dialogue_id = ""
	hide()
	dialogue_finished.emit(finished_id)


func _refresh_line() -> void:
	_line.text = _lines[_line_index]
	_continue_button.text = "继续"


func _on_continue_pressed() -> void:
	_advance()


func _on_skip_pressed() -> void:
	_finish()
