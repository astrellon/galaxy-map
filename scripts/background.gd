extends Node2D

func _process(delta: float) -> void:
	self.rotate(delta * PI / 180.0);
