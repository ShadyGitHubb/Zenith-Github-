extends Camera2D

@onready var global = get_node("/root/Global")
var move = Vector2(217, 65)
var move2 = Vector2(682, 80) 

func _ready():
	pass
	
func _process(delta):
		if global.camera_change and move.x < move2.x:
			position.x += 1
