extends CharacterBody2D

@onready var global = get_node("/root/Global")

@export var speed = 35
var player_chase = false
var player = null
var direction = -1
var gravity = 9.8
@export var jump_force = -300  # NEW: Added jump force

# NEW: Added ray cast for detecting obstacles
@onready var ray_cast = $RayCast2D

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
		
	if player_chase:
		if player.global_position.x < global_position.x - 20:
			direction = -1
			$AnimatedSprite2D.scale.x = direction
		elif player.global_position.x > global_position.x + 20:
			direction = 1
			$AnimatedSprite2D.scale.x = direction
		velocity.x = speed * direction
		
		# NEW: Check for obstacles and jump
		if is_on_floor() and ray_cast.is_colliding():
			var collider = ray_cast.get_collider()
			if collider is TileMap:
				velocity.y = jump_force
		
	move_and_slide()

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true
	$AnimatedSprite2D.play("Walk")

func _on_detection_area_body_exited(body):
	player = null
	player_chase = false
	

