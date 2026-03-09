extends Node2D

@onready var finish_button: Button = $FinishButton
@onready var gameplay_label: Label = $GameplayLabel
@onready var board_renderer: BoardRenderer = $BoardRenderer

const DEFAULT_LEVEL_PATH := "res://data/levels/level_001.json"

var board_state: BoardState

func _ready() -> void:
	finish_button.pressed.connect(_on_finish_button_pressed)
	_load_level_and_build_board()
	board_renderer.set_board(board_state)

func _on_finish_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/results.tscn")

func _load_level_and_build_board() -> void:
	var level_path := LevelSelection.selected_level_path
	if level_path.is_empty():
		level_path = DEFAULT_LEVEL_PATH

	var level_data := LevelLoader.load_level(level_path)
	if level_data == null and level_path != DEFAULT_LEVEL_PATH:
		push_warning("Falling back to default level: %s" % DEFAULT_LEVEL_PATH)
		level_data = LevelLoader.load_level(DEFAULT_LEVEL_PATH)

	if level_data == null:
		gameplay_label.text = "Gameplay Placeholder (Level Load Failed)"
		board_state = BoardState.new(8, 6, TileState.EMPTY)
		return

	gameplay_label.text = "Gameplay: %s" % level_data.name
	board_state = _build_board_state(level_data)

func _build_board_state(level_data: LevelData) -> BoardState:
	var board := BoardState.new(level_data.width, level_data.height, TileState.EMPTY)
	for y in range(level_data.height):
		for x in range(level_data.width):
			board.set_cell(Vector2i(x, y), int(level_data.tiles[y][x]))
	return board
