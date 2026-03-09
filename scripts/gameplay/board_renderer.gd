class_name BoardRenderer
extends Node2D

signal cell_clicked(cell_pos: Vector2i)

@export var cell_size: int = 48
@export var border_color: Color = Color(0.12, 0.12, 0.12, 1.0)

var board_state: BoardState

func set_board(new_board_state: BoardState) -> void:
	board_state = new_board_state
	queue_redraw()

func refresh() -> void:
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if board_state == null:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_event: InputEventMouseButton = event
		var local_pos := to_local(mouse_event.position)
		var cell_pos := Vector2i(
			int(floor(local_pos.x / cell_size)),
			int(floor(local_pos.y / cell_size))
		)

		if board_state.in_bounds(cell_pos):
			cell_clicked.emit(cell_pos)

func _draw() -> void:
	if board_state == null:
		return

	for y in range(board_state.height):
		for x in range(board_state.width):
			var tile := board_state.get_cell(Vector2i(x, y))
			var rect := Rect2(
				Vector2(x * cell_size, y * cell_size),
				Vector2(cell_size, cell_size)
			)

			draw_rect(rect, _get_tile_color(tile), true)
			draw_rect(rect, border_color, false, 2.0)

func _get_tile_color(tile: int) -> Color:
	match tile:
		TileState.EMPTY:
			return Color(0.2, 0.2, 0.2, 1.0)
		TileState.CROP_DRY:
			return Color(0.72, 0.56, 0.32, 1.0)
		TileState.CROP_GROWING:
			return Color(0.32, 0.72, 0.28, 1.0)
		TileState.CROP_HARVESTED:
			return Color(0.9, 0.76, 0.42, 1.0)
		TileState.FIRE:
			return Color(0.9, 0.26, 0.2, 1.0)
		TileState.WATER:
			return Color(0.22, 0.5, 0.92, 1.0)
		TileState.ROCK:
			return Color(0.45, 0.45, 0.45, 1.0)
		TileState.ICE:
			return Color(0.68, 0.9, 1.0, 1.0)
		_:
			return Color(1.0, 0.0, 1.0, 1.0)
