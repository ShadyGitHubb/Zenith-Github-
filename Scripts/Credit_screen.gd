extends Control


func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://UI/title_screen.tscn")  # Change to title screen
