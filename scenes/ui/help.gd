extends Control

const PAGE_COUNT := 2
const MODAL_ID := "help"

var _previous_focus: Control
var _page_index := 0

@onready var _page_title: Label = %PageTitle
@onready var _work_card_page: Control = %WorkCardPage
@onready var _monster_page: Control = %MonsterPage
@onready var _page_indicator: Label = %PageIndicator
@onready var _previous_button: Button = %PreviousButton
@onready var _next_button: Button = %NextButton


func _ready() -> void:
	visibility_changed.connect(_sync_modal_state)
	_show_page(0)
	_sync_modal_state()


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
	_show_page(0)
	show()
	%CloseButton.grab_focus()


func close_help() -> void:
	hide()
	if is_instance_valid(_previous_focus) and _previous_focus.is_visible_in_tree():
		_previous_focus.grab_focus()
	_previous_focus = null


func next_page() -> void:
	_show_page(mini(_page_index + 1, PAGE_COUNT - 1))


func previous_page() -> void:
	_show_page(maxi(_page_index - 1, 0))


func _show_page(page_index: int) -> void:
	_page_index = clampi(page_index, 0, PAGE_COUNT - 1)
	_work_card_page.visible = _page_index == 0
	_monster_page.visible = _page_index == 1
	_page_title.text = "工作证规则" if _page_index == 0 else "怪物判定"
	_page_indicator.text = "%d / %d" % [_page_index + 1, PAGE_COUNT]
	_previous_button.disabled = _page_index == 0
	_next_button.disabled = _page_index == PAGE_COUNT - 1
