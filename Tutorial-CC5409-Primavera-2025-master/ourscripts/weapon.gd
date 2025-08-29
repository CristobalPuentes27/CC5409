class_name Weapon
extends Node2D

var attacking := false
var finalizing_attack := false
var from := rotation
var to := rotation + PI/4

func _physics_process(delta: float) -> void:
	
	if attacking and !finalizing_attack:
		rotation = rotate_toward(rotation, to, .1)
		if abs(rotation - to) < 0.01:
			finalizing_attack = true
	
	if finalizing_attack:
		rotation = rotate_toward(rotation, from, .1)
		if abs(rotation - from) < 0.01:
			attacking = false
			finalizing_attack = false
	
	send_rotation.rpc(rotation)

func attack() -> void:
	if !attacking:
		attacking = true

@rpc("authority", "call_remote", "reliable")
func send_rotation(rot):
	rotation = rot

func setup(player_data: Statics.PlayerData, multiplayer_synchronizer):
	set_multiplayer_authority(player_data.id, false)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id, false)
