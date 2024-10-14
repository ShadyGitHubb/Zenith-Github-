extends Area2D

signal heart_collected

var player = null  # Reference to the player
var speed = 100  # Adjust the speed as needed
var offset = Vector2(-20, 0)  # Offset from player's center
var follow_delay = 0.5  # Delay before following
var can_follow = false

@onready var animated_sprite = $AnimatedSprite2D  # Reference to the AnimatedSprite2D node
@onready var follow_timer = Timer.new()  # Timer for delay

func _ready():
	add_child(follow_timer)
	follow_timer.wait_time = follow_delay
	follow_timer.one_shot = true
	connect("body_entered", Callable(self, "_on_Heart_body_entered"))
	follow_timer.start()
	if animated_sprite:
		animated_sprite.play("Idle")  # Adjust the animation name if needed

func _process(delta):
	if can_follow and player and follow_timer.time_left == 0:  # Follow only after delay
		var target_position = player.position + offset  # Apply offset
		var direction = (target_position - position).normalized()
		position += direction * speed * delta

func _on_Heart_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("heart_collected")
		queue_free()

func _on_area_2d_area_entered(area):
	if area.is_in_group("Player"):
		can_follow = true
		print(can_follow)
