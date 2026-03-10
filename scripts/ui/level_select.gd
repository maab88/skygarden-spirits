extends Control
const LevelCatalog = preload("res://scripts/data/level_catalog.gd")
const ProgressionService = preload("res://scripts/services/progression_service.gd")

@onready var level_1_button: Button = $Level1Button
@onready var level_2_button: Button = $Level2Button
@onready var level_3_button: Button = $Level3Button
@onready var level_4_button: Button = $Level4Button
@onready var level_5_button: Button = $Level5Button
@onready var level_6_button: Button = $Level6Button
@onready var level_7_button: Button = $Level7Button
@onready var level_8_button: Button = $Level8Button
@onready var level_9_button: Button = $Level9Button
@onready var level_10_button: Button = $Level10Button
@onready var lock_info_label: Label = $LockInfoLabel
@onready var back_button: Button = $BackButton
@onready var reset_progress_button: Button = $ResetProgressButton

func _ready() -> void:
	_connect_level_button(level_1_button, "level_001")
	_connect_level_button(level_2_button, "level_002")
	_connect_level_button(level_3_button, "level_003")
	_connect_level_button(level_4_button, "level_004")
	_connect_level_button(level_5_button, "level_005")
	_connect_level_button(level_6_button, "level_006")
	_connect_level_button(level_7_button, "level_007")
	_connect_level_button(level_8_button, "level_008")
	_connect_level_button(level_9_button, "level_009")
	_connect_level_button(level_10_button, "level_010")
	back_button.pressed.connect(_on_back_button_pressed)
	reset_progress_button.pressed.connect(_on_reset_progress_button_pressed)
	_refresh_level_buttons()

func _connect_level_button(button: Button, level_id: String) -> void:
	button.pressed.connect(func() -> void:
		_start_level(level_id)
	)

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
	_set_level_button_state(level_4_button, "level_004", "Level 4")
	_set_level_button_state(level_5_button, "level_005", "Level 5")
	_set_level_button_state(level_6_button, "level_006", "Level 6")
	_set_level_button_state(level_7_button, "level_007", "Level 7")
	_set_level_button_state(level_8_button, "level_008", "Level 8")
	_set_level_button_state(level_9_button, "level_009", "Level 9")
	_set_level_button_state(level_10_button, "level_010", "Level 10")
	lock_info_label.text = "Unlocked levels are ready to play.\nLocked levels unlock after winning the previous level."

func _set_level_button_state(button: Button, level_id: String, display_name: String) -> void:
	var unlocked := ProgressionService.is_level_unlocked(level_id)
	button.disabled = not unlocked
	if unlocked:
		button.text = "%s  |  Unlocked" % display_name
	else:
		button.text = "%s  |  Locked" % display_name
