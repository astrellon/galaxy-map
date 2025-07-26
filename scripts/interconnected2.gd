extends Sprite2D

@export var connectedPointNumbers: Array[PackedInt32Array] = []
@export var target: Node2D

var connectedPoints: Array[ConnectedPoints] = []

func _ready() -> void:
	for pointNumbers in self.connectedPointNumbers:
		var connected: Array[Node2D] = []
		for num in pointNumbers:
			var child_name = "Point" + str(num)
			var found = target.find_child(child_name)
			connected.push_back(found)
		
		connectedPoints.push_back(ConnectedPoints.new(connected))

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	for connected in self.connectedPoints:
		for i in range(1, connected.nodes.size()):
			var prev = connected.nodes[i - 1].global_position
			var curr = connected.nodes[i].global_position
			
			draw_line(prev, curr, Color.RED)
