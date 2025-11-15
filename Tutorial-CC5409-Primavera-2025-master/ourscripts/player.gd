class_name Player
extends CharacterBody2D

@onready var rage_quit: Button = $PauseMenu/RageQuit
@onready var walk_sfx: AudioStreamPlayer = $AudioListener2D
@onready var pause_menu: VBoxContainer = $PauseMenu
@onready var weapon: Weapon = $Pivot/Lantern
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var camera_2d: Camera2D = $Camera2D
@onready var pivot: Node2D = $Pivot
@onready var health_bar: ProgressBar = $ProgressBar
@onready var i_frames: Timer = $IFrames
@onready var own_light: PointLight2D = $PointLight2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var pick_up_panel: Panel = $PickUpPanel
@onready var stats_panel: Panel = $StatsPanel
@onready var rich_text_label: RichTextLabel = $StatsPanel/RichTextLabel

@export var SPEED = 125
@export var life: int = 500

var stored_data
var knockback_velocity: Vector2 = Vector2.ZERO
const max_knockback_frames: int = 4
var knockback_frames: int = 0
var damage_enabled: bool = false
var pickable_weapon: Weapon
var pickable_weapon_light: bool
@onready var stats_template: String = rich_text_label.text

signal death_sign(is_player: bool)

func _ready() -> void:
	weapon.point_light_2d.visible = true
	rage_quit.pressed.connect(_on_rage_quit)

func _physics_process(_delta: float) -> void:
	
	if not is_multiplayer_authority():
		return
	
	if Input.is_action_just_pressed("menu"):
		pause_menu.visible = !pause_menu.visible
	var paused = pause_menu.visible
	
	if damage_enabled:
		life -= 2
		send_life.rpc(life)
		if life <= 0:
			death.rpc()
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if paused: direction = Vector2.ZERO
	if direction and knockback_velocity == Vector2.ZERO:
		pivot.rotation = direction.angle()
		velocity = direction * SPEED
		animate.rpc(direction)
	elif knockback_velocity:
		velocity = knockback_velocity / 5
		knockback_frames += 1
		if knockback_frames == max_knockback_frames:
			knockback_velocity = Vector2.ZERO
			knockback_frames = 0
	else:
		velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed("attack") and not paused:
		weapon.attack()
	
	if Input.is_action_just_pressed("pick_object") and pickable_weapon and not weapon.attacking:
		change_weapon.rpc(pickable_weapon.scene_file_path, pickable_weapon_light)
	
	if Input.is_action_just_pressed("switch_light") and not paused:
		weapon.switch_light.rpc()
	
	if life <= 0:
		self.modulate = Color(1,0,0,1)
	
	move_and_slide()
	
	send_pos.rpc(position, pivot.rotation)

func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id, false)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id, false)
	weapon.setup(player_data, true)
	camera_2d.enabled = is_multiplayer_authority()
	health_bar.max_value = life
	health_bar.value = life
	health_bar.visible = is_multiplayer_authority()
	own_light.visible = is_multiplayer_authority()
	stored_data = player_data

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
	
	var dirr: Vector2 = position - other_pos
	dirr = dirr.normalized()
	knockback.rpc(dirr * punch)
	#velocity += dirr * punch
	#send_vel.rpc(velocity)

@rpc("any_peer", "call_local", "reliable")
func knockback(impulse: Vector2):
	knockback_velocity = impulse

@rpc("any_peer", "call_local", "reliable")
func death():
	self.modulate = Color(1,0,0,1)
	death_sign.emit(is_multiplayer_authority())

@rpc("any_peer", "call_local", "reliable")
func send_life(new_life) -> void:
	health_bar.value = new_life

@rpc("any_peer", "call_local", "reliable")
func damage_enabler(val: bool) -> void:
	damage_enabled = val

func _on_rage_quit() -> void:
	death.rpc()

@rpc("any_peer", "call_local", "reliable")
func change_weapon(new_weapon: String, light_on: bool) -> void:
	if is_multiplayer_authority():
		_create_new_weapon.rpc(weapon.scene_file_path, weapon.point_light_2d.visible)
		pickable_weapon.rpc_queue_free.rpc()
		weapon.rpc_server_queue_free.rpc_id(1)
	weapon = load(new_weapon).instantiate()
	pivot.add_child(weapon, true)
	weapon.setup(stored_data, light_on)
	pick_up_panel.visible = false
	pickable_weapon = null

func weapon_in_range(new_weapon: Weapon, light_on: bool) -> void:
	if !is_multiplayer_authority(): return
	pickable_weapon = new_weapon
	pickable_weapon_light = light_on
	stats_panel.visible = true
	rich_text_label.text = stats_template.format({
		"attack": new_weapon.attack_power,
		"attack_speed": new_weapon.attack_speed
	})
	pick_up_panel.visible = true

func weapon_off_range(new_weapon: Weapon) -> void:
	if !is_multiplayer_authority(): return
	if pickable_weapon == new_weapon:
		pickable_weapon = null
		pick_up_panel.visible = false
		stats_panel.visible = false

@rpc("any_peer", "call_local", "reliable")
func _create_new_weapon(scene: String, light_on: bool) -> void:
	var new_weapon: Weapon = load(scene).instantiate()
	get_parent().add_child(new_weapon, true)
	new_weapon.global_position = position
	new_weapon.point_light_2d.visible = light_on
	new_weapon.rotation = pivot.rotation
