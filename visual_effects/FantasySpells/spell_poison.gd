extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_poison: Area2D = $AreaPoison
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var poison_audio: AudioStreamPlayer = $PoisonAudio


var enemies_inside: Array[Node2D] = []
const DAMAGE := 5
const DURATION := 5.0
const TICK := 1.0

func _ready() -> void:
	animation_player.play("SpellPoison")
	poison_audio.play()
	_draw()
	_apply_poison()


func _on_area_poison_body_entered(body: Node2D):
	if body.is_in_group("enemies"):
		enemies_inside.append(body)

func _on_area_poison_body_exited(body: Node2D):
	enemies_inside.erase(body)

func _apply_poison() -> void:
	var elapsed := 0.0
	while elapsed < DURATION:
		for body in area_poison.get_overlapping_bodies():
			body.take_damage(DAMAGE, self)
		await get_tree().create_timer(1).timeout
		if animation_player.animation_finished:
				print("Hola. Me escondí :p")
				sprite_2d.hide()
		elapsed += 1
	queue_free()
	
func _draw() -> void:
	var radius := 12.0
	var length := 52.0
	var color := Color(0.6, 0.0, 0.8, 0.35)

	draw_rect(
		Rect2(
			Vector2(-length/2, -radius) + Vector2(0,48),
			Vector2(length, radius * 2)
		),
		color
	)
	draw_circle(Vector2(-length/2, 48), radius, color)
	draw_circle(Vector2(length/2, 48), radius, color)
