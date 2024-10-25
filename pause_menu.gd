extends Control

@onready var global = get_node("/root/Global")


func resume():  # Resumes the game
	self.hide()
	get_tree().paused = false


func _ready():  # Called when the node is ready
	self.hide()


func pause():  # Pauses the game
	self.show()
	get_tree().paused = true


func test_escape():  # Checks for the escape key
	if Input.is_action_just_pressed("Escape") and not get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("Escape") and get_tree().paused:
		resume()


func _on_resume_pressed():  # Called when resume button is pressed
	resume()


func _on_restart_pressed():  # Called when restart button is pressed
	resume()
	global.reset_state()
	global.reset_score()
	get_tree().reload_current_scene()


func _on_quit_pressed():  # Called when quit button is pressed
	get_tree().quit()


func _process(_delta):  # Called every frame
	test_escape()
