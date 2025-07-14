extends Sprite2D

@export var noise_speed: float = 1.0
@export var noise_amp: float = 0.5
var noise_offset: float = 0.0

func _init() -> void:
	noise_offset = randf() * 10.0

func _process(delta: float) -> void:
	var t = (Time.get_ticks_msec() / 1000.0) * self.noise_speed
	var noise = sin(2 * (t + self.noise_offset)) + sin(PI * t + self.noise_offset)
	var norm_noise = (noise + 2.0) / 4.0
	var alpha = 1 - norm_noise * self.noise_amp
	self.modulate.a = alpha
