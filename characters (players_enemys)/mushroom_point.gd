extends Area2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var point_sound: AudioStreamPlayer = $PointSound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	body_entered.connect(_on_point_gain)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_point_gain(body: Node2D) -> void:
	var player: Player = body as Player
	if player: 
		monitoring = false
		Game.mushroom += 1
		point_sound.play()
		animation_player.play("puff")
		await animation_player.animation_finished
		queue_free()
