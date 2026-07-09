extends Control

@onready var back_credit: Button = %Back_credit
@onready var rich_text_label: RichTextLabel = $RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rich_text_label.meta_clicked.connect(_on_meta_clicked)
	back_credit.pressed.connect(_on_back_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_meta_clicked(meta):
	OS.shell_open(str(meta))

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
