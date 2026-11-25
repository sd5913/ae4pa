extends Node
## Host integration only. CG owns presentation; GameManager owns rescue facts.
const MODAL := "ROOM309_REUNION"
var cg: Control
var layer: CanvasLayer
var _saved_layers: Dictionary = {}
var _floor: Node

func _ready() -> void:
	GameManager.floor_changed.connect(_bind_floor.unbind(1))
	GameManager.friend_rescued.connect(_sync_follower)
	GameManager.state_changed.connect(_state_changed)
	_bind_floor.call_deferred()

func _bind_floor() -> void:
	var world: Node = get_parent().get_node("World")
	if world.get_child_count() == 0: return
	_floor = world.get_child(0)
	if not _floor.rescue_open_requested.is_connected(open_reunion):
		_floor.rescue_open_requested.connect(open_reunion)
	_sync_follower()

func open_reunion() -> void:
	if is_instance_valid(cg) or not GameManager.is_world_input_allowed() or GameManager.current_floor != 3 or GameManager.has_friend: return
	if CardManager.active_card != "CLEANER" or not GameManager.get_completed_task_ids().has(GameManager.TASK_03_ID) or not GameManager.get_world_flags().get("registration_309_approved", false): return
	GameManager.set_modal_open(MODAL, true)
	for name in ["DeveloperOverlay", "TaskLayer", "MenuLayer", "StoryLayer"]:
		var node: CanvasLayer = get_parent().get_node(name)
		_saved_layers[name] = node.visible
		node.hide()
	layer = CanvasLayer.new()
	layer.layer = 50
	get_parent().add_child(layer)
	cg = load("res://cg309_reunion/reunion_cg.tscn").instantiate()
	cg.auto_play = false
	layer.add_child(cg)
	cg.beat_displayed.connect(_record_displayed_beat)
	cg.rescue_cg_finished.connect(_finished, CONNECT_ONE_SHOT)
	var confirmation := Label.new()
	confirmation.text = "309 · 保洁身份确认\n门锁已打开"
	confirmation.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	confirmation.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirmation.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	confirmation.add_theme_font_size_override("font_size", 24)
	layer.add_child(confirmation)
	var started: Control = cg
	get_tree().create_timer(0.5).timeout.connect(func() -> void:
		if is_instance_valid(started) and cg == started:
			confirmation.queue_free()
			cg.play()
	)

func _record_displayed_beat(token: String, speaker: String, source: String, parameters: Dictionary) -> void:
	preload("res://scenes/ui/memory_history.gd").record(token, speaker, source, "309_REUNION", parameters)

func _finished() -> void:
	# No frame or input dispatch between releasing our modal and the real API.
	GameManager.set_modal_open(MODAL, false)
	var succeeded := GameManager.rescue_friend()
	cancel()
	get_parent()._show_notice(GameManager.get_story_objective() if succeeded else "救援未结算：请确认309前置与其他模态状态。")
	get_viewport().set_input_as_handled()

func _sync_follower() -> void:
	if not GameManager.has_friend or not is_instance_valid(_floor) or _floor.has_node("Persica"): return
	var follower := preload("res://scenes/persica_follower.gd").new()
	follower.name = "Persica"
	_floor.add_child(follower)
	follower.setup(_floor.get_node("Player"))

func cancel() -> void:
	if is_instance_valid(cg): cg.cancel()
	if is_instance_valid(layer): layer.queue_free()
	cg = null
	for name: String in _saved_layers:
		get_parent().get_node(name).visible = _saved_layers[name]
	_saved_layers.clear()
	GameManager.set_modal_open(MODAL, false)

func _state_changed(state: String) -> void:
	if state in ["MENU", "LOADING", "FAILED", "RESTORING", "WON"]: cancel()
	if state == "MENU" and is_instance_valid(_floor):
		var follower := _floor.get_node_or_null("Persica")
		if follower != null: follower.queue_free()

func _exit_tree() -> void:
	cancel()
