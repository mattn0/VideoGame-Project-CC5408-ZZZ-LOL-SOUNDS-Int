class_name Enemie
extends CharacterBody2D

@export var speed = 50
@export var attack_range = 80.0
@export var attack_damage = 10
@export var attack_cooldown = 1.5
@export var mushroom_point_scene: PackedScene
@export var damage_number_scene: PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Pivot/Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var hitbox_component: HitboxComponent = $Pivot/HitboxComponent
@onready var player: Player = $"../player"
@onready var death_sound: AudioStreamPlayer = $DeathSound


var maxlife = 50
var life = 30
var knockback = Vector2.ZERO
var knockback_force = 200.0

#var player = null
var can_attack := true
var is_dead := false
var is_taking_hit := false

func _ready() -> void:
	animation_player.play("idle")
	hitbox_component.damage_dealt.connect(_on_damage_dealt)
	
	#busca player
	#player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:

	if is_dead or is_taking_hit:
		return
	
	
	#if player  == null or not is_instance_valid(player):
	#	player = get_tree().get_first_node_in_group("player")
	#	velocity = Vector2.ZERO
	#	move_and_slide()
	#	return
	
	var distance = global_position.distance_to(player.position)
	var direction = (player.position-position).normalized()
	
	if distance <= attack_range:
		#en rango
		velocity = knockback
		if can_attack:
			_attack()
	else: 
		#fuera de rango
		playback.travel("walk")
		velocity = direction * speed
		sprite_2d.flip_h = direction.x < 0
		
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	velocity += knockback
			
	move_and_slide()
	
func _attack() -> void:
	can_attack = false
	playback.travel("strike")
	#daño a player si sigue en rango
	await get_tree().create_timer(0.4).timeout
	if player and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		if distance <= attack_range:
			player.take_damage(attack_damage, self) 
	
	#esperar antes de prox strike
	await get_tree().create_timer(attack_cooldown).timeout
	if not is_dead:
		can_attack = true

func take_damage(value: int, badguy: Node2D) -> void:
	Debug.log("%s received %d damage" % [name, value])
	life -= value
	#knockback = player.global_position.direction_to(global_position) * knockback_force
	if damage_number_scene:
		var dmg_num = damage_number_scene.instantiate()
		get_parent().add_child(dmg_num)
		dmg_num.global_position = global_position + Vector2(0, -60)
		dmg_num.setup(value)
	is_taking_hit = true
	playback.travel("take_hit")
	await get_tree().create_timer(0.4).timeout
	is_taking_hit = false
	#animation_player.play("take_hit")
	#animation_tree["parameters/take_hit/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	#animation_tree["parameters/take_hit/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT

	
	if life <= 0:
		_die()
		
func _die() -> void:
	is_dead = true
	death_sound.play()
	playback.travel("death")
	await get_tree().create_timer(1.2).timeout
	sprite_2d.hide()
	
	#suelta mushrooms de puntos
	if mushroom_point_scene:
		var mushroom = mushroom_point_scene.instantiate()
		get_parent().add_child(mushroom)
		mushroom.global_position = global_position
	await get_tree().create_timer(0.5).timeout
	queue_free()
	
func _on_damage_dealt() -> void:
	pass 
