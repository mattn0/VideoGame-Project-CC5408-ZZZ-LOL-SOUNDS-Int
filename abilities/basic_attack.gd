
class_name BasicAttack
extends Ability

@export var damage: float = 10.0

func execute(player: Player) -> void:
	for enemy in player.get_tree().get_nodes_in_group("enemies"):
		var dist = player.global_position.distance_to(enemy.global_position)
		if dist <= 80.0:
			enemy.take_damage(damage, player)
