extends Node2D

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	$AnimationPlayer.play("fade")
	await get_tree().create_timer(5.0).timeout
	$AnimationPlayer.play_backwards("fade")
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://UI/title_screen.tscn")
pass
