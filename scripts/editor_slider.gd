extends Control

@export var slider: HSlider
@export var value: LineEdit
@export var label: Label
@export var is_int: bool
@export var parameter: Wireframe.SceneParameter

func _ready() -> void:
	self.slider.value_changed.connect(self._on_slider_changed)
	self.value.text_submitted.connect(self._on_text_submitted)
	self.label.text = Wireframe.SceneParameter.keys()[self.parameter]
	
	CelestialParent.instance.scene_change.connect(self._on_scene_change)

func _on_scene_change() -> void:
	var scene = CelestialParent.instance.current_scene
	if scene == null:
		self.slider.editable = false
		self.value.editable = false
	else:
		self.slider.editable = true
		self.value.editable = true
		var value = scene.get_info_parameter(self.parameter)
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

func _update_parameter(value: Variant) -> void:
	var scene = CelestialParent.instance.current_scene
	if scene != null:
		scene.set_info_parameter(self.parameter, value)
