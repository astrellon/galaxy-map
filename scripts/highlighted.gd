extends Node2D

class_name Highlighted

@export var radius = 10.0
@export var target: ShowCelestial
@export var colour = Color.CYAN
@export var closing_colour = Color.ORANGE
@export var rotate_speed = 0.2
@export var num_side = 6
@export var remove = false
@export var closing = false

var angle = 0.0
var current_radius = 0.0
var current_radius_lerp = 0.0
var segment_angle = 0.2
var segment_angle_lerp = 0.0
var current_colour: Color = self.colour

func init(target: ShowCelestial) -> void:
	self.target = target
	target.hiding.connect(self._on_hide)
	target.closing.connect(self._on_closing)

func _process(delta: float) -> void:
	if self.target != null:
		self.global_position = self.target.get_center_point()
	
	if self.closing:
		self.segment_angle_lerp = clamp(self.segment_angle_lerp + delta, 0.0, 1.0)
		self.segment_angle = 0.2 - Easing.Quad.EaseInOut(self.segment_angle_lerp, 0.0, 0.2, 1.0)
		self.current_colour = self.colour.lerp(self.closing_colour, Easing.Quad.EaseInOut(self.segment_angle_lerp, 0.0, 1.0, 1.0))
	
	if self.remove:
		self.current_radius_lerp = clamp(self.current_radius_lerp - delta, 0.0, 1.0)
		self.current_radius = Easing.Quad.EaseInOut(self.current_radius_lerp, 0.0, 1.0, 1.0) * self.radius

		if self.current_radius_lerp <= 0.01:
			self.queue_free()
			return
	else:
		self.current_radius_lerp = clamp(self.current_radius_lerp + delta, 0.0, 1.0)
		self.current_radius = Easing.Elastic.EaseOut(self.current_radius_lerp, 0.0, 1.0, 1.0) * self.radius

	self.angle = fmod(self.angle + delta * self.rotate_speed, 1.0)
	self.queue_redraw()

func _draw() -> void:
	for i in range(self.num_side):
		var current_angle = (self.angle + (i / float(self.num_side))) * TAU
		draw_arc(Vector2.ZERO, self.current_radius, current_angle - self.segment_angle, current_angle + self.segment_angle, 16, self.current_colour)

func _on_hide():
	self.remove = true

func _on_closing():
	self.closing = true
