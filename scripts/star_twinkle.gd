extends Node2D

@export var noise_speed: float = 1.0
@export var noise_amp: float = 0.5
@export var time_offset: float = 3.0
var noise_offset: float = 0.0
var parent: Node2D
var started_playing = false

var _animated: AnimatedSprite2D
var _starting_position: Vector2
var _following: Node2D
var _current_time = 0.0
var _audio_time_offset = 0.25

func _init() -> void:
	self.noise_offset = randf() * 10.0
	self._starting_position = self.position
	
	var s = self
	if s is AnimatedSprite2D:
		self._animated = s
		self._animated.frame = 0

func _ready() -> void:
	self.parent = self.get_parent()
	if self.parent is FollowRotation:
		self._following = self.parent.follow

func _process(delta: float) -> void:
	self._current_time += delta
	var t = self._current_time * self.noise_speed
	var noise = sin(2 * (t + self.noise_offset)) + sin(PI * t + self.noise_offset)
	var norm_noise = (noise + 2.0) / 4.0
	var alpha = 1 - norm_noise * self.noise_amp
	self.modulate.a = alpha
	var rotated_pos = self._following.get_global_transform().basis_xform(self._starting_position)
	self.position = rotated_pos
	
	if self.started_playing:
		var before = self._audio_time_offset
		self._audio_time_offset -= delta
		if before > 0 && self._audio_time_offset <= 0:
			AudioManager.instance.play_random_star()
	
	if self._animated != null and !self.started_playing:
		if self._current_time > self.time_offset:
			
			self._animated.play()
			self.started_playing = true
