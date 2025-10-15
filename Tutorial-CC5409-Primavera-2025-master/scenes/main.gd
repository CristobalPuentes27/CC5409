extends Node2D

@export var player_scene: PackedScene
@export var dot_scene: PackedScene

@onready var battle_music: AudioStreamPlayer = $BattleMusic
@onready var regular_music: AudioStreamPlayer = $RegularMusic
@onready var label: Label = $Label
@onready var players: Node2D = $Players
@onready var markers: Node2D = $Markers
@onready var timer: Timer = $Timer
@onready var safe_zone: Area2D = $SafeZone

func _ready() -> void:
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_inst: Player = player_scene.instantiate()
		players.add_child(player_inst)
		player_inst.global_position = markers.get_child(i).global_position
		player_inst.setup(player_data)
		player_inst.connect("death_sign", _end_game)
	await timer.timeout
	regular_music.stop()
	battle_music.play()
	safe_zone.shrink()

func _on_dot_spawn(pos):
	spawn_dot.rpc_id(1, pos)

@rpc("any_peer", "call_local", "reliable")
func spawn_dot(pos):
	if not dot_scene:
		return
	var dot_inst = dot_scene.instantiate()
	add_child(dot_inst, true)
	dot_inst.global_position = pos

func _end_game(is_player: bool) -> void:
	if is_player: get_tree().change_scene_to_file("res://game/ui/final_scene_lose.tscn")
	else: get_tree().change_scene_to_file("res://game/ui/final_scene_win.tscn")
