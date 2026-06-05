
class_name AbilityExecutor
extends Node

func execute(slot: SlotData, player: Player) -> void:
	
	if slot == null or slot.ability == null:
		Debug.log("no effect")
		return
	
	slot.ability.duplicate().execute(player)	
