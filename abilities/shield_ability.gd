
class_name ShieldAbility
extends Ability

@export var duration: float = 2.0

func execute(player: Player) -> void:
	player.activate_shield(duration)
