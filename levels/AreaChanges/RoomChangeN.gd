extends Area2D

@export var next_room_x = 0
@export var next_room_y = -720

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	# Solo entramos si el jugador existe Y su seguro 'can_change_room' es true
	if player and player.can_change_room:
		print("Cambiando de sala...")
		player.change_room(next_room_x, next_room_y)
