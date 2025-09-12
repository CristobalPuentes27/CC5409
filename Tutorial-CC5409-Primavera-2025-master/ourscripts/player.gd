class_name Player
extends CharacterBody2D

@onready var weapon: Weapon = $Pivot/Weapon
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var camera_2d: Camera2D = $Camera2D
@onready var pivot: Node2D = $Pivot
@onready var health_bar: ProgressBar = $ProgressBar
@onready var i_frames: Timer = $IFrames
@onready var own_light: PointLight2D = $PointLight2D
var knockback_velocity: Vector2 = Vector2.ZERO

@export var SPEED = 500.0
@export var life: int = 500

func _physics_process(delta: float) -> void:
	
	if not is_multiplayer_authority():
		return
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		pivot.rotation = direction.angle()
		velocity = direction * SPEED
	else:#elif knockback_velocity != Vector2.ZERO:
		velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed("attack"):
		weapon.attack()
	
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

@rpc("authority", "call_remote", "unreliable_ordered")
func send_pos(pos, pivot_rotation):
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
