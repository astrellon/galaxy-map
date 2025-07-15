extends ColorRect

@export var camera: Camera3D
@export var reveal: float = 0.0;

func _process(delta: float) -> void:
	var cameraTrans = self.camera.get_global_transform_interpolated()
	var basis = cameraTrans.basis
	
	self.material.set_shader_parameter('uCameraPosition', cameraTrans.origin)
	self.material.set_shader_parameter('uCameraMatrix', basis)
	
	var fov = self.camera.fov * 0.5
	self.material.set_shader_parameter('uCameraFov', fov)
	self.material.set_shader_parameter('uReveal', self.reveal)
	
