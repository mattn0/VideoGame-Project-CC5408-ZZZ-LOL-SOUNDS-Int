class_name Player
extends CharacterBody2D

@export var speed = 300
@export var bullet_scene: PackedScene
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var point_sound: AudioStreamPlayer = $PointSound
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/movement/playback"]
@onready var camara: Camera2D = $camara
@onready var roulette_manager: RouletterManager = $RouletteManager
@onready var ability_executor: AbilityExecutor = $AbilityExecutor
@onready var roulette_ui: RouletteUI = $RouletteUI
@onready var bullet_mark: Marker2D = $Bullet_mark

var maxlife = 100
var life = 100
var point = 0
var maxpoint = 3
var knockback = Vector2.ZERO
var knockback_force = 320
var is_spinning := false

# Tamaño de la sala
var room_width = 1280
var room_height = 720

# Posición de la sala actual
var room_x = 0
var room_y = 0


func _ready() -> void:
	animation_player.play("idle")
	
	if camara:
		camara.set_as_top_level(true)
		#camara.zoom = Vector2(2, 2)

		# Limites de cámara
		camara.limit_left = room_x
		camara.limit_top = room_y
		camara.limit_right = room_x + room_width
		camara.limit_bottom = room_y + room_height
		
	_setup_roulette()
	roulette_ui.roulette_manager = roulette_manager
	
func _setup_roulette() -> void:
	var attack = preload("res://abilities/basic_attack.tres")
	var shield = preload("res://abilities/shield.tres")
	var nothing = preload("res://abilities/nothing_ability.tres")
	
	var make_slot = func(ability: Ability, index: int) -> SlotData:
		var sd = SlotData.new()
		sd.ability = ability
		sd.weight = ability.weight
		sd.slot_index = index
		return sd
	
	roulette_manager.configure_slot(0, make_slot.call(attack, 0))
	roulette_manager.configure_slot(1, make_slot.call(shield, 1))
	roulette_manager.configure_slot(2, make_slot.call(attack, 2))
	roulette_manager.configure_slot(3, make_slot.call(attack, 3))
	roulette_manager.configure_slot(4, make_slot.call(shield, 4))
	roulette_manager.configure_slot(5, make_slot.call(attack, 5))
	roulette_manager.configure_slot(6, make_slot.call(nothing, 6))
	roulette_manager.configure_slot(7, make_slot.call(nothing, 7))
	roulette_manager.configure_slot(8, make_slot.call(shield, 8))
	roulette_manager.configure_slot(9, make_slot.call(attack, 9))
	
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
	
	
	
	if Input.is_action_just_pressed("attack") and not is_spinning:
		_trigger_attack()

func _trigger_attack() -> void:
	is_spinning = true
	var result: SlotData = roulette_manager.spin()
	roulette_ui.show_result(result, func():
		ability_executor.execute(result, self)
		is_spinning = false)
		
	if result.ability.ability_name == "Basic_attack":
		await get_tree().create_timer(1).timeout
		var bullet_inst = bullet_scene.instantiate()
		get_parent().add_child(bullet_inst)
		bullet_inst.global_position = bullet_mark.global_position
		var mouse_direction = bullet_mark.global_position.direction_to(get_global_mouse_position())
		bullet_inst.global_rotation = mouse_direction.angle()

func activate_shield(duration: float) -> void:
	Debug.log("Escudo activado por %.1f segundos" % duration)
	# Aquí irá la lógica real de escudo en el futuro	

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
	
func take_point(value: int) -> void:
	point_sound.play()
	Debug.log("I gain %s points" % value)
	animation_tree["parameters/take_point_oneshot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	
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
