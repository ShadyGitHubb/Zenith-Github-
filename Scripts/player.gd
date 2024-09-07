extends CharacterBody2D

class_name Player
 
var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 160
var player_alive = true
var attack_ip = false

var speed = 70.0
var gravity = 9.8
var jump = -200
var jump_count = 1
var max_jumps = 2
var pressed = 2

signal died

@onready var current_area = get_node("/root/MainScene1")
@onready var global = get_node("/root/Global")

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
		velocity.y += gravity
		
	move_and_slide()
	
func Move(delta):
	var direction = Input.get_axis("ui_right", "ui_left")
	if direction:
		velocity.x = lerp(velocity.x, speed * -direction, 0.1)
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			$AnimatedSprite2D.play("Walk")
		$AnimatedSprite2D.scale.x = -direction

	elif not is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, 0.01)
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.1)

	if direction > 0:
		$AnimatedSprite2D

	if not Input.is_anything_pressed():
		if attack_ip == false:
			$AnimatedSprite2D.play("Idle")
	
	if Input.is_action_just_pressed("ui_jump"):
		pressed -= 1
		print(pressed)
		
	if Input.is_action_just_pressed("ui_jump") and max_jumps > jump_count:
		velocity.y = jump
		$AnimatedSprite2D.play("Jump")
		jump_count = jump_count + 1

	if is_on_floor():
		jump_count = 1

	if !is_on_floor():
		$AnimatedSprite2D.play("Jump")
		
	if !is_on_floor() && velocity.y > 10:
		$AnimatedSprite2D.play("Fall")
	
		

func _on_spawn(position: Vector2, direction: String):
	global_position = position
	$AnimatedSprite2D.play("Walk" + direction)
	$AnimatedSprite2D.stop()

func _on_RoomDetector_area_entered(area: Area2D) -> void:
	print("1", global.current_area)
	print("2", area)
	# Gets collision shape and size of room
	#var collision_shape: CollisionShape2D = area.get_node("CollisionShape2D")
	#var size: Vector2 = collision_shape.shape.extents * 2
	if area != global.current_area and area.is_in_group("rooms"):
		global.current_area = area
		print("3", global.current_area)
		print(area)
		global.camera_target = area
		await get_tree().create_timer(0.1).timeout
		global.camera_change = true
 	
	# Changes camera's current room and size. check camera script for more info

func _on_room_detector_area_entered(area):
	if area.has_meta("Death"):
		get_tree().reload_current_scene()

func die() -> void:
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
		health = health - 20
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print(health)

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true

func attack():
	var direction = Input.get_axis("ui_right", "ui_left")

	if Input.is_action_just_pressed("attack"):
		global.player_current_attack = true
		attack_ip = true
		
	if Input.is_action_pressed("ui_left"):
		$AnimatedSprite2D.scale.x = -direction
		$AnimatedSprite2D.play("attack")
		$deal_attack_timer.start()
	elif Input.is_action_pressed("ui_right"):
		$AnimatedSprite2D.scale.x = -direction
		$AnimatedSprite2D.play("attack")
		$deal_attack_timer.start()

func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_ip = false
	
