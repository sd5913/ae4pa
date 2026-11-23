extends RefCounted
## Session-only displayed dialogue. Disk persistence must be included in A's save transaction.
const Roles = preload("res://scenes/ui/dialogue_roles.gd")
static var entries: Array[Dictionary] = []
static var _seen: Dictionary = {}
static var generation := 0

static func reset_session() -> void:
	entries.clear()
	_seen.clear()
	generation += 1

static func record(token: String, speaker: String, source: String, chapter: String, parameters: Dictionary = {}) -> void:
	if source.is_empty() or _seen.has(token): return
	_seen[token] = true
	entries.append({"speaker":speaker, "source":source, "chapter":chapter, "parameters":parameters.duplicate(true)})

static func text(entry: Dictionary) -> String:
	var value := TranslationServer.translate(str(entry.get("source", "")))
	for key: String in entry.get("parameters", {}): value = value.replace("{"+key+"}", str(entry.parameters[key]))
	return value

static func name_for(id: String) -> String:
	if Roles.ROLES.has(id): return Roles.display_name(id)
	if id in ["女主", "安", "CAROL", "Carol"]: return "Carol"
	if id in ["闺蜜", "friend", "Terese", "Persica"]: return "Terese"
	return TranslationServer.translate({"SECURITY":"保安", "CLEANER":"保洁", "MANAGER":"经理"}.get(id,id))

static func export_ui_history() -> Dictionary:
	return {"version":1, "entries":entries.duplicate(true)}

static func restore_ui_history(value: Dictionary) -> bool:
	if value.get("version") != 1 or not value.get("entries") is Array: return false
	for entry in value.entries:
		if not entry is Dictionary or not entry.get("source") is String or not entry.get("speaker") is String or not entry.get("parameters", {}) is Dictionary: return false
	reset_session()
	entries.assign(value.entries.duplicate(true))
	return true
