extends Node2D

@onready var finish_button: Button = $FinishButton
@onready var board_renderer: BoardRenderer = $BoardRenderer

var board_state: BoardState

func _ready() -> void:
	finish_button.pressed.connect(_on_finish_button_pressed)
	_create_sample_board()
	board_renderer.set_board(board_state)
	_run_simple_update_test()

func _on_finish_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/results.tscn")

func _create_sample_board() -> void:
	board_state = BoardState.new(8, 6, TileState.EMPTY)
	board_state.set_cell(Vector2i(1, 1), TileState.CROP_DRY)
	board_state.set_cell(Vector2i(2, 1), TileState.CROP_GROWING)
	board_state.set_cell(Vector2i(3, 1), TileState.CROP_HARVESTED)
	board_state.set_cell(Vector2i(4, 2), TileState.FIRE)
	board_state.set_cell(Vector2i(5, 2), TileState.WATER)
	board_state.set_cell(Vector2i(6, 3), TileState.ROCK)
	board_state.set_cell(Vector2i(2, 4), TileState.ICE)

func _run_simple_update_test() -> void:
	await get_tree().create_timer(1.0).timeout
	board_state.set_cell(Vector2i(4, 2), TileState.WATER)
	board_renderer.refresh()
