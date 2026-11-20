extends Control
## Standalone presentation only; the host owns card validation, modal locks and rescue state.
signal rescue_cg_finished

const DATA_PATH := "res://cg309_reunion/dialogue.json"
const FRAME_PATHS := {
	"approach": "res://cg309_reunion/assets/cg_01_approach.png",
	"hug": "res://cg309_reunion/assets/cg_02_hug.png",
	"leave": "res://cg309_reunion/assets/cg_03_leave.png",
}
@export var auto_play := true
var _beats: Array = []
var _index := -1
var _playing := false
var _transitioning := false
var _frame_id := ""
var _front: TextureRect
var _back: TextureRect
var _panel: PanelContainer
var _speaker: Label
var _line: Label
var _hint: Label
var _transition_tween: Tween
var _camera_tween: Tween
var _textures: Dictionary = {}
var _run_token := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if parsed is Array:
		_beats = parsed
	else:
		push_error("309 dialogue data could not be loaded")
	visible = false
	if auto_play:
		play.call_deferred()

func _build_ui() -> void:
	var fill := ColorRect.new()
	fill.color = Color("#100e12")
	fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fill)
	_back = _new_frame()
	_front = _new_frame()
	_panel = PanelContainer.new()
	_panel.anchor_left = 0.035
	_panel.anchor_right = 0.965
	_panel.anchor_top = 0.72
	_panel.anchor_bottom = 0.965
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = preload("res://scenes/ui/staff_ui_theme.tres")
	var style: StyleBox = theme.get_stylebox("panel", "PanelContainer").duplicate()
	style.content_margin_left = 32
	style.content_margin_right = 32
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 7)
	_panel.add_child(box)
	_speaker = Label.new()
	_speaker.add_theme_font_size_override("font_size", 22)
	_speaker.add_theme_color_override("font_color", Color("#ead19b"))
	box.add_child(_speaker)
	_line = Label.new()
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_line.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_line.add_theme_font_size_override("font_size", 24)
	_line.add_theme_color_override("font_color", Color("#f8f0df"))
	box.add_child(_line)
	_hint = Label.new()
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hint.add_theme_font_size_override("font_size", 16)
	_hint.add_theme_color_override("font_color", Color("#c4bda8"))
	box.add_child(_hint)
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Noto Sans CJK SC", "Microsoft YaHei", "PingFang SC", "sans-serif"])
	_panel.add_theme_font_override("font", font)

func _new_frame() -> TextureRect:
	var node := TextureRect.new()
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(node)
	return node

func play() -> void:
	_stop_tweens()
	_run_token += 1
	_index = -1
	_frame_id = ""
	_front.texture = null
	_back.texture = null
	_front.modulate.a = 1.0
	_back.modulate.a = 1.0
	_front.scale = Vector2.ONE
	_back.scale = Vector2.ONE
	_playing = true
	_transitioning = false
	show()
	if _beats.is_empty():
		_playing = false
		hide()
		push_error("309 dialogue is empty; completion was not emitted")
		return
	_show_next()

func advance() -> void:
	if not _playing or _transitioning:
		return
	_show_next()

func _show_next() -> void:
	_index += 1
	if _index >= _beats.size():
		_playing = false
		_stop_tweens()
		hide()
		rescue_cg_finished.emit()
		return
	var beat: Dictionary = _beats[_index]
	var narrative := bool(beat.get("narration", false))
	_speaker.text = " " if narrative else str(beat.get("speaker_en", beat["speaker"])) if TranslationServer.get_locale().begins_with("en") else str(beat["speaker"])
	_line.text = str(beat["text"])
	_line.add_theme_color_override("font_color", Color("#d3c5ad") if narrative else Color("#f8f0df"))
	var key := "未绑定"
	for input in InputMap.action_get_events("interact"):
		if input is InputEventKey:
			key = OS.get_keycode_string(input.physical_keycode if input.physical_keycode != 0 else input.keycode)
	_hint.text = key + (" / 鼠标左键 · 结束" if _index == _beats.size() - 1 else " / 鼠标左键 · 继续") + "    %d / %d" % [_index + 1, _beats.size()]
	var next_id := str(beat["frame"])
	if next_id != _frame_id:
		_change_frame(next_id)

func _change_frame(next_id: String) -> void:
	if not FRAME_PATHS.has(next_id):
		return
	_stop_tweens()
	_transitioning = true
	if not _textures.has(next_id):
		_textures[next_id] = load(FRAME_PATHS[next_id])
	_back.texture = _front.texture
	_back.scale = _front.scale
	_front.texture = _textures[next_id]
	_front.pivot_offset = size * Vector2(0.47, 0.43)
	_back.pivot_offset = _front.pivot_offset
	_front.scale = Vector2.ONE
	_front.modulate.a = 0.0
	_frame_id = next_id
	_transition_tween = create_tween()
	_transition_tween.tween_property(_front, "modulate:a", 1.0, 0.42 if next_id == "approach" else 0.28)
	var token := _run_token
	_transition_tween.finished.connect(func() -> void:
		if token != _run_token or not _playing:
			return
		_transitioning = false
		_back.texture = null
		_camera_tween = create_tween()
		_camera_tween.tween_property(_front, "scale", Vector2(1.025, 1.025), 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	, CONNECT_ONE_SHOT)

func _stop_tweens() -> void:
	if _transition_tween != null:
		_transition_tween.kill()
		_transition_tween = null
	if _camera_tween != null:
		_camera_tween.kill()
		_camera_tween = null

func cancel() -> void:
	## Cancellation never means the friend was rescued.
	_run_token += 1
	_playing = false
	_transitioning = false
	_stop_tweens()
	hide()

func _input(event: InputEvent) -> void:
	if not _playing or not visible:
		return
	var pressed := false
	pressed = event.is_action_pressed("interact") and not event.is_echo()
	if event is InputEventMouseButton:
		pressed = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if pressed:
		get_viewport().set_input_as_handled()
		advance()

func _exit_tree() -> void:
	_run_token += 1
	_stop_tweens()
