extends Control
const LevelCatalog = preload("res://scripts/data/level_catalog.gd")
const ProgressionService = preload("res://scripts/services/progression_service.gd")

@onready var level_1_button: Button = $Level1Button
@onready var level_2_button: Button = $Level2Button
@onready var level_3_button: Button = $Level3Button
@onready var lock_info_label: Label = $LockInfoLabel
@onready var back_button: Button = $BackButton
@onready var reset_progress_button: Button = $ResetProgressButton

func _ready() -> void:
	level_1_button.pressed.connect(_on_level_1_button_pressed)
	level_2_button.pressed.connect(_on_level_2_button_pressed)
	level_3_button.pressed.connect(_on_level_3_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	reset_progress_button.pressed.connect(_on_reset_progress_button_pressed)
	_refresh_level_buttons()

func _on_level_1_button_pressed() -> void:
	_start_level("level_001")

func _on_level_2_button_pressed() -> void:
	_start_level("level_002")

func _on_level_3_button_pressed() -> void:
	_start_level("level_003")

func _start_level(level_id: String) -> void:
	if not ProgressionService.is_level_unlocked(level_id):
		push_warning("%s is locked." % level_id)
		return

	LevelSelection.selected_level_path = LevelCatalog.get_level_path(level_id)
	get_tree().change_scene_to_file("res://scenes/gameplay/gameplay.tscn")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

func _on_reset_progress_button_pressed() -> void:
	var save_path := ProgressionService.get_save_path()
	print("Progress save path: %s" % save_path)
	ProgressionService.reset_progress()
	_refresh_level_buttons()

func _refresh_level_buttons() -> void:
	_set_level_button_state(level_1_button, "level_001", "Level 1")
	_set_level_button_state(level_2_button, "level_002", "Level 2")
	_set_level_button_state(level_3_button, "level_003", "Level 3")
	lock_info_label.text = "Locked levels cannot be played yet."

func _set_level_button_state(button: Button, level_id: String, display_name: String) -> void:
	var unlocked := ProgressionService.is_level_unlocked(level_id)
	button.disabled = not unlocked
	if unlocked:
		button.text = "%s (Unlocked)" % display_name
	else:
		button.text = "%s (Locked)" % display_name
