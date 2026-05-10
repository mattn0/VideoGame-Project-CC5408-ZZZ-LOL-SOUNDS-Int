class_name Player
extends CharacterBody2D

@export var speed = 300

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var point_sound: AudioStreamPlayer = $PointSound
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/movement/playback"]
@onready var camara: Camera2D = $Camara


# Tamaño de la sala
var room_width = 1280
var room_height = 720

# Posición de la sala actual
var room_x = 0
var room_y = 0

var maxlife = 100
var life = 100
var point = 0
var maxpoint = 3
var knockback = Vector2.ZERO
var knockback_force: float = 0.0


func _ready() -> void:
	animation_player.play("idle")

	if camara:
		camara.set_as_top_level(true)
		camara.zoom = Vector2(1, 1)

		# Limites de cámara
		camara.limit_left = room_x
		camara.limit_top = room_y
		camara.limit_right = room_x + room_width
		camara.limit_bottom = room_y + room_height


func _physics_process(delta: float) -> void:

	var direction = Vector2.ZERO

	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * speed
		playback.travel("walk")

		if direction.x != 0:
			sprite_2d.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO
		playback.travel("idle")
		
	
	

	knockback = lerp(knockback, Vector2.ZERO, 0.1)

	velocity += knockback

	move_and_slide()


func take_damage(value: int, badguy: Node2D) -> void:

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

var can_change_room: bool = true

func change_room(offset_x: float, offset_y: float):
	if not can_change_room:
		return
	
	# Bloqueamos futuros cambios
	can_change_room = false
	# Sumamos a la posición actual de la sala
	room_x += offset_x
	room_y += offset_y

	if camara:
		# Actualizamos límites
		camara.limit_left = room_x
		camara.limit_top = room_y
		camara.limit_right = room_x + room_width
		camara.limit_bottom = room_y + room_height

		# Centramos la cámara en la nueva sala
		camara.global_position = Vector2(
			room_x + room_width / 2,
			room_y + room_height / 2
		)
		await get_tree().create_timer(0.5).timeout
		can_change_room = true
		print(camara.global_position)
