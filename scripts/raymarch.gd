extends ColorRect

class_name Raymarch

@export var camera: Camera3D
@export var reveal: float = 0.0;
@export var fudge_fov_factor: float = 1.0

func _process(delta: float) -> void:
	var cameraTrans = self.camera.get_global_transform_interpolated()
	var basis = cameraTrans.basis
	
	#print('Raymarch reveal: ' + str(selfreveal) + " - " + str(self.material.get_shader_parameter('uScene')))
	
	self.material.set_shader_parameter('uCameraPosition', cameraTrans.origin)
	self.material.set_shader_parameter('uCameraMatrix', basis)
	
	var fov = self.camera.fov * 0.5
	self.material.set_shader_parameter('uCameraFov', fov * self.fudge_fov_factor)
	self.material.set_shader_parameter('uReveal', self.reveal)
	
func init(info: ShowCelestial) -> void:
	self.material.set_shader_parameter('uPlanetTexture', info.planet_texture)
	self.material.set_shader_parameter('uPlanetNoiseScale', info.raymarch_planet_noise)
	self.material.set_shader_parameter('uPlanetNoiseOffset', info.raymarch_planet_offset)
	self.material.set_shader_parameter('uScene', info.raymarch_scene)
	self.material.set_shader_parameter('uRingParams', info.raymarch_ring_params)
