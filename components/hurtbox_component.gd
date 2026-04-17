class_name  HurtboxComponent
extends Area2D

@onready var hitbox_component: HitboxComponent = $HitboxComponent


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area2D) -> void:
	var hitbox = area as HitboxComponent
	var pointbox = area as PointBoxComponent
	if hitbox:
		if owner.has_method("take_damage"):
			owner.take_damage(hitbox.damage, hitbox.owner)
			hitbox.damage_dealt.emit()
	if pointbox:
		if owner.has_method("take_point"):
			owner.take_point(pointbox.point)
			pointbox.add_point.emit()
