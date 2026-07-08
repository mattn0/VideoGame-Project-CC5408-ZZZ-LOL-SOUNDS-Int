extends Control

@onready var retry: Button = %Retry
@onready var settings: Button = %Settings
@onready var main_menu: Button = %MainMenu
@onready var quit: Button = %Quit

func _ready() -> void:
	hide()
	retry.pressed.connect(_on_retry_pressed)
	settings.pressed.connect(_on_settings_pressed)
	main_menu.pressed.connect(_on_main_menu_pressed)
	quit.pressed.connect(_on_quit_pressed)

func show_game_over() -> void:
	print("MOSTRANDO GAME OVER")
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused
	

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	Debug.log("TODO")
	
func _on_retry_pressed() -> void:
	get_tree().paused = false
	Game.mushroom = 0
	get_tree().reload_current_scene()
	
func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
