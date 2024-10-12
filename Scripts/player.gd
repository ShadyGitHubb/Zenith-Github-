extends CharacterBody2D

class_name Player

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 160
var player_alive = true
var attack_ip = false
var speed = 70.0
var gravity = 980.0  # Increase gravity for more realistic feel
var jump = -300  # Adjust jump force if needed
var jump_count = 1
var max_jumps = 2
var pressed = 2

signal died

@onready var current_area = get_node("/root/MainScene1")
@onready var global = get_node("/root/Global")
@onready var soul_link_timer = $SoulLinkTimer  # Ensure Timer node is correctly referenced
@onready var animated_sprite = $AnimatedSprite2D  # Reference the AnimatedSprite2D node

func _ready():
	soul_link_timer = $SoulLinkTimer
	if soul_link_timer:
		soul_link_timer.connect("timeout", Callable(self, "_on_soul_link_timeout"))
		print("SoulLinkTimer connected successfully.")
	else:
		print("SoulLinkTimer node not found. Check node name and placement.")
	print("Player script ready.")

func _physics_process(delta):
	Move(delta)
	enemy_attack()
	attack()
	
	if health <= 0:
		player_alive = false
		get_tree().change_scene_to_file("res://UI/game_over_screen.tscn")
		health = 0
		print("player has been killed")
		self.queue_free()
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	move_and_slide()

func Move(delta):
	var direction = Input.get_axis("ui_left", "ui_right")  # Fixing inverted controls
	if direction:
		velocity.x = lerp(velocity.x, speed * direction, 0.1)
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			if not attack_ip:  # Prevent walk animation from playing during attack
				play_animation("Walk")
		animated_sprite.scale.x = direction  # Fix the control inversion by setting scale to direction

	elif not is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, 0.01)
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.1)

	if direction == 0 and not attack_ip:  # Prevent idle animation during attack
		play_animation("Idle")

	if not Input.is_anything_pressed() and not attack_ip:
		play_animation("Idle")
	
	if Input.is_action_just_pressed("ui_jump"):
		pressed -= 1
		if pressed >= 0 and jump_count < max_jumps:
			velocity.y = jump
			play_animation("Jump")
			jump_count += 1

	if is_on_floor():
		jump_count = 1
		pressed = max_jumps

	if not is_on_floor() and velocity.y > 10:
		play_animation("Fall")
	elif not is_on_floor():
		play_animation("Jump")

func _on_spawn(position: Vector2, direction: String):
	global_position = position
	play_animation("Walk" + direction)
	animated_sprite.stop()

func _on_RoomDetector_area_entered(area: Area2D) -> void:
	if area != global.current_area and area.is_in_group("rooms"):
		global.current_area = area
		global.camera_target = area
		await get_tree().create_timer(0.1).timeout
		global.camera_change = true

func _on_room_detector_area_entered(area):
	if area.has_meta("Death"):
		get_tree().reload_current_scene()

func die() -> void:
	emit_signal("died")
	get_tree().change_scene_to_file("res://UI/game_over_screen.tscn")

func player():
	pass

func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_inattack_range = true

func _on_player_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_inattack_range = false

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true:
		health -= 20
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print(health)

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true

func attack():
	var direction = Input.get_axis("ui_left", "ui_right")

	if Input.is_action_just_pressed("attack"):
		global.player_current_attack = true
		attack_ip = true
		play_animation("Attack")  # Trigger attack animation only when attacking
		$deal_attack_timer.start()
	
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		if not attack_ip:  # Prevent walk animation from playing during attack
			play_animation("Walk")
		animated_sprite.scale.x = direction  # Fix the control inversion by setting scale to direction

func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_ip = false

# Handle player soul link timeout
func _on_soul_link_timeout():
	die()

# Function to handle animation transitions
func play_animation(animation_name):
	if not animated_sprite.is_playing() or animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)
		print("Playing animation: ", animation_name)
