extends Node

var score: int = 0
var player_current_attack: bool = false
var has_key: bool = false

signal key_status_changed  # Signal to notify key status change


func reset_state() -> void:  # Resets the game state
	score = 0
	has_key = false
	player_current_attack = false  # Ensure attack state is reset as well
	emit_signal("key_status_changed", has_key)  # Emit signal when resetting state


func set_has_key(value: bool) -> void:  # Sets key status
	has_key = value
	emit_signal("key_status_changed", has_key)  # Emit signal when key status changes


func reset_score() -> void:  # Resets the score
	score = 0


func add_coin() -> void:  # Increments the score by one
	score += 1
	update_score_label()


func update_score_label() -> void:  # Updates the score label display
	const SCORE_LABEL_PATH = "BaseLevel/CanvasLayer/ScoreLabel"
	const ANIMATION_PLAYER_PATH = "BaseLevel/CanvasLayer/AnimationPlayer"

	var label = get_tree().root.get_node(SCORE_LABEL_PATH)
	var animation_player = get_tree().root.get_node(ANIMATION_PLAYER_PATH)

	if label and animation_player:
		label.text = "Score: " + str(score)
		animation_player.play("FadeInOut", false)  # Ensure it plays only once
		print("Coin collected! Score: ", score)
	else:
		print("ScoreLabel or AnimationPlayer not found.")
