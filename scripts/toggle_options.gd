extends Area2D

@export var options: Control

func toggle() -> void:
	print("Toggled")
	self.options.visible = !self.options.visible

func _input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT >= 0 and event.pressed:
			self.toggle()
