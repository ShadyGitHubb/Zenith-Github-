extends CharacterBody2D

var speed = 40
var player_chase = false
var player = null
var gravity = 9.8
var health = 100
var player_inattack_zone = false
var can_take_damage = true

@onready var global = get_node("/root/Global")

func _physics_process(delta):
	deal_with_damage()
	
	if player_chase:
			position += (player.position - position)/speed
			
			$AnimatedSprite2D.play("Hovering")

			if(player.position.x - position.x) < 0:
				$AnimatedSprite2D.flip_h = false
			else:
				$AnimatedSprite2D.flip_h = true
	else:
			$AnimatedSprite2D.play("Idle")


func _on_detection_area_body_entered(body):
	player = body
	player_chase = true

func _on_detection_area_body_exited(body):
	player = null
	player_chase = false
	
func enemy():
	pass


func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		player_inattack_zone = true


func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		player_inattack_zone = false


func deal_with_damage():
	if player_inattack_zone and global.player_current_attack == true:
		if can_take_damage == true:
			health = health - 20
			$take_damage_cooldown.start()
			can_take_damage = false
		print("Phantom health =", health)
		if health <= 0:
			self.queue_free()


func _on_take_damage_cooldown_timeout():
	can_take_damage = true
