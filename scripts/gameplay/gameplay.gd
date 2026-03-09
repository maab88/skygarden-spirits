extends Node2D

@onready var finish_button: Button = $FinishButton
@onready var restart_button: Button = $RestartButton
@onready var test_action_button: Button = $TestActionButton
@onready var level_name_label: Label = $LevelNameLabel
@onready var moves_label: Label = $MovesLabel
@onready var board_renderer: BoardRenderer = $BoardRenderer

const DEFAULT_LEVEL_PATH := "res://data/levels/level_001.json"

var board_state: BoardState
var current_level_data: LevelData
var moves_remaining: int = 0

func _ready() -> void:
	finish_button.pressed.connect(_on_finish_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	test_action_button.pressed.connect(_on_test_action_button_pressed)
	_load_level_and_build_board()

func _on_finish_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/results.tscn")

func _on_restart_button_pressed() -> void:
	_load_level_and_build_board()

func _on_test_action_button_pressed() -> void:
	if not _perform_test_action():
		push_warning("Test action was unavailable, move not consumed.")
		return
	consume_move()
	board_renderer.refresh()

func _load_level_and_build_board() -> void:
	var level_path := LevelSelection.selected_level_path
	if level_path.is_empty():
		level_path = DEFAULT_LEVEL_PATH

	var level_data := LevelLoader.load_level(level_path)
	if level_data == null and level_path != DEFAULT_LEVEL_PATH:
		push_warning("Falling back to default level: %s" % DEFAULT_LEVEL_PATH)
		level_data = LevelLoader.load_level(DEFAULT_LEVEL_PATH)

	if level_data == null:
		current_level_data = null
		level_name_label.text = "Level: Load Failed"
		moves_label.text = "Moves: 0"
		board_state = BoardState.new(8, 6, TileState.EMPTY)
		board_renderer.set_board(board_state)
		return

	current_level_data = level_data
	moves_remaining = current_level_data.move_limit
	board_state = _build_board_state(current_level_data)
	board_renderer.set_board(board_state)
	update_hud()

func _build_board_state(level_data: LevelData) -> BoardState:
	var board := BoardState.new(level_data.width, level_data.height, TileState.EMPTY)
	for y in range(level_data.height):
		for x in range(level_data.width):
			board.set_cell(Vector2i(x, y), int(level_data.tiles[y][x]))
	return board

func _perform_test_action() -> bool:
	if moves_remaining <= 0:
		return false

	# Temporary action: convert the first Fire tile to Water.
	for y in range(board_state.height):
		for x in range(board_state.width):
			var pos := Vector2i(x, y)
			if board_state.get_cell(pos) == TileState.FIRE:
				board_state.set_cell(pos, TileState.WATER)
				return true

	return false

func consume_move() -> void:
	moves_remaining = max(0, moves_remaining - 1)
	update_hud()

func update_hud() -> void:
	if current_level_data == null:
		level_name_label.text = "Level: Unknown"
	else:
		level_name_label.text = "Level: %s" % current_level_data.name

	moves_label.text = "Moves: %d" % moves_remaining
