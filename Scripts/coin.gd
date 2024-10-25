extends AnimatedSprite2D

@onready var area = $Area2D


signal coin_collected  # Signal emitted when the coin is collected


func _ready() -> void:  # Called when the node is ready
	play("Spin")  # Play the animation


func _on_body_entered(body: Node) -> void:  # Called when a body enters the area
	if body.name == "Player":
		emit_signal("coin_collected")
		queue_free()
