extends Control

@onready var back_credit: Button = %Back_credit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back_credit.pressed.connect(_on_back_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
