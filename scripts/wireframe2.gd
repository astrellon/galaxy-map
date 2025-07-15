extends Node2D

@export_file var meshFile
@export var camera: Camera3D
@export var backface_culling: bool = true
@export var front_colour: Color = Color.GREEN
@export var back_colour: Color = Color.DARK_GREEN
@export var wireframe_scale: float = 0.75
@export var alpha: float = 1.0
@export var max_scale_fov: float = 45
@export var ignore_line: Vector4

var mesh: MeshFile

var front_faces: Array[ScreenFace]
var screen_positions: Array[Vector2] = []

func _ready() -> void:
	self.mesh = MeshFile.create(self.meshFile)
	print("Mesh loaded " + str(len(mesh.vertices)))

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if self.wireframe_scale < 0.0001 || self.alpha < 0.0001:
		return

	var fov = lerpf(180, self.max_scale_fov, self.wireframe_scale)
	self.camera.fov = fov

	var has_ignore = self.ignore_line.length() > 0.1
	var ignore_dir = Vector3(self.ignore_line.x, self.ignore_line.y, self.ignore_line.z)
	
	var back_colour = Color(self.back_colour, self.alpha)
	var front_colour = Color(self.front_colour, self.alpha)

	front_faces.clear()

	for f in self.mesh.faces:
		screen_positions.clear()

		var prev_world = Vector3.ZERO
		var has_prev_world = false
		for fv in f.faces:
			var current = self.mesh.vertices[fv.x]
			var next = self.camera.unproject_position(current)

			if has_prev_world && has_ignore:
				var dir = current - prev_world
				var length = dir.length()
				if length > self.ignore_line.w:
					var norm = dir.normalized()
					if abs(ignore_dir.dot(norm)) > 0.999:
						continue

			has_prev_world = true
			prev_world = current
			screen_positions.push_back(next)

		if len(screen_positions) < 3:
			continue

		var ab = screen_positions[1] - screen_positions[0]
		var ac = screen_positions[2] - screen_positions[1]

		var screen_sign = ab.x * ac.y - ac.x * ab.y
		if screen_sign > 0:
			if self.backface_culling:
				continue
		else:
			front_faces.push_back(ScreenFace.new(screen_positions.duplicate()))
			continue

		for i in range(len(screen_positions)):
			var prev = screen_positions[-1] if i == 0 else screen_positions[i - 1]
			var current = screen_positions[i]
			draw_line(prev, current, back_colour)

	for f in front_faces:
		for i in range(len(f.positions)):
			var prev = f.positions[-1] if i == 0 else f.positions[i - 1]
			var current = f.positions[i]
			draw_line(prev, current, front_colour)
