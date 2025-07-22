extends Node2D

@export var num_stars = 100
@export var seed = 1234
@export var colour = Color(Color.WHITE, 0.2)

var random: RandomNumberGenerator

func _init() -> void:
	self.random = RandomNumberGenerator.new()

func _process(delta: float) -> void:	
	self.random.seed = self.seed
	queue_redraw()
	
func _draw() -> void:
	for i in range(self.num_stars):
		var x = self.random.randi_range(-200, 750)
		var y = self.random.randi_range(-200, 750)
		
		draw_line(Vector2(x, y), Vector2(x + 1, y), self.colour, 1.0)
