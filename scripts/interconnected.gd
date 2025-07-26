extends Node2D

@export var interconnect: Node2D
@export var interconnect_colour: Color = Color.RED
var lines: Array[PackedVector2Array] = []

func _ready() -> void:
	for child in self.interconnect.get_children():
		for path_child in child.get_children():
			if path_child is Line2D:
				lines.push_back(path_child.points)
	#self.remove_child(self.interconnect)
	print("Found: " + str(len(lines)))
	
func _process(delta: float) -> void:
	self.rotate(delta * PI / 180.0);
	queue_redraw()

func _draw() -> void:
	for points in self.lines:
		draw_polyline(points, self.interconnect_colour)
