class_name Player
extends CharacterBody2D

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var weapon: Weapon = $Weapon
@onready var camera_2d: Camera2D = $Camera2D

@export var SPEED = 500.0
@export var life: int = 500

func _physics_process(delta: float) -> void:
	
	if not is_multiplayer_authority():
		return
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity = direction * SPEED
	else:
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
	
	send_pos.rpc(position)
	#weapon.send_rotation.rpc(weapon.rotation)

@rpc("any_peer", "call_local", "reliable")
func test() -> void:
	Debug.log("HOLA")

func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id, false)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id, false)
	weapon.setup(player_data, multiplayer_synchronizer)
	camera_2d.enabled = is_multiplayer_authority()

@rpc("authority", "call_remote", "unreliable_ordered")
func send_pos(pos):
	position = pos

func take_damage(damage: int, other_pos: Vector2, punch: float):
	
	if !multiplayer.is_server():
		return
	
	life -= damage
	if life <= 0:
		death.rpc()
	Debug.log(life)
	
	var dirr: Vector2 = position - other_pos
	dirr = dirr.normalized()
	knockback.rpc_id(get_multiplayer_authority(), dirr * punch)
	#position += dirr * punch
	Debug.log(dirr)
	send_pos.rpc(position)

@rpc("any_peer", "call_local", "reliable")
func knockback(impulse: Vector2):
	velocity += impulse

@rpc("any_peer", "call_local", "reliable")
func death():
	self.modulate = Color(1,0,0,1)
