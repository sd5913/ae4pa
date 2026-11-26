extends Control
## Standalone presentation only; the host owns card validation, modal locks and rescue state.
signal rescue_cg_finished
signal beat_displayed(token: String, speaker: String, source: String, parameters: Dictionary)

const DATA_PATH := "res://cg309_reunion/dialogue.json"
const DialogueScene := preload("res://scenes/ui/dialogue.tscn")
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
var _dialogue: Control
var _panel: Panel
var _speaker: Label
var _transition_tween: Tween
var _camera_tween: Tween
var _textures: Dictionary = {}
var _run_token := 0
var _pointer := preload("res://scenes/ui/story_pointer.gd").new()
var _displayed_index := -1

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
	_dialogue = DialogueScene.instantiate()
	_dialogue.presentation_only = true
	add_child(_dialogue)
	_panel = _dialogue.get_node("%DialogueFrame")
	_speaker = _dialogue.get_node("%Speaker")

func _new_frame() -> TextureRect:
	var node := TextureRect.new()
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(node)
	return node

func play() -> void:
	_pointer.reset()
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
	_displayed_index = -1
	show()
	if _beats.is_empty():
		_playing = false
		hide()
		push_error("309 dialogue is empty; completion was not emitted")
		return
	_show_next()

func advance() -> void:
	if not _playing or _transitioning or _displayed_index != _index:
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
	var speaker := ""
	if not beat.get("narration", false):
		speaker = str(beat.get("speaker_en", beat["speaker"])) if TranslationServer.get_locale().begins_with("en") else str(beat["speaker"])
	# Reunion artwork owns the characters; never overlay half-body portraits.
	_dialogue.present_caption(speaker, tr(str(beat["text"])).format(beat.get("parameters", {})))
	var next_id := str(beat["frame"])
	if next_id != _frame_id:
		_change_frame(next_id)
	else:
		_record_displayed_beat.call_deferred(_run_token, _index)

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
		_record_displayed_beat.call_deferred(token, _index)
		_camera_tween = create_tween()
		_camera_tween.tween_property(_front, "scale", Vector2(1.025, 1.025), 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	, CONNECT_ONE_SHOT)

func _record_displayed_beat(token: int, index: int) -> void:
	if token != _run_token or not _playing or _transitioning or index != _index or _displayed_index == index: return
	var beat: Dictionary = _beats[index]
	var speaker: String = str(beat.get("speaker_id", ""))
	if speaker.is_empty():
		speaker = "NARRATOR" if bool(beat.get("narration", false)) else "CAROL" if str(beat.get("speaker", "")) == "Carol" else "TERESE"
	_displayed_index = index
	beat_displayed.emit("cg309:reunion:%02d" % (index + 1), speaker, str(beat["text"]), beat.get("parameters", {}))

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
	var surfaces: Array[Rect2] = [_panel.get_global_rect()]
	if _speaker.visible:
		surfaces.append(_speaker.get_global_rect())
	var result: int = _pointer.feed(event, surfaces, _transitioning)
	if result == _pointer.ADVANCE:
		advance()
	if result != _pointer.IGNORE:
		get_viewport().set_input_as_handled()

func _exit_tree() -> void:
	_run_token += 1
	_stop_tweens()
