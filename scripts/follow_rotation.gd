extends Node2D

@export var follow: Node2D

func _ready() -> void:
	self.rotation = self.follow.rotation
	
func _process(delta: float) -> void:
	self.rotation = self.follow.rotation
