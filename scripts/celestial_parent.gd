extends Node2D

class_name CelestialParent

var scene = preload("res://scenes/celestial_object.tscn")

var current_scene: Wireframe
var waiting_to_remove = false
var waiting_to_trigger: ShowCelestial

func _process(delta: float) -> void:
	if self.waiting_to_remove and self.current_scene != null and self.current_scene.wireframe_hidden:
		self._remove_current_scene()
		self._setup_new_scene(self.waiting_to_trigger)
		self.waiting_to_remove = false
		self.waiting_to_trigger = null

func trigger(info: ShowCelestial) -> void:
	if self.current_scene != null:
		print('Current scene exists, hiding')
		self.waiting_to_remove = true
		self.waiting_to_trigger = info
		self.current_scene.hide_wireframe()
		return
	
	self._setup_new_scene(info)

func _setup_new_scene(info: ShowCelestial) -> void:
	self.current_scene = scene.instantiate()
	add_child(self.current_scene)
	
	self.current_scene.init(info)

func _remove_current_scene() -> void:
	remove_child(self.current_scene)
