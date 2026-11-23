extends TextureRect
## Preserve the original bilingual lettering in Chinese. Draw English in the same title area.

var _english_title: Label


func _ready() -> void:
	_english_title = Label.new()
	_english_title.text = "Monster Staff\nAccess"
	_english_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_english_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_english_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_english_title.add_theme_font_size_override("font_size", 56)
	_english_title.add_theme_color_override("font_color", Color("f2d7a1"))
	_english_title.add_theme_color_override("font_outline_color", Color("271b16"))
	_english_title.add_theme_constant_override("outline_size", 8)
	_english_title.add_theme_font_override("font", load("res://assets/final/fonts/hotel_staff_cjk.otf"))
	add_child(_english_title)
	_english_title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_refresh_language()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_language()


func _refresh_language() -> void:
	var english := TranslationServer.get_locale() == Localization.ENGLISH
	self_modulate.a = 0.0 if english else 1.0
	_english_title.visible = english
