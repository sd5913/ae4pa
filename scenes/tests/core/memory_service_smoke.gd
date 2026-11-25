extends SceneTree

class StorageHost:
	extends Node
	var revision := 1
	var restored_revision := 0
	func can_save_memory() -> Dictionary:
		return {"allowed": true, "reason": ""}
	func capture_memory_document_state() -> Dictionary:
		return {"test_fixture": true, "revision": revision}
	func validate_memory_document_state(state: Dictionary) -> bool:
		return state.get("test_fixture") == true and (state.get("revision") is int or state.get("revision") is float)
	func restore_memory_document(document: Dictionary) -> bool:
		if not validate_memory_document_state(document.get("state", {})): return false
		restored_revision = int(document.state.revision)
		return true

func _initialize() -> void:
	run.call_deferred()

func _slot(slots: Array, slot_id: int) -> Dictionary:
	for slot: Dictionary in slots:
		if slot.get("slot_id") == slot_id: return slot
	return {}

func _write(path: String, text: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null: return false
	file.store_string(text)
	file.close()
	return true

func _remove_tree(path: String) -> void:
	var directory := DirAccess.open(path)
	if directory == null: return
	for file_name: String in directory.get_files():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path.path_join(file_name)))
	for child_name: String in directory.get_directories():
		_remove_tree(path.path_join(child_name))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func run() -> void:
	var script: GDScript = load("res://scripts/memory_service.gd") as GDScript
	if script == null:
		push_error("memory service script is missing")
		quit(1)
		return
	var service: Node = script.new()
	root.add_child(service)
	var test_root := "user://memory_service_smoke_%d" % Time.get_ticks_usec()
	service.storage_root = test_root
	var slots: Array = service.list_memory_slots()
	var ids: Array[int] = []
	var empty := true
	for slot: Dictionary in slots:
		ids.append(int(slot.get("slot_id", -99)))
		empty = empty and slot.get("status") == "EMPTY"
	var valid_ids: Array[int] = [0, 1, 2, 3, 4, 5, -1]
	var passed := ids == valid_ids and empty
	print("MEMORY_SERVICE_EMPTY_SLOTS: ", "PASS" if passed else "FAIL slots=%s" % [str(slots)])
	passed = passed and not service.save_memory(-1).ok and not service.save_memory(0).ok
	var host := StorageHost.new()
	root.add_child(host)
	service.configure_host(host)
	var primary: String = service.storage_root.path_join("manual_0.json")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(test_root))
	var metadata := {"saved_at": "legacy", "location": "0F", "task_name": "", "play_time": "00:00", "play_time_seconds": 0.0, "has_friend": false}
	var legacy := JSON.stringify({"schema_version": 1, "game_build": "1", "slot_id": 0, "saved_at_unix": 1, "metadata": metadata, "state": {"test_fixture": true, "revision": 1}})
	passed = passed and _write(primary, legacy)
	passed = passed and service.load_memory(0).ok and host.restored_revision == 1
	host.revision = 2
	var first_save: Dictionary = service.save_memory(0)
	host.revision = 3
	var second_save: Dictionary = service.save_memory(0)
	var generations: Array[String] = []
	var directory := DirAccess.open(service.storage_root)
	if directory != null:
		for name: String in directory.get_files():
			if name.begins_with("manual_0.json.gen_") and name.ends_with(".json"):
				generations.append(name)
	generations.sort()
	var immutable_generations: bool = first_save.ok and second_save.ok and generations.size() == 2 and FileAccess.get_file_as_string(primary) == legacy
	print("MEMORY_SERVICE_IMMUTABLE_GENERATIONS: ", "PASS" if immutable_generations else "FAIL")
	passed = passed and immutable_generations
	var corrupt_path: String = service.storage_root.path_join("manual_1.json")
	_write(corrupt_path, "{broken")
	var corrupt_before := FileAccess.get_file_as_string(corrupt_path)
	var incompatible_path: String = service.storage_root.path_join("manual_2.json")
	_write(incompatible_path, JSON.stringify({"schema_version": 77, "game_build": "1", "slot_id": 2}))
	var incompatible_before := FileAccess.get_file_as_string(incompatible_path)
	if not generations.is_empty():
		var newest := test_root.path_join(generations.back())
		var newest_bytes := FileAccess.get_file_as_string(newest)
		# A complete temporary file is not committed.
		_write(test_root.path_join("manual_0.json.gen_99999999999999999999_00000000000000000000000000000000.json.tmp"), newest_bytes)
		_write(newest, "{broken")
	slots = service.list_memory_slots()
	var recovered := _slot(slots, 0)
	var corrupt := _slot(slots, 1)
	var incompatible := _slot(slots, 2)
	var load_result: Dictionary = service.load_memory(0)
	passed = passed and recovered.get("status") == "VALID" and recovered.get("recovered_from_backup") == true
	passed = passed and corrupt.get("status") == "CORRUPT" and incompatible.get("status") == "INCOMPATIBLE"
	passed = passed and FileAccess.get_file_as_string(corrupt_path) == corrupt_before and FileAccess.get_file_as_string(incompatible_path) == incompatible_before
	passed = passed and load_result.ok and host.restored_revision == 2
	print("MEMORY_SERVICE_BACKUP_AND_REJECTION: ", "PASS" if passed else "FAIL recovered=%s corrupt=%s incompatible=%s load=%s" % [str(recovered), str(corrupt), str(incompatible), str(load_result)])
	var blocker := test_root.path_join("write_blocker")
	_write(blocker, "not a directory")
	service.storage_root = blocker.path_join("child")
	var failed_write: Dictionary = service.save_memory(3)
	passed = passed and not failed_write.ok
	print("MEMORY_SERVICE_WRITE_FAILURE: ", "PASS" if not failed_write.ok else "FAIL wrote=%s" % str(failed_write))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(blocker))
	_remove_tree(test_root)
	service.queue_free()
	host.queue_free()
	print("MEMORY_SERVICE_SMOKE: ", "PASS" if passed else "FAIL")
	quit(0 if passed else 1)
