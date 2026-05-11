

class_name Ability
extends Resource

@export var ability_name: String = ""
@export var display_name: String = ""
@export var icon: Texture2D
@export var weight: float = 1.0

func execute(player: Player) -> void:
	push_error("execute() no implementado en " + ability_name)
