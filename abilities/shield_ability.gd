
class_name ShieldAbility
extends Ability

@export var duration: float = 2.0
@export var damage_reduction: float = 0.8
@export var shield_scene: PackedScene

func execute(player: Player) -> void:
	player.activate_shield(duration)
