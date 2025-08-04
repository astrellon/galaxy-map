extends Sprite2D

class_name CursorController

static var instance: CursorController

var highlighted_scene = preload("res://scenes/highlighted.tscn")

@export var cursor_change_speed = 4.0
@export var cursor: CursorGraphic
@export var highlight_parent: Node2D

var over = false

func _init() -> void:
	instance = self

func _process(delta: float) -> void:
	var diff = -delta
	if self.over:
		diff = delta
	
	self.cursor.cursor_mode = clamp(self.cursor.cursor_mode + diff * self.cursor_change_speed, 0.0, 1.0)
	var mouse_pos = self.get_global_mouse_position()
	self.cursor.global_position = round(mouse_pos)

func hover():
	self.over = true

func unhover():
	self.over = false

func show_highlight(info: ShowCelestial) -> void:
	var new_highlight = highlighted_scene.instantiate()
	new_highlight.init(info)
	self.highlight_parent.add_child(new_highlight)
