class_name Player
extends CharacterBody2D

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

@onready var weapon: Weapon = $Weapon
@onready var camera_2d: Camera2D = $Camera2D

@export var SPEED = 500.0
@export var LIFE: int = 500
var resta:int=0

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
		
	
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("test"):
			test()
			Debug.log(LIFE)
	if LIFE<=0:
		self.modulate = Color(1,0,0,1)
	updateLive.rpc()
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

func take_damage(damage:int,other_pos:Vector2,punch:float):
	var dirr: Vector2 =position-other_pos
	
	dirr=dirr.normalized()
	velocity+= dirr*punch
	Debug.log(dirr)
	Debug.log(LIFE)
	resta=damage*-1
	LIFE-=damage
@rpc("authority", "call_remote", "reliable")
func updateLive():
	LIFE+=resta
	resta=0
	if LIFE<=0:
		self.modulate = Color(1,0,0,1)	
