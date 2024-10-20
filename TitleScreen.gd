extends Control

@onready var animation_player = $AnimationPlayer
@onready var margin_container = $MarginContainer  # Make sure this path is correct

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_scene1.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _ready():
	if animation_player:
		animation_player.play("bouncingtitle")
	else:
		print("AnimationPlayer node not found.")
	
	get_viewport().connect("size_changed", Callable(self, "_on_screen_resized"))
	_on_screen_resized()

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")

func _on_screen_resized():
	if margin_container:
		var resolution = get_viewport().get_visible_rect().size
		margin_container.rect_min_size = resolution
		margin_container.rect_position = (resolution - margin_container.rect_min_size) / 2
	else:
		print("MarginContainer node not found.")
