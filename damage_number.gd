extends Node2D

@onready var label: Label = $Label

func setup(value: int) -> void:
	label.text = str(value)
	label.modulate = Color.RED
	
	var tween = create_tween()
	#sube y se hace pequeño
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 40, 0.6)
	tween.tween_property(self, "scale", Vector2.ZERO, 1).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)
	
	await tween.finished
	queue_free()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
