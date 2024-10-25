extends Camera2D

@onready var global = get_node("/root/Global")


func _physics_process(delta):
	# Add the gravity.

	if global.camera_change:
		if not global_position == Vector2(686, 68):
			position += Vector2(1, 0)
	if not global_position == Vector2(206, 68) and not global.camera_change:
			position -= Vector2(1, 0)

