extends MarginContainer

signal restarted  # Signal emitted when the game is restarted
@onready var global = get_node("/root/Global")


func _ready() -> void:  # Called when the node is ready
	get_tree().paused = false


func _on_button_pressed() -> void:  # Called when a button is pressed
	change_scene_to_main_scene()


func _on_quit_button_pressed() -> void:  # Called when the quit button is pressed
	get_tree().quit()


func change_scene_to_main_scene() -> void:  # Changes to the main scene
	get_tree().change_scene_to_file("res://Scenes/main_scene1.tscn")
	global.reset_score()
