extends PanelContainer

@onready var button: Button = $VBoxContainer/Button
@onready var abs_cancel_1: AudioStreamPlayer = $AbsCancel1
@onready var timer: Timer = $Timer


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	
	#Mover el selector entre botones con el teclado
	button.focus_mode = Control.FOCUS_ALL
	button.grab_focus()

func _on_button_pressed() -> void:
		await change_to_menu()

func change_to_menu()->void:
	abs_cancel_1.play()
	"res://ui/main_menu.tscn"
	timer.start()
	disable_all_buttons()
	await timer.timeout
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
	pass
func disable_all_buttons() -> void:
	button.disabled=true
