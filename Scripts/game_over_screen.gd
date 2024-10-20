extends MarginContainer

signal restarted
@onready var global = get_node("/root/Global")

func _ready():
	get_tree().paused = false

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_scene1.tscn")
	global.reset_score()



func _on_quit_button_pressed():
	pass # Replace with function body.
