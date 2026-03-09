extends Control

@onready var back_to_menu_button: Button = $BackToMenuButton

func _ready() -> void:
	back_to_menu_button.pressed.connect(_on_back_to_menu_button_pressed)

func _on_back_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
