extends Node2D

@onready var finish_button: Button = $FinishButton
@onready var restart_button: Button = $RestartButton
@onready var rain_button: Button = $RainButton
@onready var sun_button: Button = $SunButton
@onready var frost_button: Button = $FrostButton
@onready var wind_button: Button = $WindButton
@onready var wind_up_button: Button = $WindUpButton
@onready var wind_down_button: Button = $WindDownButton
@onready var wind_left_button: Button = $WindLeftButton
@onready var wind_right_button: Button = $WindRightButton
@onready var level_name_label: Label = $LevelNameLabel
@onready var moves_label: Label = $MovesLabel
@onready var selected_power_label: Label = $SelectedPowerLabel
@onready var wind_direction_label: Label = $WindDirectionLabel
@onready var board_renderer: BoardRenderer = $BoardRenderer

const DEFAULT_LEVEL_PATH := "res://data/levels/level_001.json"
const POWER_NONE := ""
const POWER_RAIN := "Rain"
const POWER_SUN := "Sun"
const POWER_FROST := "Frost"
const POWER_WIND := "Wind"

var board_state: BoardState
var current_level_data: LevelData
var moves_remaining: int = 0
var selected_power: String = POWER_NONE
var selected_wind_direction: Vector2i = Vector2i.RIGHT

func _ready() -> void:
	finish_button.pressed.connect(_on_finish_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	rain_button.pressed.connect(_on_rain_button_pressed)
	sun_button.pressed.connect(_on_sun_button_pressed)
	frost_button.pressed.connect(_on_frost_button_pressed)
	wind_button.pressed.connect(_on_wind_button_pressed)
	wind_up_button.pressed.connect(_on_wind_up_button_pressed)
	wind_down_button.pressed.connect(_on_wind_down_button_pressed)
	wind_left_button.pressed.connect(_on_wind_left_button_pressed)
	wind_right_button.pressed.connect(_on_wind_right_button_pressed)
	board_renderer.cell_clicked.connect(_on_board_cell_clicked)
	_load_level_and_build_board()

func _on_finish_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/results.tscn")

func _on_restart_button_pressed() -> void:
	_load_level_and_build_board()

func _on_rain_button_pressed() -> void:
	selected_power = POWER_RAIN
	update_hud()

func _on_sun_button_pressed() -> void:
	selected_power = POWER_SUN
	update_hud()

func _on_frost_button_pressed() -> void:
	selected_power = POWER_FROST
	update_hud()

func _on_wind_button_pressed() -> void:
	selected_power = POWER_WIND
	update_hud()

func _on_wind_up_button_pressed() -> void:
	selected_wind_direction = Vector2i.UP
	update_hud()

func _on_wind_down_button_pressed() -> void:
	selected_wind_direction = Vector2i.DOWN
	update_hud()

func _on_wind_left_button_pressed() -> void:
	selected_wind_direction = Vector2i.LEFT
	update_hud()

func _on_wind_right_button_pressed() -> void:
	selected_wind_direction = Vector2i.RIGHT
	update_hud()

func _on_board_cell_clicked(cell_pos: Vector2i) -> void:
	if selected_power == POWER_NONE:
		push_warning("Select a power first.")
		return

	var changed := false
	if selected_power == POWER_RAIN:
		changed = apply_rain_to_cell(cell_pos)
	elif selected_power == POWER_SUN:
		changed = apply_sun_to_cell(cell_pos)
	elif selected_power == POWER_FROST:
		changed = apply_frost_to_cell(cell_pos)
	elif selected_power == POWER_WIND:
		changed = apply_wind_to_cell(cell_pos)

	if not changed:
		push_warning("%s had no effect, move not consumed." % selected_power)
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
		selected_power = POWER_NONE
		selected_wind_direction = Vector2i.RIGHT
		level_name_label.text = "Level: Load Failed"
		moves_label.text = "Moves: 0"
		selected_power_label.text = "Selected: None"
		wind_direction_label.text = "Wind Dir: Right"
		board_state = BoardState.new(8, 6, TileState.EMPTY)
		board_renderer.set_board(board_state)
		return

	current_level_data = level_data
	moves_remaining = current_level_data.move_limit
	selected_power = POWER_NONE
	selected_wind_direction = Vector2i.RIGHT
	board_state = _build_board_state(current_level_data)
	board_renderer.set_board(board_state)
	update_hud()

func _build_board_state(level_data: LevelData) -> BoardState:
	var board := BoardState.new(level_data.width, level_data.height, TileState.EMPTY)
	for y in range(level_data.height):
		for x in range(level_data.width):
			board.set_cell(Vector2i(x, y), int(level_data.tiles[y][x]))
	return board

func apply_rain_to_cell(target_pos: Vector2i) -> bool:
	if moves_remaining <= 0:
		return false

	var changed := false
	var target_tile := board_state.get_cell(target_pos)
	if target_tile == TileState.CROP_DRY:
		board_state.set_cell(target_pos, TileState.CROP_GROWING)
		changed = true

	changed = _extinguish_fire_at(target_pos) or changed
	for neighbor in board_state.get_neighbors(target_pos):
		changed = _extinguish_fire_at(neighbor) or changed

	return changed

func _extinguish_fire_at(pos: Vector2i) -> bool:
	if board_state.get_cell(pos) != TileState.FIRE:
		return false
	board_state.set_cell(pos, TileState.EMPTY)
	return true

func apply_sun_to_cell(target_pos: Vector2i) -> bool:
	if moves_remaining <= 0:
		return false

	if board_state.get_cell(target_pos) != TileState.CROP_GROWING:
		return false

	board_state.set_cell(target_pos, TileState.CROP_HARVESTED)
	return true

func apply_frost_to_cell(target_pos: Vector2i) -> bool:
	if moves_remaining <= 0:
		return false

	var target_tile := board_state.get_cell(target_pos)
	if target_tile == TileState.WATER:
		board_state.set_cell(target_pos, TileState.ICE)
		return true

	if target_tile == TileState.FIRE:
		board_state.set_cell(target_pos, TileState.EMPTY)
		return true

	return false

func apply_wind_to_cell(target_pos: Vector2i) -> bool:
	if moves_remaining <= 0:
		return false

	if board_state.get_cell(target_pos) != TileState.FIRE:
		return false

	var destination := target_pos + selected_wind_direction
	if not board_state.in_bounds(destination):
		return false

	if board_state.get_cell(destination) != TileState.EMPTY:
		return false

	board_state.set_cell(target_pos, TileState.EMPTY)
	board_state.set_cell(destination, TileState.FIRE)
	return true

func consume_move() -> void:
	moves_remaining = max(0, moves_remaining - 1)
	update_hud()

func update_hud() -> void:
	if current_level_data == null:
		level_name_label.text = "Level: Unknown"
	else:
		level_name_label.text = "Level: %s" % current_level_data.name

	moves_label.text = "Moves: %d" % moves_remaining
	if selected_power.is_empty():
		selected_power_label.text = "Selected: None"
	else:
		selected_power_label.text = "Selected: %s" % selected_power

	wind_direction_label.text = "Wind Dir: %s" % _wind_direction_to_text(selected_wind_direction)

func _wind_direction_to_text(direction: Vector2i) -> String:
	if direction == Vector2i.UP:
		return "Up"
	if direction == Vector2i.DOWN:
		return "Down"
	if direction == Vector2i.LEFT:
		return "Left"
	return "Right"
