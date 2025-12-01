extends Node2D
class_name Chest
@export var dict_item:Dictionary
@export var dict_weapon:Dictionary
@onready var chest_area: Area2D = $Area2D

func _ready() -> void:
	chest_area.body_entered.connect(_on_chest_area_entered)
	chest_area.body_exited.connect(_on_chest_area_exited)
func _on_chest_area_entered(body: Node2D) -> void:
	var player = body as Player
	if player:
		player.chest_in_range(self)
func _on_chest_area_exited(body: Node2D) -> void:
	var player = body as Player
	if player:
		player.chest_off_range(self)
func open(opener:Player) ->void:
	if randf() > 0.5:
		var index=randi() % dict_item.size()
		var item=dict_item.values()[index]
		opener._create_new_item.rpc(item)

	else:
		var index=randi() % dict_weapon.size()
		var item=dict_weapon.values()[index]
		opener._create_new_weapon.rpc(item,true)

@rpc("any_peer", "call_local", "reliable")
func rpc_queue_free() -> void:
	queue_free()
