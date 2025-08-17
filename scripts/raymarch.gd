extends ColorRect

class_name Raymarch

static var _random: RandomNumberGenerator = RandomNumberGenerator.new()

class LightningPoint:
	var position: Vector3
	var age: float
	var radius: float
	var max_radius: float
	
	func _init() -> void:
		self._reset()
	
	func _reset() -> void:
		self.age = random_age()
		self.position = random_point()
		self.max_radius = random_max_radius()
	
	func update(delta: float) -> void:
		self.age = clamp(self.age + delta, -10.0, 1.0)
		if self.age >= 1.0:
			self._reset()
		
		self.radius = 0.0
		if self.age >= 0.1:
			self.radius = (self.age - 1.0) * -1.1
		elif self.age > 0.0:
			self.radius = self.age * 10.0
		
		self.radius *= self.max_radius
	
	func get_vec() -> Vector4:
		return Vector4(self.position.x, self.position.y, self.position.z, self.radius)
	
	static func random_age() -> float:
		return Raymarch._random.randf_range(-4.0, -2.0)
	
	static func random_max_radius() -> float:
		return Raymarch._random.randf_range(0.1, 0.2)
	
	static func random_point() -> Vector3:
		var phi = Raymarch._random.randf_range(0.0, TAU)
		var theta = Raymarch._random.randf_range(0.0, TAU)
		var x = sin(theta) * 0.5
		var y = cos(phi) * 0.5
		var z = sin(phi) * cos(theta) * 0.5
		return Vector3(x, y, z)

@export var camera: Camera3D
@export var reveal: float = 0.0
var _lightning_points: Array[LightningPoint] = []
var _lightning_point_vecs: Array[Vector4] = []

var current_scene_number = -1

func _process(delta: float) -> void:
	var cameraTrans = self.camera.get_global_transform_interpolated()
	var basis = cameraTrans.basis

	self.material.set_shader_parameter('uCameraPosition', cameraTrans.origin)
	self.material.set_shader_parameter('uCameraMatrix', basis)

	var fov = deg_to_rad(self.camera.fov * 0.5)
	self.material.set_shader_parameter('uCameraFov', fov)
	self.material.set_shader_parameter('uReveal', self.reveal)
	
	if self.current_scene_number == 1:
		for i in range(4):
			var lightning = self._lightning_points[i]
			lightning.update(delta)
			self._lightning_point_vecs[i] = lightning.get_vec()
		self.material.set_shader_parameter('uLightningPoints', self._lightning_point_vecs)

func init(info: ShowCelestial) -> void:
	self.current_scene_number = info.raymarch_scene
	
	if self.current_scene_number == 1 and self._lightning_points.size() == 0:
		for i in range(4):
			self._lightning_points.push_back(LightningPoint.new())
			self._lightning_point_vecs.push_back(Vector4.ZERO)
			
	self.material.set_shader_parameter('uPlanetTexture', info.planet_texture)
	self.material.set_shader_parameter('uPlanetNoiseScale', info.raymarch_planet_noise)
	self.material.set_shader_parameter('uPlanetNoiseOffset', info.raymarch_planet_offset)
	self.material.set_shader_parameter('uScene', info.raymarch_scene)
	self.material.set_shader_parameter('uRingParams', info.raymarch_ring_params)
	self.material.set_shader_parameter('uCloudParams', info.raymarch_cloud_params)
