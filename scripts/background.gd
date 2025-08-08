extends Node2D

@export var colour_map: Texture2D
@export var time_per_pixel = 0.5

@export var layer1: Node2D
@export var layer2: Node2D
@export var layer3: Node2D
@export var layer4_outer: Node2D
@export var layer4_inner: Node2D
@export var layer5: Node2D
@export var stroke: Node2D

@export var rotate_speed = 1.0

var layer1_polygons: Array[Polygon2D]
var layer2_polygons: Array[Polygon2D]
var layer3_polygons: Array[Polygon2D]
var layer4_outer_polygons: Array[Polygon2D]
var layer4_inner_polygons: Array[Polygon2D]
var layer5_polygons: Array[Polygon2D]
var stroke_lines: Array[Line2D]

var time = 0.0
var prev_index = -100

func _ready() -> void:
	self.layer1_polygons = self._find_polygons(self.layer1)
	self.layer2_polygons = self._find_polygons(self.layer2)
	self.layer3_polygons = self._find_polygons(self.layer3)
	self.layer4_outer_polygons = self._find_polygons(self.layer4_outer)
	self.layer4_inner_polygons = self._find_polygons(self.layer4_inner)
	self.layer5_polygons = self._find_polygons(self.layer5)
	self.stroke_lines = self._find_lines(self.stroke)

func get_colour(index: int, layer: int) -> Color:
	return self.colour_map.get_image().get_pixel(index, layer)

func _process(delta: float) -> void:
	if self.rotate_speed > 0:
		self.rotate(self.rotate_speed * delta * PI / 180.0);
		
	var index = clamp(floor(time / self.time_per_pixel), 0, self.colour_map.get_width() - 1)
	time += delta
	if index != self.prev_index:
		self.prev_index = index
		self._update_polygons(self.layer1_polygons, self.get_colour(index, 0))
		self._update_polygons(self.layer2_polygons, self.get_colour(index, 1))
		self._update_polygons(self.layer3_polygons, self.get_colour(index, 2))
		self._update_polygons(self.layer4_outer_polygons, self.get_colour(index, 3))
		self._update_polygons(self.layer4_inner_polygons, self.get_colour(index, 4))
		self._update_polygons(self.layer5_polygons, self.get_colour(index, 5))
		self._update_lines(self.stroke_lines, self.get_colour(index, 6))

func _update_polygons(list: Array[Polygon2D], colour: Color) -> void:
	for polygon in list:
		polygon.color = colour

func _update_lines(list: Array[Line2D], colour: Color) -> void:
	for line in list:
		line.default_color = colour

func _find_polygons(input: Node2D) -> Array[Polygon2D]:
	var result: Array[Polygon2D] = []
	if input is Polygon2D:
		result.push_back(input)
	
	for child1 in input.get_children():
		if child1 is Polygon2D:
			result.push_back(child1)
		
		for child2 in child1.get_children():
			if child2 is Polygon2D:
				result.push_back(child2)
				
			for child3 in child2.get_children():
				if child3 is Polygon2D:
					result.push_back(child3)
	
	return result
	
func _find_lines(input: Node2D) -> Array[Line2D]:
	var result: Array[Line2D] = []
	if input is Line2D:
		result.push_back(input)
	
	for child1 in input.get_children():
		if child1 is Line2D:
			result.push_back(child1)
		
		for child2 in child1.get_children():
			if child2 is Line2D:
				result.push_back(child2)
	
	return result
