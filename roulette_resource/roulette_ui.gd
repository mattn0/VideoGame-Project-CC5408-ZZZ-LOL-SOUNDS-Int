
class_name RouletteUI
extends CanvasLayer

@onready var wheel_sprite: Sprite2D = $Center/WheelSprite
@onready var arrow_sprite: Sprite2D = $Center/ArrowSprite
@onready var result_label: Label = $Center/ResultLabel

var roulette_manager: RouletterManager


func _ready() -> void:
	result_label.visible = false
	arrow_sprite.z_index = 1
	wheel_sprite.position = Vector2(90, 90)
	arrow_sprite.position = Vector2(90, 90)
	
func show_result(slot: SlotData, on_done: Callable) -> void:
	result_label.visible = false
	
	# Calcula el ángulo del slot ganador
	# La ruleta tiene 10 slots de 36° cada uno
	# El slot 0 empieza en las 12 en punto (rotación 0)
	# Para que el slot ganador quede arriba, rotamos la ruleta
	# hasta que ese slot quede en 0° (apuntado por la flecha)
	
	var slot_idx = slot.slot_index if slot else 0
	var slot_angle = deg_to_rad(slot_idx * 36.0)
	
	# Angulo normalizado
	var current = fmod(wheel_sprite.rotation, TAU)
	if current < 0:
		current += TAU
		
	# Cuanto falta para llegar al slot
	var needed = fmod(TAU - slot_angle - current, TAU)
	if needed < deg_to_rad(10):
		needed += TAU
		
	# Vueltas completas aleatorias + angulo exacto
	var full_spins = TAU * randf_range(1.0, 2.0)
	var target = wheel_sprite.rotation + full_spins + needed
	
	# Animacion con tween
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(wheel_sprite, "rotation", target, 1.0)
	tween.tween_callback(func():
		show_label(slot)
		await get_tree().create_timer(1.0).timeout
		result_label.visible = false
		
		#normalizacion de angulo
		wheel_sprite.rotation = fmod(wheel_sprite.rotation, TAU)
		
		on_done.call()
	)
	
func show_label(slot: SlotData) -> void:
	result_label.text = slot.ability.display_name if slot and slot.ability else "Sin efecto"
	result_label.visible = true
	

	
	
	
