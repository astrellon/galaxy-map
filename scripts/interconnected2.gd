extends Sprite2D

@export var connected_point_numbers: Array[PackedInt32Array] = []
@export var target: Node2D
@export var num_traffic = 100
@export var traffic: MultiMeshInstance2D
@export var traffic_speed: Vector2 = Vector2(1.5, 4.0)

var connected_points: Array[ConnectedPoints] = []
var traffic_points: Array[TrafficPoint] = []
var num_active_traffic_points = 0
var weighted_points: Array[int] = []

func _ready() -> void:
	for i in range(self.num_traffic):
		self.traffic_points.push_back(TrafficPoint.new())
		
	self.traffic.multimesh.instance_count = self.num_traffic
	
	var point_index = 0
	for point_numbers in self.connected_point_numbers:
		var connected: Array[Node2D] = []
		for num in point_numbers:
			weighted_points.push_back(point_index)
			var child_name = "Point" + str(num)
			var found = target.find_child(child_name)
			connected.push_back(found)
		
		point_index += 1
		connected_points.push_back(ConnectedPoints.new(connected))

func _process(delta: float) -> void:
	var spawned_traffic = 0
	self.num_active_traffic_points = 0
	
	for traffic in self.traffic_points:
		if traffic.active:
			self.num_active_traffic_points += 1
			traffic.update(delta)
		elif spawned_traffic < 2:
			self.num_active_traffic_points += 1
			var edge = self.pick_random_edge()
			var speed = 1.0 / randf_range(self.traffic_speed.x, self.traffic_speed.y)
			var colour = Color.from_hsv(randf(), 0.5, 0.75)
			traffic.setup(edge[0], edge[1], speed, colour)
			spawned_traffic += 1
	
	self.traffic.multimesh.visible_instance_count = self.num_active_traffic_points
	var index = 0
	for traffic in self.traffic_points:
		if traffic.active:
			var global_pos: Vector2 = traffic.get_global_pos()
			self.traffic.multimesh.set_instance_transform_2d(index, Transform2D(0.0, global_pos))
			var alpha = randf_range(0.6, 0.9)
			self.traffic.multimesh.set_instance_color(index, Color(traffic.colour, alpha))
			index += 1
		
	queue_redraw()

func _draw() -> void:
	for connected in self.connected_points:
		for i in range(1, connected.nodes.size()):
			var prev = connected.nodes[i - 1].global_position
			var curr = connected.nodes[i].global_position
			
			draw_line(prev, curr, Color.RED)

func pick_random_edge() -> Array[Node2D]:
	#var point_index = randi_range(0, self.connected_points.size() - 1)
	var point_index = self.weighted_points[randi_range(0, self.weighted_points.size() - 1)]
	var points = self.connected_points[point_index]
	
	if randf() >= 0.5:
		var index = randi_range(0, points.nodes.size() - 2)
		return [points.nodes[index], points.nodes[index + 1]]
	else:
		var index = randi_range(1, points.nodes.size() - 1)
		return [points.nodes[index], points.nodes[index - 1]]
