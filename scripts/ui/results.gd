extends Control
const ResultState = preload("res://scripts/data/result_state.gd")
const ProgressionService = preload("res://scripts/services/progression_service.gd")

@onready var title_label: Label = $TitleLabel
@onready var reason_label: Label = $ReasonLabel
@onready var back_to_menu_button: Button = $BackToMenuButton

func _ready() -> void:
	if ResultState.is_win and not ResultState.level_id.is_empty():
		ProgressionService.unlock_next_level(ResultState.level_id)

	title_label.text = ResultState.title
	reason_label.text = ResultState.reason
	back_to_menu_button.pressed.connect(_on_back_to_menu_button_pressed)

func _on_back_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
