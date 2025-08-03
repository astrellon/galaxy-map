extends Node2D

class_name Wireframe

enum RevealType { ALPHA, LINE_BY_LINE }

@export_file var mesh_file
@export var camera: Camera3D
@export var backface_culling: bool = true
@export var front_colour: Color = Color.GREEN
@export var back_colour: Color = Color.DARK_GREEN
@export var mesh_scale: float = 1.0
@export var ignore_line: Vector4
@export var animation: AnimationPlayer
@export var label: Label
@export var raymarch_node: Raymarch
@export var outline_node: Outline
@export var auto_start = false

@export var reveal_lines: float = 1.0
@export var reveal_type: RevealType = RevealType.ALPHA
@export var alpha: float = 1.0
@export var target_camera_fov: float = 100
@export var reveal_camera_fov: float = 1.0

var mesh: MeshFile
var total_lines_to_draw = 0
var frame_wait = 2

var front_faces: Array[ScreenFace]
var screen_positions: Array[Vector2] = []
var inited = false

var do_hide = false
var wireframe_hidden = false

func calc_num_total_lines() -> int:
	var total: int = 0
	for f in self.mesh.faces:
		total += len(f.faces)

	return total

func _ready() -> void:
	if self.auto_start:
		self.mesh = MeshFile.create(self.mesh_file)
		self.total_lines_to_draw = self.calc_num_total_lines()
		self.inited = true
		print("Mesh loaded " + str(len(self.mesh.vertices)))
		self.play_start_animation()

func init(info: ShowCelestial) -> void:
	if self.inited:
		return

	self.mesh_file = info.mesh_file
	self.mesh_scale = info.wireframe_mesh_scale
	self.target_camera_fov = info.target_camera_fov
	self.backface_culling = info.backface_culling
	self.reveal_type = info.reveal_type
	if info.label_colour.a < 0.01:
		self.label.label_settings.font_color = info.wireframe_front_colour
	else:
		self.label.label_settings.font_color = info.label_colour

	self.label.text = info.label

	self.inited = true
	self.mesh = MeshFile.create(self.mesh_file)
	print("Mesh loaded " + str(len(mesh.vertices)))
	self.total_lines_to_draw = self.calc_num_total_lines()

	self.front_colour = info.wireframe_front_colour
	self.back_colour = info.wireframe_back_colour

	self.outline_node.init(info)
	self.raymarch_node.init(info)

	#self.animation.play("show_wireframe")
	self.play_start_animation()

func play_start_animation() -> void:
	if self.reveal_type == RevealType.ALPHA:
		self.animation.play("reveal_alpha")
	elif self.reveal_type == RevealType.LINE_BY_LINE:
		self.animation.play("reveal_line_by_line")

func hide_wireframe() -> void:
	self.animation.stop(true)
	self.do_hide = true

func _process(delta: float) -> void:
	if self.wireframe_hidden:
		return

	if self.inited:
		if self.do_hide:
			self.reveal_lines = clampf(self.reveal_lines - delta, 0.0, 1.0)
			self.raymarch_node.reveal = clamp(self.raymarch_node.reveal - delta, 0.0, 1.0)
			if self.reveal_lines <= 0.0 and self.raymarch_node.reveal <= 0.0:
				print('Hidden!')
				self.wireframe_hidden = true
				return

		queue_redraw()

func _draw() -> void:
	if self.reveal_camera_fov < 0.0001 || self.reveal_lines < 0.0001:
		return

	if self.frame_wait > 0:
		self.frame_wait = self.frame_wait - 1
		return

	var fov = lerpf(180, self.target_camera_fov, self.reveal_camera_fov)
	self.camera.fov = fov

	var has_ignore = self.ignore_line.length() > 0.1
	var ignore_dir = Vector3(self.ignore_line.x, self.ignore_line.y, self.ignore_line.z)


	var back_colour = Color(self.back_colour, self.alpha)
	var front_colour = Color(self.front_colour, self.alpha)

	var num_lines_to_draw = self.total_lines_to_draw
	#if self.reveal_type == RevealType.LINE_BY_LINE:
	num_lines_to_draw = roundi(num_lines_to_draw * self.reveal_lines)

	front_faces.clear()

	for f in self.mesh.faces:
		screen_positions.clear()

		var prev_world = Vector3.ZERO
		var has_prev_world = false
		for fv in f.faces:
			num_lines_to_draw -= 1
			if num_lines_to_draw <= 0:
				break

			var current = self.mesh.vertices[fv.x] * self.mesh_scale
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
