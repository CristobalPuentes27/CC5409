class_name SafeZone
extends Area2D

@onready var timer: Timer = $Timer

var min_size: Vector2
var shrinking: bool = false

func _ready() -> void:
	min_size = Vector2(19,19)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if shrinking:
		scale = scale.move_toward(min_size, 0.5)

func _on_body_entered(body: Node2D) -> void:
	Debug.log("AAAAAAAAAAAAAAaa")
	if body is Player:
		var player = body as Player
		player.damage_enabler.rpc(false)

func _on_body_exited(body: Node2D) -> void:
	Debug.log("BBBBBBBBBBBBBBBbbb")
	if body is Player:
		var player = body as Player
		player.damage_enabler.rpc(true)

func shrink() -> void:
	shrinking = true
