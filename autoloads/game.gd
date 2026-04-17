extends Node

signal mushroom_changed(value: int)

var mushroom: int = 0:
	set(value):
		mushroom = value
		mushroom_changed.emit(mushroom)	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
