extends Node2D

@export var mesh: ArrayMesh
@export var camera: Camera3D
var inited = false

var vertices: Array[Vector3] = []
var numFaces = 0

func _process(delta: float) -> void:
	if (inited):
		queue_redraw()
		return
		
	inited = true
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	
	numFaces = mdt.get_face_count()
	print("Num faces " + str(numFaces))
	for i in range(numFaces):
		var a = mdt.get_face_vertex(i, 0)
		var b = mdt.get_face_vertex(i, 1)
		var c = mdt.get_face_vertex(i, 2)
		
		var ap = mdt.get_vertex(a)
		var bp = mdt.get_vertex(b)
		var cp = mdt.get_vertex(c)
		
		vertices.push_back(ap)
		vertices.push_back(bp)
		vertices.push_back(cp)
		
		print(str(i) + " = " + str(ap) + " | " + str(bp) + " | " + str(cp))
	print("Done")

func _draw() -> void:
	if (!inited):
		return
	
	for i in range(numFaces):
		var a = vertices[i * 3]
		var b = vertices[i * 3 + 1]
		var c = vertices[i * 3 + 2]
		
		var screenA = self.camera.unproject_position(a)
		var screenB = self.camera.unproject_position(b)
		var screenC = self.camera.unproject_position(c)
		
		draw_line(screenA, screenB, Color.GREEN)
		draw_line(screenB, screenC, Color.GREEN)
		draw_line(screenC, screenA, Color.GREEN)
