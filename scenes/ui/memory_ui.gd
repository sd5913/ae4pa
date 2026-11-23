extends CanvasLayer
## D view/request adapter. It cannot capture or restore A/B/C gameplay state.
const History = preload("res://scenes/ui/memory_history.gd")
const ART := preload("res://assets/final/ui/memory/memory_panel_blank.png")
const MODAL := "MEMORY_UI"
const LABELS := {"save":"保存记忆", "load":"读取记忆", "history":"历史回忆"}
static var active: Node
var backend: Node
var _root := Control.new()
var _board := Control.new()
var _content := VBoxContainer.new()
var _title := Label.new()
var _scroll := ScrollContainer.new()
var _grid := GridContainer.new()
var _history := VBoxContainer.new()
var _status := Label.new()
var _action := Button.new()
var _auto := Button.new()
var _confirm := ConfirmationDialog.new()
var _filter := OptionButton.new()
var _mode := "load"
var _automatic := false
var _selected := 0
var _slots: Array = []
var _tabs: Dictionary = {}
var _previous_focus: Control
var _confirmed_action: Callable

static func open_page(mode: String) -> void:
	if is_instance_valid(active): active.open(mode)

static func is_open() -> bool:
	return is_instance_valid(active) and active._root.visible

func _ready() -> void:
	active = self
	layer = 80
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.theme = preload("res://scenes/ui/staff_ui_theme.tres")
	var shade := ColorRect.new()
	shade.color = Color(0.015,0.025,0.02,0.84)
	_root.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_board)
	var art := TextureRect.new()
	art.texture = ART
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_board.add_child(art)
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_board.add_child(_content)
	_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_content.add_theme_constant_override("separation",8)
	var heading := HBoxContainer.new()
	_content.add_child(heading)
	_title.add_theme_font_size_override("font_size",28)
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(_title)
	var close := Button.new()
	close.custom_minimum_size = Vector2(40,40)
	close.icon = preload("res://assets/final/ui/memory/icons/close.svg")
	close.expand_icon = true
	close.add_theme_constant_override("icon_max_width",36)
	close.tooltip_text = tr("关闭")
	close.pressed.connect(close_page)
	for state in ["normal","hover","pressed","focus"]: close.add_theme_stylebox_override(state,StyleBoxEmpty.new())
	heading.add_child(close)
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation",8)
	_content.add_child(tabs)
	for mode: String in LABELS:
		var button := Button.new()
		button.text = LABELS[mode]
		button.icon = load("res://assets/final/ui/memory/icons/%s.svg" % {"save":"save_memory","load":"load_memory","history":"history_memory"}[mode])
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width",26)
		button.add_theme_constant_override("h_separation",8)
		button.add_theme_font_size_override("font_size",18)
		button.custom_minimum_size.y = 44
		button.toggle_mode = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(open.bind(mode))
		tabs.add_child(button)
		_tabs[mode] = button
	_auto.custom_minimum_size.y = 40
	_auto.pressed.connect(func() -> void: _automatic = not _automatic; _selected = -1 if _automatic else 0; refresh())
	_content.add_child(_auto)
	_filter.item_selected.connect(func(_value: int) -> void: _render_history())
	_content.add_child(_filter)
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_content.add_child(_scroll)
	_scroll.add_child(_grid)
	_scroll.add_child(_history)
	_grid.add_theme_constant_override("h_separation",10)
	_grid.add_theme_constant_override("v_separation",10)
	_history.add_theme_constant_override("separation",12)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation",12)
	_content.add_child(footer)
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_font_size_override("font_size",14)
	footer.add_child(_status)
	var back := Button.new()
	back.text = "返回"
	back.custom_minimum_size = Vector2(110,44)
	back.pressed.connect(close_page)
	footer.add_child(back)
	_action.custom_minimum_size = Vector2(170,44)
	_action.add_theme_font_size_override("font_size",18)
	_action.pressed.connect(_request_action)
	footer.add_child(_action)
	_root.add_child(_confirm)
	_confirm.title = tr("确认")
	_confirm.confirmed.connect(func() -> void: if _confirmed_action.is_valid(): _confirmed_action.call())
	get_viewport().size_changed.connect(_layout)
	_root.hide()
	_layout()

## Review contract for A's authoritative persistence service, not an existing GameManager API.
func configure_backend(provider: Node) -> bool:
	for method in ["list_memory_slots", "can_save_memory", "save_memory", "load_memory"]:
		if provider == null or not provider.has_method(method): return false
	backend = provider
	refresh()
	return true

func has_loadable_memory() -> bool:
	if not is_instance_valid(backend): return false
	var slots: Array = backend.list_memory_slots()
	return slots.any(func(slot): return slot is Dictionary and slot.get("status") == "VALID")

func open(mode: String) -> void:
	if not LABELS.has(mode): return
	if not _root.visible:
		_previous_focus = get_viewport().gui_get_focus_owner()
		GameManager.set_modal_open(MODAL,true)
	_mode = mode
	_automatic = false
	_selected = 0
	_root.show()
	refresh()
	_tabs[mode].grab_focus()

func refresh() -> void:
	if not is_node_ready(): return
	_title.text = tr(LABELS[_mode])
	for mode: String in _tabs: _tabs[mode].button_pressed = mode == _mode
	_slots = backend.list_memory_slots() if is_instance_valid(backend) else []
	_auto.visible = _mode != "history"
	_auto.text = tr("手动记忆") if _automatic else tr("自动记忆")
	_filter.visible = _mode == "history"
	_grid.visible = _mode != "history"
	_history.visible = _mode == "history"
	_action.visible = _mode != "history"
	_action.text = tr("保存至此") if _mode == "save" else tr("读取这段记忆")
	_status.text = tr("仅展示已读内容，回看不会推进任务。") if _mode == "history" else tr("完整存档接口待 A 接入") if not is_instance_valid(backend) else ""
	if _mode == "history":
		_filter.clear()
		_filter.add_item(tr("全部角色"))
		_filter.set_item_metadata(0, "")
		var speakers: Array[String] = []
		for entry: Dictionary in History.entries:
			var name := History.name_for(str(entry.speaker))
			if speakers.has(name): continue
			speakers.append(name)
			_filter.add_item(name)
			_filter.set_item_metadata(_filter.item_count-1, name)
		_render_history()
	else: _render_slots()
	_layout()
	_bind_page_focus()

func _bind_page_focus() -> void:
	var controls: Array[Control] = []
	for node: Node in _board.find_children("*", "Control", true, false):
		if node.focus_mode != Control.FOCUS_ALL or not node.is_visible_in_tree(): continue
		if node is BaseButton and node.disabled: continue
		controls.append(node)
	for i in controls.size():
		var control := controls[i]
		var previous := control.get_path_to(controls[(i-1+controls.size()) % controls.size()])
		var next := control.get_path_to(controls[(i+1) % controls.size()])
		control.focus_previous = previous
		control.focus_next = next
		control.focus_neighbor_left = previous
		control.focus_neighbor_top = previous
		control.focus_neighbor_right = next
		control.focus_neighbor_bottom = next

func _slot(id: int) -> Dictionary:
	for slot: Dictionary in _slots:
		if slot.get("slot_id") == id: return slot
	return {"slot_id":id,"status":"EMPTY"}

func _render_slots() -> void:
	for child in _grid.get_children(): _grid.remove_child(child); child.queue_free()
	var group := ButtonGroup.new()
	for i in range(1 if _automatic else 6):
		var id := -1 if _automatic else i
		var slot := _slot(id)
		var button := Button.new()
		button.custom_minimum_size.y = 126
		button.toggle_mode = true
		button.button_group = group
		button.button_pressed = id == _selected
		button.add_theme_font_size_override("font_size",17)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var heading := tr("自动记忆") if id == -1 else tr("记忆 %02d") % (i+1)
		var detail := tr("完整存档接口待 A 接入") if not is_instance_valid(backend) else tr("尚未留下记忆")
		if slot.status == "VALID":
			detail = "%s\n%s\n%s · %s" % [slot.get("location",""), tr(str(slot.get("task_name",""))),slot.get("saved_at",""),slot.get("play_time","")]
			detail += "\n" + tr("Terese已获救") if slot.get("has_friend",false) else "\n"+tr("Terese尚未获救")
		elif slot.status not in ["VALID","EMPTY"]: detail = tr("记忆暂时无法读取")
		button.text = heading + "\n" + detail
		button.pressed.connect(func() -> void: _selected = id; _update_action(); button.grab_focus())
		_grid.add_child(button)
	_update_action()

func _update_action() -> void:
	var slot := _slot(_selected)
	_action.disabled = not is_instance_valid(backend)
	if not _action.disabled:
		if _mode == "save":
			var permission: Dictionary = backend.can_save_memory()
			_action.disabled = _automatic or not permission.get("allowed",false)
			_status.text = tr(str(permission.get("reason",""))) if not permission.get("allowed",false) else ""
			for surface: Node in get_tree().get_nodes_in_group("memory_dialogue_surface"):
				if surface.is_visible_in_tree():
					_action.disabled = true
					_status.text = tr("这段演出结束后可以保存")
		else: _action.disabled = slot.status != "VALID"
	if _automatic and _mode == "save": _status.text = tr("自动记忆只由系统写入")

func _render_history() -> void:
	for child in _history.get_children(): _history.remove_child(child); child.queue_free()
	for entry: Dictionary in History.entries:
		var body := History.text(entry)
		var speaker := History.name_for(str(entry.speaker))
		var selected_speaker := str(_filter.get_item_metadata(_filter.selected)) if _filter.selected >= 0 else ""
		if not selected_speaker.is_empty() and speaker != selected_speaker: continue
		var label := Label.new()
		label.text = speaker + "\n" + body
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size",18)
		_history.add_child(label)
	if _history.get_child_count() == 0:
		var empty := Label.new()
		empty.text = tr("暂无已读对白")
		_history.add_child(empty)
	_layout()

func _request_action() -> void:
	if _action.disabled or not is_instance_valid(backend): return
	if _mode == "load":
		_confirm.dialog_text = tr("当前未保存的进度将丢失。")
		_confirmed_action = _execute_action
		_confirm.popup_centered(Vector2i(480,180))
	elif _slot(_selected).status != "EMPTY":
		_confirm.dialog_text = tr("覆盖这段记忆？")
		_confirmed_action = _execute_action
		_confirm.popup_centered(Vector2i(480,180))
	else: _execute_action()

func _execute_action() -> void:
	if not is_instance_valid(backend): return
	_update_action()
	if _action.disabled: return
	var result: Dictionary = backend.save_memory(_selected) if _mode == "save" else backend.load_memory(_selected)
	if not result.get("ok",false):
		_status.text = tr(str(result.get("error","记忆暂时无法读取")))
		return
	if _mode == "load": close_page()
	else: refresh(); _status.text = tr("记忆已保存")

func _layout() -> void:
	var viewport := _root.get_viewport_rect().size
	var width := minf(1160, minf(viewport.x-32,(viewport.y-32)*1586.0/992.0))
	_board.size = Vector2(width,width*992.0/1586.0)
	_board.position = (viewport-_board.size)*0.5
	_content.offset_left = width*0.105
	_content.offset_right = -width*0.105
	_content.offset_top = _board.size.y*0.13
	_content.offset_bottom = -_board.size.y*0.14
	var content_width := width*0.79
	_grid.columns = 2 if viewport.x < 1000 else 3
	_grid.custom_minimum_size.x = content_width-18
	_history.custom_minimum_size.x = content_width-18
	for child in _grid.get_children(): child.custom_minimum_size.x = (content_width-18-10*(_grid.columns-1))/_grid.columns

func _input(event: InputEvent) -> void:
	if not _root.visible: return
	if not event.is_echo() and event.is_action_pressed("pause") and not _confirm.visible:
		close_page()
		get_viewport().set_input_as_handled()
		return
	# Stop the same physical event before the underlying story's _input.
	if event is InputEventMouse or event is InputEventScreenTouch or event is InputEventScreenDrag: return
	if event.is_action("interact") or event.is_action("switch_id") or event.is_action("open_bag") or event.is_action("open_help"):
		get_viewport().set_input_as_handled()

func close_page() -> void:
	_confirm.hide()
	_root.hide()
	GameManager.set_modal_open(MODAL,false)
	for surface: Node in get_tree().get_nodes_in_group("memory_dialogue_surface"):
		if surface.is_visible_in_tree(): surface.record_current_memory_beat()
	if is_instance_valid(_previous_focus) and _previous_focus.is_visible_in_tree(): _previous_focus.grab_focus()
	_previous_focus = null

func _exit_tree() -> void:
	GameManager.set_modal_open(MODAL,false)
	if active == self: active = null
