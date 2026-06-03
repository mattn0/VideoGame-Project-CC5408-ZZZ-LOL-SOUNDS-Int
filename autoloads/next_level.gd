extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node) -> void:
	var player: Player = body as Player
	if player:
		Debug.log("HOLA")
		Debug.log(LevelManager.current_level)
		LevelManager.next_level()
