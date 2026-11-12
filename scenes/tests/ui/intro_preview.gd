extends Control

const DialogueScreen = preload("res://scenes/ui/dialogue.gd")

@onready var dialogue: DialogueScreen = $Dialogue
@onready var start_button: Button = %StartPreview
@onready var status_label: Label = %Status

var _chain_manager := false
var _completed: Array[String] = []

func _ready() -> void:
	dialogue.set_progress_file_path_for_test("user://intro_pr_test_progress.cfg")
	dialogue.set_skip_transitions_for_test("--ui-smoke" in OS.get_cmdline_user_args())
	dialogue.reset_progress_file_for_test()
	dialogue.dialogue_finished.connect(_on_dialogue_finished)
	start_button.pressed.connect(_start_preview)
	if "--ui-smoke" in OS.get_cmdline_user_args():
		call_deferred("_run_smoke")

func _start_preview() -> void:
	_chain_manager = true
	start_button.hide()
	status_label.hide()
	dialogue.show_dialogue("V4_INTRO")

func _on_dialogue_finished(dialogue_id: String) -> void:
	_completed.append(dialogue_id)
	if dialogue_id == "V4_INTRO" and _chain_manager:
		dialogue.show_dialogue("V4_MANAGER_TALK")
	elif dialogue_id == "V4_MANAGER_TALK":
		_chain_manager = false
		status_label.text = "预览结束 · 正式楼层与线索由 A 接入"
		status_label.show()
		start_button.text = "重新预览"
		start_button.show()

func _run_smoke() -> void:
	var failures: Array[String] = []
	dialogue.set_skip_transitions_for_test(true)
	_chain_manager = false
	start_button.hide()
	dialogue.show_dialogue("V4_INTRO")
	_check(dialogue.visible and dialogue._beats.size() > 50, "V4 intro opens with full TSV content", failures)
	_check(not dialogue.get_node("%SkipButton").visible, "First-run intro cannot be skipped", failures)
	_check(dialogue.get_node("%Background").texture != null, "Intro background texture is loaded", failures)
	_check(dialogue.get_node("%SMSPanel").visible and not dialogue.get_node("%Line").visible, "SMS shown only in chat UI", failures)
	_check(dialogue.get_node("%SMSHistory").get_child_count() == 1, "First SMS appears once", failures)
	var first_index: int = dialogue._line_index
	var key := InputEventAction.new()
	key.action = "interact"
	key.pressed = true
	dialogue._unhandled_input(key)
	_check(dialogue._line_index == first_index + 1, "E action advances one beat", failures)
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	dialogue._unhandled_input(mouse)
	_check(dialogue._line_index == first_index + 2, "Mouse click advances one beat", failures)
	await _drain_dialogue(failures)
	_check(_completed == ["V4_INTRO"], "Intro completion emits V4_INTRO once", failures)
	dialogue.show_dialogue("V4_MANAGER_TALK")
	_check(not dialogue.get_node("%SkipButton").visible, "First-run manager conversation cannot be skipped", failures)
	_check(dialogue.get_node("%Portrait").texture != null and dialogue.get_node("%Speaker").text == "经理", "Manager portrait and speaker display", failures)
	await _drain_dialogue(failures)
	_check(_completed == ["V4_INTRO", "V4_MANAGER_TALK"], "Manager completion emits its own ID once", failures)
	_check(dialogue.has_completed_intro(), "Read flag saved only after manager conversation", failures)
	dialogue.show_dialogue("V4_INTRO")
	_check(dialogue.get_node("%SkipButton").visible, "Completed intro can be skipped on replay", failures)
	dialogue.get_node("%SkipButton").pressed.emit()
	_check(_completed == ["V4_INTRO", "V4_MANAGER_TALK", "V4_INTRO"], "Replay skip emits intro completion once", failures)
	dialogue.reset_progress_file_for_test()
	if failures.is_empty():
		print("PASS: V4 opening preview, first-run lock, SMS rendering, one-beat E/mouse input, manager display, separate completion IDs and replay skip.")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)

func _drain_dialogue(failures: Array[String]) -> void:
	var guard := 0
	while dialogue.visible and guard < 200:
		var previous_index: int = dialogue._line_index
		dialogue.get_node("%ContinueButton").pressed.emit()
		await get_tree().process_frame
		guard += 1
		if dialogue.visible and dialogue._dialogue_id != "" and dialogue._line_index == previous_index and not dialogue._transition_in_progress:
			_check(false, "Continue advances or completes a beat", failures)
	_check(guard < 200, "Dialogue sequence terminates", failures)

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
