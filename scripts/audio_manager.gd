extends Node2D

class_name AudioManager

static var instance: AudioManager

@export var background: AudioStreamPlayer2D
@export var sample_players: Array[AudioStreamPlayer2D]
@export var hover_effects: Array[AudioStream]
@export var click_effects: Array[AudioStream]
@export var text_effects: Array[AudioStream]
@export var star_effects: Array[AudioStream]

@export var music_volume = 1.0
@export var sfx_volume = 1.0

var _play_background_timer = 1.0

func _init() -> void:
	instance = self

func _process(delta: float) -> void:
	var before = self._play_background_timer
	self._play_background_timer -= delta
	if self._play_background_timer <= 0.0 and before > 0.0:
		self.background.play()
	
	self.background.stream_paused = self.music_volume < 0.01
	self.background.volume_db = (1.0 - self.music_volume) * -40

func play_random_hover() -> void:
	self.play_random_audio(self.hover_effects, 0)
	
func play_random_click() -> void:
	self.play_random_audio(self.click_effects, 0)

func play_random_text() -> void:
	self.play_random_audio(self.text_effects, 0)

func play_random_star() -> void:
	self.play_random_audio(self.star_effects, -10)

func play_random_audio(list: Array[AudioStream], volume_db: float) -> void:
	if self.sfx_volume < 0.01:
		return
	
	var index = randi_range(0, list.size() - 1)
	var stream = list[index]
	
	var player = self._get_available_player()
	player.stop()
	player.volume_db = volume_db - (1.0 - self.sfx_volume) * 30
	player.stream = stream
	player.play()

func _get_available_player() -> AudioStreamPlayer2D:
	for player in self.sample_players:
		if !player.playing:
			return player
	
	var index = randi_range(0, self.sample_players.size() - 1)
	return self.sample_players[index]
