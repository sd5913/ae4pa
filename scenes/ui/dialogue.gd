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
const FRIEND_PORTRAIT_SHEET := preload("res://assets/final/ui/visual_novel/friend_expressions.png")
const MODAL_ID := "dialogue"

var _dialogue_id := ""
var _lines: Array[String] = []
var _line_index := 0

@onready var _speaker: Label = %Speaker
@onready var _line: Label = %Line
@onready var _continue_button: Button = %ContinueButton
@onready var _skip_button: Button = %SkipButton
var _friend_portrait: TextureRect


func _ready() -> void:
	visibility_changed.connect(_sync_modal_state)
	_friend_portrait = TextureRect.new()
	_friend_portrait.name = "FriendPortrait"
	_friend_portrait.position = Vector2(24, 142)
	_friend_portrait.size = Vector2(225, 430)
	_friend_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_friend_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_friend_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_friend_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_friend_portrait.texture = _friend_portrait_texture()
	_friend_portrait.hide()
	add_child(_friend_portrait)
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
	_friend_portrait.visible = _dialogue_id == "RESCUE_309"


func _friend_portrait_texture() -> AtlasTexture:
	var portrait := AtlasTexture.new()
	portrait.atlas = FRIEND_PORTRAIT_SHEET
	portrait.region = Rect2(0, 0, 512, 512)
	return portrait


func _on_continue_pressed() -> void:
	_advance()


func _on_skip_pressed() -> void:
	_finish()
