class_name Boss
extends CharacterBody2D

@export var speed = 100
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Pivot/Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var hitbox_component: HitboxComponent = $Pivot/HitboxComponent

var maxlife = 100
var life = 100
var point = 0
var maxpoint = 3
var knockback = Vector2.ZERO
var knockback_force = 0


func _ready() -> void:
	animation_player.play("idle")
	hitbox_component.damage_dealt.connect(_on_damage_dealt)

func _physics_process(delta: float) -> void:

	var direction = Vector2.ZERO

	#direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	#direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * speed
		playback.travel("walk")

		if direction.x != 0:
			sprite_2d.flip_h = direction.x > 0
	else:
		velocity = Vector2.ZERO
		playback.travel("idle")
		
	knockback = lerp(knockback, Vector2.ZERO, 0.1)	
		
	velocity += knockback	
		
	move_and_slide()
	

func take_damage(value: int, badguy: Node2D) -> void:
	#Debug.log("%s received %d damage" % [name, value])	
	animation_tree["parameters/take_hit/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	animation_tree["parameters/take_hit/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
	life -= value
	
	knockback = badguy.global_position.direction_to(global_position) * knockback_force
	
	if life <= 0:
		sprite_2d.hide()
		await get_tree().create_timer(0.5).timeout
		queue_free()	
	
func _on_damage_dealt() -> void:
	pass 
	
	
