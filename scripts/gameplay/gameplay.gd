extends Node2D

@onready var finish_button: Button = $FinishButton

func _ready() -> void:
	finish_button.pressed.connect(_on_finish_button_pressed)

func _on_finish_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/results.tscn")
