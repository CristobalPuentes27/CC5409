class_name Item
extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var spawnable := false
var description: String

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
	audio_stream_player_2d.play()
	_effect()

#Hacer override a esta función 
func _effect() -> void:
	assert(false)
