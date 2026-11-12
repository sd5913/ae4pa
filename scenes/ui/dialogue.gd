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
const V4_INTRO_ID := "V4_INTRO"
const V4_MANAGER_ID := "V4_MANAGER_TALK"
const SCRIPT_PATH := "res://scenes/ui/intro_script.tsv"
const DEFAULT_PROGRESS_PATH := "user://intro_progress.cfg"
const BACKGROUNDS := {
	"bedroom": preload("res://assets/final/ui/visual_novel/bedroom_rain.png"),
	"cafe": preload("res://assets/final/ui/visual_novel/cafe_sunset.png"),
	"exterior": preload("res://assets/final/ui/visual_novel/hotel_exterior_rain.png"),
	"lobby": preload("res://assets/final/ui/visual_novel/hotel_lobby.png"),
}
const PROTAGONIST_SHEET := preload("res://assets/final/ui/visual_novel/protagonist_expressions.png")
const FRIEND_SHEET := preload("res://assets/final/ui/visual_novel/friend_expressions.png")
const MANAGER_PORTRAIT := preload("res://assets/final/ui/visual_novel/manager_portrait.png")
const DIALOGUE_FRAME := preload("res://assets/final/ui/visual_novel/dialogue_frame.png")
const FACE_INDEX := {
	"pensive": 0,
	"worried": 1,
	"surprised": 2,
	"suspicious": 3,
	"determined": 4,
	"relieved": 5,
	"calm": 0,
	"happy": 1,
	"teasing": 2,
	"anxious": 3,
	"afraid": 4,
	"concerned": 1,
	"curious": 0,
	"neutral": 0,
}

var _dialogue_id := ""
var _lines: Array[String] = []
var _beats: Array[Dictionary] = []
var _line_index := 0
var _progress_path := DEFAULT_PROGRESS_PATH
var _current_scene := ""
var _transition_in_progress := false
var _skip_transitions := false

@onready var _background: TextureRect = %Background
@onready var _fade: ColorRect = %Fade
@onready var _portrait: TextureRect = %Portrait
@onready var _frame: TextureRect = %DialogueFrame
@onready var _speaker: Label = %Speaker
@onready var _line: Label = %Line
@onready var _cue: Label = %StageCue
@onready var _continue_button: Button = %ContinueButton
@onready var _skip_button: Button = %SkipButton
@onready var _sms_panel: PanelContainer = %SMSPanel
@onready var _sms_history: VBoxContainer = %SMSHistory
@onready var _sms_scroll: ScrollContainer = %SMSScroll
@onready var _title_label: Label = %TitleLabel


func _ready() -> void:
	visible = false
	_skip_transitions = "--ui-smoke" in OS.get_cmdline_user_args()
	_continue_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _dialogue_id.is_empty() or _transition_in_progress:
		return
	var mouse_advance: bool = false
	if event is InputEventMouseButton:
		mouse_advance = event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	var key_advance: bool = event.is_action_pressed("interact") and not event.is_echo()
	if mouse_advance or key_advance:
		_advance()
		get_viewport().set_input_as_handled()


func show_dialogue(dialogue_id: String) -> void:
	var old_scene := _current_scene
	_dialogue_id = dialogue_id
	_line_index = 0
	_lines.clear()
	_beats.clear()
	for child: Node in _sms_history.get_children():
		child.queue_free()
	_title_label.hide()
	_cue.hide()
	match dialogue_id:
		"INTRO":
			_lines = INTRO_LINES.duplicate()
			_speaker.text = "手机消息"
			_set_scene("bedroom", false)
			_show_line()
		"RESCUE_309":
			_lines = RESCUE_309_LINES.duplicate()
			_speaker.text = "闺蜜"
			_set_scene("lobby", false)
			_show_line()
		V4_INTRO_ID:
			_load_story_beats("bedroom", "exterior")
			if _beats.is_empty():
				_dialogue_id = ""
				return
			_set_scene(_beats[0].scene, old_scene != _beats[0].scene)
			_show_story_beat()
		V4_MANAGER_ID:
			_load_story_beats("lobby", "lobby")
			if _beats.is_empty():
				_dialogue_id = ""
				return
			_set_scene(_beats[0].scene, old_scene != _beats[0].scene)
			_show_story_beat()
		_:
			_dialogue_id = ""
			return
	_skip_button.visible = _can_skip_current_dialogue()
	if dialogue_id == V4_INTRO_ID:
		_skip_button.text = "跳过已读序章"
	elif dialogue_id == V4_MANAGER_ID:
		_skip_button.text = "跳过已读对白"
	else:
		_skip_button.text = "跳过"
	_continue_button.text = "继续"
	show()
	_continue_button.grab_focus()


func has_completed_intro() -> bool:
	var config := ConfigFile.new()
	if config.load(_progress_path) != OK:
		return false
	return config.get_value("story", "intro_and_manager_read", false) == true


func set_progress_file_path_for_test(path: String) -> void:
	_progress_path = path


func set_skip_transitions_for_test(skip: bool) -> void:
	_skip_transitions = skip


func reset_progress_file_for_test() -> void:
	var absolute_path := ProjectSettings.globalize_path(_progress_path)
	if FileAccess.file_exists(_progress_path):
		DirAccess.remove_absolute(absolute_path)


func _can_skip_current_dialogue() -> bool:
	if _dialogue_id == V4_INTRO_ID or _dialogue_id == V4_MANAGER_ID:
		return has_completed_intro()
	return true


func _load_story_beats(start_scene: String, end_scene: String) -> void:
	var file := FileAccess.open(SCRIPT_PATH, FileAccess.READ)
	if file == null:
		push_error("Unable to open visual novel script: " + SCRIPT_PATH)
		return
	var current_section := ""
	while not file.eof_reached():
		var row := file.get_line().strip_edges()
		if row.is_empty() or row.begins_with("#"):
			continue
		var fields := row.split("\t")
		if fields.size() != 5:
			push_error("Invalid visual novel script row: " + row)
			continue
		var beat := {
			"scene": fields[0],
			"speaker": fields[1],
			"expression": fields[2],
			"mode": fields[3],
			"text": fields[4],
		}
		if fields[0] == "lobby":
			current_section = V4_MANAGER_ID
		elif current_section.is_empty():
			current_section = V4_INTRO_ID
		if current_section == _dialogue_id and fields[0] in [start_scene, "bedroom", "cafe", "exterior", "lobby"]:
			_beats.append(beat)
			if current_section == V4_INTRO_ID and fields[0] == end_scene and fields[3] == "title":
				current_section = V4_MANAGER_ID


func _show_line() -> void:
	_speaker.show()
	_line.show()
	_line.text = _lines[_line_index]
	_sms_panel.hide()
	_frame.show()
	_cue.hide()
	_portrait.hide()
	_title_label.hide()


func _show_story_beat() -> void:
	if _beats.is_empty() or _line_index >= _beats.size():
		return
	var beat: Dictionary = _beats[_line_index]
	var mode: String = beat.mode
	_speaker.visible = mode == "dialogue"
	_line.visible = mode == "dialogue"
	_speaker.text = beat.speaker
	_line.text = beat.text
	_cue.hide()
	_title_label.hide()
	if mode == "sms":
		_sms_panel.show()
		_frame.hide()
		_portrait.hide()
		_add_sms_message(str(beat.speaker), str(beat.text))
	elif mode == "cue":
		_sms_panel.hide()
		_frame.hide()
		_portrait.hide()
		_cue.text = "（" + str(beat.text) + "）"
		_cue.show()
	elif mode == "title":
		_sms_panel.hide()
		_frame.show()
		_portrait.hide()
		_title_label.text = str(beat.text)
		_title_label.show()
	else:
		_sms_panel.hide()
		_frame.show()
		_display_portrait(str(beat.speaker), str(beat.expression))


func _add_sms_message(speaker: String, text: String) -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var bubble := PanelContainer.new()
	bubble.custom_minimum_size = Vector2(220, 0)
	bubble.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if speaker == "闺蜜" else Control.SIZE_SHRINK_END
	var style := StyleBoxFlat.new()
	style.bg_color = Color("e9e2d3") if speaker == "闺蜜" else Color("638f8e")
	style.set_corner_radius_all(14)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	bubble.add_theme_stylebox_override("panel", style)
	var body := Label.new()
	body.text = text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_color_override("font_color", Color("142326") if speaker == "闺蜜" else Color("ffffff"))
	body.add_theme_font_size_override("font_size", 22)
	bubble.add_child(body)
	if speaker == "闺蜜":
		row.add_child(bubble)
		_add_sms_spacer(row)
	else:
		_add_sms_spacer(row)
		row.add_child(bubble)
	_sms_history.add_child(row)
	call_deferred("_scroll_sms_to_bottom")


func _add_sms_spacer(row: HBoxContainer) -> void:
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)


func _scroll_sms_to_bottom() -> void:
	_sms_scroll.scroll_vertical = int(_sms_scroll.get_v_scroll_bar().max_value)


func _display_portrait(speaker: String, expression: String) -> void:
	_portrait.show()
	if speaker == "女主":
		var index := int(FACE_INDEX.get(expression, 0))
		_portrait.texture = _atlas_cell(PROTAGONIST_SHEET, index)
		_portrait.position = Vector2(42, 80)
		_portrait.size = Vector2(430, 465)
		_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	elif speaker == "闺蜜":
		var index := int(FACE_INDEX.get(expression, 0))
		_portrait.texture = _atlas_cell(FRIEND_SHEET, index)
		_portrait.position = Vector2(42, 80)
		_portrait.size = Vector2(430, 465)
		_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	elif speaker == "经理":
		_portrait.texture = MANAGER_PORTRAIT
		_portrait.position = Vector2(65, 28)
		_portrait.size = Vector2(410, 540)
		_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	else:
		_portrait.hide()


func _atlas_cell(sheet: Texture2D, face_index: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	var row_index := 0 if face_index < 3 else 1
	atlas.region = Rect2((face_index % 3) * 512, row_index * 512, 512, 512)
	return atlas


func _set_scene(scene_id: String, fade: bool) -> void:
	if not BACKGROUNDS.has(scene_id):
		return
	_current_scene = scene_id
	if not fade or _skip_transitions:
		_background.texture = BACKGROUNDS[scene_id]
		_fade.color.a = 0.0
		return
	_transition_in_progress = true
	_fade.color.a = 0.0
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 1.0, 0.22).from(0.0)
	tween.tween_callback(func() -> void:
		_background.texture = BACKGROUNDS[scene_id]
		var reveal_tween := create_tween()
		reveal_tween.tween_property(_fade, "color:a", 0.0, 0.32).from(1.0)
		reveal_tween.finished.connect(func() -> void: _transition_in_progress = false, CONNECT_ONE_SHOT)
	)


func _advance() -> void:
	if _dialogue_id.is_empty() or _transition_in_progress:
		return
	if not _beats.is_empty():
		if _line_index + 1 < _beats.size():
			_line_index += 1
			var next_beat: Dictionary = _beats[_line_index]
			var scene_changed := str(next_beat.scene) != _current_scene
			if scene_changed:
				_set_scene(str(next_beat.scene), true)
			_show_story_beat()
			return
		_finish()
		return
	if _line_index + 1 < _lines.size():
		_line_index += 1
		_show_line()
		return
	_finish()


func _finish() -> void:
	if _dialogue_id.is_empty():
		return
	var finished_id := _dialogue_id
	_dialogue_id = ""
	if finished_id == V4_MANAGER_ID:
		_save_intro_read()
	hide()
	dialogue_finished.emit(finished_id)


func _save_intro_read() -> void:
	var config := ConfigFile.new()
	if config.load(_progress_path) != OK:
		config = ConfigFile.new()
	config.set_value("story", "intro_and_manager_read", true)
	var error := config.save(_progress_path)
	if error != OK:
		push_error("Unable to save completed intro state: " + error_string(error))


func _on_continue_pressed() -> void:
	_advance()


func _on_skip_pressed() -> void:
	if not _can_skip_current_dialogue():
		return
	_finish()
