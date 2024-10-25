extends Area2D

# Function that is called when a body enters the area
func _on_body_entered(body: Node) -> void:
	# Check if the entered body has a 'die' method and call it if it does
	if body.has_method("die"):
		body.die()  # Call the die method on the body
