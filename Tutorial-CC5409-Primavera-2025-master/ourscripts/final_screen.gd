extends PanelContainer

@onready var button: Button = $VBoxContainer/Button


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	
	#Mover el selector entre botones con el teclado
	button.focus_mode = Control.FOCUS_ALL
	button.grab_focus()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
