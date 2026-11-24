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
	if token.is_empty() or source.is_empty() or _seen.has(token): return
	_seen[token] = true
	entries.append({"token":token, "speaker":speaker, "source":source, "chapter":chapter, "parameters":parameters.duplicate(true)})

static func text(entry: Dictionary) -> String:
	var value := TranslationServer.translate(str(entry.get("source", "")))
	for key: String in entry.get("parameters", {}): value = value.replace("{"+key+"}", str(entry.parameters[key]))
	return value

static func name_for(id: String) -> String:
	if Roles.ROLES.has(id): return Roles.display_name(id)
	if id == "TERESE": return TranslationServer.translate("Terese")
	if id == "NARRATOR": return TranslationServer.translate("旁白")
	if id in ["女主", "安", "CAROL", "Carol"]: return "Carol"
	if id in ["闺蜜", "friend", "Terese", "Persica"]: return "Terese"
	return TranslationServer.translate({"SECURITY":"保安", "CLEANER":"保洁", "MANAGER":"经理"}.get(id,id))

static func export_ui_history() -> Dictionary:
	return {"version":2, "entries":entries.duplicate(true)}

static func validate_ui_history(value: Dictionary) -> bool:
	if value.get("version") != 2 or not value.get("entries") is Array: return false
	var tokens: Dictionary = {}
	for entry: Variant in value.entries:
		if not entry is Dictionary or not entry.get("token") is String or str(entry.token).is_empty(): return false
		if not entry.get("speaker") is String or not entry.get("source") is String or str(entry.source).is_empty(): return false
		if not entry.get("chapter") is String or not entry.get("parameters", {}) is Dictionary: return false
		if tokens.has(entry.token): return false
		tokens[entry.token] = true
	return true

static func restore_ui_history(value: Dictionary) -> bool:
	if not validate_ui_history(value): return false
	reset_session()
	entries.assign(value.entries.duplicate(true))
	for entry: Dictionary in entries: _seen[entry.token] = true
	return true
