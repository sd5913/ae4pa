extends MenuButton
const LOCALES := [Localization.CHINESE, Localization.ENGLISH]
var selected := 0
func _ready() -> void:
	alignment = HORIZONTAL_ALIGNMENT_CENTER
	tooltip_text = "Language / 语言"
	get_popup().add_radio_check_item("简体中文", 0)
	get_popup().add_radio_check_item("English", 1)
	get_popup().id_pressed.connect(_select_language)
	_sync_selection()
func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready(): _sync_selection()
func _select_language(index: int) -> void:
	Localization.set_language(LOCALES[index])
func select(index: int) -> void:
	selected = maxi(0,index)
	text = get_popup().get_item_text(selected)
	for i in range(2): get_popup().set_item_checked(i, i == selected)
	queue_redraw()
func _sync_selection() -> void:
	select(LOCALES.find(TranslationServer.get_locale()))
func _draw() -> void:
	var c := Vector2(size.x - 20, size.y * 0.5)
	draw_polyline(PackedVector2Array([c+Vector2(-4,-2),c+Vector2(0,2),c+Vector2(4,-2)]), Color("ecd4a1"), 2.0, true)
