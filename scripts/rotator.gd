extends Node3D

class_name Rotator

@export var speed = Vector2(1.0 / PI, 1.0)
@export var held_velocity = Vector2.ZERO
@export var held_countdown = 4.0

var _held = false
var _held_timer = 0.0

func _process(delta: float) -> void:
	if self._held:
		self.held_velocity *= 1.0 - delta
		self._rotate_global(self.held_velocity)

		if self.held_velocity.length() < 0.1:
			self._held_timer += delta
			if self._held_timer >= self.held_countdown:
				self._held = false
	else:
		self.rotate_y(delta * self.speed.y)
		self.rotate_x(delta * self.speed.x)

func do_held(held_velocity: Vector2) -> void:
	self.held_velocity = held_velocity
	self._rotate_global(held_velocity)
	self._held = true
	self._held_timer = 0.0

func _rotate_global(values: Vector2) -> void:
	if values.length() < 0.001:
		return
	
	var x = self.basis.y * -values.y
	var y = self.basis.x * -values.x
	var axis = x + y
	self.global_rotate(axis.normalized(), axis.length())
