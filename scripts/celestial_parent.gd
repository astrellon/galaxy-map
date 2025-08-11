extends Node2D

class_name CelestialParent

static var instance: CelestialParent

var scene = preload("res://scenes/celestial_object.tscn")

@export var child_offset: Node2D
@export var draw_line_to: Node2D

var current_scene_target: Node2D
var current_scene_info: ShowCelestial

var current_scene: Wireframe
var waiting_to_remove = false
var waiting_to_trigger: ShowCelestial

func _init() -> void:
	instance = self

func _process(delta: float) -> void:
	if self.waiting_to_remove and self.current_scene != null and self.current_scene.wireframe_hidden:
		self._remove_current_scene()
		if self.waiting_to_trigger != null:
			self._setup_new_scene(self.waiting_to_trigger)
		self.waiting_to_remove = false
		self.waiting_to_trigger = null
	
	if OS.is_debug_build():
		if self.current_scene_info != null:
			self.current_scene.update_info(self.current_scene_info)

func trigger(info: ShowCelestial) -> void:
	if self.current_scene_info == info:
		self.close_current_scene()
		return
		
	CursorController.instance.show_highlight(info)
	
	if self.close_current_scene():
		self.waiting_to_trigger = info
		return
	
	self._setup_new_scene(info)

func close_current_scene() -> bool:
	if self.current_scene != null:
		print('Current scene exists, hiding')
		self.waiting_to_remove = true
		self.current_scene.hide_wireframe()
		self.current_scene_info.trigger_closing()
		return true
	return false

func _draw() -> void:
	if self.current_scene_target != null:
		var from = self.current_scene_target.global_position
		var to = self.draw_line_to.global_position
		
		var lerp = clamp(self.current_scene.label.visible_ratio * 2.0 - 0.5, 0.0, 1.0)
		lerp = Easing.Quint.EaseInOut(lerp, 0.0, 1.0, 1.0)
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
	self.current_scene_info.trigger_hide()
	self.current_scene.queue_free()
	#self.child_offset.remove_child(self.current_scene)
