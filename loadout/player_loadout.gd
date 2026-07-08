## Estado configurable del jugador: cuántos slots de cada tipo de habilidad
## tiene en la ruleta, qué nivel de mejora tiene cada una, y sus puntos.
## LoadoutManager lo mantiene solo en memoria durante la partida actual
## (no se guarda en disco), así que cada partida nueva arranca de cero.
class_name PlayerLoadout
extends Resource

@export var slot_counts: Dictionary = {}     # ability_id (String) -> int
@export var upgrade_levels: Dictionary = {}  # ability_id (String) -> int

func get_count(ability_id: String) -> int:
	return slot_counts.get(ability_id, 0)

func get_level(ability_id: String) -> int:
	return upgrade_levels.get(ability_id, 0)

func total_slots() -> int:
	var total := 0
	for v in slot_counts.values():
		total += v
	return total
