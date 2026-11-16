extends Node2D
## A assembles D dialogue/task UI with real B/C gameplay and checkpoint recovery.

const STORY_MODAL: String = "STORY_DIALOGUE"
var _active_dialogue_id: String = ""

@onready var state_label: Label = $DeveloperOverlay/Margin/Info/State
@onready var notice_label: Label = $DeveloperOverlay/Margin/Info/Notice
@onready var dialogue: Control = $StoryLayer/Dialogue
@onready var objective_label: Label = $DeveloperOverlay/Margin/Info/Objective
@onready var menu: Control = $MenuLayer/MainMenu
@onready var notebook: Control = $MenuLayer/Notebook
@onready var bag: Control = $MenuLayer/Bag


func _ready() -> void:
	GameManager.state_changed.connect(_on_state_changed)
	CardManager.cards_changed.connect(_on_cards_changed)
	GameManager.floor_changed.connect(_on_floor_changed)
	GameManager.game_failed.connect(_on_game_failed)
	GameManager.safe_return_started.connect(_on_safe_return_started)
	GameManager.modal_changed.connect(_sync_story_controls)
	GameManager.task_offered.connect(_on_task_offered)
	GameManager.task_updated.connect(_refresh_objective)
	dialogue.dialogue_finished.connect(_on_dialogue_finished)
	$DeveloperOverlay/Margin/Info/NewGame.pressed.connect(_start_session)
	$TaskLayer.menu_requested.connect(_show_menu)
	menu.start_requested.connect(_start_session)
	menu.help_requested.connect(notebook.open_help)
	notebook.set_process_unhandled_input(false)
	bag.set_process_unhandled_input(false)
	GameManager.set_floor_host($World)
	GameManager.start_game()
	_show_menu()


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("open_help"):
		if notebook.visible:
			notebook.close_help()
		elif menu.visible or GameManager.is_world_input_allowed():
			notebook.open_help()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("open_bag"):
		if bag.visible:
			bag.close_bag()
		elif GameManager.is_world_input_allowed():
			bag.open_bag()
		get_viewport().set_input_as_handled()
	elif notebook.visible or bag.visible or menu.visible:
		if event.is_action_pressed("switch_id") or event.is_action_pressed("interact"):
			get_viewport().set_input_as_handled()
	elif not _active_dialogue_id.is_empty() and event.is_action("switch_id"):
		get_viewport().set_input_as_handled()


func _show_menu() -> void:
	_active_dialogue_id = ""
	dialogue.hide()
	notebook.close_help()
	bag.close_bag()
	$TaskLayer.close_views()
	GameManager.return_to_menu()
	$DeveloperOverlay.hide()
	$TaskLayer.hide()
	menu.show()
	menu.get_node("%StartButton").grab_focus()


func _start_session() -> void:
	menu.hide()
	notebook.close_help()
	bag.close_bag()
	_active_dialogue_id = ""
	dialogue.hide()
	$TaskLayer.close_views()
	GameManager.start_game()
	_show_story_dialogue("V4_INTRO")


func _show_story_dialogue(dialogue_id: String) -> void:
	if not _active_dialogue_id.is_empty() or not GameManager.is_world_input_allowed():
		return
	_active_dialogue_id = dialogue_id
	$DeveloperOverlay.hide()
	$TaskLayer.hide()
	GameManager.set_modal_open(STORY_MODAL, true)
	dialogue.show_dialogue(dialogue_id)


func _on_dialogue_finished(dialogue_id: String) -> void:
	if dialogue_id != _active_dialogue_id:
		return
	_active_dialogue_id = ""
	$DeveloperOverlay.show()
	$TaskLayer.show()
	if dialogue_id == "V4_MANAGER_TALK":
		GameManager.complete_manager_intro()
	GameManager.set_modal_open(STORY_MODAL, false)
	_show_notice("经理交谈完成 · 从右端楼梯上 2F，向右找到 201 房门接任务" if dialogue_id == "V4_MANAGER_TALK" else "到前台找经理，靠近后按 E 交谈")
	_refresh_objective()


func _sync_story_controls() -> void:
	if $World.get_child_count() > 0:
		$World.get_child(0).get_node("Player").set_movement_locked(not GameManager.is_world_input_allowed())


func _exit_tree() -> void:
	notebook.close_help()
	bag.close_bag()
	GameManager.set_modal_open(STORY_MODAL, false)


func _on_state_changed(new_state: String) -> void:
	if new_state in ["FAILED", "RESTORING", "LOADING", "MENU"]:
		notebook.close_help()
		bag.close_bag()
	state_label.text = "状态：%s · %dF · 已获：%d/3 · 双槽：%s · 当前：%s" % [
		new_state, GameManager.current_floor, CardManager.get_owned_cards().size(),
		CardManager.get_equipped_cards(), CardManager.active_card
	]


func _on_cards_changed() -> void:
	_on_state_changed(GameManager.game_state)
	_refresh_objective()


func _on_floor_changed(_number: int) -> void:
	var floor_node: Node = $World.get_child(0)
	floor_node.notice_requested.connect(_show_notice)
	floor_node.manager_talk_requested.connect(_on_manager_talk_requested)
	floor_node.task_offer_requested.connect($TaskLayer.open_offer)
	notice_label.text = "E 交谈／楼梯／交付；工作处长按 E，Q 切换当前身份。"
	_on_state_changed(GameManager.game_state)
	_refresh_objective()


func _on_task_offered(task_id: String) -> void:
	if task_id == GameManager.TASK_01_ID:
		_show_notice("201 的客人提出清洁任务；请在面板中确认接受，接受后开始 210 秒计时。")
	_refresh_objective()


func _refresh_objective() -> void:
	if not GameManager.has_completed_manager_intro():
		objective_label.text = "当前目标：到 1F 前台找经理，靠近后按 E 交谈。"
		return
	match GameManager.task_status:
		"NONE":
			objective_label.text = "当前目标：向右找到本层的 201 房门。" if GameManager.current_floor == 2 else "当前目标：从右端楼梯上 2F，向右找到 201 房门。"
		"AVAILABLE":
			objective_label.text = "当前目标：在面板中接受 201 清洁任务；关闭后可在门前按 E 重开。"
		"ACTIVE":
			objective_label.text = "当前目标：回 1F，在保洁身后长按 E 取得工作证。" if not CardManager.has_card("CLEANER") else "当前目标：Q 切到保洁身份，回 2F 污渍处按住 E 1.5 秒清理。"
		"READY_TO_SUBMIT":
			objective_label.text = "当前目标：回 201 房门按 E 交付。"
		"COMPLETED":
			objective_label.text = "任务 01 已交付；任务 02 尚未开放。"
		"FAILED":
			objective_label.text = "任务失败；点击“重新挑战本任务”，回 201 重新接受。"


func _on_manager_talk_requested() -> void:
	if not GameManager.has_completed_manager_intro():
		_show_story_dialogue("V4_MANAGER_TALK")


func _show_notice(message: String) -> void:
	notice_label.text = message


func _on_game_failed(reason: String) -> void:
	_show_notice("偷窃被发现 · 可重新挑战本任务" if reason == "STAFF_CAUGHT" else "失败：" + reason)


func _on_safe_return_started(reason: String) -> void:
	_show_notice("普通门警告：%s · 已退回来侧，请观察后重试" % reason)
