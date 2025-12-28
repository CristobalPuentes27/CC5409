class_name SafeZone
extends Area2D

const damage := 2

var min_size: Vector2
var shrinking: bool = false

func _ready() -> void:
	min_size = Vector2(18.8,18.8)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if shrinking:
		scale = scale.move_toward(min_size, 0.2)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		player.damage_enabler.rpc(-damage)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		player.damage_enabler.rpc(damage)

func shrink() -> void:
	shrinking = true
