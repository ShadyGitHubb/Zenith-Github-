extends Control

func _ready():
	$MarginContainer/VBoxContainer/Volume.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	
	

func _on_volume_mouse_exited():
	release_focus()
