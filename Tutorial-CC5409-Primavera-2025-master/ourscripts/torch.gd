extends Item

@onready var point_light_2d: PointLight2D = $PointLight2D

func use() -> void:
	point_light_2d.visible = true
	super.use()
