
class_name RouletteUI
extends CanvasLayer

@onready var wheel_sprite: Sprite2D = $Center/WheelSprite
@onready var arrow_sprite: Sprite2D = $Center/ArrowSprite
@onready var result_label: Label = $Center/ResultLabel
@onready var center: Control = $Center

var roulette_manager: RouletterManager


func _ready() -> void:
	result_label.visible = false
	arrow_sprite.z_index = 1
	
	#semitrasnparente
	wheel_sprite.modulate.a = 0.55
	arrow_sprite.modulate.a = 0.55
	
	#escala para el centro de la pantalla
	wheel_sprite.scale = Vector2(3.0, 3.0)
	arrow_sprite.scale = Vector2(3.0, 3.0)
	
	#centrado en la pantalla
	var screen = get_viewport().get_visible_rect().size
	wheel_sprite.position = screen/2
	arrow_sprite.position = screen/2
	result_label.position = Vector2(screen.x / 2 - 100, screen.y / 2 + 160)
	
	#oculto al inicio
	center.visible = false
	
func show_result(slot: SlotData, on_done: Callable) -> void:
	result_label.visible = false
	center.visible = true
	
	var slot_idx = slot.slot_index if slot else 0
	
	# Calcula el ángulo del slot ganador
	# La ruleta tiene 10 slots de 36° cada uno
	# El slot 0 empieza en las 12 en punto (rotación 0)
	# Para que el slot ganador quede arriba, rotamos la ruleta
	# hasta que ese slot quede en 0° (apuntado por la flecha)
	var target_angle = deg_to_rad(-slot_idx * 36.0)
	
	#normalizar
	var current = fmod(wheel_sprite.rotation, TAU)
	#cuanto falta
	var needed = fmod(target_angle - current, TAU)
	#if needed
	if needed > -deg_to_rad(5):
		needed -= TAU
		
	#vueltas mas angulo
	var full_spins = TAU * randf_range(1.0, 3.0)
	var target = wheel_sprite.rotation + full_spins + needed
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(wheel_sprite, "rotation", target, 1.0)
	tween.tween_callback(func():
		show_label(slot)
		await get_tree().create_timer(1.0).timeout
		result_label.visible = false
		center.visible = false
		#normalizar de nuevo
		wheel_sprite.rotation = fmod(wheel_sprite.rotation, TAU)
		on_done.call()
		)
	
	
func show_label(slot: SlotData) -> void:
	result_label.text = slot.ability.display_name if slot and slot.ability else "Sin efecto"
	result_label.visible = true
	

	
	
	
