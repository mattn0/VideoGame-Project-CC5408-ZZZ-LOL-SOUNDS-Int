extends Control

@onready var buy_health_button = $Panel/VBoxContainer/vida_1
@onready var buy_speed_button = $Panel/VBoxContainer/velocidad_1
@onready var buy_shield = $Panel/VBoxContainer/escudo_1
@onready var close_button = $Panel/VBoxContainer/cerrar

func _ready():
	visible = false

	buy_health_button.pressed.connect(_on_buy_health_pressed)
	buy_speed_button.pressed.connect(_on_buy_speed_pressed)
	buy_shield.pressed.connect(_on_buy_shield)
	close_button.pressed.connect(_on_close_pressed)

func _on_buy_health_pressed() -> void:
	if Game.spend_mushrooms(5):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.add_health(20)

func _on_buy_speed_pressed() -> void:
	if Game.spend_mushrooms(10):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.add_speed(25)

func _on_buy_shield() -> void:
	if Game.spend_mushrooms(15):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.buy_shield()

func _on_close_pressed() -> void:
	visible = false
