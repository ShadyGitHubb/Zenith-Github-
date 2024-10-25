extends Node2D

# Constants to define timing durations and the title screen scene path
const FADE_IN_DURATION = 1.0  # Duration for fade-in effect
const DISPLAY_DURATION = 5.0  # Duration to display the title screen
const FADE_OUT_DURATION = 3.0  # Duration for fade-out effect
const TITLE_SCREEN_PATH = "res://UI/title_screen.tscn"  # Path to the title screen scene

# Function called when the node is ready
func _ready() -> void:
	# Wait for the fade-in duration and then play the fade-in animation
	await get_tree().create_timer(FADE_IN_DURATION).timeout
	$AnimationPlayer.play("fade")

	# Wait for the display duration before starting the fade-out animation
	await get_tree().create_timer(DISPLAY_DURATION).timeout
	$AnimationPlayer.play_backwards("fade")

	# Wait for the fade-out duration before changing to the title screen
	await get_tree().create_timer(FADE_OUT_DURATION).timeout
	get_tree().change_scene_to_file(TITLE_SCREEN_PATH)  # Change to the title screen scene
