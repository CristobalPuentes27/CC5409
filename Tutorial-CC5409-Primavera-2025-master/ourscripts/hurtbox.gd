class_name Hurtbox
extends Area2D

signal hurt(area: Area2D)

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		emit_signal("hurt", area)
