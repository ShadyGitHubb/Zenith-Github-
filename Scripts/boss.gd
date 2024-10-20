extends CharacterBody2D

var speed = 40
var player_chase = false
var player = null
var gravity = 9.8
var health = 400  # Increase health for the boss
var player_inattack_zone = false
var can_take_damage = true
var dash_speed = 200  # Speed for the dash
var dash_distance = 200  # Minimum distance to trigger dash
var minion_scene = preload("res://Minion.tscn")  # Preload the minion scene

@onready var global = get_node("/root/Global")

func _physics_process(delta):
	deal_with_damage()
	if player:
		var distance_to_player = (player.position - position).length()
		if distance_to_player > dash_distance:
			dash_towards_player(delta)
		else:
			follow_player()
		spawn_minions()
	else:
		$AnimatedSprite2D.play("Idle")

func dash_towards_player(delta):
	if player:
		var direction = (player.position - position).normalized()
		position += direction * dash_speed * delta
		$AnimatedSprite2D.play("Dash")
		if player.position.x - position.x < 0:
			$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.flip_h = true

func follow_player():
	if player_chase:
		position += (player.position - position) / speed
		$AnimatedSprite2D.play("Hovering")
		if player.position.x - position.x < 0:
			$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.flip_h = true

func spawn_minions():
	if player and not $SpawnTimer.is_stopped():
		$SpawnTimer.start()
	else:
		$SpawnTimer.stop()

func _on_SpawnTimer_timeout():
	var minion = minion_scene.instance()
	get_parent().add_child(minion)
	minion.position = position + Vector2(randf() * 50, randf() * 50)  # Spawn near the boss

func _on_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		player_chase = false

func _on_enemy_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		player_inattack_zone = true

func _on_enemy_hitbox_body_exited(body):
	if body.is_in_group("Player"):
		player_inattack_zone = false

func deal_with_damage():
	if player_inattack_zone and global.player_current_attack == true:
		if can_take_damage == true:
			health -= 20
			$take_damage_cooldown.start()
			can_take_damage = false
			print("Boss health =", health)
		if health <= 0:
			self.queue_free()

func _on_take_damage_cooldown_timeout():
	can_take_damage = true
