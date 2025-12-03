extends Item

@onready var point_light_2d: PointLight2D = $PointLight2D

func _init() -> void:
	spawnable=true
	description = "Torch that will help you illuminate a bigger area"

func _effect() -> void:
	Debug.log(spawnable)
	point_light_2d.visible = true
	area_2d.monitoring = false
