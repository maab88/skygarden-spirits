class_name BoardState
extends RefCounted

var width: int
var height: int
var cells: Array = []

func _init(board_width: int = 8, board_height: int = 8, fill_value: int = TileState.EMPTY) -> void:
	width = max(1, board_width)
	height = max(1, board_height)
	_create_grid(fill_value)

func in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.y >= 0 and pos.x < width and pos.y < height

func get_cell(pos: Vector2i) -> int:
	if not in_bounds(pos):
		return TileState.EMPTY
	return cells[pos.y][pos.x]

func set_cell(pos: Vector2i, value: int) -> bool:
	if not in_bounds(pos):
		return false
	cells[pos.y][pos.x] = value
	return true

func get_neighbors(pos: Vector2i) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	var directions: Array[Vector2i] = [
		Vector2i(0, -1),
		Vector2i(1, 0),
		Vector2i(0, 1),
		Vector2i(-1, 0)
	]

	for direction in directions:
		var neighbor := pos + direction
		if in_bounds(neighbor):
			results.append(neighbor)

	return results

func clone_state() -> BoardState:
	var copy := BoardState.new(width, height)
	for y in range(height):
		copy.cells[y] = cells[y].duplicate()
	return copy

func _create_grid(fill_value: int) -> void:
	cells.clear()
	for y in range(height):
		var row: Array[int] = []
		for x in range(width):
			row.append(fill_value)
		cells.append(row)
