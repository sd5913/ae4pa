extends Control
## Presentation only. The host owns input, history, backgrounds and completion.
signal closed
const ART_PATH := "res://assets/final/ui/chapter_cards/"
const BASE_SIZE := Vector2(1672, 941)
const ENTRANCE_SECONDS := 2.8
const EXIT_SECONDS := 0.85
const TITLE_REGION := Rect2(300, 400, 1072, 108)
const HEADING_REGION := Rect2(300, 270, 1072, 62)
const ENGLISH_REGION := Rect2(200, 508, 1272, 80)
const HINT_REGION := Rect2(480, 620, 730, 70)

class Artwork extends Control:
	var card: Control
	func _draw() -> void:
		if is_instance_valid(card): card._paint(self)

var active := false
var ready_to_continue := false
var _clock := 0.0
var _exit_clock := -1.0
var _card_id := "bedroom_1"
var _veil: ColorRect
var _art: Artwork
var _sheet: Texture2D
var _hint: Texture2D
var _ornaments: Texture2D
var _rule: Texture2D
var _cache: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_veil = ColorRect.new()
	_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material_instance := ShaderMaterial.new()
	material_instance.shader = preload("res://scenes/ui/chapter_paper.gdshader")
	material_instance.set_shader_parameter("paper_grain", load(ART_PATH + "paper_grain.png"))
	_veil.material = material_instance
	add_child(_veil)
	_art = Artwork.new()
	_art.card = self
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_art)
	_ornaments = load(ART_PATH + "ornaments.png")
	_rule = load(ART_PATH + "rule.png")
	resized.connect(func(): _art.queue_redraw())
	set_process(false)
	hide()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready() and active:
		_load_sheet()
		_art.queue_redraw()

func _load_sheet() -> void:
	var locale := "en" if TranslationServer.get_locale().begins_with("en") else "zh"
	var key := _card_id + "_" + locale
	if not _cache.has(key): _cache[key] = load(ART_PATH + key + ".png")
	_sheet = _cache[key]
	_hint = load(ART_PATH + "hint_" + locale + ".png")

func present(heading: String, location: String, card_id: String = "") -> void:
	cancel()
	_card_id = card_id
	if _card_id.is_empty():
		if heading == "309": _card_id = "reunion_309"
		elif location == tr("咖啡馆回忆"): _card_id = "cafe_2"
		elif location == tr("旅馆外"): _card_id = "exterior_4"
		elif location == tr("共赴长夜"): _card_id = "ending"
		else: _card_id = "bedroom_3" if heading.ends_with("3") else "bedroom_1"
	_load_sheet()
	active = true
	_clock = 0.0
	_exit_clock = -1.0
	show()
	set_process(true)
	_update_frame()

func _process(delta: float) -> void:
	if not active: return
	_clock += delta
	if _exit_clock >= 0.0:
		_exit_clock += delta
		if _exit_clock >= EXIT_SECONDS:
			active = false
			set_process(false)
			hide()
			closed.emit()
			return
	else:
		ready_to_continue = _clock >= ENTRANCE_SECONDS
	_update_frame()

func _ease(value: float) -> float:
	return 1.0 - pow(1.0 - clampf(value, 0.0, 1.0), 3.0)

func _ramp(start: float, duration: float) -> float:
	return _ease((_clock - start) / duration)

func _update_frame() -> void:
	var paper_out := 1.0 if _exit_clock < 0.0 else 1.0 - _ease((_exit_clock - 0.13) / 0.65)
	_veil.material.set_shader_parameter("strength", _ramp(0.1, 0.95) * paper_out)
	_art.queue_redraw()

func _region(canvas: Control, texture: Texture2D, source: Rect2, alpha: float, offset := Vector2.ZERO) -> void:
	if texture == null or alpha <= 0.0 or source.size.x <= 0.0: return
	canvas.draw_texture_rect_region(texture, Rect2(source.position + offset, source.size), source, Color(1, 1, 1, alpha))

func _paint(canvas: Control) -> void:
	if not active: return
	var factor := minf(size.x / BASE_SIZE.x, size.y / BASE_SIZE.y)
	canvas.draw_set_transform((size - BASE_SIZE * factor) * 0.5, 0.0, Vector2.ONE * factor)
	var ui_out := 1.0 if _exit_clock < 0.0 else 1.0 - _ease(_exit_clock / 0.38)
	var heading := _ramp(0.5, 0.65)
	_region(canvas, _sheet, HEADING_REGION, heading * ui_out, Vector2(0, (1.0 - heading) * 5.0))
	var line := _ramp(0.66, 0.85)
	_region(canvas, _rule, Rect2(836.0 - 146.0 * line, 339, 292.0 * line, 25), _ramp(0.66, 0.7) * ui_out)
	var ornament := _ramp(0.78, 1.05) * ui_out
	_region(canvas, _ornaments, Rect2(650, 298, 400.0 * _ramp(0.78, 1.1), 218), ornament)
	var long_english := TranslationServer.get_locale().begins_with("en") and _card_id in ["cafe_2", "exterior_4", "ending"]
	var side_offset := 150.0 if long_english else 0.0
	_region(canvas, _ornaments, Rect2(480, 450, 125, 40), ornament, Vector2(-side_offset, 0))
	_region(canvas, _ornaments, Rect2(1090, 450, 125, 40), ornament, Vector2(side_offset, 0))
	var english := _ramp(1.4, 1.0)
	_region(canvas, _sheet, ENGLISH_REGION, english * ui_out, Vector2(0, (1.0 - english) * 5.0))
	var title := _ramp(1.1, 0.85)
	_region(canvas, _sheet, TITLE_REGION, title * ui_out, Vector2(0, (1.0 - title) * 9.0))
	var breath := 1.0 if _clock < ENTRANCE_SECONDS else 0.86 + 0.14 * cos((_clock - ENTRANCE_SECONDS) * PI / 1.8)
	_region(canvas, _hint, HINT_REGION, _ramp(2.15, 0.65) * breath * ui_out)
	canvas.draw_set_transform(Vector2.ZERO)

func dismiss() -> void:
	if not active or not ready_to_continue or _exit_clock >= 0.0: return
	ready_to_continue = false
	_exit_clock = 0.0

func cancel() -> void:
	active = false
	ready_to_continue = false
	_clock = 0.0
	_exit_clock = -1.0
	set_process(false)
	hide()
