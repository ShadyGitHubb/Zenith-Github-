extends CharacterBody2D

class_name Player

var speed = 150.0
var gravity = 9.8
var jump = -220
var jump_count = 1
var max_jumps = 2
var pressed = 2

@onready var current_area = get_node("/root/MainScene/Level 1")
@onready var global = get_node("/root/Global")

func _physics_process(delta):
	Move(delta)
	
	if not is_on_floor():
		velocity.y += gravity
		
	move_and_slide()
	
func Move(delta):
	var direction = Input.get_axis("ui_right", "ui_left")
	if direction:
		velocity.x = lerp(velocity.x, speed * -direction, 0.1)
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			$anim.play("Walk")
		$Spritesheet.scale.x = -direction

	elif not is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, 0.01)
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.1)

	if direction > 0:
		$anim

	if not Input.is_anything_pressed():
		$anim.play("Idle")
	
	if Input.is_action_just_pressed("ui_jump"):
		pressed -= 1
		print(pressed)
		
	if Input.is_action_just_pressed("ui_jump") and max_jumps > jump_count:
		velocity.y = jump
		$anim.play("Jump")
		jump_count = jump_count + 1

	if is_on_floor():
		jump_count = 1

	if !is_on_floor():
		$anim.play("Jump")
		
	if !is_on_floor() && velocity.y > 10:
		$anim.play("Fall")
		
func _ready():
	NavigationManager.on_trigger_player_spawn.connect(_on_spawn)
	
func _on_spawn(position: Vector2, direction: String):
	global_position = position
	$anim.play("Walk" + direction)
	$anim.stop()

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
	
