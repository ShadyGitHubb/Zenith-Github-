extends CharacterBody2D

@onready var global = get_node("/root/Global")
@export var speed = 35
var player_chase = false
var player = null
var direction = -1
var gravity = 200
@export var jump_force = -300  # NEW: Added jump force
@onready var ray_cast_ground = $RayCast2D2
@onready var ray_cast_forward = $AnimatedSprite2D/RayCast2D
@onready var soul_link_timer = $SoulLinkTimer  # Declare the Timer variable

func _ready():
	if soul_link_timer:
		soul_link_timer.connect("timeout", Callable(self, "_on_soul_link_timeout"))
		print("SoulLinkTimer connected successfully.")
	else:
		print("SoulLinkTimer node not found. Check node name and placement.")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	if player_chase:
		if player.global_position.x < global_position.x - 20:
			direction = -1
		elif player.global_position.x > global_position.x + 20:
			direction = 1
		$AnimatedSprite2D.scale.x = direction
		velocity.x = speed * direction
		if is_on_floor() and ray_cast_forward.is_colliding() and ray_cast_ground.is_colliding():
			var collider = ray_cast_forward.get_collider()
			if collider is TileMap:
				velocity.y = jump_force
				play_animation("Jump")
		elif not is_on_floor():
			if velocity.y > 0:
				play_animation("Fall")
			else:
				play_animation("Jump")
		else:
			play_animation("Walk")
	move_and_slide()

func _on_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		player_chase = true
		if soul_link_timer:
			soul_link_timer.stop()  # Stop timer when player is close
		play_animation("Walk")

func _on_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		player_chase = false
		if soul_link_timer:
			soul_link_timer.start(5)  # Start timer with 5 seconds

func _on_soul_link_timeout():
	get_tree().change_scene_to_file("res://UI/game_over_screen.tscn")  # Handle game over

# Function to handle animation transitions
func play_animation(animation_name):
	if not $AnimatedSprite2D.is_playing() or $AnimatedSprite2D.animation != animation_name:
		$AnimatedSprite2D.play(animation_name)
