extends Item

@onready var collider: Area2D = $Collider
@onready var sprite_2d: Sprite2D = $Sprite2D

var throw := false
var frames := 0

func _init() -> void:
	spawnable = true
	description = "Bottle that explodes into flames"

func _physics_process(_delta: float) -> void:
	
	if not throw: return
	
	sprite_2d.rotate(.2)
	var dir = transform.x.normalized() 
	position += dir * 5
	if frames >= 180 and is_multiplayer_authority(): _explode.rpc()
	frames += 1

func _effect() -> void:
	throw = true
	area_2d.monitoring = false
	collider.body_entered.connect(_on_collider_body_entered)

func _on_collider_body_entered(body: Node2D) -> void:
	if body == user_player: return
	_explode.rpc()

@rpc("any_peer", "call_local", "reliable")
func _explode() -> void:
	var fire_scene := load("res://game/fire.tscn")
	var fire = fire_scene.instantiate()
	fire.position = position
	get_parent().add_child(fire, true)
	queue_free()
