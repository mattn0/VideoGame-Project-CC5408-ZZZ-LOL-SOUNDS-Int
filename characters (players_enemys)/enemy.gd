extends CharacterBody2D


@export var speed = 300
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hitbox_component: HitboxComponent = $HitboxComponent


func _ready() -> void:
	animation_player.play("idle")
	hitbox_component.damage_dealt.connect(_on_damage_dealt)

func take_damage(value: int) -> void:
	#Debug.log("%s received %d damage" % [name, value])
	pass
	
func _on_damage_dealt() -> void:
	#Debug.log("%s made damage" % name)	
	pass
