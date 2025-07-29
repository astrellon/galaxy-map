extends Node2D

class_name CelestialParent

var scene = preload("res://scenes/celestial_object.tscn")

var current_scene: Wireframe

func trigger(info: ShowCelestial) -> void:
	if self.current_scene == null:
		remove_current_scene()
	
	self.current_scene = scene.instantiate()
	add_child(self.current_scene)
	
	self.current_scene.init(info)
	#self.current_scene.jk

func remove_current_scene() -> void:
	remove_child(self.current_scene)
