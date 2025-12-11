class_name MainMenu
extends Control


@onready var host: Button = %Host
@onready var join: Button = %Join
@onready var tutorial: Button = %Tutorial
@onready var credits: Button = %Credits
@onready var quit: Button = %Quit
@onready var abs_confirm_1: AudioStreamPlayer = $AbsConfirm1
@onready var timer_2: Timer = $Timer2


func _ready() -> void:
	if Game.multiplayer_test:
		get_tree().change_scene_to_file("res://lobby/lobby_test.tscn")
		return
	
	quit.pressed.connect(on_quit_pressed)
	host.pressed.connect(on_host_pressed)
	tutorial.pressed.connect(on_tutorial_pressed)
	join.pressed.connect(on_join_pressed)
	credits.pressed.connect(on_credits_pressed)
	
	host.grab_focus()
func on_quit_pressed()->void:
		abs_confirm_1.play()
		timer_2.start()
		disable_all_buttons()
		await timer_2.timeout
		get_tree().quit()
func on_host_pressed()->void:
		abs_confirm_1.play()
		timer_2.start()
		disable_all_buttons()
		await timer_2.timeout
		get_tree().change_scene_to_file("res://lobby/host_screen.tscn")
func on_tutorial_pressed()->void:
	abs_confirm_1.play()
	timer_2.start()
	disable_all_buttons()
	await timer_2.timeout
	get_tree().change_scene_to_file("res://game/tutorial.tscn")
func on_credits_pressed()->void:
	abs_confirm_1.play()
	timer_2.start()
	disable_all_buttons()
	await timer_2.timeout
	get_tree().change_scene_to_file("res://ui/credits.tscn")
func on_join_pressed()->void:
	abs_confirm_1.play()
	timer_2.start()
	disable_all_buttons()
	await timer_2.timeout
	get_tree().change_scene_to_file("res://lobby/join_screen.tscn")
func disable_all_buttons()->void:
	host.disabled=true
	join.disabled=true
	tutorial.disabled=true
	credits.disabled=true
	quit.disabled=true
	
