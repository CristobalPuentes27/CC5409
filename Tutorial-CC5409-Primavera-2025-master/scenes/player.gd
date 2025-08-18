extends CharacterBody2D

signal dot_spawn_requested

@export var max_speed: int = 300
@export var jump_speed: int = 200
@export var acceleration: int = 1000
@export var gravity: int = 500

@export var dot_scene: PackedScene

@onready var label: Label = $Label
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if input_synchronizer.jumped:
		velocity.y = -jump_speed
		input_synchronizer.jumped = false
	var move_input = input_synchronizer.move_input
	velocity.x = move_toward(velocity.x, move_input * max_speed, acceleration * delta)
	move_and_slide()
	
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("click"):
			dot_spawn_requested.emit(get_global_mouse_position())


func setup(player_data: Statics.PlayerData):
	label.text = player_data.name
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id, false)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id, false)


@rpc("any_peer", "call_local", "reliable")
func test():
	Debug.log("test: %s" % [label.text] )

@rpc("authority", "call_remote", "unreliable_ordered")
func send_pos(pos):
	position = pos
	
