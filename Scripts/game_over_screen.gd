extends MarginContainer

signal restarted

func _ready():
	get_tree().paused = false

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_scene1.tscn")

