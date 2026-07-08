## AUTOLOAD. Registrar este script en Project Settings > Autoload
## con el nombre exacto "LoadoutManager".
##
## Es el dueño de la configuración de la ruleta: cuántos slots tiene cada
## tipo de habilidad (siempre suman 10), los niveles de mejora, y los puntos
## del jugador. Cualquier cambio se guarda en disco y se vuelca automáticamente
## al RouletteManager activo.
extends Node

signal loadout_changed
signal action_failed(reason: String)

const TOTAL_SLOTS := 10

const BASIC_ATTACK_PATH := "res://abilities/basic_attack.tres"
const SHIELD_PATH := "res://abilities/shield.tres"
const NOTHING_PATH := "res://abilities/nothing_ability.tres"

var options: Array[AbilityLoadoutOption] = []
var loadout: PlayerLoadout

var _active_roulette: RouletterManager = null


func _ready() -> void:
	if options.is_empty():
		options = _build_default_options()
	reset_to_defaults()


## Llamar desde Player al crear su RouletteManager. A partir de acá,
## cualquier cambio en el loadout se refleja automáticamente en esa ruleta.
func register_roulette(rm: RouletterManager) -> void:
	_active_roulette = rm
	apply_to_roulette(rm)

func reset_to_defaults() -> void:
	loadout = PlayerLoadout.new()
	for opt in options:
		loadout.slot_counts[opt.ability_id] = 0
	_set_default_distribution()
	_notify_changed()

func get_option(ability_id: String) -> AbilityLoadoutOption:
	for opt in options:
		if opt.ability_id == ability_id:
			return opt
	return null


## --- Acción: pagar puntos para robarle 1 slot a otra habilidad ---
func increase_slot(ability_id: String) -> bool:
	var opt := get_option(ability_id)
	if opt == null:
		action_failed.emit("Habilidad desconocida.")
		return false
	if loadout.get_count(ability_id) >= opt.max_slots:
		action_failed.emit("%s ya está al máximo de slots." % opt.display_name)
		return false
	if Game.mushroom < opt.point_cost_per_slot:
		action_failed.emit("No tienes suficientes puntos.")
		return false

	var donor_id := _find_donor(ability_id)
	if donor_id == "":
		action_failed.emit("No hay slots disponibles para quitar de otra habilidad.")
		return false

	Game.mushroom -= opt.point_cost_per_slot
	loadout.slot_counts[donor_id] = loadout.get_count(donor_id) - 1
	loadout.slot_counts[ability_id] = loadout.get_count(ability_id) + 1
	_notify_changed()
	return true


## --- Acción: devolver 1 slot gratis (va a la habilidad "relleno") ---
func decrease_slot(ability_id: String) -> bool:
	var opt := get_option(ability_id)
	if opt == null:
		action_failed.emit("Habilidad desconocida.")
		return false
	if loadout.get_count(ability_id) <= opt.min_slots:
		action_failed.emit("%s ya está en su mínimo de slots." % opt.display_name)
		return false

	var recipient_id := _find_recipient(ability_id)
	if recipient_id == "":
		action_failed.emit("No hay espacio para reasignar ese slot.")
		return false

	loadout.slot_counts[ability_id] = loadout.get_count(ability_id) - 1
	loadout.slot_counts[recipient_id] = loadout.get_count(recipient_id) + 1
	_notify_changed()
	return true


## --- Acción: sin costo en puntos, sube un stat a cambio de slots propios ---
func upgrade_ability(ability_id: String) -> bool:
	var opt := get_option(ability_id)
	if opt == null or not opt.upgradable:
		action_failed.emit("Esta habilidad no se puede mejorar.")
		return false

	var level := loadout.get_level(ability_id)
	if level >= opt.max_upgrade_level:
		action_failed.emit("%s ya está al máximo de poder." % opt.display_name)
		return false

	var current_count := loadout.get_count(ability_id)
	if current_count - opt.upgrade_slot_cost < opt.min_slots:
		action_failed.emit("No puedes sacrificar más slots de %s." % opt.display_name)
		return false

	var recipient_id := _find_recipient(ability_id)
	if recipient_id == "":
		action_failed.emit("No hay espacio para reasignar los slots sacrificados.")
		return false

	loadout.slot_counts[ability_id] = current_count - opt.upgrade_slot_cost
	loadout.slot_counts[recipient_id] = loadout.get_count(recipient_id) + opt.upgrade_slot_cost
	loadout.upgrade_levels[ability_id] = level + 1
	_notify_changed()
	return true


func add_points(amount: int) -> void:
	Game.mushroom += amount


## Construye el array de 10 SlotData a partir de la configuración actual,
## aplicando las mejoras de poder correspondientes a cada instancia.
func build_slot_data() -> Array[SlotData]:
	var result: Array[SlotData] = []

	for opt in options:
		var count := loadout.get_count(opt.ability_id)
		var level := loadout.get_level(opt.ability_id)
		for i in count:
			var ability_instance: Ability = opt.base_ability.duplicate()
			if opt.upgradable and level > 0 and opt.upgrade_stat != "":
				var current_value = ability_instance.get(opt.upgrade_stat)
				if current_value != null:
					ability_instance.set(opt.upgrade_stat, current_value + opt.upgrade_amount * level)
				else:
					Debug.log("upgrade_stat '%s' no existe en %s" % [opt.upgrade_stat, opt.ability_id])
			var sd := SlotData.new()
			sd.ability = ability_instance
			sd.weight = ability_instance.weight
			result.append(sd)

	while result.size() < TOTAL_SLOTS:
		result.append(null)

	for i in result.size():
		if result[i]:
			result[i].slot_index = i

	return result


func apply_to_roulette(rm: RouletterManager) -> void:
	if rm == null:
		return
	var slots := build_slot_data()
	for i in TOTAL_SLOTS:
		rm.configure_slot(i, slots[i] if i < slots.size() else null)


func _notify_changed() -> void:
	loadout_changed.emit()
	if _active_roulette:
		apply_to_roulette(_active_roulette)


## Busca de dónde sacar 1 slot para dárselo a `exclude_id`.
## Prioriza la habilidad marcada is_filler; si no tiene sobrante, toma
## la que tenga más margen sobre su mínimo.
func _find_donor(exclude_id: String) -> String:
	var filler_id := ""
	var best_id := ""
	var best_surplus := 0

	for opt in options:
		if opt.ability_id == exclude_id:
			continue
		var surplus := loadout.get_count(opt.ability_id) - opt.min_slots
		if surplus <= 0:
			continue
		if opt.is_filler:
			filler_id = opt.ability_id
		if surplus > best_surplus:
			best_surplus = surplus
			best_id = opt.ability_id

	if filler_id != "":
		return filler_id
	return best_id


## Busca a quién darle 1 slot que se le quita a `exclude_id`.
## Prioriza la habilidad marcada is_filler; si está llena, reparte
## en la que tenga más espacio libre.
func _find_recipient(exclude_id: String) -> String:
	for opt in options:
		if opt.is_filler and opt.ability_id != exclude_id and loadout.get_count(opt.ability_id) < opt.max_slots:
			return opt.ability_id

	var best_id := ""
	var best_room := 0
	for opt in options:
		if opt.ability_id == exclude_id:
			continue
		var room := opt.max_slots - loadout.get_count(opt.ability_id)
		if room > best_room:
			best_room = room
			best_id = opt.ability_id
	return best_id


## Configuración inicial: equivalente a la que estaba hardcodeada en
## Player._setup_roulette() (5 ataque / 3 escudo / 2 nada).
func _set_default_distribution() -> void:
	if get_option("basic_attack"):
		loadout.slot_counts["basic_attack"] = 5
	if get_option("shield"):
		loadout.slot_counts["shield"] = 3
	if get_option("nothing"):
		loadout.slot_counts["nothing"] = 2


func _build_default_options() -> Array[AbilityLoadoutOption]:
	var basic := AbilityLoadoutOption.new()
	basic.ability_id = "basic_attack"
	basic.display_name = "Ataque Básico"
	basic.base_ability = load(BASIC_ATTACK_PATH)
	basic.min_slots = 1
	basic.max_slots = 10
	basic.point_cost_per_slot = 5
	basic.upgradable = true
	basic.upgrade_stat = "damage"
	basic.upgrade_amount = 5.0
	basic.upgrade_slot_cost = 1
	basic.max_upgrade_level = 3

	var shield := AbilityLoadoutOption.new()
	shield.ability_id = "shield"
	shield.display_name = "Escudo"
	shield.base_ability = load(SHIELD_PATH)
	shield.min_slots = 0
	shield.max_slots = 10
	shield.point_cost_per_slot = 4
	shield.upgradable = true
	shield.upgrade_stat = "duration"
	shield.upgrade_amount = 1.0
	shield.upgrade_slot_cost = 1
	shield.max_upgrade_level = 2

	var nothing := AbilityLoadoutOption.new()
	nothing.ability_id = "nothing"
	nothing.display_name = "Vacío"
	nothing.base_ability = load(NOTHING_PATH)
	nothing.min_slots = 0
	nothing.max_slots = 10
	nothing.point_cost_per_slot = 0
	nothing.is_filler = true

	var result: Array[AbilityLoadoutOption] = []
	result.append(basic)
	result.append(shield)
	result.append(nothing)
	return result
