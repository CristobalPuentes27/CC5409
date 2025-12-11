extends Panel

@onready var back_button: Button = %BackButton
@onready var abs_cancel_1: AudioStreamPlayer = $AbsCancel1
@onready var timer: Timer = $Timer

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
func _on_back_pressed()->void:
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
		back_button.disabled=true
