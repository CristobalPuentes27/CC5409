class_name Item
extends Node2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var area_2d: Area2D = $Area2D

var spawnable := false
var description: String
var user_player: Player

func _ready() -> void:
	set_multiplayer_authority(1, false)

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	_send_position.rpc(position)

func _on_area_2d_body_entered(body: Node2D) -> void:
	var player = body as Player
	if player:
		player.item_in_range(self)

func _on_area_2d_body_exited(body: Node2D) -> void:
	var player = body as Player
	if player:
		player.item_off_range(self)

@rpc("any_peer", "call_local", "reliable")
func rpc_queue_free() -> void:
	queue_free()

func use() -> void:
	_rpc_play.rpc()
	_effect()

@rpc("any_peer", "call_local", "reliable")
func _rpc_play() -> void:
	audio_stream_player_2d.play()

@rpc("any_peer", "call_remote", "unreliable")
func _send_position(pos: Vector2) -> void:
	position = pos

#Hacer override a esta función 
func _effect() -> void:
	assert(false)
