extends Control

@onready var resume: Button = %Resume
@onready var retry: Button = %Retry
@onready var settings: Button = %Settings
@onready var main_menu: Button = %MainMenu

func _ready() -> void:
	hide()
	resume.pressed.connect(_on_resume_pressed)
	retry.pressed.connect(_on_retry_pressed)
	settings.pressed.connect(_on_settings_pressed)
	main_menu.pressed.connect(_on_main_menu_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		get_tree().paused = not get_tree().paused
		visible = get_tree().paused

func _on_resume_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_settings_pressed() -> void:
	Debug.log("TODO")
	
func _on_retry_pressed() -> void:
	get_tree().paused = false
	Game.mushroom = 0
	LoadoutManager.reset_to_defaults()
	get_tree().reload_current_scene()
	
func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
