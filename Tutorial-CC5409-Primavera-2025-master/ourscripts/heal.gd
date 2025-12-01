extends Item

@export var to_heal=60
var description="Potion that will heal you "+ str(to_heal)+" life"
func use() -> void:
	get_parent().take_damage(-to_heal,Vector2(0,0),0)
	queue_free()
