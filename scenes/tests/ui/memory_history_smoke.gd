extends SceneTree

const History = preload("res://scenes/ui/memory_history.gd")

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	History.reset_session()
	History.record("reunion:RESCUE_309:beat_01", "Terese", "You came back.", "309", {"chapter": "reunion"})
	var payload: Dictionary = History.export_ui_history()
	var restored := History.restore_ui_history(payload)
	History.record("reunion:RESCUE_309:beat_01", "Terese", "You came back.", "309", {"chapter": "reunion"})
	var passed := restored and History.entries.size() == 1
	print("MEMORY_HISTORY_RESTORE_DEDUP: ", "PASS" if passed else "FAIL entries=%d" % History.entries.size())
	quit(0 if passed else 1)
