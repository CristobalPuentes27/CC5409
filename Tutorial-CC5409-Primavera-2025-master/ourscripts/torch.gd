extends Item

@onready var point_light_2d: PointLight2D = $PointLight2D
var description="Torch that will help you illuminate a bigger area"
func _init() -> void:
	spawnable=true
func use() -> void:
	Debug.log(spawnable)
	point_light_2d.visible = true
	super.use()
