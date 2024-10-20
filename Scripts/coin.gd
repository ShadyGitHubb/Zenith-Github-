extends AnimatedSprite2D

@onready var area = $Area2D

signal coin_collected

func _ready():
	play("Spin")  # Play the animation

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("coin_collected")
		queue_free()
