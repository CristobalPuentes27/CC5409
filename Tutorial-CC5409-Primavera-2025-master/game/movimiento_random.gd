extends Node2D

@export var speed: float = 180.0                   # px/s
@export var change_interval: float = 2.0           # segundos (promedio)
@export var wander_radius: float = 300.0           # radio máximo del nuevo destino
@export var stop_at_target_distance: float = 8.0   # distancia para considerar "llegado"

var _target: Vector2 = Vector2.ZERO
var _timer: float = 0.0

func _ready() -> void:
	randomize()
	_pick_new_target()

func _physics_process(delta: float) -> void:
	_timer -= delta
	var to_target = _target - global_position
	if _timer <= 0.0 or to_target.length() <= stop_at_target_distance:
		_pick_new_target()

	if to_target.length() > 0.0:
		var dir = to_target.normalized()
		global_position += dir * speed * delta
		rotation = dir.angle()
@export var bounds: Rect2 = Rect2(-400, -300, 800, 600)  # ajustar

func _pick_new_target() -> void:
	_timer = change_interval * (0.6 + randf() * 0.8)
	var x = randf_range(bounds.position.x, bounds.position.x + bounds.size.x)
	var y = randf_range(bounds.position.y, bounds.position.y + bounds.size.y)
	_target = bounds.position + Vector2(x - bounds.position.x, y - bounds.position.y)
