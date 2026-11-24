extends Node
## A-owned durable memory storage and UI adapter. World state stays with its owners.

const SAVE_VERSION := 1
const DEFAULT_STORAGE_ROOT := "user://memory"
const SLOT_IDS: Array[int] = [0, 1, 2, 3, 4, 5, -1]
const GAME_BUILD := "1"

var storage_root: String = DEFAULT_STORAGE_ROOT
var _host: Node
var _backup_serial := 0

func configure_host(host: Node) -> void:
	_host = host

func list_memory_slots() -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	for slot_id: int in SLOT_IDS:
		var result := _read_slot(slot_id)
		var slot: Dictionary = {"slot_id": slot_id, "status": result.status}
		if result.status == "VALID":
			slot.merge(result.document.metadata, true)
			slot["recovered_from_backup"] = bool(result.get("recovered_from_backup", false))
		elif result.status not in ["EMPTY"]:
			slot["error"] = result.get("error", "记忆暂时无法读取")
		slots.append(slot)
	return slots

func can_save_memory() -> Dictionary:
	if not is_instance_valid(_host):
		return {"allowed": false, "reason": "完整存档服务尚未就绪"}
	if not _host.has_method("can_save_memory"):
		return {"allowed": false, "reason": "完整存档服务尚未就绪"}
	return _host.can_save_memory()

func save_memory(slot_id: int) -> Dictionary:
	if slot_id not in range(6):
		return _failure("自动记忆只由系统写入")
	return _save_slot(slot_id, false)

func save_automatic_memory() -> Dictionary:
	return _save_slot(-1, true)

func _save_slot(slot_id: int, automatic: bool) -> Dictionary:
	if slot_id not in SLOT_IDS or (slot_id == -1) != automatic:
		return _failure("自动记忆只由系统写入")
	var permission := can_save_memory()
	if not permission.allowed:
		return _failure(str(permission.reason))
	if not is_instance_valid(_host) or not _host.has_method("capture_memory_document_state"):
		return _failure("完整存档服务尚未就绪")
	var state: Variant = _host.capture_memory_document_state()
	if not state is Dictionary or not _host.has_method("validate_memory_document_state") or not _host.validate_memory_document_state(state):
		return _failure("记忆数据暂时无法保存")
	var now := Time.get_unix_time_from_system()
	var document := {
		"schema_version": SAVE_VERSION,
		"game_build": GAME_BUILD,
		"slot_id": slot_id,
		"saved_at_unix": int(now),
		"metadata": _make_metadata(state, int(now)),
		"state": state,
	}
	if not _commit_document(slot_id, document):
		return _failure("记忆写入失败，请稍后重试")
	return {"ok": true, "error": ""}

func load_memory(slot_id: int) -> Dictionary:
	if slot_id not in SLOT_IDS:
		return _failure("记忆暂时无法读取")
	var result := _read_slot(slot_id)
	if result.status != "VALID":
		return _failure(str(result.get("error", "记忆暂时无法读取")))
	if not is_instance_valid(_host) or not _host.has_method("restore_memory_document"):
		return _failure("完整存档服务尚未就绪")
	# The host validates every owner payload before any modal, scene, timer or data changes.
	var restored: bool = _host.restore_memory_document(result.document)
	return {"ok": restored, "error": "" if restored else "记忆暂时无法读取", "recovered_from_backup": bool(result.get("recovered_from_backup", false))}

func _make_metadata(state: Dictionary, saved_at_unix: int) -> Dictionary:
	var floor_number := int(state.get("game", {}).get("current_floor", 0))
	var task_id := str(state.get("game", {}).get("current_task_id", "NONE"))
	var task_name: String = preload("res://scripts/task_definitions.gd").get_definition(task_id).get("name", "")
	var play_seconds := int(round(float(state.get("game", {}).get("play_time_seconds", 0.0))))
	var hours := play_seconds / 3600
	var minutes := (play_seconds % 3600) / 60
	return {
		"saved_at": Time.get_datetime_string_from_unix_time(saved_at_unix, false),
		"saved_at_unix": saved_at_unix,
		"location": "%dF" % floor_number,
		"task_name": task_name,
		"play_time": "%02d:%02d" % [hours, minutes],
		"play_time_seconds": float(play_seconds),
		"has_friend": bool(state.get("game", {}).get("has_friend", false)),
	}

func _commit_document(slot_id: int, document: Dictionary) -> bool:
	if not _valid_storage_root() or not _validate_document(slot_id, document):
		return false
	if _ensure_storage_directory() != OK:
		return false
	var target := _slot_path(slot_id)
	var temporary := target + ".tmp"
	var encoded := JSON.stringify(document, "\t")
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(encoded)
	file.flush()
	var write_ok := file.get_error() == OK
	file.close()
	if not write_ok:
		return false
	var temporary_document := _parse_document(temporary)
	if not temporary_document.ok or not _validate_document(slot_id, temporary_document.document):
		return false
	if FileAccess.file_exists(target):
		_backup_serial += 1
		var backup := target + ".bak_%020d_%06d" % [int(Time.get_unix_time_from_system() * 1000000.0), _backup_serial]
		if not _copy_file(target, backup):
			return false
		# A damaged or incompatible prior document remains in the backup unchanged.
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(target)) == OK

func _read_slot(slot_id: int) -> Dictionary:
	if not _valid_storage_root():
		return {"status": "CORRUPT", "error": "记忆暂时无法读取"}
	var primary := _slot_path(slot_id)
	if not FileAccess.file_exists(primary):
		var backup_only := _read_latest_backup(slot_id)
		if backup_only.ok:
			return {"status": "VALID", "document": backup_only.document, "recovered_from_backup": true}
		if backup_only.get("exists", false):
			return {"status": backup_only.status, "error": backup_only.error}
		return {"status": "EMPTY"}
	var current := _parse_document(primary)
	if current.ok and _validate_document(slot_id, current.document):
		return {"status": "VALID", "document": current.document, "recovered_from_backup": false}
	if current.ok:
		current = {"status": "CORRUPT", "error": "记忆暂时无法读取"}
	var backup := _read_latest_backup(slot_id)
	if backup.ok:
		return {"status": "VALID", "document": backup.document, "recovered_from_backup": true}
	return {"status": current.status, "error": current.error}

func _read_latest_backup(slot_id: int) -> Dictionary:
	var directory := DirAccess.open(storage_root)
	if directory == null:
		return {"ok": false, "exists": false}
	var prefix := _slot_filename(slot_id) + ".bak_"
	var names := directory.get_files()
	names.sort()
	names.reverse()
	var found := false
	for name: String in names:
		if not name.begins_with(prefix): continue
		found = true
		var parsed := _parse_document(storage_root.path_join(name))
		if parsed.ok and _validate_document(slot_id, parsed.document):
			return {"ok": true, "exists": true, "document": parsed.document}
	return {"ok": false, "exists": found, "status": "CORRUPT", "error": "记忆暂时无法读取"}

func _parse_document(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "status": "CORRUPT", "error": "记忆暂时无法读取"}
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	var parsed: Variant = parser.data if parse_error == OK else null
	if not parsed is Dictionary:
		return {"ok": false, "status": "CORRUPT", "error": "记忆暂时无法读取"}
	if parsed.get("schema_version") != SAVE_VERSION or parsed.get("game_build") != GAME_BUILD:
		return {"ok": false, "status": "INCOMPATIBLE", "error": "此版本无法读取这段记忆"}
	return {"ok": true, "status": "VALID", "document": parsed}

func _validate_document(slot_id: int, document: Dictionary) -> bool:
	if document.get("schema_version") != SAVE_VERSION or document.get("game_build") != GAME_BUILD:
		return false
	if document.get("slot_id") != slot_id or not _is_integral_number(document.get("saved_at_unix")):
		return false
	if not document.get("metadata") is Dictionary or not document.get("state") is Dictionary:
		return false
	var metadata: Dictionary = document.metadata
	if not metadata.has_all(["saved_at", "location", "task_name", "play_time", "play_time_seconds", "has_friend"]):
		return false
	if not metadata.saved_at is String or not metadata.location is String or not metadata.task_name is String or not metadata.play_time is String:
		return false
	if not metadata.play_time_seconds is float or not metadata.has_friend is bool:
		return false
	if is_instance_valid(_host) and _host.has_method("validate_memory_document_state"):
		return _host.validate_memory_document_state(document.state)
	return false

func _copy_file(source: String, destination: String) -> bool:
	var bytes := FileAccess.get_file_as_bytes(source)
	if FileAccess.get_open_error() != OK:
		return false
	var output := FileAccess.open(destination, FileAccess.WRITE)
	if output == null:
		return false
	output.store_buffer(bytes)
	output.flush()
	var ok := output.get_error() == OK
	output.close()
	return ok and FileAccess.get_file_as_bytes(destination) == bytes

func _ensure_storage_directory() -> Error:
	if not _valid_storage_root():
		return ERR_INVALID_PARAMETER
	return DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(storage_root))

func _valid_storage_root() -> bool:
	if not storage_root.begins_with("user://"):
		return false
	for segment: String in storage_root.trim_prefix("user://").split("/"):
		if segment == "..": return false
	return true

func _slot_filename(slot_id: int) -> String:
	return "automatic.json" if slot_id == -1 else "manual_%d.json" % slot_id

func _slot_path(slot_id: int) -> String:
	return storage_root.path_join(_slot_filename(slot_id))

func _failure(reason: String) -> Dictionary:
	return {"ok": false, "error": reason}

func _is_integral_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value))
