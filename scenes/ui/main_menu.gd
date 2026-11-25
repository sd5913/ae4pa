extends Control

signal start_requested()
## Kept for the main-scene hookup; the cover no longer has a Help button.
signal help_requested()

const MemoryUI = preload("res://scenes/ui/memory_ui.gd")
const History = preload("res://scenes/ui/memory_history.gd")

var _opening: Tween
var _ready_for_input := false
var _starting := false

@onready var _title: Control = $Center/Content/TitleSlot/Title
@onready var _content: VBoxContainer = $Center/Content
@onready var _actions: VBoxContainer = $Center/Content/Actions
@onready var _blackout: ColorRect = $Blackout
@onready var _lightning: ColorRect = $Lightning
@onready var _bolt: Line2D = $LightningBolt

func _ready() -> void:
	var memory := MemoryUI.new()
	memory.name = "MemoryUI"
	add_child(memory)
	%LoadMemory.pressed.connect(func() -> void: MemoryUI.open_page("load"))
	visibility_changed.connect(_on_visibility_changed)
	resized.connect(_resize_layout)
	_resize_layout()
	if "--ui-smoke" in OS.get_cmdline_user_args():
		_finish_opening()
	else:
		_play_opening()

func _resize_layout() -> void:
	_bolt.scale = size / Vector2(1280, 720)
	_content.custom_minimum_size.x = minf(size.x * 0.76, 700.0)
	$Center/Content/TitleSlot.custom_minimum_size.y = clampf(size.y * 0.27, 100.0, 220.0)

func _set_interactive(enabled: bool) -> void:
	_ready_for_input = enabled
	for button: Button in [%StartButton, %LoadMemory, %LanguageSelector]:
		button.disabled = not enabled or (button == %LoadMemory and not MemoryUI.active.has_loadable_memory())
		button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE

func _play_opening() -> void:
	if _opening != null and _opening.is_valid():
		_opening.kill()
	_starting = false
	_set_interactive(false)
	_title.modulate.a = 0.0
	_title.offset_top = 72
	_title.offset_bottom = 72
	for button: Button in [%StartButton, %LoadMemory, %LanguageSelector]:
		button.modulate.a = 0.0
		button.scale = Vector2.ONE
	_blackout.color.a = 1.0
	_lightning.color.a = 0.0
	_bolt.modulate.a = 0.0
	_opening = create_tween()
	_opening.tween_property(_blackout, "color:a", 0.0, 0.35)
	_opening.tween_interval(0.18)
	_opening.tween_callback(_show_lightning)
	_opening.tween_property(_lightning, "color:a", 0.0, 0.22).from(0.4)
	_opening.parallel().tween_property(_bolt, "modulate:a", 0.0, 0.22)
	for pause: float in [0.09, 0.12]:
		_opening.tween_property(_blackout, "color:a", 0.92, 0.065)
		_opening.tween_interval(pause)
		_opening.tween_property(_blackout, "color:a", 0.0, 0.13)
		_opening.tween_interval(0.12)
	_opening.tween_property(_title, "offset_top", 0.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_opening.parallel().tween_property(_title, "offset_bottom", 0.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_opening.parallel().tween_property(_title, "modulate:a", 1.0, 0.6)
	_opening.tween_property(%StartButton, "modulate:a", 1.0, 0.25)
	_opening.tween_property(%LoadMemory, "modulate:a", 1.0, 0.2)
	_opening.tween_property(%LanguageSelector, "modulate:a", 1.0, 0.2)
	_opening.finished.connect(_finish_opening, CONNECT_ONE_SHOT)

func _show_lightning() -> void:
	_bolt.modulate.a = 0.85

func _finish_opening() -> void:
	if _opening != null and _opening.is_valid():
		_opening.kill()
	_opening = null
	_blackout.color.a = 0.0
	_lightning.color.a = 0.0
	_bolt.modulate.a = 0.0
	_title.offset_top = 0.0
	_title.offset_bottom = 0.0
	_title.modulate.a = 1.0
	for button: Button in [%StartButton, %LoadMemory, %LanguageSelector]:
		button.modulate.a = 1.0
	_set_interactive(true)
	if visible:
		%StartButton.grab_focus()

func _on_visibility_changed() -> void:
	if not is_node_ready():
		return
	if visible:
		if "--ui-smoke" in OS.get_cmdline_user_args():
			_starting = false
			_finish_opening()
		else:
			_play_opening()
	else:
		if _opening != null and _opening.is_valid():
			_opening.kill()
		_opening = null
		_set_interactive(false)

func _on_start_pressed() -> void:
	if not _ready_for_input or _starting:
		return
	History.reset_session()
	_starting = true
	_set_interactive(false)
	start_requested.emit()
func _process(_delta: float) -> void:
	if is_instance_valid(MemoryUI.active):
		%LoadMemory.disabled = not _ready_for_input or not MemoryUI.active.has_loadable_memory()
		%LoadMemory.tooltip_text = tr("尚未留下记忆") if not is_instance_valid(MemoryUI.active.backend) else ""
