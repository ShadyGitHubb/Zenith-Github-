extends Node

const scene_main_scene1 = preload("res://Scenes/main_scene1.tscn")
const scene_level2 = preload("res://level_2.tscn")

signal on_trigger_player_spawn

var spawn_door_tag

func go_to_level(level_tag, destination_tag):
	var scene_to_load
	
	match level_tag:
		"main_scene1":
			scene_to_load = scene_main_scene1
		"level2":
			scene_to_load = scene_level2
			
	if scene_to_load != null:
		spawn_door_tag = destination_tag
		get_tree().change_scene_to_packed(scene_to_load)

func trigger_player_spawn(position: Vector2, direction: String):
	on_trigger_player_spawn.emit(position, direction)
