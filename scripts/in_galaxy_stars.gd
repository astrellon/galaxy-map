extends MultiMeshInstance2D

@export var num_stars = 100
@export var seed = 1234
@export var radius = 100
@export var follow_rotation: Node2D
@export var alpha_range = Vector2(0.1, 0.25)
@export var gradient: Gradient

var random: RandomNumberGenerator
var positions: Array[Vector2] = []

func _ready() -> void:
	self.random = RandomNumberGenerator.new()
	self.multimesh.instance_count = self.num_stars
	self.multimesh.visible_instance_count = self.num_stars
	
	self.random.seed = self.seed
	
	for i in range(self.num_stars):
		var angle = self.random.randf_range(0, 2.0 * PI)
		var dist = self.random.randf_range(0, self.radius)
		var x = cos(angle) * dist
		var y = sin(angle) * dist
		
		self.positions.push_back(Vector2(x, y))

		var alpha = self.random.randf_range(self.alpha_range.x, self.alpha_range.y)
		var sample_point = self.random.randf()
		var colour = self.gradient.sample(sample_point)
		var inst_colour = Color(colour, alpha)
		
		self.multimesh.set_instance_color(i, inst_colour)

func _process(delta: float) -> void:
	self.random.seed = self.seed
	var parent_rotation = self.follow_rotation.global_transform
	
	for i in range(self.num_stars):
		var rotated_position = (parent_rotation * self.positions[i]).round()
		var trans = Transform2D(0.0, rotated_position)
		
		self.multimesh.set_instance_transform_2d(i, trans)
