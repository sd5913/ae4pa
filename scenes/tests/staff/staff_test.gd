extends Node2D

@onready var player: HotelPlayer = $Corridor/Player
@onready var status_label: Label = $TestLabel/Label
@onready var staff_members: Array[Node] = [
	$StaffMembers/Security,
	$StaffMembers/Cleaner,
	$StaffMembers/Manager,
]


func _ready() -> void:
	GameManager.start_game()
	for staff: Node in staff_members:
		staff.setup(player)
	CardManager.cards_changed.connect(_update_status)
	CardManager.identity_changed.connect(_on_identity_changed)
	_update_status()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_1:
			CardManager.equip_card("SECURITY", 0)
		KEY_2:
			CardManager.equip_card("CLEANER", 1)
		KEY_3:
			CardManager.equip_card("MANAGER", 0)
		KEY_0:
			CardManager.equip_card("NONE", CardManager.active_slot)


func _on_identity_changed(_action: String) -> void:
	_update_status()


func _update_status() -> void:
	status_label.text = (
		"STAFF TEST | A/D move, stand behind, hold E 0.8s, Q switch identity\n"
		+ "Test equip: 1=SECURITY→A, 2=CLEANER→B, 3=MANAGER→A, 0=clear active slot\n"
		+ "Owned: %s | Slots: %s | Active slot: %d | Identity: %s"
		% [
			CardManager.get_owned_cards(),
			CardManager.get_equipped_cards(),
			CardManager.active_slot,
			CardManager.active_card,
		]
	)
