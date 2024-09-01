extends CharacterBody2D

@export var speed = 35
var player_chase = false
var player = null

func _physics_process(delta):
	if player_chase:
		position += (player.position - position) / speed



func _on_detection_area_body_entered(body):
	player = body
	player_chase = true
	$AnimatedSprite2D.play("Walk")

func _on_detection_area_body_exited(body):
	player = null
	player_chase = false
	$AnimatedSprite2D.play("Idle")

