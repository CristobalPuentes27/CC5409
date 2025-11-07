class_name Weapon
extends Node2D

@onready var pick_up_area: Area2D = $PickUpArea
@onready var area_2d: Area2D = $Area2D
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var switch_light_sound: AudioStreamPlayer = $SwitchLightSound

@export var attack_power: int = 100
@export var knockback: float = 2000
@export var attack_speed: float = .7
@export var rotation_cone := PI/2

var attacking := false
var player: Player = null
var change_collision := false

func _ready() -> void:
	if not multiplayer.is_server(): return

	area_2d.body_entered.connect(_on_area_2d_body_entered)
	pick_up_area.body_entered.connect(_on_pick_up_area_entered)

func _physics_process(_delta: float) -> void:
	send_rotation.rpc(rotation)

func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body as Player
	damage()

func _on_pick_up_area_entered(body: Node2D) -> void:
	player = body as Player
	Debug.log(player)
	if player:
		player.change_weapon.rpc(self.scene_file_path)

func attack() -> void:
	
	if attacking: return
	
	#enable_collision.rpc_id(1, true)
	audio_stream_player.play()
	var tween := create_tween()
	tween.tween_callback(Callable(self, "rpc_enable_collision").bind(true))
	tween.tween_property(self, "attacking", true, 0)
	tween.tween_property(self, "change_collision", true, 0)
	tween.tween_property(self, "rotation", rotation_cone/2, attack_speed/4)
	tween.tween_property(self, "rotation", -rotation_cone/2, attack_speed/2)
	tween.tween_property(self, "rotation", 0, attack_speed/4)
	tween.tween_callback(Callable(self, "rpc_enable_collision").bind(false))
	tween.tween_property(self, "attacking", false, 0)
	#enable_collision.rpc_id(1, false)

@rpc("authority", "call_remote", "reliable")
func send_rotation(rot):
	rotation = rot

@rpc("any_peer", "call_local", "reliable")
func switch_light() -> void:
	point_light_2d.visible = !point_light_2d.visible
	switch_light_sound.play()

func setup(player_data: Statics.PlayerData):
	set_multiplayer_authority(player_data.id, false)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id, false)
	switch_light()

func damage() -> void:
	if player:
		player.take_damage(attack_power, global_position, knockback)

@rpc("any_peer", "call_local", "reliable")
func enable_collision(val: bool) -> void:
	area_2d.monitoring = val

func rpc_enable_collision(val: bool) -> void:
	enable_collision.rpc(val)

@rpc("authority", "call_local", "reliable")
func picked_up() -> void:
	pick_up_area.monitoring = false
