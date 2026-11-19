extends OptionButton

const LOCALES := [Localization.CHINESE, Localization.ENGLISH]


func _ready() -> void:
	alignment = HORIZONTAL_ALIGNMENT_CENTER
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
