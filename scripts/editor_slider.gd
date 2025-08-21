extends Control

@export var slider: HSlider
@export var value: LineEdit
@export var label: Label
@export var is_int: bool
@export var parameter: Constants.Options

func _ready() -> void:
	self.slider.value_changed.connect(self._on_slider_changed)
	self.value.text_submitted.connect(self._on_text_submitted)
	self.label.text = Constants.Options.keys()[self.parameter]
	
	CelestialParent.instance.scene_change.connect(self._on_scene_change)
	
	if (self.parameter == Constants.Options.GALAXY_ROTATE or 
		self.parameter == Constants.Options.TRAFFIC or 
		self.parameter == Constants.Options.MUSIC or
		self.parameter == Constants.Options.SFX):
		self._on_scene_change()

func _on_scene_change() -> void:
	var value = self._get_parameter()
	if value == null:
		self.slider.editable = false
		self.value.editable = false
	else:
		self.slider.editable = true
		self.value.editable = true
		self.slider.value = value
		self._on_slider_changed(value)

func _on_text_submitted(new_text: String) -> void:
	if self.is_int:
		if new_text.is_valid_int():
			var value = int(new_text)
			self.slider.value = value
			self._update_parameter(value)
	else:
		if new_text.is_valid_float():
			var value = float(new_text)
			self.slider.value = value
			self._update_parameter(value)

func _on_slider_changed(value: float) -> void:
	if self.is_int:
		var as_int = int(value)
		self.value.text = str(as_int)
		self._update_parameter(as_int)
	else:
		self.value.text = str(value)
		self._update_parameter(value)

func _get_parameter() -> Variant:
	if self.parameter == Constants.Options.GALAXY_ROTATE:
		return Background.instance.rotate_speed 
	elif self.parameter == Constants.Options.TRAFFIC:
		return Interconnected.instance.num_traffic
	elif self.parameter == Constants.Options.MUSIC:
		return AudioManager.instance.music_volume
	elif self.parameter == Constants.Options.SFX:
		return AudioManager.instance.sfx_volume
	else:
		var scene = CelestialParent.instance.current_scene
		if scene != null:
			return scene.get_info_parameter(self.parameter)
	
	return null

func _update_parameter(value: Variant) -> void:
	if self.parameter == Constants.Options.GALAXY_ROTATE:
		Background.instance.rotate_speed = value
	elif self.parameter == Constants.Options.TRAFFIC:
		Interconnected.instance.num_traffic = int(value)
	elif self.parameter == Constants.Options.MUSIC:
		AudioManager.instance.music_volume = value
	elif self.parameter == Constants.Options.SFX:
		AudioManager.instance.sfx_volume = value
	else:
		var scene = CelestialParent.instance.current_scene
		if scene != null:
			scene.set_info_parameter(self.parameter, value)
