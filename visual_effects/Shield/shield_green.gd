extends Node2D

@export var defense_spell: PackedScene
@onready var animation_shield: AnimationPlayer = $AnimationShield
@onready var shield_green_base: Sprite2D = $ShieldGreenBase
@onready var shield_crack: Sprite2D = $ShieldCrack
@onready var shield_audio: AudioStreamPlayer = $ShieldAudio

var defense_spell_inst: Node

func _ready() -> void:
	shield_spell()
	animation_shield.play("ShieldBase")
	shield_audio.play()
	shield_crack.hide()

func shield_spell() -> void:
	if defense_spell:
		defense_spell_inst = defense_spell.instantiate()
		var spell = defense_spell_inst
		add_child(spell)
		spell.scale = Vector2(1.5, 1.5)
		spell.position = Vector2(25,-210)
		var anim = spell.get_node("AnimationPlayer")
		anim.play("SpellDefense")
	
func break_shield():
	shield_green_base.hide()
	shield_crack.show()
	animation_shield.play("ShieldCrack")
	await animation_shield.animation_finished
	queue_free()
