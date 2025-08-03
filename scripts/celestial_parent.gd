extends Node2D

class_name CelestialParent

var scene = preload("res://scenes/celestial_object.tscn")

@export var child_offset: Node2D
@export var draw_line_to: Node2D

var current_scene_target: Node2D
var current_scene_info: ShowCelestial

var current_scene: Wireframe
var waiting_to_remove = false
var waiting_to_trigger: ShowCelestial

# Easing Ease In Out Quad function
static func ease_in_out_quad(start: float, end: float, value: float) -> float:
	value /= 0.5
	end -= start
	
	if value < 1:
		return end * 0.5 * value * value + start
		
	value -= 1
	return -end * 0.5 * (value * (value - 2) - 1) + start

func _process(delta: float) -> void:
	if self.current_scene_target != null:
		queue_redraw()
		
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

func _draw() -> void:
	if self.current_scene_target != null:
		var from = self.current_scene_target.global_position
		var to = self.draw_line_to.global_position
		
		var lerp = clamp(self.current_scene.label.visible_ratio * 2.0 - 0.5, 0.0, 1.0)
		lerp = ease_in_out_quad(0.0, 1.0, lerp)
		if self.waiting_to_remove:
			from = to.lerp(from, lerp)
		else:
			to = to.lerp(from, 1.0 - lerp)
		
		draw_line(from, to, self.current_scene_info.wireframe_front_colour)

func _setup_new_scene(info: ShowCelestial) -> void:
	self.current_scene_target = info
	self.current_scene_info = info
	self.current_scene = scene.instantiate()
	self.child_offset.add_child(self.current_scene)
	
	self.current_scene.init(info)

func _remove_current_scene() -> void:
	self.child_offset.remove_child(self.current_scene)
