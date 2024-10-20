extends CharacterBody2D
class_name Player

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 14000
var player_alive = true
var attack_ip = false
var speed = 70.0
var gravity = 980.0
var jump = -300
var jump_count = 0  # Start with zero jumps
var max_jumps = 2
var pressed = 2
var dash_speed = 900.0
var dash_duration = 0.2
var dash_cooldown = 0.5
var can_dash = true
var heart_following = null
var saved_position = Vector2(-42,2)
var saved_score = 0
var heart_scene = preload("res://Scenes/heart.tscn") as PackedScene
const wall_jump_pushback = 100
signal died

@onready var current_area = get_node("/root/MainScene1")
@onready var global = Global  # Correct reference to autoloaded Global
@onready var soul_link_timer = $SoulLinkTimer
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	soul_link_timer = $SoulLinkTimer
	if soul_link_timer:
		soul_link_timer.connect("timeout", Callable(self, "_on_soul_link_timeout"))
		print("SoulLinkTimer connected successfully.")

func _physics_process(delta):
	if health <= 0:
		player_alive = false
		get_tree().change_scene_to_file("res://UI/game_over_screen.tscn")
		health = 0
		print("player has been killed")
		self.queue_free()
		if heart_following:
			heart_following.queue_free()
			heart_following = null

	handle_movement(delta)
	wall_jump()
	# Apply gravity
	velocity.y += gravity * delta
	if Input.is_action_just_pressed("dash") and can_dash:
		Dash(delta)
	enemy_attack()
	attack()
	# Move player
	move_and_slide()

func Dash(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * dash_speed
		can_dash = false
		await get_tree().create_timer(dash_duration).timeout
		velocity.x = direction * speed  # Continue moving in the same direction
		await get_tree().create_timer(dash_cooldown).timeout
		can_dash = true

func wall_jump():
	if is_on_wall():
		if Input.is_action_pressed("ui_jump"):
			if Input.is_action_pressed("ui_right"):
				velocity.y = jump
				velocity.x = -wall_jump_pushback
			elif Input.is_action_pressed("ui_left"):
				velocity.y = jump
				velocity.x = wall_jump_pushback

func handle_movement(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * speed
		animated_sprite.scale.x = abs(animated_sprite.scale.x) * direction
		if is_on_floor():
			if not attack_ip:
				play_animation("Walk")
		else:
			if not attack_ip:
				play_animation("Jump")
	else:
		if is_on_floor():
			if not attack_ip:
				play_animation("Idle")
		velocity.x = 0
	if is_on_floor():
		jump_count = 0
	if Input.is_action_just_pressed("ui_jump") and jump_count < max_jumps:
		velocity.y = jump
		jump_count += 1
	if not is_on_floor() and velocity.y > 10:
		if not attack_ip:
			play_animation("Idle")
	elif not is_on_floor():
		if not attack_ip:
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
	if Input.is_action_just_pressed("attack"):
		global.player_current_attack = true
		attack_ip = true
		play_animation("Attack")
		$deal_attack_timer.start()
		print("Attack started")
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		if not attack_ip:
			play_animation("Walk")

func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_ip = false

func _on_soul_link_timeout():
	die()

func play_animation(animation_name):
	if not animated_sprite.is_playing() or animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)

func _on_coin_collected():
	Global.add_coin()

func _on_heart_collected():
	if heart_following == null:
		heart_following = heart_scene.instantiate()
		add_child(heart_following)
		heart_following.connect("heart_collected", Callable(self, "_on_Heart_collected"))
	health += 20
	print("Life increased! Total health: ", health)

func save_state():
	saved_position = global_position
	saved_score = Global.score

func load_state():
	global_position = saved_position
	Global.score = saved_score
