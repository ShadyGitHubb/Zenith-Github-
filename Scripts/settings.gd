extends Control

# Initialize nodes and variables
@onready var margin_container = $Label/MarginContainer
@onready var volume_slider = $MarginContainer/VBoxContainer/Label/Volume
@onready var display_mode_option = $MarginContainer/VBoxContainer/Label2/DisplayModeOption

const SETTINGS_FILE = "user://settings.cfg"  # Path to the settings file

func _ready() -> void:
	# Load settings when the menu is ready
	load_settings()
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))  # Set volume slider to current volume
	
	# Initialize display mode options if not already populated
	if display_mode_option.get_item_count() == 0:
		display_mode_option.add_item("Windowed", 0)
		display_mode_option.add_item("Fullscreen", 1)
	
	# Connect signals for the sliders and options
	volume_slider.connect("value_changed", Callable(self, "_on_volume_value_changed"))
	display_mode_option.connect("item_selected", Callable(self, "_on_display_mode_option_item_selected"))

func _on_volume_value_changed(value: float) -> void:
	# Set the audio volume based on the slider value
	if value <= 0:
		AudioServer.set_bus_volume_db(0, -80)  # Mute level at lowest value
	else:
		AudioServer.set_bus_volume_db(0, linear_to_db(value))  # Change audio volume based on slider

func _on_display_mode_option_item_selected(index: int) -> void:
	# Change the display mode based on the selected option
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
			print("Windowed mode selected")
		1:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
			print("Fullscreen mode selected")

func load_settings() -> void:
	# Load settings from the configuration file
	var config = ConfigFile.new()  # Create a new ConfigFile instance
	if config.load(SETTINGS_FILE) == OK:  # Load settings file if it exists
		var saved_volume = config.get_value("Audio", "volume", 0.5)  # Load saved volume
		volume_slider.value = saved_volume
		AudioServer.set_bus_volume_db(0, linear_to_db(saved_volume))  # Set volume to saved level
		
		var display_mode = config.get_value("Display", "mode", 0)  # Load display mode setting
		display_mode_option.select(display_mode)  # Set dropdown state
		match display_mode:
			0:
				DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
				print("Windowed mode applied")
			1:
				DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
				print("Fullscreen mode applied")

func save_settings() -> void:
	# Save the current settings to the configuration file
	var config = ConfigFile.new()  # Create a new ConfigFile instance
	config.set_value("Audio", "volume", volume_slider.value)  # Save current volume
	config.set_value("Display", "mode", display_mode_option.get_selected_id())  # Save display mode state
	var err = config.save(SETTINGS_FILE)  # Save settings to file
	print("Settings saved with error code: ", err)

func _on_exit_button_pressed() -> void:
	# Save settings before exiting the game
	save_settings()
	get_tree().change_scene_to_file("res://UI/title_screen.tscn")  # Change to title screen
