extends Node3D

@export var speed = Vector2(1.0 / PI, 1.0)

func _process(delta: float) -> void:
	self.rotate_y(delta * self.speed.y)
	self.rotate_x(delta * self.speed.x)
