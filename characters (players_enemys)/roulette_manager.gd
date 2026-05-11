
class_name RouletterManager
extends Node

signal spin_finished(slot: SlotData)

var slots: Array[SlotData] = []

func _ready() -> void:
	slots.resize(10)
	
func configure_slot(index: int, slot: SlotData) -> void:
	if index >= 0 and index < slots.size():
		slots[index] = slot
		
func spin() -> SlotData:
	var valid = slots.filter(func(s): return s != null and s.ability != null)
	
	if valid.is_empty():
		spin_finished.emit(null)
		return null
			
	var total: float = 0.0	
	for s in valid:
		total += s.weight	
		
	var roll = randf() * total	
	var cumulative: float = 0.0
	for s in valid:
		cumulative += s.weight
		if roll <= cumulative:
			spin_finished.emit(s)
			return s
	
	spin_finished.emit(valid.back())
	return valid.back()
