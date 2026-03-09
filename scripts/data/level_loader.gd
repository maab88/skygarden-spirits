class_name LevelLoader
extends RefCounted

static func load_level(level_path: String) -> LevelData:
	if not FileAccess.file_exists(level_path):
		push_error("Level file not found: %s" % level_path)
		return null

	var file := FileAccess.open(level_path, FileAccess.READ)
	if file == null:
		push_error("Could not open level file: %s" % level_path)
		return null

	var json_text := file.get_as_text()
	var json := JSON.new()
	var parse_result := json.parse(json_text)
	if parse_result != OK:
		push_error(
			"JSON parse error in %s at line %d: %s" %
			[level_path, json.get_error_line(), json.get_error_message()]
		)
		return null

	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("Level JSON root must be an object: %s" % level_path)
		return null

	var data: Dictionary = json.data
	var required_fields := [
		"id",
		"name",
		"width",
		"height",
		"move_limit",
		"available_powers",
		"win_conditions",
		"lose_conditions",
		"tiles"
	]

	for field in required_fields:
		if not data.has(field):
			push_error("Missing required field '%s' in %s" % [field, level_path])
			return null

	var width := int(data["width"])
	var height := int(data["height"])
	if width <= 0 or height <= 0:
		push_error("Level width/height must be > 0 in %s" % level_path)
		return null

	if typeof(data["tiles"]) != TYPE_ARRAY:
		push_error("Field 'tiles' must be an array in %s" % level_path)
		return null

	var tile_rows: Array = data["tiles"]
	if tile_rows.size() != height:
		push_error("Tile row count does not match height in %s" % level_path)
		return null

	var parsed_tiles: Array = []
	for y in range(height):
		if typeof(tile_rows[y]) != TYPE_ARRAY:
			push_error("Tile row %d must be an array in %s" % [y, level_path])
			return null

		var row: Array = tile_rows[y]
		if row.size() != width:
			push_error("Tile column count mismatch at row %d in %s" % [y, level_path])
			return null

		var parsed_row: Array[int] = []
		for x in range(width):
			if typeof(row[x]) != TYPE_STRING:
				push_error("Tile value at (%d,%d) must be a string in %s" % [x, y, level_path])
				return null

			var tile_name := String(row[x])
			var tile_state := _tile_name_to_state(tile_name)
			if tile_state == -1:
				push_error("Unknown tile '%s' at (%d,%d) in %s" % [tile_name, x, y, level_path])
				return null
			parsed_row.append(tile_state)

		parsed_tiles.append(parsed_row)

	var available_powers: Variant = _to_string_array(data["available_powers"], "available_powers", level_path)
	var win_conditions: Variant = _to_string_array(data["win_conditions"], "win_conditions", level_path)
	var lose_conditions: Variant = _to_string_array(data["lose_conditions"], "lose_conditions", level_path)
	if available_powers == null or win_conditions == null or lose_conditions == null:
		return null

	var level := LevelData.new()
	level.id = String(data["id"])
	level.name = String(data["name"])
	level.width = width
	level.height = height
	level.move_limit = int(data["move_limit"])
	level.available_powers = available_powers
	level.win_conditions = win_conditions
	level.lose_conditions = lose_conditions
	level.tiles = parsed_tiles
	return level

static func _to_string_array(value: Variant, field_name: String, level_path: String) -> Variant:
	if typeof(value) != TYPE_ARRAY:
		push_error("Field '%s' must be an array in %s" % [field_name, level_path])
		return null

	var result: Array[String] = []
	for item in value:
		if typeof(item) != TYPE_STRING:
			push_error("Field '%s' must contain only strings in %s" % [field_name, level_path])
			return null
		result.append(String(item))
	return result

static func _tile_name_to_state(tile_name: String) -> int:
	match tile_name:
		"Empty":
			return TileState.EMPTY
		"CropDry":
			return TileState.CROP_DRY
		"CropGrowing":
			return TileState.CROP_GROWING
		"CropHarvested":
			return TileState.CROP_HARVESTED
		"Fire":
			return TileState.FIRE
		"Water":
			return TileState.WATER
		"Rock":
			return TileState.ROCK
		"Ice":
			return TileState.ICE
		_:
			return -1
