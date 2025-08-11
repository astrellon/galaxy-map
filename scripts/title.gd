extends Area2D

@export var text: Label
@export var text_visible = true

var _fade = 1.0

func _init() -> void:
	self._fade = 1.0 if self.text_visible else 0.0

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT >= 0 and event.pressed:
			self.toggle()

func _process(delta: float) -> void:
	var change = delta if self.text_visible else -delta
	var prev = self._fade
	self._fade = clamp(self._fade + change, 0.0, 1.0)
	
	if self._fade != prev:
		self.text.material.set_shader_parameter('fade', Easing.Sine.EaseInOut(self._fade, 0.0, 1.0, 1.0))
	
func toggle() -> void:
	self.text_visible = !self.text_visible
