class_name LevelCatalog
extends RefCounted

const LEVEL_IDS: Array[String] = [
	"level_001",
	"level_002",
	"level_003",
	"level_004",
	"level_005",
	"level_006",
	"level_007",
	"level_008",
	"level_009",
	"level_010"
]

static func get_level_path(level_id: String) -> String:
	return "res://data/levels/%s.json" % level_id

static func get_level_index(level_id: String) -> int:
	return LEVEL_IDS.find(level_id)

static func get_next_level_id(level_id: String) -> String:
	var index := get_level_index(level_id)
	if index == -1:
		return ""

	var next_index := index + 1
	if next_index >= LEVEL_IDS.size():
		return ""
	return LEVEL_IDS[next_index]
