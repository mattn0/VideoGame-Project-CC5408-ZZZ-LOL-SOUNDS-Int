class_name Player
extends CharacterBody2D

@export var explosion_scene: PackedScene
@export var poison_scene: PackedScene
@export var bullet_scene: PackedScene
@export var shield_scene: PackedScene
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
@onready var shop_menu = $"../ShopCanvas/ShopMenu"
@onready var game_over = $"../GameOverCanvas/GameOver"

signal life_changed(value)

var maxlife: int
var life: int
var speed: int
var point = 0
var maxpoint = 3
var knockback = Vector2.ZERO
var knockback_force = 320
var is_spinning := false
var is_dead: bool = false
var shield_active := false
var damage_reduction := 0.20
var shield_instance: Node2D

# Tamaño de la sala
var room_width = 1280
var room_height = 720

# Posición de la sala actual
var room_x = 0
var room_y = 0

var loadout_ui: LoadoutUI


func _ready() -> void:
	animation_player.play("idle")
	add_to_group("player")
	life = Game.player_data.life
	maxlife = Game.player_data.max_life
	speed = Game.player_data.speed

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
	
	loadout_ui = LoadoutUI.new()
	add_child(loadout_ui)
	loadout_ui.setup(roulette_manager)
	
func _setup_roulette() -> void:
	#var attack = preload("res://abilities/basic_attack.tres")
	#var shield = preload("res://abilities/shield.tres")
	#var nothing = preload("res://abilities/nothing_ability.tres")
	#
	#var make_slot = func(ability: Ability, index: int) -> SlotData:
	#	var sd = SlotData.new()
	#	sd.ability = ability
	#	sd.weight = ability.weight
	#	sd.slot_index = index
	#	return sd
	
	#roulette_manager.configure_slot(0, make_slot.call(attack, 0))
	#roulette_manager.configure_slot(1, make_slot.call(shield, 1))
	#roulette_manager.configure_slot(2, make_slot.call(attack, 2))
	#roulette_manager.configure_slot(3, make_slot.call(attack, 3))
	#roulette_manager.configure_slot(4, make_slot.call(shield, 4))
	#roulette_manager.configure_slot(5, make_slot.call(attack, 5))
	#roulette_manager.configure_slot(6, make_slot.call(nothing, 6))
	#roulette_manager.configure_slot(7, make_slot.call(nothing, 7))
	#roulette_manager.configure_slot(8, make_slot.call(shield, 8))
	#roulette_manager.configure_slot(9, make_slot.call(attack, 9))
	
	# Los 10 slots ya no están hardcodeados: LoadoutManager (autoload) guarda
	# la configuración del jugador (cuántos de cada tipo, niveles de mejora,
	# puntos) y la vuelca automáticamente a este RouletteManager cada vez
	# que cambia, incluyendo esta primera vez.
	LoadoutManager.register_roulette(roulette_manager)
	
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
	
	if Input.is_action_just_pressed("open_shop"):
		shop_menu.visible = !shop_menu.visible	
	
	if Input.is_action_just_pressed("attack") and not is_spinning:
		_trigger_attack()
		
func _unhandled_input(event: InputEvent) -> void:
	if is_spinning:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_0 or event.keycode == KEY_J:
			loadout_ui.toggle()
			get_viewport().set_input_as_handled()

## Punto de entrada para abrir el menú desde otro sistema, por ejemplo
## al completar un nivel: player.open_loadout_menu()
func open_loadout_menu() -> void:
	loadout_ui.open()

func _trigger_attack() -> void:
	is_spinning = true
	var result: SlotData = roulette_manager.spin()
	roulette_ui.show_result(result, func():
		ability_executor.execute(result, self)
		is_spinning = false)
		
	if result.ability.ability_name == "Basic_attack":
		await get_tree().create_timer(1).timeout
		var bullet_inst = bullet_scene.instantiate()
		# La bala tiene su propio "damage" (HitboxComponent.damage) separado
		# del "damage" de BasicAttack. Si no lo igualamos acá, la bala siempre
		# pega el valor fijo de la escena y las mejoras de poder no le afectan.
		if result.ability is BasicAttack:
			bullet_inst.damage = int(result.ability.damage)
		
		get_parent().add_child(bullet_inst)
		bullet_inst.global_position = bullet_mark.global_position
		var mouse_direction = bullet_mark.global_position.direction_to(get_global_mouse_position())
		bullet_inst.global_rotation = mouse_direction.angle()
	

func activate_shield(duration: float) -> void:
	if shield_active:
		return
	shield_active = true
	shield_instance = shield_scene.instantiate()
	shield_instance.scale = Vector2(0.25,0.25)
	add_child(shield_instance)
	shield_instance.position = Vector2.ZERO
	await get_tree().create_timer(duration).timeout
	shield_active = false
	if shield_instance:
		shield_instance.break_shield()
		shield_instance = null

func cast_poison() -> void:
	var poison = poison_scene.instantiate()
	get_parent().add_child(poison)
	poison.global_position = get_global_mouse_position() + Vector2(0,-48)

func cast_explosion() -> void:
	var explosion = explosion_scene.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = get_global_mouse_position() + Vector2(0, -50)


func take_damage(value: int, badguy: Node2D) -> void:
	#Debug.log("%s received %d damage" % [name, value])	
	animation_tree["parameters/take_damage_one/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	animation_tree["parameters/take_point_oneshot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
	if shield_active:
		value = int(value * (1.0 - damage_reduction))
	life -= value
	Game.player_data.life = life
	life_changed.emit(life)
	print(life)
	knockback = badguy.global_position.direction_to(global_position) * knockback_force

	if life <= 0:
		_player_dead()

func _player_dead() -> void:
	print("PLAYER DEAD")
	is_dead = true
	sprite_2d.hide()
	death_sound.play()
	Game.player_data._reset_stats()
	game_over.show_game_over()


func _on_damage_dealt() -> void:
	pass 
	
func take_point(value: int) -> void:
	point_sound.play()
	point += value
	LoadoutManager.add_points(value)
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
		
func add_health(amount: int):
	life += amount
	life = min(life, maxlife)
	Game.player_data.life = life
	life_changed.emit(life)

func add_speed(amount: int):
	speed += amount
	Game.player_data.speed

func buy_shield():
	Debug.log("Escudo comprado")
