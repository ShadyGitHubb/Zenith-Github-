extends ColorRect
class_name lighting

func _ready():
	show()

func _process(_delta):
	var light_positions = _get_light_positions()
	material.set_shader_parameter("number_of_lights", light_positions.size())
	material.set_shader_parameter("lights", light_positions)
	
func _get_light_positions():
	return get_tree().get_nodes_in_group("light").map(
		func(light: Node2D):
			return light.get_global_transform_with_canvas().origin
	)
	
