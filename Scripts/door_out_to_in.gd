extends Area2D

@onready var global = get_node("/root/Global")  # Access the global score variable

@export var required_score = 5  # Number of coins required to open the door
@export var target_scene = "res://Scenes/main_scene1.tscn"  # Path to the main scene
@export var target_position = Vector2(0, 0)  # Position to place the player in the main scene


func _on_body_entered(body):
	if body.is_in_group("Player"):
		open_door(body)

func open_door(body):
	queue_free()  # Remove the door (or change its collision shape)
	get_tree().change_scene_to_file(target_scene)  # Load the next scene
	# Set the player's position in the new scene
	body.global_position = target_position
