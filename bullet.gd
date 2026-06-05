extends HitboxComponent

@onready var timer: Timer = $Timer
@onready var basic_attack_sound: AudioStreamPlayer = $basic_attack_sound

@export var speed = 500
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	basic_attack_sound.play()
	timer.timeout.connect(func(): queue_free())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _physics_process(delta: float) -> void:
	
	var direction = global_transform.x
	global_position += direction * speed * delta
	
