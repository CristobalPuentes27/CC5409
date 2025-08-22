class_name Weapon
extends Node2D

var attacking := false
var finalizing_attack := false
var from := rotation
var to = rotation + PI/2

func _physics_process(delta: float) -> void:
	
	if attacking and !finalizing_attack:
		rotation = rotate_toward(rotation, to, .1)
		print("r:", rotation)
		print("to:", to)
		if rotation == to:
			finalizing_attack = true
	
	if finalizing_attack:
		rotation = rotate_toward(rotation, from, .1)
		print(rotation)
		print("asdfasdf")
		if rotation == from:
			attacking = false
			finalizing_attack = false

func attack() -> void:
	if !attacking:
		attacking = true
