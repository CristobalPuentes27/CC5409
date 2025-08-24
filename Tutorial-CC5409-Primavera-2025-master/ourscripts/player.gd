class_name Player
extends CharacterBody2D

@export var SPEED = 500.0
@onready var weapon: Weapon = $Weapon


func _physics_process(delta: float) -> void:
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed("attack"):
		weapon.attack() 
	
	move_and_slide()

@rpc("any_peer", "call_local", "reliable")
func test() -> void:
	Debug.log("HOLA")
