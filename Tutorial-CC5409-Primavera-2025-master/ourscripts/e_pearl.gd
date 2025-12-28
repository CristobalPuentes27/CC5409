extends Item
@onready var audio_stream_player_2d_2: AudioStreamPlayer2D = $AudioStreamPlayer2D2
@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var collider: Area2D = $Collider
var throw := false
var entrar =true
func _init() -> void:
	spawnable = true
	description = "Gem that teleports the player"

func _physics_process(_delta: float) -> void:
	if throw: 
		var dir = transform.x.normalized() 
		position += dir * 5

func _effect() -> void:
	throw = true
	area_2d.monitoring = false
	collider.body_entered.connect(_on_collider_body_entered)

func _on_collider_body_entered(body: Node2D) -> void:
	if body == user_player: return
	audio_stream_player_2d_2.play()
	
	sprite_2d.visible = false
	collider.monitoring = false
	collider.monitorable = false
	if entrar:
		user_player.position = position
		entrar = false
		await audio_stream_player_2d_2.finished
		
	rpc_queue_free.rpc()
