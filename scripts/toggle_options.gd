extends Area2D

@export var options: Control
@export var texture: Sprite2D

@export var hover_colour: Color
@export var idle_colour: Color

func toggle() -> void:
	print("Toggled")
	self.options.visible = !self.options.visible

func _mouse_shape_enter(shape_idx: int) -> void:
	self.texture.material.set_shader_parameter('colour', self.hover_colour)

func _mouse_shape_exit(shape_idx: int) -> void:
	self.texture.material.set_shader_parameter('colour', self.idle_colour)

func _input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT >= 0 and event.pressed:
			self.toggle()
