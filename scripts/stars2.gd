extends MultiMeshInstance2D

@export var num_stars = 100
@export var seed = 1234
@export var radius = 100
@export var follow_rotation: Node2D
@export var alpha_range = Vector2(0.1, 0.25)
@export var gradient: Gradient

var random: RandomNumberGenerator

func _ready() -> void:
	self.random = RandomNumberGenerator.new()
	self.multimesh.instance_count = self.num_stars
	self.multimesh.visible_instance_count = self.num_stars

func _process(delta: float) -> void:
	self.random.seed = self.seed
	var parent_rotation = self.follow_rotation.global_transform
	
	for i in range(self.num_stars):
		var angle = self.random.randf_range(0, 2.0 * PI)
		var dist = self.random.randf_range(0, self.radius)
		var x = cos(angle) * dist
		var y = sin(angle) * dist
		
		var position = (parent_rotation * Vector2(x, y)).round()
		var trans = Transform2D(0.0, position)
		var alpha = self.random.randf_range(self.alpha_range.x, self.alpha_range.y)
		#var inst_colour = Color(self.colour, alpha)
		var sample_point = self.random.randf()
		var colour = self.gradient.sample(sample_point)
		#print(str(sample_point) + " | " + str(colour))
		var inst_colour = Color(colour, alpha)
		
		self.multimesh.set_instance_transform_2d(i, trans)
		self.multimesh.set_instance_color(i, inst_colour)
