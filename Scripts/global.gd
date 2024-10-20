extends Node

var score = 0
var player_current_attack = false

func reset_score():
	score = 0

func add_coin():
	score += 1
	update_score_label()

func update_score_label():
	var label = get_tree().root.get_node("BaseLevel/CanvasLayer/ScoreLabel")
	var animation_player = get_tree().root.get_node("BaseLevel/CanvasLayer/AnimationPlayer")
	if label and animation_player:
		label.text = "Score: " + str(score)
		animation_player.play("FadeInOut", false)  # Ensure it plays only once
		print("Coin collected! Score: ", score)
	else:
		print("ScoreLabel or AnimationPlayer not found.")
