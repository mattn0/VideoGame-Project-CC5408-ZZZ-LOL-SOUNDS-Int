extends CanvasLayer

@onready var mushroom_label: Label = $MarginContainer/HBoxContainer/MushroomLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_mushroom_changed(Game.mushroom)
	Game.mushroom_changed.connect(_on_mushroom_changed)

func _on_mushroom_changed(value: int) -> void:
	mushroom_label.text = str(value)
