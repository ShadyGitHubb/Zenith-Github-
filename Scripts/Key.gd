extends Area2D

@onready var global = get_node("/root/Global")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		global.set_has_key(true)  # Use the new function to set the key status
		queue_free()  # Remove the key
