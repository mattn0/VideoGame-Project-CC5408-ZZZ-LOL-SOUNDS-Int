class_name ExplosionAbility
extends Ability

func execute(player: Player) -> void:
	print("Explosion ejecutado")
	player.cast_explosion()
