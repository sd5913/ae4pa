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
const AN_AVATAR := preload("res://assets/final/ui/hotel_interface/avatar_an.png")
const FRIEND_AVATAR := preload("res://assets/final/ui/hotel_interface/avatar_friend.png")
const FRIEND_SHEET := preload("res://assets/final/ui/visual_novel/friend_expressions.png")
const PORTRAIT_ROLES := {"女主": "an", "安": "an", "Carol": "an", "保洁": "cleaner", "保安": "security", "经理": "manager"}
const EXPRESSION_ALIASES := {
	"calm": "neutral", "pensive": "neutral", "curious": "neutral",
	"happy": "smile", "teasing": "smile", "relieved": "smile",
	"concerned": "worried", "anxious": "worried", "afraid": "worried",
	"determined": "stern",
}
const ROLE_PORTRAITS := {
	"an": {
		"neutral": preload("res://assets/final/ui/dialogue_portraits/an/an_neutral.png"),
		"smile": preload("res://assets/final/ui/dialogue_portraits/an/an_smile.png"),
		"surprised": preload("res://assets/final/ui/dialogue_portraits/an/an_surprised.png"),
		"worried": preload("res://assets/final/ui/dialogue_portraits/an/an_worried.png"),
		"suspicious": preload("res://assets/final/ui/dialogue_portraits/an/an_suspicious.png"),
		"stern": preload("res://assets/final/ui/dialogue_portraits/an/an_stern.png"),
	},
	"cleaner": {
		"neutral": preload("res://assets/final/ui/dialogue_portraits/cleaner/cleaner_neutral.png"),
		"smile": preload("res://assets/final/ui/dialogue_portraits/cleaner/cleaner_smile.png"),
		"surprised": preload("res://assets/final/ui/dialogue_portraits/cleaner/cleaner_surprised.png"),
		"worried": preload("res://assets/final/ui/dialogue_portraits/cleaner/cleaner_worried.png"),
		"suspicious": preload("res://assets/final/ui/dialogue_portraits/cleaner/cleaner_suspicious.png"),
		"stern": preload("res://assets/final/ui/dialogue_portraits/cleaner/cleaner_stern.png"),
	},
	"security": {
		"neutral": preload("res://assets/final/ui/dialogue_portraits/security/security_neutral.png"),
		"smile": preload("res://assets/final/ui/dialogue_portraits/security/security_smile.png"),
		"surprised": preload("res://assets/final/ui/dialogue_portraits/security/security_surprised.png"),
		"worried": preload("res://assets/final/ui/dialogue_portraits/security/security_worried.png"),
		"suspicious": preload("res://assets/final/ui/dialogue_portraits/security/security_suspicious.png"),
		"stern": preload("res://assets/final/ui/dialogue_portraits/security/security_stern.png"),
	},
	"manager": {
		"neutral": preload("res://assets/final/ui/dialogue_portraits/manager/manager_neutral.png"),
		"smile": preload("res://assets/final/ui/dialogue_portraits/manager/manager_smile.png"),
		"surprised": preload("res://assets/final/ui/dialogue_portraits/manager/manager_surprised.png"),
		"worried": preload("res://assets/final/ui/dialogue_portraits/manager/manager_worried.png"),
		"suspicious": preload("res://assets/final/ui/dialogue_portraits/manager/manager_suspicious.png"),
		"stern": preload("res://assets/final/ui/dialogue_portraits/manager/manager_stern.png"),
	},
}
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
var _pointer := preload("res://scenes/ui/story_pointer.gd").new()
var _portrait_cache: Dictionary = {}
var _phone_waiting_for_open := false
var _phone_tween: Tween

@onready var _background: TextureRect = %Background
@onready var _fade: ColorRect = %Fade
@onready var _portrait: TextureRect = %Portrait
@onready var _frame: Panel = %DialogueFrame
@onready var _speaker: Label = %Speaker
@onready var _line: Label = %Line
@onready var _cue: Label = %StageCue
@onready var _skip_button: Button = %SkipButton
@onready var _sms_panel: Control = %SMSPanel
@onready var _phone_screen: Control = %PhoneScreen
@onready var _phone_chat: VBoxContainer = %PhoneChat
@onready var _phone_notification: PanelContainer = %PhoneNotification
@onready var _vibration_marks: TextureRect = %VibrationMarks
@onready var _sms_history: VBoxContainer = %SMSHistory
@onready var _sms_scroll: ScrollContainer = %SMSScroll
@onready var _story_title: TextureRect = %StoryTitle


func _ready() -> void:
	visible = false
	_skip_transitions = "--ui-smoke" in OS.get_cmdline_user_args()
	resized.connect(_fit_dialogue_text.call_deferred)
	_line.resized.connect(_fit_dialogue_text.call_deferred)


func _notification(what: int) -> void:
	if what != NOTIFICATION_TRANSLATION_CHANGED or not is_node_ready():
		return
	for row: Control in _sms_history.get_children():
		_size_sms_body(row.get_node("Bubble/Body"))
	if _sms_history.get_child_count() > 0:
		_scroll_sms_to_message(_sms_history.get_child(-1))
	if _cue.visible and not _beats.is_empty():
		_refresh_stage_cue()
	_fit_dialogue_text.call_deferred()


func _fit_dialogue_text() -> void:
	if not is_node_ready() or not _line.visible or not _frame.visible:
		return
	# Grow paragraphs within the panel, independent of the removed action button.
	var bottom := minf(size.y * 0.91, _skip_button.position.y - 16.0) if _skip_button.visible else size.y * 0.91
	var top := minf(size.y * 0.763, bottom - _line.get_minimum_size().y)
	_line.offset_top = top - size.y * _line.anchor_top
	_line.offset_bottom = bottom - size.y * _line.anchor_bottom
	_frame.offset_top = minf(0.0, top - 32.0 - size.y * _frame.anchor_top)
	_speaker.offset_top = _frame.position.y - 28.0 - size.y * _speaker.anchor_top
	_speaker.offset_bottom = _frame.position.y + 24.0 - size.y * _speaker.anchor_bottom
	if _portrait.texture != null:
		var height := minf(size.y * 0.52, size.x * 0.265 / _portrait.texture.get_width() * _portrait.texture.get_height())
		var width := height * _portrait.texture.get_width() / _portrait.texture.get_height()
		_portrait.offset_right = size.x * _portrait.anchor_left + width - size.x * _portrait.anchor_right
		_portrait.offset_top = size.y * 0.95 - height - size.y * _portrait.anchor_top
		var name_left := maxf(size.x * 0.25, _portrait.position.x + width + 20.0)
		_speaker.offset_left = name_left - size.x * _speaker.anchor_left
		_speaker.offset_right = name_left + maxf(128.0, _speaker.get_minimum_size().x + 24.0) - size.x * _speaker.anchor_right


func _refresh_stage_cue() -> void:
	_cue.text = tr("（%s）") % tr(_beats[_line_index].text)


func _input(event: InputEvent) -> void:
	if not visible or _dialogue_id.is_empty():
		return
	# Skip owns its gesture and must not also advance the story underneath.
	if event is InputEventMouse or event is InputEventScreenTouch or event is InputEventScreenDrag:
		if _skip_button.visible and _skip_button.get_global_rect().has_point(event.position):
			_pointer.reset()
			return
	var surfaces: Array[Rect2] = []
	if _sms_panel.visible:
		surfaces.append(_phone_screen.get_global_rect() if _phone_waiting_for_open else _sms_scroll.get_global_rect())
	elif _frame.visible:
		surfaces.append(_frame.get_global_rect())
		if _portrait.visible:
			surfaces.append(_portrait.get_global_rect())
	else:
		surfaces.append(get_global_rect())
	var result: int = _pointer.feed(event, surfaces, _transition_in_progress or _phone_tween != null)
	if result == _pointer.ADVANCE:
		_advance()
	if result != _pointer.IGNORE:
		get_viewport().set_input_as_handled()


func show_dialogue(dialogue_id: String) -> void:
	_pointer.reset()
	_finish_phone_animation()
	var old_scene := _current_scene
	_dialogue_id = dialogue_id
	_line_index = 0
	_lines.clear()
	_beats.clear()
	for child: Node in _sms_history.get_children():
		_sms_history.remove_child(child)
		child.queue_free()
	_story_title.hide()
	_cue.hide()
	match dialogue_id:
		"INTRO":
			_lines = INTRO_LINES.duplicate()
			_speaker.text = "手机消息"
			_set_scene("bedroom", false)
			_show_line()
		"RESCUE_309":
			_lines = RESCUE_309_LINES.duplicate()
			_speaker.text = tr("Terese")
			_set_scene("lobby", false)
			_show_line()
		V4_INTRO_ID:
			_load_story_beats("bedroom", "exterior")
			if _beats.is_empty():
				_dialogue_id = ""
				return
			_set_scene(_beats[0].scene, false)
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
	show()


## Shared task adapter: A owns when to offer/start a task; D only presents these lines.
func show_task_dialogue(dialogue_id: String, speaker: String, lines: Array[String]) -> bool:
	if lines.is_empty() or not _dialogue_id.is_empty():
		return false
	_finish_phone_animation()
	_dialogue_id = dialogue_id
	_line_index = 0
	_lines.assign(lines)
	_beats.clear()
	_speaker.text = speaker
	_set_scene("lobby", false)
	_show_line()
	_skip_button.hide()
	show()
	return true


func has_completed_intro() -> bool:
	var config := ConfigFile.new()
	if config.load(_progress_path) != OK:
		return false
	return config.get_value("story", "intro_and_manager_read", false) == true


func set_progress_file_path_for_test(path: String) -> void:
	_progress_path = path


func set_skip_transitions_for_test(skip: bool) -> void:
	_skip_transitions = skip
	if skip and is_node_ready():
		_finish_phone_animation()


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
	if _dialogue_id == "RESCUE_309":
		_display_portrait("闺蜜", "relieved")
	else:
		_portrait.hide()
	_story_title.hide()
	_fit_dialogue_text.call_deferred()


func _show_story_beat() -> void:
	if _beats.is_empty() or _line_index >= _beats.size():
		return
	var beat: Dictionary = _beats[_line_index]
	var mode: String = beat.mode
	_speaker.visible = mode == "dialogue"
	_line.visible = mode == "dialogue"
	_speaker.text = "Carol" if beat.speaker in ["女主", "安", "Carol"] else tr("Terese") if beat.speaker in ["闺蜜", "Terese", "Persica", "friend"] else beat.speaker
	_line.text = beat.text
	_cue.hide()
	_story_title.hide()
	if mode == "sms":
		_sms_panel.show()
		_frame.hide()
		_portrait.hide()
		_add_sms_message(str(beat.speaker), str(beat.text))
		if _line_index == 0 and not _skip_transitions:
			_animate_phone_notification()
	elif mode == "cue":
		_sms_panel.hide()
		_frame.hide()
		_portrait.hide()
		_refresh_stage_cue()
		_cue.show()
	elif mode == "title":
		_sms_panel.hide()
		_frame.hide()
		_portrait.hide()
		_story_title.show()
	else:
		_sms_panel.hide()
		_frame.show()
		_display_portrait(str(beat.speaker), str(beat.expression))
		_fit_dialogue_text.call_deferred()


func _animate_phone_notification() -> void:
	_phone_chat.hide()
	_phone_notification.show()
	_vibration_marks.show()
	_sms_panel.rotation_degrees = 9
	_phone_tween = create_tween()
	for angle: float in [13.0, -12.0, 11.0, -10.0, 9.0, -8.0, 7.0, -6.0, 5.0, -4.0, 3.0, -2.0, 1.5, -1.0]:
		_phone_tween.tween_property(_sms_panel, "rotation_degrees", angle, 0.105)
	_phone_tween.tween_callback(_vibration_marks.hide)
	_phone_tween.tween_property(_sms_panel, "rotation_degrees", 0.0, 0.22).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_phone_tween.finished.connect(func() -> void:
		_phone_tween = null
		_phone_waiting_for_open = true
		_vibration_marks.hide()
	, CONNECT_ONE_SHOT)


func _finish_phone_animation() -> void:
	if _phone_tween != null:
		_phone_tween.kill()
		_phone_tween = null
	_vibration_marks.hide()
	_sms_panel.rotation_degrees = 0.0
	_phone_notification.hide()
	_phone_waiting_for_open = false
	_phone_chat.show()


func _add_sms_message(speaker: String, text: String) -> void:
	var is_friend := speaker in ["闺蜜", "Terese", "Persica", "friend"]
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 7)
	var avatar := TextureRect.new()
	avatar.custom_minimum_size = Vector2(36, 36)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.texture = FRIEND_AVATAR if is_friend else AN_AVATAR
	var bubble := PanelContainer.new()
	bubble.name = "Bubble"
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("414a34") if is_friend else Color("dfbd78")
	style.set_corner_radius_all(8)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	bubble.add_theme_stylebox_override("panel", style)
	var body := Label.new()
	body.text = text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_color_override("font_color", Color("fff4dc") if is_friend else Color("3c2920"))
	body.add_theme_font_size_override("font_size", 18)
	body.name = "Body"
	bubble.add_child(body)
	var spacer := Control.new()
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if is_friend:
		row.add_child(avatar)
		row.add_child(bubble)
		row.add_child(spacer)
	else:
		row.add_child(spacer)
		row.add_child(bubble)
		row.add_child(avatar)
	_sms_history.add_child(row)
	_size_sms_body(body)
	_scroll_sms_to_message(row)


func _size_sms_body(body: Label) -> void:
	var font := body.get_theme_font("font")
	body.custom_minimum_size.x = minf(maxf(100.0, _sms_scroll.size.x * 0.76 - 20.0), ceilf(font.get_string_size(
		tr(body.text), HORIZONTAL_ALIGNMENT_LEFT, -1, body.get_theme_font_size("font_size")
	).x))


func _scroll_sms_to_message(row: Control) -> void:
	# Wait for container layout to update the scroll range for the new bubble.
	await get_tree().process_frame
	if is_instance_valid(row) and row.is_inside_tree():
		_sms_scroll.ensure_control_visible(row)


func _display_portrait(speaker: String, expression: String) -> void:
	if speaker in ["闺蜜", "Terese", "Persica", "friend"]:
		var index := int(FACE_INDEX.get(expression, 0))
		_portrait.texture = _atlas_cell(FRIEND_SHEET, index)
	else:
		var role: String = PORTRAIT_ROLES.get(speaker, "")
		if role.is_empty():
			_portrait.hide()
			return
		var portraits: Dictionary = ROLE_PORTRAITS[role]
		var key: String = EXPRESSION_ALIASES.get(expression, expression)
		_portrait.texture = portraits.get(key, portraits["neutral"])
	_portrait.texture = _trim_portrait(_portrait.texture)
	_portrait.show()
	_fit_dialogue_text.call_deferred()


func _trim_portrait(texture: Texture2D) -> Texture2D:
	if _portrait_cache.has(texture):
		return _portrait_cache[texture]
	var image := texture.get_image()
	if image == null:
		return texture
	var region := image.get_used_rect()
	if region.size == Vector2i.ZERO:
		return texture
	var cropped := ImageTexture.create_from_image(image.get_region(region))
	_portrait_cache[texture] = cropped
	return cropped


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
	if _phone_tween != null:
		return
	if _phone_waiting_for_open:
		_phone_waiting_for_open = false
		_phone_notification.hide()
		_phone_chat.show()
		_scroll_sms_to_message(_sms_history.get_child(-1))
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
	_finish_phone_animation()
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


func _on_skip_pressed() -> void:
	if not _can_skip_current_dialogue():
		return
	_finish()
