extends Node

@export var levels: Array[PackedScene]

var current_level = 0


func start() -> void:
	current_level = 0
	if not levels.is_empty():
		get_tree().change_scene_to_packed(levels[0])


func next_level() -> void:
	current_level += 1
	if current_level < levels.size():
		get_tree().change_scene_to_packed(levels[current_level])
