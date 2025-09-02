class_name Weapon
extends Node2D
@onready var area_2d: Area2D = $Area2D
@export var attack_power: int =200
@export var knockback: float =2
var hitting =false
var attacking := false
var finalizing_attack := false
var from := rotation
var to := rotation + PI/4
var player: Player	=null
func _physics_process(delta: float) -> void:
	if attacking:
		area_2d.monitoring =true
	if attacking and !finalizing_attack:
		rotation = rotate_toward(rotation, to, .1)
		if abs(rotation - to) < 0.01:
			finalizing_attack = true
	
	if finalizing_attack:
		rotation = rotate_toward(rotation, from, .1)
		if abs(rotation - from) < 0.01:
			attacking = false
			area_2d.monitoring = false
			finalizing_attack = false
	if hitting:
		damage.rpc()
		hitting=false
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
@rpc("authority","call_local","reliable")
func damage():
	var actual: Vector2= position
	if player:
		player.take_damage(attack_power,actual,knockback)
		Debug.log("golpeo")
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	player=body as Player
	hitting=true
	
	
		
		
