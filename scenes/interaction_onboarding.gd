extends CanvasLayer
## Nonmodal, session-only teaching. Task/card state always comes from the managers.
const CardDisplay = preload("res://scenes/ui/card_display.gd")
var _bag_seen := false
var _switched := false
var _known_cards: Array[String] = []
var _pending_card := ""
var _reviewed: Dictionary = {}
var _monster_kind := ""
var _monster_door: Node
var _review_left := 0.0
var _identity_left := 0.0
var _last_identity := "NONE"
var _panel := PanelContainer.new()
var _body := Label.new()
var _portrait := preload("res://scenes/doors/monster_idle_visual.gd").new()
var _hud: Control
func _ready() -> void:
	layer = 4
	_hud = get_parent().get_node("TaskLayer/HUD")
	_panel.name = "GuidePanel"
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.theme = load("res://scenes/ui/hud_theme.tres")
	var style := StyleBoxFlat.new()
	style.bg_color = Color("302b25",0.96)
	style.border_color = Color("d0b783")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 64
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	_panel.add_theme_stylebox_override("panel",style)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_theme_font_size_override("font_size",17)
	_body.add_theme_color_override("font_color",Color("f5e7c9"))
	_panel.add_child(_body)
	add_child(_panel)
	_portrait.position = Vector2(32,94)
	_panel.add_child(_portrait)
	get_parent().bag.visibility_changed.connect(_on_bag_visibility)
	CardManager.identity_changed.connect(_on_identity_changed)
	CardManager.cards_changed.connect(_on_cards_changed)
	GameManager.state_changed.connect(_on_state_changed)
func _on_bag_visibility() -> void:
	if get_parent().bag.visible: _bag_seen = true
func _on_identity_changed(action: String) -> void:
	if action == "SWITCH_ACTIVE" and CardManager.active_card != "NONE": _switched = true
func _on_cards_changed() -> void:
	var owned: Array[String] = CardManager.get_owned_cards()
	var equipped: Array[String] = CardManager.get_equipped_cards()
	for id in owned:
		if not _known_cards.has(id) and not equipped.has(id): _pending_card = id
	if not owned.has(_pending_card) or equipped.has(_pending_card): _pending_card = ""
	_known_cards.assign(owned)
func _on_state_changed(state: String) -> void:
	if state == "MENU":
		_bag_seen = false
		_switched = false
		_known_cards.clear()
		_pending_card = ""
		_reviewed.clear()
		_monster_kind = ""
		_review_left = 0
		_identity_left = 0
		_last_identity = "NONE"
func get_identity_hint() -> String:
	var owned: Array = CardManager.get_owned_cards()
	var equipped: Array = CardManager.get_equipped_cards()
	if owned.is_empty(): return ""
	if not _pending_card.is_empty():
		return tr("新证件在收藏中。按I打开背包，把它拖到A／B槽；原证件会保留。")
	if CardManager.active_card == "NONE" and equipped.any(func(id): return id != "NONE"):
		return tr("当前槽未装备。关闭背包后按Q启用另一槽的工作证。")
	if not _bag_seen:
		return tr("已获得工作证！右上角显示当前身份。按I查看收藏与装备。")
	return ""
func _find_monster() -> void:
	if GameManager.current_floor < 3: return
	var world: Node = get_parent().get_node("World")
	if world.get_child_count() != 1: return
	var floor_node: Node = world.get_child(0)
	for door in floor_node.get("_doors"):
		if door.door_mode != "NORMAL" or door.door_state not in ["WARNING","OPEN"] or _reviewed.has(door.monster_type): continue
		if absf(floor_node.player.global_position.x - door.global_position.x) > 215: continue
		var entries: Array = GameManager.get_notebook_view()["entries"]
		if not entries.any(func(entry): return entry["id"] == door.monster_type and entry["status"] == "KNOWN"): continue
		_monster_door = door
		_monster_kind = door.monster_type
		_reviewed[_monster_kind] = true
		_review_left = 6
		_portrait.configure(_monster_kind,0.15)
		return
func _process(delta: float) -> void:
	var active: String = CardManager.active_card
	if active != _last_identity:
		_last_identity = active
		_identity_left = 2.8
	if not GameManager.is_world_input_allowed():
		_panel.hide()
		_set_highlight("")
		return
	_identity_left = maxf(0,_identity_left-delta)
	_review_left = maxf(0,_review_left-delta)
	if _review_left > 0:
		if not is_instance_valid(_monster_door) or not _monster_door.is_inside_tree() or _monster_door.door_state not in ["WARNING","OPEN"]:
			_review_left = 0
		elif absf(_monster_door.get("_player").global_position.x - _monster_door.global_position.x) > 215:
			_review_left = 0
	if _review_left <= 0:
		_monster_kind = ""
		_find_monster()
	var hint := get_identity_hint()
	var highlight := "BagButton" if "I" in hint else "SwitchHint" if "Q" in hint else ""
	_set_highlight("" if _review_left > 0 else highlight)
	_portrait.visible = _review_left > 0
	if _review_left > 0:
		var guide: Dictionary = GameManager.get_monster_guide(_monster_kind)
		hint = tr(guide["name"]) + "\n" + tr(guide["text"]) + "\n" + tr("H：查看已学住客规则")
	elif hint.is_empty() and _identity_left > 0:
		hint = tr("当前身份：%s") % tr(CardDisplay.name_for(active))
	_panel.visible = not hint.is_empty()
	_body.text = hint
	var right: Control = _hud.get_node("Margin/Groups/Right")
	_panel.position = Vector2(right.global_position.x, right.get_global_rect().end.y + 12)
	_panel.size = Vector2(right.size.x,0)
	_body.custom_minimum_size.x = maxf(160,right.size.x-78)
func _set_highlight(target: String) -> void:
	for key in ["BagButton","SwitchHint"]:
		_hud.get_node("%"+key).modulate = Color("ffe4a1") if target == key else Color.WHITE
