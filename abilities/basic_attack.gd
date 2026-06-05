
class_name BasicAttack
extends Ability

@export var damage: float = 10.0
@export var bullet_scene : PackedScene


func execute(player: Player) -> void:
	for enemy in player.get_tree().get_nodes_in_group("enemies"):
		var dist = player.global_position.distance_to(enemy.global_position)
		if dist <= 150.0:
			enemy.take_damage(damage, player)
	#var bullet_mark_inst = bullet_mark.instanciate()
	#var bullet_inst = bullet_scene.instantiate()
	#bullet_inst.global_position = bullet_mark_inst
	
