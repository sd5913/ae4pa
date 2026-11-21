extends "res://scenes/ui/help.gd"
## Add authoritative clue status to the encounter-gated handbook pages.

const MONSTER_IDS: Array[String] = ["EYE", "NOSE", "HAT", "EAR", "CHECKER"]


func _ready() -> void:
	GameManager.notebook_changed.connect(_refresh_notebook)
	CardManager.cards_changed.connect(_refresh_notebook)
	super._ready()


func _show_page(page_index: int) -> void:
	super._show_page(page_index)
	_refresh_notebook()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_notebook()


func _refresh_notebook() -> void:
	if not is_node_ready() or _page_index < 5 or _page_index >= 10:
		return
	var monster_id := MONSTER_IDS[_page_index - 5]
	if not _is_seen(monster_id):
		return
	var entries: Array = GameManager.get_notebook_view().get("entries", [])
	var entry: Dictionary = {}
	for candidate: Dictionary in entries:
		if str(candidate.get("id", "")) == monster_id:
			entry = candidate
			break
	var clue := _monster_page.get_node_or_null("InvestigationStatus") as Label
	if clue == null:
		clue = Label.new()
		clue.name = "InvestigationStatus"
		clue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		clue.add_theme_font_size_override("font_size", 16)
		clue.add_theme_color_override("font_color", Color("705a40"))
		_monster_page.add_child(clue)
	var status := str(entry.get("status", "UNKNOWN"))
	var status_label: String = {"UNKNOWN": "未知", "HINT": "线索", "KNOWN": "已确认"}.get(status, "未知")
	clue.text = "%s：%s" % [status_label, str(entry.get("text", "尚未取得线索。"))]
