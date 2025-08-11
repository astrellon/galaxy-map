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
		var axis = Vector3(-held_velocity.x, held_velocity.y, 0.0)
		self.global_rotate(axis.normalized(), axis.length())
		
		if self.held_velocity.length() < 0.1:
			self._held_timer += delta
			if self._held_timer >= self.held_countdown:
				self._held = false
	else:
		self.rotate_y(delta * self.speed.y)
		self.rotate_x(delta * self.speed.x)

func do_held(held_velocity: Vector2) -> void:
	self.held_velocity = held_velocity
	var axis = Vector3(-held_velocity.x, held_velocity.y, 0.0)
	self.global_rotate(axis.normalized(), axis.length())
	self._held = true
	self._held_timer = 0.0
