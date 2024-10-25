extends Node2D

@onready var key_label = $CanvasLayer/KeyLabel  # Ensure this path is correct
@onready var global = get_node("/root/Global")


func _ready():  # Called when the node is ready
	global.connect("key_status_changed", Callable(self, "_on_key_status_changed"))
	update_key_label(global.has_key)


func _on_key_status_changed(has_key: bool):  # Called when key status changes
	update_key_label(has_key)


func update_key_label(has_key: bool):  # Updates the key label based on key status
	const KEY_ACQUIRED_TEXT = "You have the key!"
	const NO_KEY_TEXT = "No key"

	if has_key:
		key_label.text = KEY_ACQUIRED_TEXT
	else:
		key_label.text = NO_KEY_TEXT


func _on_game_over_screen_restarted() -> void:  # Called when game over screen is restarted
	get_tree().reload_current_scene()
