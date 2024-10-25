extends Area2D

class_name Door

@export var destination_level_tag: String
@export var destination_door_tag: String
@export var spawn_direction = "up"

@onready var spawn = $Spawn
@onready var global = get_node("/root/Global")

func _on_body_entered(body):
	if body is Player:
		global.camera_change = true
		NavigationManager.go_to_level(destination_level_tag, destination_door_tag) 
