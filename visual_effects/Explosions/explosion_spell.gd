extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_explosion: HitboxComponent = $AreaExplosion
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio


var enemies_inside: Array[Node2D] = []


func _ready() -> void:
	animation_player.play("Explosion1")
	explosion_audio.play()
	_explosion()

func _on_area_explosion_body_entered(body: Node2D):
	if body.is_in_group("enemies"):
		enemies_inside.append(body)

func _on_area_explosion_body_exited(body: Node2D):
	enemies_inside.erase(body)
	
func _explosion() -> void:
	for body in area_explosion.get_overlapping_bodies():
		if animation_player.animation_finished:
			sprite_2d.hide()
		body.take_damage(30, self)
	await get_tree().create_timer(1).timeout
	queue_free()
