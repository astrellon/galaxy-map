extends Node2D

class_name CursorGraphic

@export var max_length = 10.0
@export var min_length = 3.0
@export var bit_colour = Color.CYAN
@export var cursor_mode = 0.0
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
	
	var dir1 = Vector2.from_angle(angle1 * 2.0 * PI)
	var dir2 = Vector2.from_angle(angle2 * 2.0 * PI)
	var dir3 = Vector2.from_angle(angle3 * 2.0 * PI)
	
	var offset = Vector2(0.5, 0.5)
	
	var hover_pos1a = dir1 * self.min_length + offset
	var hover_pos1b = dir1 * self.max_length + offset
	var hover_pos2a = dir2 * self.min_length + offset
	var hover_pos2b = dir2 * self.max_length + offset
	var hover_pos3a = dir3 * self.min_length + offset
	var hover_pos3b = dir3 * self.max_length + offset

	var idle_pos1a = Vector2.ZERO
	var idle_pos1b = Vector2(0, self.max_length)
	var idle_pos2a = Vector2.ZERO
	var idle_pos2b = round(idle_dir * self.max_length)
	var idle_pos3a = idle_pos1b
	var idle_pos3b = idle_pos2b

	var pos1a = lerp(idle_pos1a, hover_pos1a, self.cursor_mode)
	var pos1b = lerp(idle_pos1b, hover_pos1b, self.cursor_mode)
	var pos2a = lerp(idle_pos2a, hover_pos2a, self.cursor_mode)
	var pos2b = lerp(idle_pos2b, hover_pos2b, self.cursor_mode)
	var pos3a = lerp(idle_pos3a, hover_pos3a, self.cursor_mode)
	var pos3b = lerp(idle_pos3b, hover_pos3b, self.cursor_mode)
	
	draw_line(pos1a, pos1b, self.bit_colour)
	draw_line(pos2a, pos2b, self.bit_colour)
	draw_line(pos3a, pos3b, self.bit_colour)
