extends CharacterBody2D

@onready var death_sound: AudioStreamPlayer = $DeathSound

@export var speed = 300
@export var life = 100
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hitbox_component: HitboxComponent = $HitboxComponent
var knockback = Vector2.ZERO
var knockback_force = 320

func _ready() -> void:
	animation_player.play("idle")
	hitbox_component.damage_dealt.connect(_on_damage_dealt)
	
func _physics_process(delta: float) -> void:
	knockback = lerp(knockback, Vector2.ZERO, 0.1)	
		
	velocity += knockback	
	move_and_slide()

func take_damage(value: int, badguy: Node2D) -> void:
	Debug.log("%s received %d damage" % [name, value])	
	#animation_tree["parameters/take_damage_one/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	#animation_tree["parameters/take_point_oneshot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
	life -= value
	
	if life <= 0:
		sprite_2d.hide()
		death_sound.play()
		await get_tree().create_timer(0.5).timeout
		queue_free()	
	
func _on_damage_dealt() -> void:
	#Debug.log("%s made damage" % name)	
	pass
