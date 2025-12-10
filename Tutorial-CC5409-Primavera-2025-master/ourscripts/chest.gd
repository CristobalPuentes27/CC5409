class_name Chest
extends Node2D

@onready var chest_area: Area2D = $Area2D

@export var dict_item: Dictionary[String, String]
@export var dict_weapon: Dictionary[String, String]
@export var is_arma: bool = true

func _ready() -> void:
	chest_area.body_entered.connect(_on_chest_area_entered)
	chest_area.body_exited.connect(_on_chest_area_exited)
	modulate = Color(0,1,1,1) if is_arma else Color(1,0,0,1)

func _on_chest_area_entered(body: Node2D) -> void:
	var player = body as Player
	if player:
		player.chest_in_range(self)

func _on_chest_area_exited(body: Node2D) -> void:
	var player = body as Player
	if player:
		player.chest_off_range(self)

func open(opener:Player) -> void:
	if not is_arma:
		var index = randi() % dict_item.size()
		var item = dict_item.values()[index]
		opener._create_new_item.rpc(item)
	
	else:
		var index = randi() % dict_weapon.size()
		var item = dict_weapon.values()[index]
		print(dict_weapon)
		opener._create_new_weapon.rpc(item, false)

@rpc("any_peer", "call_local", "reliable")
func rpc_queue_free() -> void:
	queue_free()
