extends CharacterBody2D
class_name Player

# Constants for player configuration
const MAX_HEALTH = 150  # Maximum health of the player
const REGEN_AMOUNT = 10  # Amount of health to regenerate over time
const INITIAL_HEALTH = 150  # Starting health for the player
const PLAYER_SPEED = 70.0  # Base speed of the player
const GRAVITY_FORCE = 980.0  # Gravity affecting the player
const JUMP_FORCE = -300  # Force applied when the player jumps
const MAX_JUMPS = 2  # Maximum number of jumps (double jump)
const DASH_SPEED = 900.0  # Speed during a dash
const DASH_DURATION = 0.2  # Duration of the dash
const DASH_COOLDOWN = 0.5  # Time before a new dash can be performed
const WALL_JUMP_PUSHBACK = 100  # Force pushing the player away from the wall during a wall jump
const ENEMY_DAMAGE = 20  # Damage taken from enemy attacks
const HEALTH_REGEN_TIME = 2.0  # Time in seconds for health regeneration
const HEART_LIFE_GAIN = 20  # Health gained from collecting hearts
const START_SAVED_POSITION = Vector2(-42, 2)  # Initial position for saving state

# Variables for player state and mechanics
var enemy_in_attack_range: bool = false  # Flag to check if an enemy is in attack range
var enemy_attack_cooldown: bool = true  # Flag to control enemy attack cooldown
var health: int = INITIAL_HEALTH  # Current health of the player
var player_alive: bool = true  # Flag to check if the player is alive
var attack_in_progress: bool = false  # Flag to indicate if an attack is ongoing
var speed: float = PLAYER_SPEED  # Player's movement speed
var gravity: float = GRAVITY_FORCE  # Gravity affecting the player
var jump: float = JUMP_FORCE  # Jump force for the player
var jump_count: int = 0  # Counter for jumps (for double jump)
var pressed: int = MAX_JUMPS  # Remaining jumps available
var dash_speed: float = DASH_SPEED  # Speed during dashing
var dash_duration: float = DASH_DURATION  # Duration of the dash
var dash_cooldown: float = DASH_COOLDOWN  # Cooldown time for dashing
var can_dash: bool = true  # Flag to control if the player can dash
var saved_position: Vector2 = START_SAVED_POSITION  # Position to save for respawn
var saved_score: int = 0  # Score to save for respawn

signal died  # Signal emitted when the player dies
signal healthChanged(new_health)  # Signal emitted when health changes

# Onready variables for node references
@onready var current_area: Node2D = get_node("/root/MainScene1")  # Reference to the main scene
@onready var global: Global = Global  # Correct reference to autoloaded Global
@onready var soul_link_timer: Timer = $SoulLinkTimer  # Timer for soul link actions
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D  # Animated sprite for player
@onready var health_regen_timer: Timer = $HealthRegen  # Timer for health regeneration
@onready var player_health_bar = get_node("/root/BaseLevel/CanvasLayer/PlayerHealthBar")  # Health bar for the player


# Called when the node is added to the scene
func _ready() -> void:
	# Set up health regeneration timer
	health_regen_timer.wait_time = HEALTH_REGEN_TIME  # Regenerate health every set time
	add_child(health_regen_timer)  # Add the timer to the scene
	health_regen_timer.start()  # Start the health regeneration timer
	# Initialize health bar values
	player_health_bar.max_value = MAX_HEALTH  # Set maximum health for the health bar
	player_health_bar.value = health  # Set current health for the health bar
	
	
# Called every frame to update player state
func _physics_process(delta: float) -> void:
	# Check if player's health is zero or less
	if health <= 0:
		player_alive = false  # Set player alive status to false
		get_tree().change_scene_to_file("res://UI/game_over_screen.tscn")  # Change to game over screen
		health = 0  # Ensure health is set to zero
		print("Player has been killed")  # Debug message
		self.queue_free()  # Remove player from the scene


	handle_movement(delta)  # Handle player movement logic
	wall_jump()  # Handle wall jump mechanics


	# Apply gravity to the player
	velocity.y += gravity * delta


	# Check for dash input
	if Input.is_action_just_pressed("dash") and can_dash:
		Dash(delta)  # Call the dash function


	enemy_attack()  # Check for enemy attacks
	attack()  # Check for player attacks


	# Move player based on calculated velocity
	move_and_slide()  # Move the player based on physics


# Called when the health regeneration timer times out
func _on_health_regen_timeout() -> void:
	# Regenerate health if the player is alive and health is below max
	if player_alive and health < MAX_HEALTH:
		health += REGEN_AMOUNT  # Amount of health to regenerate each cycle
		emit_signal("healthChanged", health)  # Emit the signal when health changes
		print("Health regenerated. Current health:", health)  # Debug message


# This function updates the health bar whenever the signal is emitted
func _on_health_changed(new_health: int) -> void:
	if player_health_bar != null:  # Ensure health bar exists
		player_health_bar.value = new_health  # Update health bar value
		print("Health bar updated:", new_health)  # Debug message


# Function for dashing
func Dash(delta: float) -> void:
	var direction: float = Input.get_axis("ui_left", "ui_right")  # Get horizontal movement direction
	if direction != 0:  # If there is input direction
		velocity.x = direction * dash_speed  # Set velocity for dashing
		can_dash = false  # Disable further dashing until cooldown
		await get_tree().create_timer(dash_duration).timeout  # Wait for the duration of the dash
		velocity.x = direction * speed  # Continue moving in the same direction after dash
		await get_tree().create_timer(dash_cooldown).timeout  # Wait for cooldown period
		can_dash = true  # Allow dashing again


# Function for handling wall jumps
func wall_jump() -> void:
	if is_on_wall():  # Check if the player is against a wall
		if Input.is_action_pressed("ui_jump"):  # Check if jump is pressed
			if Input.is_action_pressed("ui_right"):  # If moving right
				velocity.y = jump  # Apply jump force
				velocity.x = -WALL_JUMP_PUSHBACK  # Push back from the wall
			elif Input.is_action_pressed("ui_left"):  # If moving left
				velocity.y = jump  # Apply jump force
				velocity.x = WALL_JUMP_PUSHBACK  # Push back from the wall


# Function for handling player movement
func handle_movement(delta: float) -> void:
	var direction: float = Input.get_axis("ui_left", "ui_right")  # Get horizontal input direction


	if direction != 0:  # If there is horizontal input
		velocity.x = direction * speed  # Set horizontal velocity
		animated_sprite.scale.x = abs(animated_sprite.scale.x) * direction  # Flip sprite based on direction


		if is_on_floor():  # If the player is on the ground
			if not attack_in_progress:  # Only play walk animation if not attacking
				play_animation("Walk")  # Play walking animation
	else:
		if is_on_floor():  # If the player is on the ground and no input
			if not attack_in_progress:  # Only play idle animation if not attacking
				play_animation("Idle")  # Play idle animation
		velocity.x = 0  # Stop horizontal movement if no input


	if is_on_floor():  # Reset jump count if on the ground
		jump_count = 0


	if Input.is_action_just_pressed("ui_jump") and jump_count < MAX_JUMPS:  # Check for jump input
		velocity.y = jump  # Apply jump force
		jump_count += 1  # Increment jump count


	# Animation handling based on vertical velocity
	if not is_on_floor() and velocity.y > 10:  # Check if falling
		if not attack_in_progress:  # Only play idle animation if not attacking
			play_animation("Idle")
	elif not is_on_floor():  # If in the air but not falling
		if not attack_in_progress:  # Only play jump animation if not attacking
			play_animation("Jump")


# Function to handle player spawn
func _on_spawn(position: Vector2, direction: String) -> void:
	global_position = position  # Set player's position
	play_animation("Walk" + direction)  # Play walk animation in the given direction
	animated_sprite.stop()  # Stop the sprite animation if necessary


# Function to handle player death
func die() -> void:
	emit_signal("died")  # Emit the died signal
	get_tree().change_scene_to_file("res://UI/game_over_screen.tscn")  # Change to game over screen


# Function triggered when an enemy enters the player's hitbox
func _on_player_hitbox_body_entered(body: Node) -> void:
	if body.has_method("enemy"):  # Check if the body has an enemy method
		enemy_in_attack_range = true  # Set flag indicating enemy is in attack range


# Function triggered when an enemy exits the player's hitbox
func _on_player_hitbox_body_exited(body: Node) -> void:
	if body.has_method("enemy"):  # Check if the body has an enemy method
		enemy_in_attack_range = false  # Set flag indicating enemy is no longer in attack range


# Function for handling enemy attacks
func enemy_attack() -> void:
	if enemy_in_attack_range and enemy_attack_cooldown:  # Check if in attack range and cooldown allows
		health -= ENEMY_DAMAGE  # Reduce health by enemy damage
		emit_signal("healthChanged", health)  # Emit the signal when health changes
		enemy_attack_cooldown = false  # Disable further enemy attacks until cooldown
		$attack_cooldown.start()  # Start cooldown timer for enemy attacks
		print("Player health:", health)  # Debug message


# Function triggered when the enemy attack cooldown times out
func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true  # Enable enemy attacks again


# Function for handling player attacks
func attack() -> void:
	if Input.is_action_just_pressed("attack"):  # Check for attack input
		global.player_current_attack = true  # Set global attack state
		attack_in_progress = true  # Set attack flag
		play_animation("Attack")  # Play attack animation
		$deal_attack_timer.start()  # Start attack timer
		print("Attack started")  # Debug message


# Function triggered when the attack deal timer times out
func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()  # Stop the attack deal timer
	global.player_current_attack = false  # Reset global attack state
	attack_in_progress = false  # Reset attack flag
	
	
	# Play walk animation if moving while not attacking
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		if not attack_in_progress:  # Only play walk animation if not attacking
			play_animation("Walk")


# Function triggered when the soul link timer times out
func _on_soul_link_timeout() -> void:
	die()  # Call the die function


# Function to play animations based on the animation name
func play_animation(animation_name: String) -> void:
	if not animated_sprite.is_playing() or animated_sprite.animation != animation_name:  # Check if animation is not already playing
		animated_sprite.play(animation_name)  # Play the specified animation


# Function triggered when a coin is collected
func _on_coin_collected() -> void:
	global.add_coin()  # Increment coin count in global state


# Function to save player state
func save_state() -> void:
	saved_position = global_position  # Save the current position
	saved_score = global.score  # Save the current score


# Function to load player state
func load_state() -> void:
	global_position = saved_position  # Restore the saved position
	global.score = saved_score  # Restore the saved score
