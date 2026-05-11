extends Control

@onready var start: Button = %Start
@onready var settings: Button = %Settings
@onready var credits: Button = %Credits
@onready var quit: Button = %Quit
@onready var parallax_background: ParallaxBackground = $ParallaxBackground


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start.pressed.connect(_on_start_pressed)
	quit.pressed.connect(_on_quit_pressed)
	credits.pressed.connect(_on_credits_pressed)
	settings.pressed.connect(_on_settings_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/Level2.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()
	
func _on_credits_pressed() -> void:
	Debug.log("Credits")
	get_tree().change_scene_to_file("res://ui/credits_menu.tscn")
	
func _on_settings_pressed() -> void:
	Debug.log("Settings")		

func _process(delta: float) -> void:
	parallax_background.scroll_offset.x += 20 * delta
