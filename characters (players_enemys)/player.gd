class_name Boss
extends CharacterBody2D

@export var speed = 300
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var point_sound: AudioStreamPlayer = $PointSound
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/movement/playback"]
@onready var camara: Camera2D = $camara

var maxlife = 100
var life = 100
var point = 0
var maxpoint = 3
var knockback = Vector2.ZERO
var knockback_force = 0


func _ready() -> void:
	animation_player.play("idle")
	if camara:
		camara.zoom = Vector2(2, 2)  

func _physics_process(delta: float) -> void:

	var direction = Vector2.ZERO

	#direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	#direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	#if direction != Vector2.ZERO:
	#	direction = direction.normalized()
	#	velocity = direction * speed
	#	playback.travel("walk")

	#	if direction.x != 0:
	#		sprite_2d.flip_h = direction.x < 0
	#else:
	#	velocity = Vector2.ZERO
	#	playback.travel("idle")
		
	knockback = lerp(knockback, Vector2.ZERO, 0.1)	
		
	velocity += knockback	
		
	move_and_slide()
	
	var min_x = 38   # Borde izquierdo
	var max_x = 1120  # Borde derecho
	var min_y = 2	# Borde superior
	var max_y = 602  # Borde inferior
	
	global_position.x = clamp(global_position.x, min_x, max_x)
	global_position.y = clamp(global_position.y, min_y, max_y)

func take_damage(value: int, badguy: Node2D) -> void:
	#Debug.log("%s received %d damage" % [name, value])	
	animation_tree["parameters/take_damage_one/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	animation_tree["parameters/take_point_oneshot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
	life -= value
	
	knockback = badguy.global_position.direction_to(global_position) * knockback_force
	
	if life <= 0:
		sprite_2d.hide()
		death_sound.play()
		await get_tree().create_timer(0.5).timeout
		queue_free()	
	
func _on_damage_dealt() -> void:
	pass 
	
#func take_point(value: int) -> void:
#	point_sound.play()
#	Debug.log("I gain %s points" % value)
#	animation_tree["parameters/take_point_oneshot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	
