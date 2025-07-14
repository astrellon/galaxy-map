extends Node3D

func _process(delta: float) -> void:
	self.rotate_y(delta)
	self.rotate_x(delta * 0.5)
