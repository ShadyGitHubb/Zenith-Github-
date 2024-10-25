extends CharacterBody2D

# Constants for enemy behavior and attributes
const ENEMY_SPEED = 40.0  # Base speed of the enemy
const GRAVITY_FORCE = 9.8  # Gravity affecting the enemy
const MAX_HEALTH = 100  # Maximum health of the enemy
const DAMAGE_AMOUNT = 20  # Amount of damage taken from an attack
const CHASE_SPEED_DIVIDER = 40  # Factor to slow down the chase speed

# Variables to hold the enemy's state and attributes
var speed = ENEMY_SPEED
var player_chase = false  # Flag to indicate if the enemy is chasing the player
var player = null  # Reference to the player
var gravity = GRAVITY_FORCE
var health = MAX_HEALTH  # Current health of the enemy
var player_inattack_zone = false  # Flag to check if the player is in attack zone
var can_take_damage = true  # Flag to control damage taking

@onready var global = get_node("/root/Global")  # Reference to the global singleton


# Function to handle physics updates
func _physics_process(_delta: float) -> void:
	deal_with_damage()  # Check for damage
	if player_chase:
		# Move towards the player
		position += (player.position - position) / CHASE_SPEED_DIVIDER
		$AnimatedSprite2D.play("Hovering")  # Play hovering animation
		# Flip the sprite based on the player's position
		if (player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = false  # Facing right
		else:
			$AnimatedSprite2D.flip_h = true  # Facing left
	else:
		$AnimatedSprite2D.play("Idle")  # Play idle animation

# Function called when a body enters the detection area
func _on_detection_area_body_entered(body: Node) -> void:
	if body is Player:
		player = body  # Store reference to the player
		player_chase = true  # Start chasing the player

# Function called when a body exits the detection area
func _on_detection_area_body_exited(body: Node) -> void:
	player = null  # Clear player reference
	player_chase = false  # Stop chasing

# Function called when the enemy hitbox detects a player entering
func _on_enemy_hitbox_body_entered(body: Node) -> void:
	if body is Player:
		player_inattack_zone = true  # Set attack zone flag

# Function called when the enemy hitbox detects a player exiting
func _on_enemy_hitbox_body_exited(body: Node) -> void:
	if body is Player:
		player_inattack_zone = false  # Clear attack zone flag


func deal_with_damage() -> void:
	if player_inattack_zone and global.player_current_attack:
		if can_take_damage:
			print("Applying damage...")  # Add this print to confirm the damage block is entered
			health -= DAMAGE_AMOUNT  # Apply damage
			print("Damage applied! Enemy health:", health)  # Debug the new health value
			$take_damage_cooldown.start()  # Start cooldown timer
			can_take_damage = false  # Prevent further damage until cooldown
			if health <= 0:
				print("Enemy killed")  # Confirm enemy death
				queue_free()  # Remove enemy from the scene

# Function called when the damage cooldown timer times out
func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true  # Allow the enemy to take damage again
