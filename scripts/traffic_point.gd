class_name TrafficPoint

var from: Node2D
var to: Node2D
var progress: float
var speed: float
var active: bool
var colour: Color

func setup(from: Node2D, to: Node2D, speed: float, colour: Color):
	self.from = from
	self.to = to
	self.speed = speed
	self.colour = colour
	self.progress = 0
	self.active = true

func update(dt: float):
	self.progress = clamp(self.progress + self.speed * dt, 0, 1)
	if self.progress >= 1:
		self.active = false

func get_global_pos() -> Vector2:
	var lerped = self.from.global_position.lerp(self.to.global_position, self.progress)
	return lerped
