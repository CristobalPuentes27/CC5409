extends Item

@export var to_heal=60

func use() -> void:
	get_parent().take_damage(-to_heal,Vector2(0,0),0)
	queue_free()
