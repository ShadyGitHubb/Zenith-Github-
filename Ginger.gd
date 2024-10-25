extends CharacterBody2D

# Constants for configuration
const PLAYER_CHASE_DISTANCE: float = 20.0  # Distance threshold for chasing the player
const SOUL_LINK_TIMER_DURATION: float = 5.0  # Timer duration for the soul link

# Onready variables
@onready var global: Global = get_node("/root/Global")
@onready var ray_cast_ground: RayCast2D = $RayCast2D2
@onready var ray_cast_forward: RayCast2D = $AnimatedSprite2D/RayCast2D
@onready var soul_link_timer: Timer = $SoulLinkTimer  # Declare the Timer variable

# Exported and regular variables
@export var speed: float = 35.0
var player_chase: bool = false
var player: Node2D = null
var direction: int = -1
var gravity: float = 200.0
@export var jump_force: float = -300.0  # NEW: Added jump force


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0


	if player_chase:
		update_direction_based_on_player()


		$AnimatedSprite2D.scale.x = direction
		velocity.x = speed * direction


		if is_on_floor() and ray_cast_forward.is_colliding() and ray_cast_ground.is_colliding():
			var collider: Node = ray_cast_forward.get_collider()
			if collider is TileMap:
				velocity.y = jump_force
				play_animation("Jump")
		elif not is_on_floor():
			handle_airborne_animation()
		else:
			play_animation("Walk")
	
	move_and_slide()


func update_direction_based_on_player() -> void:
	if player.global_position.x < global_position.x - PLAYER_CHASE_DISTANCE:
		direction = -1
	elif player.global_position.x > global_position.x + PLAYER_CHASE_DISTANCE:
		direction = 1


func handle_airborne_animation() -> void:
	if velocity.y > 0:
		play_animation("Fall")
	else:
		play_animation("Jump")


func _on_detection_area_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		player_chase = true
		if soul_link_timer:
			soul_link_timer.stop()  # Stop timer when player is close
		play_animation("Walk")


func _on_detection_area_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		player = null
		player_chase = false
		if soul_link_timer:
			soul_link_timer.start(SOUL_LINK_TIMER_DURATION)  # Start timer with predefined duration


func _on_soul_link_timeout() -> void:
	get_tree().change_scene_to_file("res://UI/game_over_screen.tscn")  # Handle game over


# Function to handle animation transitions
func play_animation(animation_name: String) -> void:
	if not $AnimatedSprite2D.is_playing() or $AnimatedSprite2D.animation != animation_name:
		$AnimatedSprite2D.play(animation_name)
