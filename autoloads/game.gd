extends Node

signal mushroom_changed(value: int)

var player_data: PlayerData
var mushroom: int = 0:
	set(value):
		mushroom = value
		mushroom_changed.emit(mushroom)

func spend_mushrooms(amount: int) -> bool:
	if mushroom >= amount:
		mushroom -= amount
		mushroom_changed.emit(mushroom)
		return true

	return false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_data = PlayerData.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
