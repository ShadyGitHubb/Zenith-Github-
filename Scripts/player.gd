extends CharacterBody2D

var speed = 150.0
var gravity = 9.8
var jump = -220
var jump_count = 1
var max_jumps = 2
var pressed = 2

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
		
	
