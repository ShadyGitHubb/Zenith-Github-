extends CharacterBody2D

@onready var global = get_node("/root/Global")

@export var speed = 35
var player_chase = false
var player = null
var direction = -1
var gravity = 9.8


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
		
	if player_chase:
		if player.global_position.x < global_position.x:
			direction = -1
			$AnimatedSprite2D.scale.x = direction
		else:
			direction = 1
			$AnimatedSprite2D.scale.x = direction
		position += (player.position - position) / speed
		

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true
	$AnimatedSprite2D.play("Walk")

func _on_detection_area_body_exited(body):
	player = null
	player_chase = false
	$AnimatedSprite2D.play("Idle")

