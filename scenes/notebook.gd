extends "res://scenes/ui/help.gd"
## A binds the current D help view to authoritative story/settlement facts.

const ENTRY_NODES: Array[String] = ["Eye", "Nose", "Hat", "Ear", "Checker"]
const CARD_ROWS: Dictionary = {"Security": "SECURITY", "Cleaner": "CLEANER", "Manager": "MANAGER"}


func _ready() -> void:
	GameManager.notebook_changed.connect(_refresh_notebook)
	CardManager.cards_changed.connect(_refresh_notebook)
	super._ready()


func _show_page(page_index: int) -> void:
	super._show_page(page_index)
	_refresh_notebook()


func _refresh_notebook() -> void:
	var view: Dictionary = GameManager.get_notebook_view()
	_page_title.text = "操作与工作证" if _page_index == 0 else "调查笔记"
	for row: String in CARD_ROWS:
		_work_card_page.get_node(row + "Rule").text = "已获得，可在背包选择佩戴槽。" if CardManager.has_card(CARD_ROWS[row]) else "尚未获得。"
	for index: int in range(ENTRY_NODES.size()):
		var entry: Dictionary = view["entries"][index]
		_monster_page.get_node(ENTRY_NODES[index] + "Id").text = entry["name"]
		_monster_page.get_node(ENTRY_NODES[index] + "Rule").text = entry["text"]
	var hint: Label = _monster_page.get_node("Unconfirmed")
	hint.visible = not view["unlocked"]
	hint.text = "先与前台经理交谈，收集住客的线索。"
	get_node("Center/Panel/Content/InputSummary").text = "A/D 或方向键移动；E 交谈、楼梯或交付；偷卡／清理按住 E；Q 切当前身份；I 背包；H 说明与笔记。"
