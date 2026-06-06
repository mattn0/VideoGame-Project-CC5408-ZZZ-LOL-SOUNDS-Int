extends Resource
class_name PlayerData

var life:int = 100
var max_life: int = 100
var speed = 300

func _reset_stats() -> void:
	life = 100
	max_life = 100
	speed = 300

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
