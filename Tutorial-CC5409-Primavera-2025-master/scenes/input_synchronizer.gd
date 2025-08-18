class_name InputSynchronizer
extends MultiplayerSynchronizer

@export var move_input: float
var jumped = false

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	move_input = Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("jump"):
		jump.rpc()

@rpc("authority", "call_local", "reliable")
func jump():
	jumped = true
