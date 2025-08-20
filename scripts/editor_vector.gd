extends Control

@export var x_slider: HSlider
@export var y_slider: HSlider
@export var z_slider: HSlider
@export var x_value: LineEdit
@export var y_value: LineEdit
@export var z_value: LineEdit
@export var label: Label
@export var parameter: Wireframe.SceneParameter

var _current: Vector3

func _ready() -> void:
	self.x_slider.value_changed.connect(self._on_x_slider_changed)
	self.y_slider.value_changed.connect(self._on_y_slider_changed)
	self.z_slider.value_changed.connect(self._on_z_slider_changed)
	self.x_value.text_submitted.connect(self._on_x_value_submitted)
	self.y_value.text_submitted.connect(self._on_y_value_submitted)
	self.z_value.text_submitted.connect(self._on_z_value_submitted)
	self.label.text = Wireframe.SceneParameter.keys()[self.parameter]
	
	CelestialParent.instance.scene_change.connect(self._on_scene_change)

func _on_scene_change() -> void:
	var scene = CelestialParent.instance.current_scene
	var editable = false
	if scene != null:
		editable = true
		self._current = scene.get_info_parameter(self.parameter)
		self.x_slider.value = self._current.x
		self.y_slider.value = self._current.y
		self.z_slider.value = self._current.z
		self.x_value.text = str(self._current.x)
		self.y_value.text = str(self._current.y)
		self.z_value.text = str(self._current.z)
	
	self.x_slider.editable = editable
	self.y_slider.editable = editable
	self.z_slider.editable = editable
	self.x_value.editable = editable
	self.y_value.editable = editable
	self.z_value.editable = editable

func _on_x_value_submitted(new_text: String) -> void:
	if new_text.is_valid_float():
		var x = float(new_text)
		self.x_slider.value = x
		self._current.x = x
		self._update_parameter(self._current)

func _on_y_value_submitted(new_text: String) -> void:
	if new_text.is_valid_float():
		var y = float(new_text)
		self.y_slider.value = y
		self._current.y = y
		self._update_parameter(self._current)

func _on_z_value_submitted(new_text: String) -> void:
	if new_text.is_valid_float():
		var z = float(new_text)
		self.z_slider.value = z
		self._current.z = z
		self._update_parameter(self._current)

func _on_x_slider_changed(value: float) -> void:
	self.x_value.text = str(value)
	self._current.x = value
	self._update_parameter(self._current)

func _on_y_slider_changed(value: float) -> void:
	self.y_value.text = str(value)
	self._current.y = value
	self._update_parameter(self._current)

func _on_z_slider_changed(value: float) -> void:
	self.z_value.text = str(value)
	self._current.z = value
	self._update_parameter(self._current)

func _update_parameter(value: Variant) -> void:
	var scene = CelestialParent.instance.current_scene
	if scene != null:
		scene.set_info_parameter(self.parameter, value)
