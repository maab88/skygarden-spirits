extends Control

@onready var play_level_1_button: Button = $PlayLevel1Button
@onready var back_button: Button = $BackButton

const LEVEL_1_PATH := "res://data/levels/level_001.json"

func _ready() -> void:
	play_level_1_button.pressed.connect(_on_play_level_1_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

func _on_play_level_1_button_pressed() -> void:
	LevelSelection.selected_level_path = LEVEL_1_PATH
	get_tree().change_scene_to_file("res://scenes/gameplay/gameplay.tscn")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
