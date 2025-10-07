class_name Player
extends CharacterBody2D
@onready var walk_sfx: AudioStreamPlayer = $AudioListener2D

@onready var weapon: Weapon = $Pivot/Weapon
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var camera_2d: Camera2D = $Camera2D
@onready var pivot: Node2D = $Pivot
@onready var health_bar: ProgressBar = $ProgressBar
@onready var i_frames: Timer = $IFrames
@onready var own_light: PointLight2D = $PointLight2D
var knockback_velocity: Vector2 = Vector2.ZERO
@onready var animation_tree: AnimationTree = $AnimationTree
var damage_enabled: bool = false

@export var SPEED = 100
@export var life: int = 500

func _physics_process(_delta: float) -> void:
	
	if not is_multiplayer_authority():
		return
	
	if damage_enabled:
		life -= 2
		send_life.rpc(life)
		if life <= 0:
			death.rpc()
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction and knockback_velocity == Vector2.ZERO:
		pivot.rotation = direction.angle()
		velocity = direction * SPEED
		animate.rpc(direction)
	elif knockback_velocity:
		velocity = knockback_velocity
		knockback_velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed("attack"):
		weapon.attack()
	
	if Input.is_action_just_pressed("switch_light"):
		weapon.audio_stream_player_2.play()
		weapon.switch_light.rpc()
	
	if Input.is_action_just_pressed("test"):
		#test()
		Debug.log("mi vida")
		Debug.log(life)
	
	if life <= 0:
		self.modulate = Color(1,0,0,1)
	
	move_and_slide()
	
	send_pos.rpc(position, pivot.rotation)
	#weapon.send_rotation.rpc(weapon.rotation)

@rpc("any_peer", "call_local", "reliable")
func test() -> void:
	Debug.log("HOLA")

func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id, false)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id, false)
	weapon.setup(player_data)
	camera_2d.enabled = is_multiplayer_authority()
	health_bar.max_value = life
	health_bar.value = life
	health_bar.visible = is_multiplayer_authority()
	own_light.visible = is_multiplayer_authority()
	if !multiplayer.is_server(): pass

@rpc("any_peer", "call_local", "unreliable_ordered")
func animate(direction: Vector2) -> void:
	animation_tree.get('parameters/playback').travel('move')
	animation_tree.set('parameters/move/blend_position', direction)

@rpc("authority", "call_remote", "unreliable_ordered")
func send_pos(pos: Vector2, pivot_rotation: float):
	position = pos
	pivot.rotation = pivot_rotation

@rpc("authority", "call_remote", "unreliable_ordered")
func send_vel(vel):
	velocity = vel

func take_damage(damage: int, other_pos: Vector2, punch: float):
	
	if !multiplayer.is_server():
		return
	
	if not i_frames.is_stopped():
		return
	
	i_frames.start()
	life -= damage
	send_life.rpc(life)
	if life <= 0:
		death.rpc()
	#Debug.log(life)
	
	var dirr: Vector2 = position - other_pos
	dirr = dirr.normalized()
	knockback.rpc(dirr * punch)
	Debug.log(dirr * punch)
	Debug.log(position)
	#velocity += dirr * punch
	#send_vel.rpc(velocity)

@rpc("any_peer", "call_local", "reliable")
func knockback(impulse: Vector2):
	knockback_velocity = impulse

@rpc("any_peer", "call_local", "reliable")
func death():
	self.modulate = Color(1,0,0,1)

@rpc("any_peer", "call_local", "reliable")
func send_life(new_life) -> void:
	health_bar.value = new_life

@rpc("any_peer", "call_local", "reliable")
func damage_enabler(val: bool) -> void:
	damage_enabled = val
	Debug.log(val)
