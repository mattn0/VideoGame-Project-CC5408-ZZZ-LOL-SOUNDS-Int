## Describe un "tipo" de habilidad que el jugador puede configurar en la
## ruleta (Ataque básico, Escudo, Nada...). No es una habilidad en sí,
## es la plantilla + reglas de costo que usa LoadoutManager.
class_name AbilityLoadoutOption
extends Resource

## Identificador interno único (no confundir con Ability.ability_name).
@export var ability_id: String = ""
@export var display_name: String = ""
@export var icon: Texture2D

## Plantilla que se duplica para generar cada slot de la ruleta.
@export var base_ability: Ability

## Límites de cuántos de los 10 slots totales puede ocupar esta habilidad.
@export var min_slots: int = 0
@export var max_slots: int = 10

## Si es true, esta habilidad actúa como "relleno" por defecto: cuando se
## quita un slot de otra habilidad, o se sacrifican slots al mejorar poder,
## primero se intenta devolver/entregar el slot a la que tenga is_filler = true.
@export var is_filler: bool = false

## Costo en puntos para robarle 1 slot a otra habilidad y dárselo a esta.
@export var point_cost_per_slot: int = 5

## --- Mejora de poder a cambio de frecuencia (sin costo en puntos) ---
## Ejemplo: subir "damage" +5 pero perder 1 slot de este tipo en la ruleta.
@export var upgradable: bool = false
@export var upgrade_stat: String = ""       # nombre de la propiedad exportada en el Ability (ej: "damage", "duration")
@export var upgrade_amount: float = 0.0     # cuánto sube el stat por nivel
@export var upgrade_slot_cost: int = 1      # cuántos slots se sacrifican por nivel
@export var max_upgrade_level: int = 3
