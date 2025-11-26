extends Item

@onready var point_light_2d: PointLight2D = $PointLight2D

func _init() -> void:
	spawnable=true
func use() -> void:
	Debug.log(spawnable)
	point_light_2d.visible = true
	super.use()
