class_name Weapon
extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_stream_player_2: AudioStreamPlayer = $AudioStreamPlayer2

@export var attack_power: int = 200
@export var knockback: float = 10000

var attacking := false
var finalizing_attack := false
var from := rotation
var to := rotation + PI/4
var player: Player = null
#@export var cooldown: bool = false

func _ready() -> void:
	if multiplayer.is_server():
		area_2d.body_entered.connect(_on_area_2d_body_entered)

func _physics_process(_delta: float) -> void:
	
	if attacking and !finalizing_attack:
		rotation = rotate_toward(rotation, to, .1)
		if abs(rotation - to) < 0.01:
			finalizing_attack = true
	
	if finalizing_attack:
		rotation = rotate_toward(rotation, from, .1)
		if abs(rotation - from) < 0.01:
			attacking = false
			enable_collision.rpc_id(1, false)
			finalizing_attack = false
			#cooldown = false
			#Debug.log("cooldown!!!!!!!!!!!!!!!!!!!!!")
	
	send_rotation.rpc(rotation)

func _on_area_2d_body_entered(body: Node2D) -> void:
	#Debug.log("Antes!!!!!!!!!!!!")
	#if cooldown:
	#	return
	#Debug.log("despues!!!!!!!!!!!!!!!!!!")
	#cooldown = true
	player = body as Player
	#var cooldown: Timer =  Timer.new()
	damage()

func attack() -> void:
	if !attacking:
		audio_stream_player.play()
		attacking = true
		enable_collision.rpc_id(1, true)

@rpc("authority", "call_remote", "reliable")
func send_rotation(rot):
	rotation = rot

@rpc("any_peer", "call_local", "reliable")
func switch_light() -> void:
	point_light_2d.visible = !point_light_2d.visible

func setup(player_data: Statics.PlayerData):
	set_multiplayer_authority(player_data.id, false)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id, false)

#@rpc("authority","call_local","reliable")
func damage():
	if player:
		player.take_damage(attack_power, global_position, knockback)
		#Debug.log("golpeo")

@rpc("any_peer", "call_local", "reliable")
func enable_collision(val: bool):
	area_2d.monitoring = val
