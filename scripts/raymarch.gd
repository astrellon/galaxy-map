extends ColorRect

class_name Raymarch

@export var camera: Camera3D
@export var reveal: float = 0.0;

func _process(delta: float) -> void:
	var cameraTrans = self.camera.get_global_transform_interpolated()
	var basis = cameraTrans.basis

	self.material.set_shader_parameter('uCameraPosition', cameraTrans.origin)
	self.material.set_shader_parameter('uCameraMatrix', basis)

	var fov = deg_to_rad(self.camera.fov * 0.5)
	self.material.set_shader_parameter('uCameraFov', fov)
	self.material.set_shader_parameter('uReveal', self.reveal)

	var camera_projection = self.camera.get_camera_projection().inverse()
	self.material.set_shader_parameter('uProjectionMatrix', camera_projection)

func init(info: ShowCelestial) -> void:
	self.material.set_shader_parameter('uPlanetTexture', info.planet_texture)
	self.material.set_shader_parameter('uPlanetNoiseScale', info.raymarch_planet_noise)
	self.material.set_shader_parameter('uPlanetNoiseOffset', info.raymarch_planet_offset)
	self.material.set_shader_parameter('uScene', info.raymarch_scene)
	self.material.set_shader_parameter('uRingParams', info.raymarch_ring_params)
