extends SceneTree
## Real UI geometry: the original 202 English paragraph overlapped Continue.
var failures: Array[String] = []
func _initialize() -> void:
	call_deferred("_run")
func _expect(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func _settle() -> void:
	await process_frame
	await process_frame
	await process_frame
func _run() -> void:
	var dialogue: Control = load("res://scenes/ui/dialogue.tscn").instantiate()
	root.add_child(dialogue)
	var lines: Array[String] = [
		"按Q把保安证切为当前身份，再到我门前的保管柜按E领取包裹。只放在备用槽不行。",
		"取到后回202按E交付，我才会开放通往三楼的路。现在请确认是否接受。",
	]
	for locale in ["en", "zh_CN"]:
		root.get_node("Localization").set_language(locale)
		dialogue.show_task_dialogue("LAYOUT_TEST", "独眼客 · 202", lines)
		for i in lines.size():
			await _settle()
			var text: Label = dialogue.get_node("%Line")
			var button: Button = dialogue.get_node("%ContinueButton")
			var frame: Control = dialogue.get_node("%DialogueFrame")
			_expect(text.get_global_rect().end.y <= button.get_global_rect().position.y - 8, "Dialogue text reserves a footer gap in " + locale)
			_expect(frame.get_global_rect().encloses(text.get_global_rect()), "Dialogue frame contains complete text in " + locale)
			_expect(text.get_visible_line_count() == text.get_line_count(), "All dialogue lines remain visible in " + locale)
			dialogue.call("_on_continue_pressed")
	var hud: Control = load("res://scenes/ui/hud.tscn").instantiate()
	root.add_child(hud)
	var cards := root.get_node("CardManager")
	cards.collect_card("CLEANER")
	cards.collect_card("SECURITY")
	root.get_node("Localization").set_language("en")
	await _settle()
	for path in ["Stack/Readout/SlotA", "Stack/Readout/SlotB"]:
		var slot: Control = hud.get_node(path)
		var caption: Label = slot.get_node("SlotAValue" if path.ends_with("A") else "SlotBValue")
		_expect(slot.get_global_rect().encloses(caption.get_global_rect()), "HUD slot reserves enough space for its caption")
	dialogue.queue_free()
	hud.queue_free()
	await process_frame
	root.get_node("Localization").set_language("zh_CN")
	for message in failures: printerr("FAIL: ", message)
	print("ENGLISH_LAYOUT: PASS" if failures.is_empty() else "ENGLISH_LAYOUT: FAIL")
	quit(0 if failures.is_empty() else 1)
