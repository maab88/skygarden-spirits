class_name ProgressionService
extends RefCounted
const LevelCatalog = preload("res://scripts/data/level_catalog.gd")

const SAVE_PATH := "user://progression.save"
const DEFAULT_HIGHEST_UNLOCKED_INDEX := 0

static func get_highest_unlocked_index() -> int:
	var data := _load_data()
	if not data.has("highest_unlocked_index"):
		return DEFAULT_HIGHEST_UNLOCKED_INDEX
	return max(DEFAULT_HIGHEST_UNLOCKED_INDEX, int(data["highest_unlocked_index"]))

static func is_level_unlocked(level_id: String) -> bool:
	var level_index := LevelCatalog.get_level_index(level_id)
	if level_index == -1:
		return false
	return level_index <= get_highest_unlocked_index()

static func unlock_level(level_id: String) -> void:
	var level_index := LevelCatalog.get_level_index(level_id)
	if level_index == -1:
		return

	var highest := get_highest_unlocked_index()
	if level_index <= highest:
		return

	_save_data({"highest_unlocked_index": level_index})

static func unlock_next_level(current_level_id: String) -> void:
	var next_level_id := LevelCatalog.get_next_level_id(current_level_id)
	if next_level_id.is_empty():
		return
	unlock_level(next_level_id)

static func _load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {"highest_unlocked_index": DEFAULT_HIGHEST_UNLOCKED_INDEX}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Could not open progression save, using defaults.")
		return {"highest_unlocked_index": DEFAULT_HIGHEST_UNLOCKED_INDEX}

	var json := JSON.new()
	var parse_result := json.parse(file.get_as_text())
	if parse_result != OK or typeof(json.data) != TYPE_DICTIONARY:
		push_warning("Invalid progression save data, using defaults.")
		return {"highest_unlocked_index": DEFAULT_HIGHEST_UNLOCKED_INDEX}

	var data: Dictionary = json.data
	if not data.has("highest_unlocked_index"):
		data["highest_unlocked_index"] = DEFAULT_HIGHEST_UNLOCKED_INDEX
	return data

static func _save_data(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not write progression save.")
		return
	file.store_string(JSON.stringify(data))

static func get_save_path() -> String:
	return ProjectSettings.globalize_path(SAVE_PATH)

static func reset_progress() -> void:
	var absolute_path := get_save_path()
	if not FileAccess.file_exists(absolute_path):
		return

	var remove_result := DirAccess.remove_absolute(absolute_path)
	if remove_result != OK:
		push_warning("Could not remove progression save at: %s" % absolute_path)
