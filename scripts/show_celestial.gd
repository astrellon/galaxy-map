extends Area2D

class_name ShowCelestial

signal hiding
signal closing

@export_file var mesh_file
@export var backface_culling: bool = false
@export var wireframe_front_colour: Color = Color.GREEN
@export var wireframe_back_colour: Color = Color.DARK_GREEN
@export var wireframe_mesh_scale: float = 1.0
@export var target_camera_fov: float = 100
@export var reveal_type: Wireframe.RevealType = Wireframe.RevealType.ALPHA
@export var outline_colour: Color = Color.RED
@export var outline_inside: bool
@export var outline_pattern: int
@export var outline_threshold = 0.0

@export var label: String = "Celestial"
@export_multiline var description: String = ""
@export var label_colour = Color.TRANSPARENT
@export var planet_texture: Texture2D
@export var raymarch_planet_noise: Vector4 = Vector4.ONE
@export var raymarch_planet_offset: Vector4
@export var raymarch_ring_params: Vector4 = Vector4(1.1, 0.75, 0.015, 0)
@export var raymarch_cloud_params: Vector4 = Vector4(0.2, 0.1, 0.3, 0)
@export var raymarch_wave_params: Vector4 = Vector4(0.4, 0.2, 0.1, 0)
@export var raymarch_scene: int
@export var fov_test = 1.0

@export var center_point: Node2D
@export var collision: CollisionShape2D

var hovered = false
var hit_radius = 10.0

func _ready() -> void:
	if self.collision.shape is CircleShape2D:
		self.hit_radius = self.collision.shape.radius

func get_center_point() -> Vector2:
	if self.center_point != null:
		return self.center_point.global_position
	return self.global_position

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT > 0:
			CelestialParent.instance.trigger(self)

func _process(delta: float) -> void:
	var self_pos = self.global_position
	var mouse_pos = self.get_global_mouse_position()

	var dist = (self_pos - mouse_pos).length()
	if dist < self.hit_radius:
		if !self.hovered:
			CursorController.instance.hover()
			self.hovered = true
	else:
		if self.hovered:
			CursorController.instance.unhover()
			self.hovered = false

func trigger_hide():
	self.hiding.emit()

func trigger_closing():
	self.closing.emit()
