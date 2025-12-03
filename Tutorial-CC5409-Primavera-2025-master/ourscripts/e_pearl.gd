extends Item

@onready var collider: Area2D = $Collider
var throw := false

func _init() -> void:
	spawnable = true
	description = "Gem tha teleports the player"

func _physics_process(_delta: float) -> void:
	if throw: 
		var dir = transform.x.normalized() 
		position += dir

func _effect() -> void:
	throw = true
	area_2d.monitoring = false
	collider.body_entered.connect(_on_collider_body_entered)

func _on_collider_body_entered(body: Node2D) -> void:
	if body == user_player: return
	
	user_player.position = position
	rpc_queue_free.rpc()
