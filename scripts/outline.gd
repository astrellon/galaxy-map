extends Sprite2D

class_name Outline

func init(info: ShowCelestial) -> void:
	self.material.set_shader_parameter('color', info.outline_colour)
	self.material.set_shader_parameter('pattern', info.outline_pattern)
	self.material.set_shader_parameter('inside', info.outline_inside)
	self.material.set_shader_parameter('threshold', info.outline_threshold)
