extends Control

@export var full_heart: Texture2D
@export var half_heart: Texture2D
@export var empty_heart: Texture2D

@onready var hearts = [
	$HeartsContainer/Heart1,
	$HeartsContainer/Heart2,
	$HeartsContainer/Heart3,
	$HeartsContainer/Heart4,
	$HeartsContainer/Heart5
]

func _ready():
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.life_changed.connect(update_hearts)
		update_hearts(player.life)

func update_hearts(current_life: int):
	var remaining = current_life
	for heart in hearts:
		if remaining >= 20:
			heart.texture = full_heart
		elif remaining >= 10:
			heart.texture = half_heart
		else:
			heart.texture = empty_heart
		remaining -= 20
