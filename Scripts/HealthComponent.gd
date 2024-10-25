extends Node2D

class_name HealthComponent

signal health_changed(new_health)
signal died

@export var max_health: int = 100
var current_health: int


func _ready() -> void:  # Called when the node is ready
	current_health = max_health


func take_damage(amount: int) -> void:  # Reduces health by the given amount
	current_health = max(0, current_health - amount)
	emit_signal("health_changed", current_health)

	if current_health == 0:
		emit_signal("died")


func heal(amount: int) -> void:  # Increases health by the given amount
	current_health = min(max_health, current_health + amount)
	emit_signal("health_changed", current_health)
