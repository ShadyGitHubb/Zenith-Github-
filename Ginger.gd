extends CharacterBody2D

@onready var global = get_node("/root/Global")

@export var speed = 35
var player_chase = false
var player = null
var direction = -1
var gravity = 9.8
@export var jump_force = -300  # NEW: Added jump force

@onready var ray_cast_ground = $RayCast2D2
@onready var ray_cast_forward = $AnimatedSprite2D/RayCast2D

@onready var death_timer = $DeathTimer
func _ready():
	death_timer = Timer.new()
	death_timer.set_one_shot(true)
	death_timer.set_wait_time(5.0)
	death_timer.connect("timeout", Callable(self, "_on_death_timer_timeout"))
	add_child(death_timer)


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
		
		if is_on_floor() and ray_cast_forward.is_colliding() and ray_cast_ground.is_colliding():
			var collider = ray_cast_forward.get_collider()
			if collider is TileMap:
				velocity.y = jump_force
			$AnimatedSprite2D.play("Jump")
		elif not is_on_floor():
			if velocity.y > 0:
				$AnimatedSprite2D.play("Fall")
			else:
				$AnimatedSprite2D.play("Jump")
		else:
			$AnimatedSprite2D.play("Walk")
		
	move_and_slide()

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true
	$AnimatedSprite2D.play("Walk")
	death_timer.stop()
	
func _on_detection_area_body_exited(body):
	player = null
	player_chase = false
	death_timer.start()
	

# NEW: Handle player death
func _on_death_timer_timeout():
	if player:
		player.die()
		
func stop_death_timer():
	death_timer.stop()
