extends Area2D

@export var target: Wireframe

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT > 0:
			print("Clicked")
			self.target.animation.play("show_wireframe")
