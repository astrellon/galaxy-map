extends MultiMeshInstance2D

@export var num_stars = 100
@export var seed = 1234
@export var radius = 100
@export var alpha_range = Vector2(0.1, 0.25)
@export var gradient: Gradient
@export var ignore_node: CollisionShape2D

var ignore_circle: CircleShape2D
var random: RandomNumberGenerator

func _ready() -> void:
	self.random = RandomNumberGenerator.new()
	self.random.seed = self.seed
	self.multimesh.instance_count = self.num_stars
	self.multimesh.visible_instance_count = self.num_stars
	
	self.ignore_circle = self.ignore_node.shape as CircleShape2D
	
	var index = 0
	for i in range(self.num_stars):
		for overflow_test in range(0, 10):
			var x = self.random.randf_range(-10, 490)
			var y = self.random.randf_range(-10, 280)
			
			var position = Vector2(x, y).round()
			var dist = (self.ignore_node.global_position - position).length() - self.ignore_circle.radius
			if dist < 0:
				continue
			
			var alpha = self.random.randf_range(self.alpha_range.x, self.alpha_range.y)
			var sample_point = self.random.randf()
			var colour = self.gradient.sample(sample_point)
			var inst_colour = Color(colour, alpha)
			var trans = Transform2D(0.0, position)
			
			index += 1
			self.multimesh.set_instance_transform_2d(index, trans)
			self.multimesh.set_instance_color(index, inst_colour)
			break
