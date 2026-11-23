extends OptionButton

var _caption: Label

const LOCALES := [Localization.CHINESE, Localization.ENGLISH]


func _ready() -> void:
	alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption = Label.new()
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_caption.offset_left = 32
	_caption.offset_right = -32
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_caption.add_theme_font_size_override("font_size", 20)
	add_child(_caption)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		add_theme_color_override(state, Color.TRANSPARENT)
	add_theme_font_size_override("font_size", 20)
	tooltip_text = "Language / 语言"
	add_item("简体中文")
	add_item("English")
	item_selected.connect(_select_language)
	_sync_selection()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_sync_selection()


func _select_language(index: int) -> void:
	Localization.set_language(LOCALES[index])


func _sync_selection() -> void:
	select(LOCALES.find(TranslationServer.get_locale()))
	if is_instance_valid(_caption): _caption.text = get_item_text(selected)
