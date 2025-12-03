extends Item

@export var to_heal = 60
@onready var audio_stream_player_2d1: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var area_2d2: Area2D = $Area2D

func _ready() -> void:
	spawnable=false
	description = "Potion that will heal you " + str(to_heal) + " life"

func use() -> void:
	get_parent().take_damage(-to_heal,Vector2(0,0),0)
	audio_stream_player_2d1.play()
	area_2d2.monitorable=false
	area_2d2.monitoring = false
	await audio_stream_player_2d1.finished
	queue_free()
