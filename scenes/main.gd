extends Node2D
## A assembles D's opening and manager dialogue; task UI/work/checkpoint remain pending.

const STORY_MODAL: String = "STORY_DIALOGUE"
var _active_dialogue_id: String = ""

@onready var state_label: Label = $DeveloperOverlay/Margin/Info/State
@onready var notice_label: Label = $DeveloperOverlay/Margin/Info/Notice
@onready var dialogue: Control = $StoryLayer/Dialogue


func _ready() -> void:
	GameManager.state_changed.connect(_on_state_changed)
	CardManager.cards_changed.connect(_on_cards_changed)
	GameManager.floor_changed.connect(_on_floor_changed)
	GameManager.game_failed.connect(_on_game_failed)
	GameManager.safe_return_started.connect(_on_safe_return_started)
	GameManager.modal_changed.connect(_sync_story_controls)
	dialogue.dialogue_finished.connect(_on_dialogue_finished)
	$DeveloperOverlay/Margin/Info/NewGame.pressed.connect(_start_session)
	GameManager.set_floor_host($World)
	_start_session()


func _input(event: InputEvent) -> void:
	if not _active_dialogue_id.is_empty() and event.is_action("switch_id"):
		get_viewport().set_input_as_handled()


func _start_session() -> void:
	_active_dialogue_id = ""
	dialogue.hide()
	GameManager.start_game()
	_show_story_dialogue("V4_INTRO")


func _show_story_dialogue(dialogue_id: String) -> void:
	if not _active_dialogue_id.is_empty() or not GameManager.is_world_input_allowed():
		return
	_active_dialogue_id = dialogue_id
	$DeveloperOverlay.hide()
	GameManager.set_modal_open(STORY_MODAL, true)
	dialogue.show_dialogue(dialogue_id)


func _on_dialogue_finished(dialogue_id: String) -> void:
	if dialogue_id != _active_dialogue_id:
		return
	_active_dialogue_id = ""
	$DeveloperOverlay.show()
	if dialogue_id == "V4_MANAGER_TALK":
		GameManager.complete_manager_intro()
	GameManager.set_modal_open(STORY_MODAL, false)
	_show_notice("经理交谈完成 · 右端楼梯可上 2F" if dialogue_id == "V4_MANAGER_TALK" else "到前台找经理，靠近后按 E 交谈")


func _sync_story_controls() -> void:
	if $World.get_child_count() > 0:
		$World.get_child(0).get_node("Player").set_movement_locked(not GameManager.is_world_input_allowed())


func _exit_tree() -> void:
	GameManager.set_modal_open(STORY_MODAL, false)


func _on_state_changed(new_state: String) -> void:
	state_label.text = "状态：%s · %dF · 已获：%d/3 · 双槽：%s · 当前：%s" % [
		new_state, GameManager.current_floor, CardManager.get_owned_cards().size(),
		CardManager.get_equipped_cards(), CardManager.active_card
	]


func _on_cards_changed() -> void:
	_on_state_changed(GameManager.game_state)


func _on_floor_changed(_number: int) -> void:
	var floor_node: Node = $World.get_child(0)
	floor_node.notice_requested.connect(_show_notice)
	floor_node.manager_talk_requested.connect(_on_manager_talk_requested)
	notice_label.text = "前台经理可按 E 交谈；201 已接真实门，任务页面／清理／重试待交付"
	_on_state_changed(GameManager.game_state)


func _on_manager_talk_requested() -> void:
	if not GameManager.has_completed_manager_intro():
		_show_story_dialogue("V4_MANAGER_TALK")


func _show_notice(message: String) -> void:
	notice_label.text = message


func _on_game_failed(reason: String) -> void:
	_show_notice("偷窃被发现 · 可点开发新局重新测试" if reason == "STAFF_CAUGHT" else "失败：" + reason)


func _on_safe_return_started(reason: String) -> void:
	_show_notice("普通门警告：%s · 已退回来侧，请观察后重试" % reason)
