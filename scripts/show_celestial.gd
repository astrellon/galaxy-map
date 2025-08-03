extends Node2D

class_name ShowCelestial

@export_file var mesh_file
@export var backface_culling: bool = false
@export var wireframe_front_colour: Color = Color.GREEN
@export var wireframe_back_colour: Color = Color.DARK_GREEN
@export var wireframe_mesh_scale: float = 1.0
@export var target_camera_fov: float = 100
@export var reveal_type: Wireframe.RevealType = Wireframe.RevealType.ALPHA
@export var ignore_line: Vector4
@export var outline_colour: Color = Color.RED
@export var outline_inside: bool
@export var outline_pattern: int
@export var outline_threshold = 0.0

@export var label: String = "Celestial"
@export var label_colour = Color.TRANSPARENT
@export var planet_texture: Texture2D
@export var raymarch_planet_noise: Vector4 = Vector4.ONE
@export var raymarch_planet_offset: Vector4
@export var raymarch_ring_params: Vector4 = Vector4(1.1, 0.75, 0.015, 0)
@export var raymarch_scene: int

@export var target: CelestialParent

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT > 0:
			print("Clicked")
			self.target.trigger(self)
