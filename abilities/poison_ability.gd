class_name PoisonAbility
extends Ability

@export var poison_duration := 5.0

func execute(player: Player) -> void:
	print("Poison ejecutado")
	player.cast_poison()
