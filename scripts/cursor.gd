extends Node2D

class_name CursorGraphic

@export var max_length = 10.0
@export var min_length = 3.0
@export var bit_colour = Color.CYAN
var cursor_mode = 0.0
var angle = 0.0

var idle_dir = Vector2(1, 1).normalized()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(delta: float) -> void:
	self.angle = fmod(angle + delta, 1.0)
	
	queue_redraw()

func _draw() -> void:
	var angle1 = self.angle - 1.0 / 3.0
	var angle2 = self.angle
	var angle3 = self.angle + 1.0 / 3.0
	
	var dir1 = Vector2.from_angle(angle1 * TAU)
	var dir2 = Vector2.from_angle(angle2 * TAU)
	var dir3 = Vector2.from_angle(angle3 * TAU)
	
	var offset = Vector2(0.5, 0.5)

	var modified_min_length = cos_bounce(self.cursor_mode) * 3.0 + self.min_length
	var modified_max_length = cos_bounce(self.cursor_mode) * 5.0 + self.max_length
	
	var hover_pos1a = dir1 * modified_min_length + offset
	var hover_pos1b = dir1 * modified_max_length + offset
	var hover_pos2a = dir2 * modified_min_length + offset
	var hover_pos2b = dir2 * modified_max_length + offset
	var hover_pos3a = dir3 * modified_min_length + offset
	var hover_pos3b = dir3 * modified_max_length + offset

	var idle_pos1a = Vector2.ZERO
	var idle_pos1b = Vector2(0, modified_max_length)
	var idle_pos2a = Vector2.ZERO
	var idle_pos2b = round(idle_dir * modified_max_length)
	var idle_pos3a = idle_pos1b
	var idle_pos3b = idle_pos2b

	var mode_lerp = Easing.Quart.EaseInOut(self.cursor_mode, 0.0, 1.0, 1.0)

	var pos1a = lerp(idle_pos1a, hover_pos1a, mode_lerp)
	var pos1b = lerp(idle_pos1b, hover_pos1b, mode_lerp)
	var pos2a = lerp(idle_pos2a, hover_pos2a, mode_lerp)
	var pos2b = lerp(idle_pos2b, hover_pos2b, mode_lerp)
	var pos3a = lerp(idle_pos3a, hover_pos3a, mode_lerp)
	var pos3b = lerp(idle_pos3b, hover_pos3b, mode_lerp)
	
	draw_line(pos1a, pos1b, self.bit_colour)
	draw_line(pos2a, pos2b, self.bit_colour)
	draw_line(pos3a, pos3b, self.bit_colour)

static func cos_bounce(t: float) -> float:
	return -cos(t * TAU) * 0.5 + 0.5
