extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_stream_player_2d_2: AudioStreamPlayer2D = $AudioStreamPlayer2D2

const damage := 2

var frames = 0

func _ready() -> void:
	set_multiplayer_authority(1, false)
	audio_stream_player_2d_2.play()
	audio_stream_player_2d.play()

func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	if frames >= 500: rpc_queue_free.rpc()
	frames += 1
	

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		player.damage_enabler.rpc(damage)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		player.damage_enabler.rpc(-damage)

@rpc("any_peer", "call_local", "reliable")
func rpc_queue_free() -> void:
	audio_stream_player_2d.playing =false
	queue_free()
