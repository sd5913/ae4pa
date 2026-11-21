extends Node
## Language preferences are independent of story and task progress.

const CHINESE := "zh_CN"
const ENGLISH := "en"
const SETTINGS_PATH := "user://language.cfg"
const CJK_FONT_PATH := "res://assets/final/fonts/hotel_staff_cjk.otf"


func _ready() -> void:
	_register_font_fallback()
	var settings := ConfigFile.new()
	var locale := CHINESE
	if settings.load(SETTINGS_PATH) == OK and settings.get_value("ui", "language", CHINESE) == ENGLISH:
		locale = ENGLISH
	_apply_locale(locale)


func set_language(locale: String) -> void:
	if locale not in [CHINESE, ENGLISH] or locale == TranslationServer.get_locale():
		return
	_apply_locale(locale)
	var settings := ConfigFile.new()
	settings.set_value("ui", "language", locale)
	var error := settings.save(SETTINGS_PATH)
	if error != OK:
		push_warning("Could not save the language preference: %s" % error_string(error))



func _register_font_fallback() -> void:
	var font: Font = load(CJK_FONT_PATH)
	if font == null:
		return
	var default_font := ThemeDB.get_default_theme().default_font
	var fallbacks := default_font.fallbacks
	fallbacks.append(font)
	default_font.fallbacks = fallbacks


func _apply_locale(locale: String) -> void:
	TranslationServer.set_locale(locale)
	get_tree().root.title = "Monster Hotel"
