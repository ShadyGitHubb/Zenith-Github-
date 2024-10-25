extends CharacterBody2D

var speed: float = 40.0
var player_chase: bool = false
var player: Node2D = null
var gravity: float = 9.8
var health: int = 400  # Increase health for the boss
var player_in_attack_zone: bool = false
var can_take_damage: bool = true
var dash_speed: float = 200.0  # Speed for the dash
var dash_distance: float = 200.0  # Minimum distance to trigger dash
var minion_scene: PackedScene = preload("res://Minion.tscn")  # Preload the minion scene

const HEALTH_ATTACK = 20

@onready var global = get_node("/root/Global")


func _physics_process(delta: float) -> void:  # Called every physics frame
	deal_with_damage()

	if player:
		var distance_to_player: float = (player.position - position).length()

		if distance_to_player > dash_distance:
			dash_towards_player(delta)
		else:
			follow_player()

		spawn_minions()
	else:
		$AnimatedSprite2D.play("Idle")


func dash_towards_player(delta: float) -> void:  # Dashes towards the player
	if player:
		var direction: Vector2 = (player.position - position).normalized()
		position += direction * dash_speed * delta
		$AnimatedSprite2D.play("Dash")

		if player.position.x - position.x < 0:
			$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.flip_h = true


func follow_player() -> void:  # Follows the player
	if player_chase:
		position += (player.position - position) / speed
		$AnimatedSprite2D.play("Hovering")

		if player.position.x - position.x < 0:
			$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.flip_h = true


func spawn_minions() -> void:  # Spawns minions
	if player and not $SpawnTimer.is_stopped():
		$SpawnTimer.start()
	else:
		$SpawnTimer.stop()


func _on_SpawnTimer_timeout() -> void:  # Called when the spawn timer times out
	var minion: Node2D = minion_scene.instance()
	get_parent().add_child(minion)
	minion.position = position + Vector2(randf() * 50, randf() * 50)  # Spawn near the boss


func _on_detection_area_body_entered(body: Node) -> void:  # Called when a body enters the detection area
	if body.is_in_group("Player"):
		player = body
		player_chase = true


func _on_detection_area_body_exited(body: Node) -> void:  # Called when a body exits the detection area
	if body.is_in_group("Player"):
		player = null
		player_chase = false


func _on_enemy_hitbox_body_entered(body: Node) -> void:  # Called when a body enters the hitbox
	if body.is_in_group("Player"):
		player_in_attack_zone = true


func _on_enemy_hitbox_body_exited(body: Node) -> void:  # Called when a body exits the hitbox
	if body.is_in_group("Player"):
		player_in_attack_zone = false


func deal_with_damage() -> void:  # Deals with damage logic
	if player_in_attack_zone and global.player_current_attack:
		if can_take_damage:
			health -= HEALTH_ATTACK
			$take_damage_cooldown.start()
			can_take_damage = false
			print("Boss health =", health)

		if health <= 0:
			self.queue_free()
			defeat_boss()

func defeat_boss():
	# Logic for boss defeat
	show_win_screen()


func show_win_screen():
	var win_screen = load("res://win_screen.tscn").instantiate()
	get_tree().current_scene.add_child(win_screen)
	win_screen.rect_position = Vector2.ZERO # Centre the Win Screen

func _on_take_damage_cooldown_timeout() -> void:  # Called when the take damage cooldown times out
	can_take_damage = true
