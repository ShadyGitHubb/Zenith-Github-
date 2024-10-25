extends Area2D

@onready var global = get_node("/root/Global")  # Access the global score variable

@export var required_score = 5  # Number of coins required to open the door

func _on_body_entered(body):
	if body.is_in_group("Player") and global.score >= required_score:
		open_door()

func open_door():
	queue_free()  # Remove the door (or change its collision shape)
	# Optional: Add code to change scenes or allow player to go outside
	get_tree().change_scene_to_file("res://Outside.tscn")  # Load the next scene
