extends Control

const CardDisplay = preload("res://scenes/ui/card_display.gd")
const PAGE_COUNT := 10
const MODAL_ID := "help"
const DEFAULT_CODEX_PATH := "user://monster_codex_seen.cfg"
const CARD_PAGES := [
	{"id": "SECURITY", "name": "保安工作证", "rule": "独眼客 EYE 检查时安全；只保护独眼客。"},
	{"id": "CLEANER", "name": "保洁工作证", "rule": "长鼻客 NOSE 检查时安全；只保护长鼻客。"},
	{"id": "MANAGER", "name": "经理工作证", "rule": "礼帽客 HAT 检查时安全；只保护礼帽客。"},
]
const MONSTER_PAGES := [
	{"id": "EYE", "name": "独眼客", "art": "eye", "rule": "游玩中，门 OPEN 且在范围内：当前卡非 SECURITY → WRONG_CARD；用保安卡或等关门。"},
	{"id": "NOSE", "name": "长鼻客", "art": "nose", "rule": "游玩中，门 OPEN 且在范围内：当前卡非 CLEANER → WRONG_CARD；用保洁卡或等关门。"},
	{"id": "HAT", "name": "礼帽客", "art": "hat", "rule": "游玩中，门 OPEN 且在范围内：当前卡非 MANAGER → WRONG_CARD；用经理卡或等关门。"},
	{"id": "EAR", "name": "大耳客", "art": "ear", "rule": "游玩中，门 OPEN 且在范围内仍移动 → MOVED_NEAR_EAR；停步，等门关再走。"},
	{"id": "CHECKER", "name": "核验客", "art": "checker", "rule": "游玩中，门 OPEN 且在范围内主动切卡或更换佩戴槽 → SWITCHED_NEAR_CHECKER；提前选卡，门前不换证。"},
]
const MONSTER_SHEETS := {
	"EYE": preload("res://assets/final/monster_idle/eye_idle_sheet.png"),
	"NOSE": preload("res://assets/final/monster_idle/nose_idle_sheet.png"),
	"HAT": preload("res://assets/final/monster_idle/hat_idle_sheet.png"),
	"EAR": preload("res://assets/final/monster_idle/ear_idle_sheet.png"),
	"CHECKER": preload("res://assets/final/monster_idle/checker_idle_sheet.png"),
}

var _previous_focus: Control
var _page_index := 0
var _seen_in_run: Dictionary = {}
var _codex_path := DEFAULT_CODEX_PATH

@onready var _page_title: Label = %PageTitle
@onready var _work_card_page: GridContainer = %WorkCardPage
@onready var _monster_page: VBoxContainer = %MonsterPage
@onready var _page_indicator: Label = %PageIndicator
@onready var _previous_button: Button = %PreviousButton
@onready var _next_button: Button = %NextButton


func _ready() -> void:
	visibility_changed.connect(_sync_modal_state)
	resized.connect(_layout_book)
	_layout_book()
	GameManager.monster_encounter_requested.connect(_on_monster_encounter)
	_show_page(0)
	_sync_modal_state()


func _layout_book() -> void:
	if not is_node_ready(): return
	var width := minf(900.0, maxf(320.0, size.x - 48.0))
	$Center/Panel.custom_minimum_size.x = width
	$Center/Panel/Content/Scroll.custom_minimum_size.y = minf(350.0, maxf(160.0, size.y - 240.0))
	$Center/Panel/Content/Scroll/Pages.custom_minimum_size.x = width - 80.0

func _mapped_press(event: InputEvent, action: StringName) -> bool:
	if not event.is_pressed() or event.is_echo(): return false
	if event.is_action_pressed(action): return true
	if event is InputEventKey:
		for binding in InputMap.action_get_events(action):
			if binding is InputEventKey:
				var configured: int = binding.physical_keycode if binding.physical_keycode != 0 else binding.keycode
				var actual: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
				if actual == configured and event.ctrl_pressed == binding.ctrl_pressed and event.alt_pressed == binding.alt_pressed and event.shift_pressed == binding.shift_pressed: return true
	return false

func _input(event: InputEvent) -> void:
	var help_pressed := _mapped_press(event, &"open_help")
	if visible and (_mapped_press(event, &"pause") or help_pressed):
		close_help()
		get_viewport().set_input_as_handled()
	elif not visible and help_pressed and (GameManager.game_state == "MENU" or GameManager.is_world_input_allowed()):
		open_help()
		get_viewport().set_input_as_handled()

func _sync_modal_state() -> void:
	if GameManager.has_method("set_modal_open"):
		GameManager.set_modal_open(MODAL_ID, visible)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("open_help"):
		return
	if visible:
		close_help()
	else:
		open_help()
	get_viewport().set_input_as_handled()


func open_help() -> void:
	if visible:
		return
	_previous_focus = get_viewport().gui_get_focus_owner()
	_refresh_encounter_records()
	_show_page(0)
	show()
	%CloseButton.grab_focus()


func close_help() -> void:
	hide()
	if is_instance_valid(_previous_focus) and _previous_focus.is_visible_in_tree():
		_previous_focus.grab_focus()
	_previous_focus = null


func set_codex_path_for_test(path: String) -> void:
	_codex_path = path
	_seen_in_run.clear()


func reset_codex_file_for_test() -> void:
	if FileAccess.file_exists(_codex_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(_codex_path))


func next_page() -> void:
	_show_page(mini(_page_index + 1, PAGE_COUNT - 1))


func previous_page() -> void:
	_show_page(maxi(_page_index - 1, 0))


func _on_monster_encounter(context: Dictionary) -> void:
	var monster_id := str(context.get("monster_type", ""))
	if MONSTER_SHEETS.has(monster_id):
		_record_seen(monster_id)
	if visible:
		_show_page(_page_index)


func _refresh_encounter_records() -> void:
	var config := ConfigFile.new()
	_seen_in_run.clear()
	if config.load(_codex_path) == OK:
		for entry: Dictionary in MONSTER_PAGES:
			var monster_id: String = entry.id
			if bool(config.get_value("seen", monster_id, false)):
				_seen_in_run[monster_id] = true
	for entry: Dictionary in MONSTER_PAGES:
		var monster_id: String = entry.id
		if GameManager.has_met_monster(monster_id):
			_record_seen(monster_id)


func _record_seen(monster_id: String) -> void:
	_seen_in_run[monster_id] = true
	var config := ConfigFile.new()
	if config.load(_codex_path) != OK:
		config = ConfigFile.new()
	for seen_id: String in _seen_in_run:
		config.set_value("seen", seen_id, true)
	var absolute_path := ProjectSettings.globalize_path(_codex_path)
	DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	var save_error := config.save(absolute_path)
	if save_error != OK:
		push_error("Could not save encountered monster record: " + error_string(save_error))


func _is_seen(monster_id: String) -> bool:
	return bool(_seen_in_run.get(monster_id, false)) or GameManager.has_met_monster(monster_id)


func _show_page(page_index: int) -> void:
	_page_index = clampi(page_index, 0, PAGE_COUNT - 1)
	_work_card_page.visible = false
	_monster_page.visible = false
	if _page_index == 0:
		_page_title.text = "夜班操作"
		_show_text_page(_work_card_page, [
			"A / ←　向左移动",
			"D / →　向右移动",
			"E　交谈、工作交互、楼梯与出口",
			"Q　切换当前生效工作证",
			"I　打开背包　　H　打开本手册　　Esc　暂停菜单",
		])
	elif _page_index in [1, 2, 3]:
		var card: Dictionary = CARD_PAGES[_page_index - 1]
		_page_title.text = str(card.name)
		_show_card_page(card)
	elif _page_index == 4:
		_page_title.text = "佩戴与任务"
		_show_text_page(_work_card_page, [
			"最多佩戴两张工作证；当前生效身份由高亮槽位标记。",
			"按 Q 切换生效槽；按 I 打开背包调整佩戴槽。",
			"工作证只匹配对应身份检查，不提供速度或通用开门权限。",
			"接受任务后，按目标使用身份完成实际工作，并返回住客处交付。",
		])
	else:
		var monster: Dictionary = MONSTER_PAGES[_page_index - 5]
		_show_monster_page(monster)
	_page_indicator.text = "%d / %d" % [_page_index + 1, PAGE_COUNT]
	_previous_button.disabled = _page_index == 0
	_next_button.disabled = _page_index == PAGE_COUNT - 1


func _clear(container: Control) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()


func _show_text_page(container: GridContainer, lines: Array[String]) -> void:
	container.columns = 1
	container.visible = true
	_clear(container)
	for line_text: String in lines:
		var line := Label.new()
		line.text = line_text
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_theme_font_size_override("font_size", 22)
		line.add_theme_color_override("font_color", Color("493827"))
		container.add_child(line)


func _show_card_page(card: Dictionary) -> void:
	_work_card_page.columns = 1
	_work_card_page.visible = true
	_clear(_work_card_page)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 34)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var icon := TextureRect.new()
	icon.texture = CardDisplay.art_for(str(card.id))
	icon.custom_minimum_size = Vector2(300, 220)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)
	var description := VBoxContainer.new()
	description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description.custom_minimum_size.x = 360
	description.add_theme_constant_override("separation", 18)
	var identity := Label.new()
	identity.text = str(card.id)
	identity.add_theme_font_size_override("font_size", 25)
	identity.add_theme_color_override("font_color", Color("8b5c28"))
	description.add_child(identity)
	var rule := Label.new()
	rule.text = str(card.rule)
	rule.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.add_theme_font_size_override("font_size", 22)
	rule.add_theme_color_override("font_color", Color("493827"))
	description.add_child(rule)
	row.add_child(description)
	_work_card_page.add_child(row)


func _show_monster_page(monster: Dictionary) -> void:
	_monster_page.visible = true
	_clear(_monster_page)
	var seen := _is_seen(str(monster.id))
	_page_title.text = str(monster.name) if seen else "未知住客"
	var art := TextureRect.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = MONSTER_SHEETS[str(monster.id)]
	atlas.region = Rect2(0, 0, 362, 543)
	art.texture = atlas
	art.custom_minimum_size = Vector2(200, 300)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not seen:
		art.modulate = Color(0.025, 0.035, 0.045, 1.0)
	_monster_page.add_child(art)
	var rule := Label.new()
	rule.text = str(monster.rule) if seen else "尚未遇见。首次实际遇见后，才会解锁住客档案。"
	rule.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rule.add_theme_font_size_override("font_size", 20)
	rule.add_theme_color_override("font_color", Color("493827"))
	_monster_page.add_child(rule)
