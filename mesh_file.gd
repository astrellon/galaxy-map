class_name MeshFile

var vertices: Array[Vector3]
var normals: Array[Vector3]
var faces: Array[MeshFace]

func _init(vertices: Array[Vector3], normals: Array[Vector3], faces: Array[MeshFace]):
	self.vertices = vertices
	self.normals = normals
	self.faces = faces
	
static func create(resource: String):
	var f = FileAccess.open(resource, FileAccess.READ)
	var contents = f.get_as_text()
	
	var vertices: Array[Vector3] = []
	var normals: Array[Vector3] = []
	var faces: Array[MeshFace] = []
	
	for line in contents.split("\n", false):
		var split = line.split(" ", false)
		if split[0] == "v":
			var vertex = Vector3(float(split[1]), float(split[2]), float(split[3]))
			vertices.push_back(vertex)
		elif split[0] == "vn":
			var vertex = Vector3(float(split[1]), float(split[2]), float(split[3]))
			normals.push_back(vertex)
		elif split[0] == "f":
			var face: Array[Vector2i] = []
			for i in range(1, len(split)):
				var face_split = split[i].split("/", true)
				var vertex_index = int(face_split[0]) - 1
				var normal_index = int(face_split[2]) - 1
				face.push_back(Vector2i(vertex_index, normal_index))
			faces.push_back(MeshFace.new(face))
	
	return MeshFile.new(vertices, normals, faces)
