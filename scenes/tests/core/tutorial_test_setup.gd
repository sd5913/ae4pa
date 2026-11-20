extends RefCounted
## API-only prerequisite fixture for legacy309/known-door tests. Not full tutorial evidence.
## five_monster_main_flow_smoke instead obtains cards/works/deliveries in the actual world.
static func complete_remaining(game: Node, cards: Node, main: Node = null, restore_cards: bool = true) -> bool:
	var original: Dictionary = cards.export_snapshot()
	var screen: Control = main.get_node("TaskLayer/MonsterDialogue") if main != null else null
	for id: String in ["TASK_T03_ROOM_SERVICE", "TASK_T04_DUAL_WORK", "TASK_T05_TRANSIT"]:
		if not game.offer_task(id): return false
		_drain(screen)
		if not game.accept_task(id): return false
		var definition: Dictionary = game.get_task_definition(id)
		for card: String in definition["required_cards"]:
			if not cards.has_card(card): cards.collect_card(card)
		for i: int in range(definition["required_cards"].size()): cards.equip_card(definition["required_cards"][i], i)
		for work: Dictionary in definition["work_steps"]:
			if cards.active_card != work["required_card"]: cards.switch_active()
			if not game.record_work_result(work["target_id"]): return false
		if not game.submit_task(id): return false
		_drain(screen)
	for kind in ["NOSE", "EYE", "HAT", "EAR", "CHECKER"]: game.get("_seen_monsters")[kind] = true
	# Deliberate missing-manager fixture keeps legacy309 theft/identity/retry edge coverage.
	if restore_cards: cards.restore_snapshot(original)
	return true
static func _drain(screen: Control) -> void:
	if screen == null: return
	for i in range(80):
		if not screen.visible: return
		screen.advance()
