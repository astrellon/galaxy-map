extends Node2D

@export_file var meshFile
@export var camera: Camera3D
@export var backface_culling: bool = true
@export var front_colour: Color = Color.GREEN
@export var back_colour: Color = Color.DARK_GREEN
@export var wireframe_scale: float = 0.75
@export var max_scale_fov: float = 45

var mesh: MeshFile

var front_faces: Array[ScreenFace]
var screen_positions: Array[Vector2] = []

func _ready() -> void:
	self.mesh = MeshFile.create(self.meshFile)
	print("Mesh loaded " + str(len(mesh.vertices)))
	
func _process(delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	if self.wireframe_scale < 0.0001:
		return
	
	var fov = lerpf(180, self.max_scale_fov, self.wireframe_scale)
	self.camera.fov = fov
	
	front_faces.clear()
	
	for f in self.mesh.faces:
		screen_positions.clear()
		
		for fv in f.faces:
			var next = self.camera.unproject_position(self.mesh.vertices[fv.x])
			screen_positions.push_back(next)
		
		if len(screen_positions) < 3:
			continue
		
		var ab = screen_positions[1] - screen_positions[0]
		var ac = screen_positions[2] - screen_positions[1]
		var sign = ab.x * ac.y - ac.x * ab.y
		if sign > 0:
			if self.backface_culling:
				continue
		else:
			front_faces.push_back(ScreenFace.new(screen_positions.duplicate()))
			continue
			
		for i in range(len(screen_positions)):
			var prev = screen_positions[-1] if i == 0 else screen_positions[i - 1]
			var current = screen_positions[i]
			draw_line(prev, current, self.back_colour)
	
	for f in front_faces:
		for i in range(len(f.positions)):
			var prev = f.positions[-1] if i == 0 else f.positions[i - 1]
			var current = f.positions[i]
			draw_line(prev, current, self.front_colour)
