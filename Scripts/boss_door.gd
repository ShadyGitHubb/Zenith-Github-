extends Area2D

@onready var global = get_node("/root/Global")
@export var target_scene = "res://Scenes/target_scene.tscn"  # Path to the next scene


func _on_body_entered(body):
	if body.is_in_group("Player") and global.has_key:
		global.set_has_key(false)  # Use the key
		open_door()

func open_door():
	queue_free()  # Remove the door (or change its collision shape)
	get_tree().change_scene_to_file(target_scene)  # Load the next scene
